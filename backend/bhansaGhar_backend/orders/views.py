from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from django.utils import timezone
from .serializers import (
    OrderKitchenSerializer, BargainSerializer, TableStatusSerializer, WaiterOrderSerializer,
    TableOrderSerializer, BargainRequestSerializer, CustomerBargainResponseSerializer, EmptySerializer
)
from .models import Order, OrderBargain, OrderServeLog
from websocket.services import (
    broadcast_order_update, broadcast_kitchen_ping, 
    broadcast_table_update, broadcast_bargain, broadcast_bargain_resolution
)
from drf_spectacular.utils import extend_schema, OpenApiParameter, OpenApiTypes
from restaurants.models import Table
from .permissions import KitchenPermission, WaiterPermission
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync

# Broadcasting functions are now imported from websocket.services

# --- Kitchen APIs ---

@extend_schema(tags=['Kitchen: Orders'], responses={200: OrderKitchenSerializer(many=True)})
@api_view(['GET'])
@permission_classes([KitchenPermission])
def kitchen_live_orders(request):
    # Depending on how restaurant is associated (user.restaurant or user.owned_restaurant)
    # The models show user.restaurant for staff.
    restaurant = getattr(request.user, 'restaurant', None)
    if not restaurant and hasattr(request.user, 'owned_restaurant'):
         restaurant = request.user.owned_restaurant
         
    if not restaurant:
        return Response({'error': 'No restaurant associated'}, status=400)

    orders = Order.objects.filter(
        restaurant=restaurant,
        status__in=['pending', 'preparing', 'bargain']
    ).prefetch_related('bargains').order_by('-created_at')
    return Response(OrderKitchenSerializer(orders, many=True).data)

@extend_schema(tags=['Kitchen: Orders'], request=EmptySerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['PATCH'])
@permission_classes([KitchenPermission])
def start_order_prep(request, order_id):
    restaurant = getattr(request.user, 'restaurant', None) or getattr(request.user, 'owned_restaurant', None)
    try:
        order = Order.objects.get(id=order_id, restaurant=restaurant)
    except Order.DoesNotExist:
        return Response({'error': 'Order not found'}, status=404)
        
    order.status = 'preparing'
    order.save()
    broadcast_order_update(order.restaurant.id, order.id)
    return Response({'status': 'preparing'})

@extend_schema(tags=['Kitchen: Orders'], request=BargainRequestSerializer, responses={201: BargainSerializer})
@api_view(['POST'])
@permission_classes([KitchenPermission])
def kitchen_bargain(request, order_id):
    restaurant = getattr(request.user, 'restaurant', None) or getattr(request.user, 'owned_restaurant', None)
    try:
        order = Order.objects.get(id=order_id, restaurant=restaurant)
    except Order.DoesNotExist:
        return Response({'error': 'Order not found'}, status=404)

    bargain = OrderBargain.objects.create(
        order=order,
        item_id=request.data['item_id'],
        customer_qty=request.data['customer_qty'],
        kitchen_qty=request.data['kitchen_qty'],
        kitchen_message=request.data['message']
    )
    order.status = 'bargain'
    order.save()
    broadcast_bargain(order.restaurant.id, bargain.id)
    return Response(BargainSerializer(bargain).data)

@extend_schema(tags=['Kitchen: Orders'], request=EmptySerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['PATCH'])
@permission_classes([KitchenPermission])
def mark_order_ready(request, order_id):
    restaurant = getattr(request.user, 'restaurant', None) or getattr(request.user, 'owned_restaurant', None)
    try:
        order = Order.objects.get(id=order_id, restaurant=restaurant)
    except Order.DoesNotExist:
        return Response({'error': 'Order not found'}, status=404)

    order.status = 'ready'
    order.save()
    broadcast_order_update(order.restaurant.id, order.id)
    return Response({'status': 'ready'})

# --- Waiter APIs ---

# Table Management is in restaurants/views.py

@extend_schema(tags=['Waiter: Orders'], responses={200: WaiterOrderSerializer(many=True)})
@api_view(['GET'])
@permission_classes([WaiterPermission])
def waiter_ready_orders(request):
    """GET /api/waiter/ready-orders/ → Pickup list"""
    restaurant = getattr(request.user, 'restaurant', None) or getattr(request.user, 'owned_restaurant', None)
    orders = Order.objects.filter(
        restaurant=restaurant,
        status='ready'
    ).order_by('table_number')
    
    # Pre-fetch table statuses to avoid N+1 in serializer
    tables = Table.objects.filter(restaurant=restaurant).values('number', 'status')
    table_status_map = {t['number']: t['status'] for t in tables}
    
    return Response(WaiterOrderSerializer(orders, many=True, context={'table_status_map': table_status_map}).data)

@extend_schema(tags=['Waiter: Orders'], responses={200: TableOrderSerializer(many=True)})
@api_view(['GET'])
@permission_classes([WaiterPermission])
def table_orders(request, table_number):
    """GET /api/waiter/table/<number>/orders/ → Table orders"""
    restaurant = getattr(request.user, 'restaurant', None) or getattr(request.user, 'owned_restaurant', None)
    orders = Order.objects.filter(
        restaurant=restaurant,
        table_number=table_number,
        status__in=['ready', 'serving']
    )
    return Response(TableOrderSerializer(orders, many=True).data)

@extend_schema(tags=['Waiter: Orders'], request=EmptySerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['PATCH'])
@permission_classes([WaiterPermission])
def pickup_order(request, order_id):
    """PATCH /api/waiter/orders/<id>/pickup/ → Start serving"""
    restaurant = getattr(request.user, 'restaurant', None) or getattr(request.user, 'owned_restaurant', None)
    try:
        order = Order.objects.get(id=order_id, restaurant=restaurant)
    except Order.DoesNotExist:
        return Response({'error': 'Order not found'}, status=404)
        
    order.status = 'serving'
    order.save()
    
    # Update table status
    try:
        table = Table.objects.get(restaurant=restaurant, number=order.table_number)
        table.status = 'serving'
        table.save()
        broadcast_table_update(restaurant.id, table.number, table.status)
    except Table.DoesNotExist:
        pass
        
    broadcast_order_update(restaurant.id, order.id, 'serving')
    return Response({'status': 'serving'})

@extend_schema(tags=['Waiter: Orders'], request=EmptySerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['PATCH'])
@permission_classes([WaiterPermission])
def mark_order_served(request, order_id):
    """PATCH /api/waiter/orders/<id>/served/ → Complete"""
    restaurant = getattr(request.user, 'restaurant', None) or getattr(request.user, 'owned_restaurant', None)
    try:
        order = Order.objects.get(id=order_id, restaurant=restaurant)
    except Order.DoesNotExist:
        return Response({'error': 'Order not found'}, status=404)
        
    # Create serve log
    table_status = "unknown"
    try:
        table = Table.objects.get(restaurant=restaurant, number=order.table_number)
        table_status = table.status
    except Table.DoesNotExist:
        pass

    OrderServeLog.objects.create(
        order=order,
        table_status_before=table_status,
        served_items=request.data.get('served_items', {}),
        waiter_notes=request.data.get('notes', '')
    )
    
    order.status = 'served'
    order.save()
    
    # Update table status to dirty (needs cleanup)
    if table_status != "unknown":
        table.status = 'dirty'
        table.last_served = timezone.now()
        table.save()
        broadcast_table_update(restaurant.id, table.number, table.status)
    
    broadcast_order_update(restaurant.id, order.id, 'served')
    return Response({'status': 'served'})

@extend_schema(tags=['Waiter: Orders'], request=EmptySerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['POST'])
@permission_classes([WaiterPermission])
def ping_kitchen(request, order_id):
    """POST /api/waiter/kitchen-ping/<order_id>/ → Notify kitchen delay"""
    restaurant = getattr(request.user, 'restaurant', None) or getattr(request.user, 'owned_restaurant', None)
    try:
        order = Order.objects.get(id=order_id, restaurant=restaurant)
        message = request.data.get('message', 'Delay - table waiting')
        broadcast_kitchen_ping(restaurant.id, order.id, message)
        return Response({'success': True})
    except Order.DoesNotExist:
        return Response({'error': 'Order not found'}, status=404)

# --- Customer APIs ---

@extend_schema(tags=['Customer: Ordering'], request=CustomerBargainResponseSerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['PATCH'])
@permission_classes([AllowAny])
def customer_bargain_response(request, bargain_id):
    try:
        bargain = OrderBargain.objects.get(id=bargain_id)
    except OrderBargain.DoesNotExist:
         return Response({'error': 'Bargain not found'}, status=404)
         
    if bargain.order.session_id != request.data.get('session_id'):
        return Response({'error': 'Unauthorized'}, status=403)
    
    bargain.status = request.data['status']  # accepted/rejected
    bargain.customer_response = request.data.get('response', '')
    bargain.resolved_at = timezone.now()
    bargain.save()
    
    bargain.order.status = 'preparing' if bargain.status == 'accepted' else 'cancelled'
    bargain.order.save()
    
    broadcast_bargain_resolution(bargain.order.restaurant.id, bargain.id)
    return Response({'success': True})


# --- Enhanced Order Management APIs (Auto-assign, Admin Master Role, Bargain Chat) ---

@extend_schema(tags=['Orders: Auto-Assignment'], responses={200: EmptySerializer})
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def auto_assign_waiter(request, order_id):
    """Auto-assign a free waiter to an order. If none available, assign to admin."""
    from .services import OrderAssignmentService, AdminMasterRoleService
    
    restaurant = getattr(request.user, 'restaurant', None) or getattr(request.user, 'owned_restaurant', None)
    
    try:
        order = Order.objects.get(id=order_id, restaurant=restaurant)
    except Order.DoesNotExist:
        return Response({'error': 'Order not found'}, status=404)
    
    service = OrderAssignmentService()
    
    # Try to auto-assign a waiter
    waiter = service.auto_assign_waiter(order)
    
    if not waiter:
        # No waiter available, check if we should use admin fallback
        if request.data.get('force_admin', False) or True:  # Default to admin fallback
            admin_service = AdminMasterRoleService()
            if admin_service.admin_auto_manage_order(request.user, order):
                service.create_order_timeline(
                    order, order.status, 'admin_fallback',
                    request.user, 'No waiters available, admin assigned'
                )
                return Response({
                    'success': True,
                    'message': 'Order assigned to admin (no staff available)',
                    'assigned_to': 'admin'
                })
        return Response({'error': 'No waiters available and admin fallback disabled'}, status=400)
    
    # Waiter found
    order.assigned_waiter = waiter
    order.save()
    
    service.create_order_timeline(
        order, order.status, order.status,
        request.user, f'Waiter {waiter.get_full_name()} assigned (auto)'
    )
    
    broadcast_order_update(order.restaurant.id, order_id)
    
    return Response({
        'success': True,
        'message': f'Order assigned to {waiter.get_full_name()}',
        'waiter_id': waiter.id,
        'waiter_name': waiter.get_full_name()
    })


@extend_schema(tags=['Orders: Waiter'], responses={200: EmptySerializer})
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def waiter_heartbeat(request):
    """Update waiter availability and heartbeat"""
    from .models import WaiterSession
    
    if request.user.role != 'waiter':
        return Response({'error': 'Only waiters can send heartbeat'}, status=403)
    
    restaurant = getattr(request.user, 'restaurant', None)
    if not restaurant:
        return Response({'error': 'Waiter not assigned to restaurant'}, status=400)
    
    session, created = WaiterSession.objects.get_or_create(
        user=request.user,
        restaurant=restaurant
    )
    
    # Update status
    session.status = request.data.get('status', 'idle')  # idle/busy/on_break/offline
    session.last_heartbeat = timezone.now()
    session.save()
    
    # Broadcast waiter availability update
    async_to_sync(get_channel_layer().group_send)(
        f'restaurant_{restaurant.id}_staff',
        {
            'type': 'waiter_status_update',
            'waiter_id': request.user.id,
            'status': session.status
        }
    )
    
    return Response({'success': True, 'status': session.status})


@extend_schema(tags=['Orders: Waiter'], responses={200: EmptySerializer})
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def waiter_assigned_orders(request):
    """Get all orders assigned to waiter"""
    from .serializers import EnhancedOrderSerializer
    
    if request.user.role != 'waiter':
        return Response({'error': 'Only waiters can access this'}, status=403)
    
    orders = Order.objects.filter(
        assigned_waiter=request.user,
        status__in=['pending', 'preparing', 'ready', 'serving']
    ).prefetch_related(
        'assigned_kitchen_staff',
        'bargains',
        'assignments',
        'timeline'
    )
    
    return Response(EnhancedOrderSerializer(orders, many=True).data)


@extend_schema(tags=['Orders: Bargain Chat'], responses={200: EmptySerializer})
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def send_bargain_message(request, bargain_id):
    """Send a message in bargain chat"""
    from .models import BargainMessage
    from .serializers import BargainMessageSerializer
    from .services import BargainChatService
    
    try:
        bargain = OrderBargain.objects.get(id=bargain_id)
    except OrderBargain.DoesNotExist:
        return Response({'error': 'Bargain not found'}, status=404)
    
    # Check permissions
    order = bargain.order
    restaurant = order.restaurant
    
    is_admin = restaurant.owner_id == request.user.id
    is_kitchen = request.user in order.assigned_kitchen_staff.all()
    is_waiter = order.assigned_waiter_id == request.user.id
    
    if not (is_admin or is_kitchen or is_waiter):
        return Response({'error': 'Unauthorized'}, status=403)
    
    # Determine sender type
    sender_type = 'admin' if is_admin else ('kitchen' if is_kitchen else 'waiter')
    
    service = BargainChatService()
    message = service.add_message(
        bargain=bargain,
        sender_type=sender_type,
        sender=request.user,
        message_text=request.data.get('message', '')
    )
    
    # Broadcast message to relevant parties
    async_to_sync(get_channel_layer().group_send)(
        f'bargain_{bargain.id}',
        {
            'type': 'bargain_message',
            'message': BargainMessageSerializer(message).data
        }
    )
    
    return Response(BargainMessageSerializer(message).data, status=201)


@extend_schema(tags=['Orders: Bargain Chat'], responses={200: EmptySerializer})
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_bargain_messages(request, bargain_id):
    """Get all messages in bargain chat"""
    from .serializers import BargainMessageSerializer
    
    try:
        bargain = OrderBargain.objects.get(id=bargain_id)
    except OrderBargain.DoesNotExist:
        return Response({'error': 'Bargain not found'}, status=404)
    
    # Check permissions
    order = bargain.order
    restaurant = order.restaurant
    
    is_admin = restaurant.owner_id == request.user.id
    is_kitchen = request.user.role == 'kitchen' and request.user in order.assigned_kitchen_staff.all()
    is_waiter = order.assigned_waiter_id == request.user.id
    
    if not (is_admin or is_kitchen or is_waiter):
        return Response({'error': 'Unauthorized'}, status=403)
    
    messages = bargain.messages.all().order_by('created_at')
    return Response(BargainMessageSerializer(messages, many=True).data)


@extend_schema(tags=['Orders: Bargain Chat'], responses={200: EmptySerializer})
@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def accept_bargain_offer(request, bargain_id):
    """Accept bargain offer (kitchen/admin decides on quantity)"""
    from .services import BargainChatService
    from .serializers import EnhancedBargainSerializer
    
    try:
        bargain = OrderBargain.objects.get(id=bargain_id)
    except OrderBargain.DoesNotExist:
        return Response({'error': 'Bargain not found'}, status=404)
    
    # Only kitchen or admin can accept
    order = bargain.order
    restaurant = order.restaurant
    
    is_admin = restaurant.owner_id == request.user.id
    is_kitchen = request.user.role == 'kitchen' and request.user in order.assigned_kitchen_staff.all()
    
    if not (is_admin or is_kitchen):
        return Response({'error': 'Only kitchen or admin can accept bargains'}, status=403)
    
    service = BargainChatService()
    success = service.accept_bargain(bargain)
    
    if success:
        # Broadcast bargain resolution
        broadcast_bargain_resolution(restaurant.id, bargain_id)
        return Response(EnhancedBargainSerializer(bargain).data)
    
    return Response({'error': 'Could not accept bargain'}, status=400)


@extend_schema(tags=['Orders: Bargain Chat'], responses={200: EmptySerializer})
@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def reject_bargain_offer(request, bargain_id):
    """Reject bargain offer"""
    from .services import BargainChatService
    from .serializers import EnhancedBargainSerializer
    
    try:
        bargain = OrderBargain.objects.get(id=bargain_id)
    except OrderBargain.DoesNotExist:
        return Response({'error': 'Bargain not found'}, status=404)
    
    # Only kitchen or admin can reject
    order = bargain.order
    restaurant = order.restaurant
    
    is_admin = restaurant.owner_id == request.user.id
    is_kitchen = request.user.role == 'kitchen' and request.user in order.assigned_kitchen_staff.all()
    
    if not (is_admin or is_kitchen):
        return Response({'error': 'Only kitchen or admin can reject bargains'}, status=403)
    
    service = BargainChatService()
    success = service.reject_bargain(bargain)
    
    if success:
        # Broadcast rejection
        async_to_sync(get_channel_layer().group_send)(
            f'bargain_{bargain_id}',
            {
                'type': 'bargain_rejected',
                'bargain_id': str(bargain_id)
            }
        )
        return Response(EnhancedBargainSerializer(bargain).data)
    
    return Response({'error': 'Could not reject bargain'}, status=400)


@extend_schema(tags=['Orders: Admin Master Role'], responses={200: EmptySerializer})
@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def admin_reassign_staff(request, order_id):
    """Admin manually reassign waiters and kitchen staff"""
    from .services import AdminMasterRoleService
    from .serializers import EnhancedOrderSerializer
    
    restaurant = getattr(request.user, 'owned_restaurant', None)
    if not restaurant or restaurant.owner_id != request.user.id:
        return Response({'error': 'Only restaurant admin can reassign staff'}, status=403)
    
    try:
        order = Order.objects.get(id=order_id, restaurant=restaurant)
    except Order.DoesNotExist:
        return Response({'error': 'Order not found'}, status=404)
    
    service = AdminMasterRoleService()
    success = service.admin_reassign_staff(
        admin=request.user,
        order=order,
        new_waiter_id=request.data.get('new_waiter_id'),
        remove_kitchen_staff_ids=request.data.get('remove_kitchen_staff', []),
        add_kitchen_staff_ids=request.data.get('add_kitchen_staff', []),
        reason=request.data.get('reason', 'Admin reassignment')
    )
    
    if success:
        broadcast_order_update(restaurant.id, order_id)
        return Response(EnhancedOrderSerializer(order).data)
    
    return Response({'error': 'Could not reassign staff'}, status=400)


@extend_schema(tags=['Orders: Admin Master Role'], responses={200: EmptySerializer})
@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def admin_takeover_order(request, order_id):
    """Admin takes over order as both waiter and kitchen"""
    from .services import AdminMasterRoleService
    from .serializers import EnhancedOrderSerializer
    
    restaurant = getattr(request.user, 'owned_restaurant', None)
    if not restaurant or restaurant.owner_id != request.user.id:
        return Response({'error': 'Only restaurant admin can takeover orders'}, status=403)
    
    try:
        order = Order.objects.get(id=order_id, restaurant=restaurant)
    except Order.DoesNotExist:
        return Response({'error': 'Order not found'}, status=404)
    
    service = AdminMasterRoleService()
    success = service.admin_auto_manage_order(request.user, order)
    
    if success:
        from .services import OrderAssignmentService
        assign_service = OrderAssignmentService()
        assign_service.create_order_timeline(
            order, order.status, order.status,
            request.user, 'Admin took over order management'
        )
        broadcast_order_update(restaurant.id, order_id)
        return Response(EnhancedOrderSerializer(order).data)
    
    return Response({'error': 'Could not takeover order'}, status=400)


@extend_schema(tags=['Orders: Admin Master Role'], responses={200: EmptySerializer})
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def admin_staff_status(request):
    """Get all staff availability for restaurant"""
    from .models import WaiterSession
    from .serializers import WaiterSessionSerializer
    from core.models import User
    
    restaurant = getattr(request.user, 'owned_restaurant', None)
    if not restaurant or restaurant.owner_id != request.user.id:
        return Response({'error': 'Only restaurant admin can access this'}, status=403)
    
    # Get all active staff
    staff = User.objects.filter(restaurant=restaurant, role__in=['waiter', 'kitchen'])
    
    data = {
        'staff': [],
        'waiter_sessions': [],
        'kitchen_availability': []
    }
    
    # Get waiter sessions
    waiter_sessions = WaiterSession.objects.filter(restaurant=restaurant).select_related('user')
    data['waiter_sessions'] = WaiterSessionSerializer(waiter_sessions, many=True).data
    
    return Response(data)
