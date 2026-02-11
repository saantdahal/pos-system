from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework_simplejwt.tokens import RefreshToken
from .models import Restaurant, RestaurantType, Category, MenuItem, Table, StaffInvite
from .serializers import (
    RestaurantSerializer, RestaurantUpdateSerializer, RestaurantTypeSerializer, RestaurantCreateRequestSerializer,
    CategorySerializer, MenuItemSerializer, TableSerializer, TableListSerializer,
    QRCodeScanSerializer, TableDetailWithMenuSerializer,
    StaffInviteCreateSerializer, StaffInviteSerializer, ClaimInviteSerializer, StaffUserSerializer,
    UpdateStockSerializer, BulkTableCreateSerializer, UpdateTableStatusSerializer, ToggleStaffStatusSerializer
)
from orders.serializers import TableStatusSerializer
from orders.permissions import WaiterPermission
from core.models import User
from drf_spectacular.utils import extend_schema, OpenApiTypes, inline_serializer, OpenApiParameter
from rest_framework import serializers
from typing import cast, Any, Dict, Optional, TYPE_CHECKING
from django.utils import timezone
from drf_spectacular.utils import extend_schema, OpenApiParameter, OpenApiTypes

if TYPE_CHECKING:
    from django.contrib.auth.models import AnonymousUser

class IsOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.owner == request.user

@extend_schema(tags=['Admin: Restaurant'])
class RestaurantTypeViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = RestaurantType.objects.filter(is_active=True)
    
    serializer_class = RestaurantTypeSerializer
    permission_classes = [permissions.AllowAny]

@extend_schema(tags=['Admin: Restaurant'], parameters=[OpenApiParameter("id", OpenApiTypes.UUID, OpenApiParameter.PATH)])
class RestaurantViewSet(viewsets.ModelViewSet):
    serializer_class = RestaurantSerializer
    permission_classes = [permissions.IsAuthenticated, IsOwner]

    def get_queryset(self): # type: ignore
        return Restaurant.objects.filter(owner=self.request.user)
    
    def list(self, request, *args, **kwargs):
        """Override list to add logging"""
        print(f"\n{'='*80}")
        print(f"🏪 RESTAURANT LIST REQUEST")
        print(f"📧 User: {request.user.email}")
        queryset = self.get_queryset()
        print(f"📊 Queryset count: {queryset.count()}")
        for restaurant in queryset:
            print(f"  - Restaurant: {restaurant.name} (ID: {restaurant.id})")
        print(f"{'='*80}\n")
        
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)

    def perform_create(self, serializer):
        user = self.request.user
        # Delete existing restaurant for the user if any
        Restaurant.objects.filter(owner=user).delete()
        serializer.save(owner=user)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response({'success': True, 'restaurant': serializer.data}, status=status.HTTP_201_CREATED, headers=headers)

class IsRestaurantOwner(permissions.BasePermission):
    def has_permission(self, request, view):
        # Check if user has a restaurant
        if not request.user.is_authenticated:
            return False
        owned_restaurant = request.user.get_owned_restaurant()
        return owned_restaurant is not None

    def has_object_permission(self, request, view, obj):
        # Check if the category belongs to the user's restaurant
        return obj.restaurant.owner == request.user

class IsRestaurantOwnerOrStaff(permissions.BasePermission):
    def has_permission(self, request, view):
        if not request.user.is_authenticated:
            return False
        # Allow if user has a restaurant (owner) or assigned restaurant (staff)
        owned_rest = request.user.get_owned_restaurant()
        assigned_rest = request.user.restaurant
        
        # For development/testing: Allow authenticated users to view/list if no restaurant exists
        # They just won't see any items (get_queryset will return empty)
        if request.method in ['GET', 'HEAD', 'OPTIONS']:
            return True
        
        # For write operations (POST, PUT, DELETE), require restaurant ownership
        return owned_rest is not None or assigned_rest is not None

    def has_object_permission(self, request, view, obj):
        # Allow if object's restaurant matches user's (owned or assigned) restaurant
        user_restaurant = request.user.get_owned_restaurant() or request.user.restaurant
        return obj.restaurant == user_restaurant

@extend_schema(tags=['Admin: Menu'], parameters=[OpenApiParameter("id", OpenApiTypes.UUID, OpenApiParameter.PATH)])
class CategoryViewSet(viewsets.ModelViewSet):
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticated, IsRestaurantOwnerOrStaff]

    def get_queryset(self):
        # Return categories for the user's restaurant only
        user = self.request.user
        restaurant = user.get_owned_restaurant() or user.restaurant
        
        if restaurant:
            categories = Category.objects.filter(restaurant=restaurant)
            print(f"📂 Fetching categories for restaurant: {restaurant.name}, Found: {categories.count()} categories")
            return categories
            
        print(f"⚠️ User {user.email} has no restaurant")
        return Category.objects.none()

    def perform_create(self, serializer):
        # Automatically set the restaurant to the user's restaurant
        owned_restaurant = self.request.user.get_owned_restaurant()
        if owned_restaurant:
            # Auto-assign the next position
            next_position = Category.objects.filter(restaurant=owned_restaurant).count() + 1
            print(f"✨ Creating category: {serializer.validated_data.get('name')} for restaurant: {owned_restaurant.name}, Position: {next_position}")
            serializer.save(restaurant=owned_restaurant, position=next_position)
            print(f"✅ Category created successfully: ID={serializer.instance.id}, Name={serializer.instance.name}")
        else:
            print(f"❌ Cannot create category - User {self.request.user.email} has no restaurant")
            raise ValueError("User does not have an associated restaurant")

@extend_schema(tags=['Admin: Menu'], parameters=[OpenApiParameter("id", OpenApiTypes.UUID, OpenApiParameter.PATH)])
class MenuItemViewSet(viewsets.ModelViewSet):
    serializer_class = MenuItemSerializer
    # Allow owners full access, staff read access + specific actions
    permission_classes = [permissions.IsAuthenticated, IsRestaurantOwnerOrStaff]

    def get_queryset(self):
        user = self.request.user
        restaurant = user.get_owned_restaurant() or user.restaurant
        
        if restaurant:
            items = MenuItem.objects.filter(restaurant=restaurant)
            print(f"📋 Fetching menu items for restaurant: {restaurant.name}, Found: {items.count()} items")
            return items
            
        print(f"⚠️ User {user.email} has no associated restaurant")
        return MenuItem.objects.none()

    def perform_create(self, serializer):
        # Only owners can create items (enforce via permission or check here)
        owned_restaurant = self.request.user.get_owned_restaurant()
        if owned_restaurant:
            print(f"\n{'='*80}")
            print(f"✨ [perform_create] Creating menu item: {serializer.validated_data.get('name')} for restaurant: {owned_restaurant.name}")
            # ... (rest of debug logs) ...
            serializer.save(restaurant=owned_restaurant)
            # ...
            print(f"{'='*80}\n")
        else:
            raise permissions.PermissionDenied("Only restaurant owners can create menu items")

    def perform_update(self, serializer):
        # Only owners can update details (name, price etc), staff can only update stock via specific endpoint
        # But standard update might be blocked for staff if strictly enforced. 
        # For now, let's allow owners everything. Staff validation logic inside permission or serializer if needed.
        # Ideally: Split permissions. keeping it simple: Owner check.
        if self.request.user.get_owned_restaurant():
             # ... (existing logging) ...
             serializer.save()
        else:
             raise permissions.PermissionDenied("Only restaurant owners can edit menu details")

    def perform_destroy(self, instance):
        if self.request.user.get_owned_restaurant():
             item_id = instance.id
             item_name = instance.name
             print(f"🗑️  Deleting menu item: ID={item_id}, Name: {item_name}")
             instance.delete()
             print(f"✅ Menu item deleted successfully")
        else:
             raise permissions.PermissionDenied("Only restaurant owners can delete menu items")

    @extend_schema(request=UpdateStockSerializer, responses={200: OpenApiTypes.OBJECT})
    @action(detail=True, methods=['patch'], url_path='update-stock')
    def update_stock(self, request, pk=None):
        """
        Allow kitchen staff (and owners) to update stock quantity.
        Body: { "stock_quantity": 10 } or { "stock_quantity": null } for unlimited.
        """
        item = self.get_object()
        stock_qty = request.data.get('stock_quantity')
        
        # Simple validation: ensure it's int or None
        if stock_qty == 'null' or stock_qty is None:
            item.stock_quantity = None
        else:
            try:
                item.stock_quantity = int(stock_qty)
            except (ValueError, TypeError):
                return Response({'error': 'Invalid stock quantity'}, status=status.HTTP_400_BAD_REQUEST)
        
        item.save(update_fields=['stock_quantity'])
        return Response({
            'success': True, 
            'message': 'Stock updated',
            'item': MenuItemSerializer(item, context={'request': request}).data
        })

@extend_schema(tags=['Admin: Restaurant'], request=RestaurantCreateRequestSerializer, responses={201: OpenApiTypes.OBJECT})
@api_view(['POST'])
@permission_classes([permissions.AllowAny])
def create_restaurant(request: Any) -> Response:
    """Step 5: Create restaurant (Online users only)"""
    print(f"🔍 Create restaurant called")
    print(f"📨 Request data: {request.data}")
    
    serializer = RestaurantCreateRequestSerializer(data=request.data)
    if not serializer.is_valid():
        print(f"❌ Serializer errors: {serializer.errors}")
        return Response(serializer.errors, status=400)
    
    validated_data: Dict[str, Any] = cast(Dict[str, Any], serializer.validated_data)
    email: str = validated_data['email']
    
    try:
        user = User.objects.get(
            email=email,
            is_email_verified=True,
            profile_completed=True,
            mode_selection_completed=True
        )
    except User.DoesNotExist:
        return Response({
            'error': 'User not found or registration not complete. Please complete profile and select mode first.'
        }, status=404)
    
    # **Check if user selected online mode**
    if user.selected_mode != 'online':
        return Response({
            'error': f'Restaurant creation is only for online users. Your mode is: {user.selected_mode}'
        }, status=400)
    
    # **Check if user already has a restaurant**
    owned_restaurant = user.get_owned_restaurant()
    if owned_restaurant is not None:
        print("⚠️ Restaurant already exists for this user")
        return Response({
            'message': 'Restaurant already created for this user.',
            'restaurant': RestaurantSerializer(owned_restaurant).data,
            'registration_completed': True,
            'next_step': 'dashboard'
        }, status=200)
    
    try:
        # Create restaurant
        restaurant = Restaurant.objects.create(
            owner=user,
            name=validated_data['name'],
            type=validated_data['type'],
            address=validated_data.get('address', user.address or ''),
            latitude=validated_data.get('latitude', user.latitude),
            longitude=validated_data.get('longitude', user.longitude),
            phone=validated_data.get('phone', user.phone or ''),
            description=validated_data.get('description', ''),
            tables_capacity=validated_data.get('tables_capacity', 0),
            operating_hours=validated_data.get('operating_hours'),
            is_active=True
        )
        
        # Auto-generate tables with QR codes based on tables_capacity
        tables_count = validated_data.get('tables_capacity', 0)
        created_tables = []
        if tables_count > 0:
            for table_number in range(1, tables_count + 1):
                table = Table.objects.create(
                    restaurant=restaurant,
                    table_number=table_number
                )
                created_tables.append(table)
                print(f"✅ Table {table_number} created with QR code for restaurant {restaurant.name}")
        
        # Update user registration status
        # Note: owned_restaurant is reverse relation from Restaurant.owner, no direct assignment needed
        user.registration_completed = True
        user.save()
        
        print(f"✅ Restaurant created successfully for user {user.email} with {len(created_tables)} tables")
        
        # Serialize created tables with QR codes
        tables_data = [TableSerializer(table).data for table in created_tables] if created_tables else []
        
        return Response({
            'success': True,
            'message': f'Restaurant created successfully with {len(created_tables)} tables! Your registration is complete.',
            'restaurant': RestaurantSerializer(restaurant).data,
            'created_tables': tables_data,
            'tables_count': len(created_tables),
            'registration_completed': True,
            'next_step': 'dashboard',
            'user_status': {
                'is_google_verified': user.is_google_verified,
                'is_email_verified': user.is_email_verified,
                'profile_completed': user.profile_completed,
                'selected_mode': user.selected_mode,
                'mode_selection_completed': user.mode_selection_completed,
                'registration_completed': user.registration_completed,
                'restaurant_created': user.get_owned_restaurant() is not None,
            }
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        print(f"❌ Error creating restaurant: {str(e)}")
        return Response({
            'error': f'Failed to create restaurant: {str(e)}'
        }, status=500)


@extend_schema(tags=['Admin: Restaurant'], responses={200: RestaurantSerializer})
@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def get_restaurant(request: Any) -> Response:
    """
    Get restaurant details for the authenticated admin user.
    GET /api/restaurants/my-restaurant/
    """
    user = cast(User, request.user)
    restaurant = user.get_owned_restaurant()
    
    print(f"\n{'='*80}")
    print(f"🏪 GET MY RESTAURANT REQUEST")
    print(f"📧 User: {user.email}")
    print(f"🏢 Restaurant: {restaurant.name if restaurant else 'None'}")
    print(f"{'='*80}\n")
    
    if not restaurant:
        return Response({
            'error': 'You do not own a restaurant.'
        }, status=status.HTTP_404_NOT_FOUND)
    
    serializer = RestaurantSerializer(restaurant)
    print(f"✅ Restaurant data: {serializer.data}")
    return Response(serializer.data)


@extend_schema(tags=['Admin: Restaurant'], request=RestaurantUpdateSerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['PATCH'])
@permission_classes([permissions.IsAuthenticated])
def update_restaurant(request: Any) -> Response:
    """
    Update restaurant details for the authenticated admin user.
    PATCH /api/restaurants/update/
    Body: {name, type, address, latitude, longitude, phone, description, operating_hours}
    """
    user = cast(User, request.user)
    restaurant = user.get_owned_restaurant()
    
    print(f"\n{'='*80}")
    print(f"🏪 RESTAURANT UPDATE REQUEST")
    print(f"📧 User: {user.email}")
    print(f"🏢 Restaurant: {restaurant.name if restaurant else 'None'}")
    print(f"📨 Request data: {request.data}")
    print(f"{'='*80}\n")
    
    if not restaurant:
        return Response({
            'error': 'You do not own a restaurant. Only restaurant owners can update details.'
        }, status=status.HTTP_403_FORBIDDEN)
    
    if user.role != 'admin':
        return Response({
            'error': 'Only admins can update restaurant details.'
        }, status=status.HTTP_403_FORBIDDEN)
    
    serializer = RestaurantUpdateSerializer(restaurant, data=request.data, partial=True)
    
    if serializer.is_valid():
        print(f"✅ Serializer is valid")
        print(f"📝 Validated data: {serializer.validated_data}")
        serializer.save()
        print(f"💾 Restaurant updated successfully")
        return Response({
            'success': True,
            'message': 'Restaurant updated successfully',
            'restaurant': RestaurantSerializer(restaurant).data
        })
    
    print(f"❌ Serializer errors: {serializer.errors}")
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(tags=['Admin: Tables'], parameters=[OpenApiParameter("id", OpenApiTypes.UUID, OpenApiParameter.PATH)])
class TableViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing restaurant tables and QR codes.
    
    Endpoints:
    - POST /tables/ - Create tables for the user's restaurant
    - GET /tables/ - List all tables for the user's restaurant
    - GET /tables/{id}/ - Get specific table details
    - PUT /tables/{id}/ - Update table
    - DELETE /tables/{id}/ - Delete table
    - POST /tables/scan-qr/ - Scan QR code and get table + menu
    """
    serializer_class = TableSerializer
    permission_classes = [permissions.IsAuthenticated, IsRestaurantOwner]

    def get_permissions(self):
        """Allow public access to scan_qr"""
        if self.action == 'scan_qr':
            return [permissions.AllowAny()]
        return [permission() for permission in self.permission_classes]
    
    def get_queryset(self):
        """Return tables for the user's restaurant only"""
        owned_restaurant = self.request.user.get_owned_restaurant()
        if owned_restaurant:
            tables = Table.objects.filter(restaurant=owned_restaurant)
            print(f"📊 Fetching tables for restaurant: {owned_restaurant.name}, Found: {tables.count()} tables")
            return tables
        print(f"⚠️ User {self.request.user.email} has no restaurant")
        return Table.objects.none()
    
    def get_serializer_class(self):
        """Use different serializers for different actions"""
        if self.action == 'list':
            return TableListSerializer
        elif self.action == 'scan_qr':
            return QRCodeScanSerializer
        return TableSerializer
    
    def perform_create(self, serializer):
        """Automatically set the restaurant to the user's restaurant"""
        owned_restaurant = self.request.user.get_owned_restaurant()
        if owned_restaurant:
            print(f"✨ Creating table {serializer.validated_data.get('number')} for restaurant: {owned_restaurant.name}")
            serializer.save(restaurant=owned_restaurant)
            print(f"✅ Table created successfully: ID={serializer.instance.id}, Table Number={serializer.instance.number}")
        else:
            print(f"❌ Cannot create table - User {self.request.user.email} has no restaurant")
            raise ValueError("User does not have an associated restaurant")
    
    def create(self, request, *args, **kwargs):
        """Handle both single and bulk table creation"""
        # Check if creating multiple tables
        if isinstance(request.data, list):
            # Bulk creation
            serializers = [self.get_serializer(data=item) for item in request.data]
            for serializer in serializers:
                serializer.is_valid(raise_exception=True)
            
            # Create all tables
            owned_restaurant = request.user.get_owned_restaurant()
            if not owned_restaurant:
                return Response({'error': 'User does not have an associated restaurant'}, status=status.HTTP_400_BAD_REQUEST)
            
            created_tables = []
            for serializer in serializers:
                self.perform_create(serializer)
                created_tables.append(serializer.data)
            
            return Response({
                'success': True,
                'message': f'Successfully created {len(created_tables)} tables',
                'tables': created_tables
            }, status=status.HTTP_201_CREATED)
        
        # Single creation
        return super().create(request, *args, **kwargs)
    
    @extend_schema(request=BulkTableCreateSerializer, responses={201: OpenApiTypes.OBJECT})
    @action(detail=False, methods=['post'])
    def create_bulk(self, request):
        """
        Create multiple tables at once.
        
        Expected payload: {"count": 5}
        """
        count = request.data.get('count', 0)
        try:
            count = int(count)
        except (ValueError, TypeError):
            return Response({'error': 'Count must be a valid integer'}, status=status.HTTP_400_BAD_REQUEST)
        
        if count < 1 or count > 100:
            return Response({'error': 'Count must be between 1 and 100'}, status=status.HTTP_400_BAD_REQUEST)
        
        owned_restaurant = request.user.get_owned_restaurant()
        if not owned_restaurant:
            return Response({'error': 'User does not have an associated restaurant'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Find existing table numbers
        existing_numbers = set(Table.objects.filter(restaurant=owned_restaurant).values_list('number', flat=True))
        
        # Create tables with consecutive numbers starting from the lowest available
        created_tables = []
        table_number = 1
        for i in range(count):
            try:
                # Find next available number
                while table_number in existing_numbers:
                    table_number += 1
                
                print(f"\n📍 Creating table {i+1}/{count}, number={table_number}")
                
                # Create table
                table = Table.objects.create(
                    restaurant=owned_restaurant,
                    number=table_number
                )
                print(f"✅ Table created: {table.id}")
                
                # Generate QR code after table is saved to DB
                print(f"🔄 Generating QR code for table {table.number}")
                table.generate_qr_code()
                print(f"✅ QR code generated, URL: {table.qr_url}")
                
                # Save the QR URL to the table
                table.save()
                print(f"✅ Table saved with QR code")
                
                created_tables.append(table)
                existing_numbers.add(table_number)
                table_number += 1
                print(f"✅ Table {i+1} completed successfully\n")
                
            except Exception as e:
                print(f"❌ Error creating table {i+1}: {e}")
                import traceback
                traceback.print_exc()
                return Response({
                    'error': f'Error creating table {i+1}: {str(e)}'
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        serializer = self.get_serializer(created_tables, many=True)
        return Response({
            'success': True,
            'message': f'Successfully created {len(created_tables)} tables',
            'tables': serializer.data
        }, status=status.HTTP_201_CREATED)
    
    @extend_schema(responses={200: OpenApiTypes.OBJECT})
    @action(detail=True, methods=['post'])
    def regenerate_qr(self, request, pk=None):
        """Regenerate QR code for a specific table"""
        table = self.get_object()
        table.regenerate_qr_code()
        serializer = self.get_serializer(table)
        return Response({
            'success': True,
            'message': 'QR code regenerated successfully',
            'table': serializer.data
        }, status=status.HTTP_200_OK)
    
    @extend_schema(responses={200: OpenApiTypes.OBJECT})
    @action(detail=True, methods=['post'])
    def clear_table(self, request, pk=None):
        """Clear occupied table - reset to available status"""
        table = self.get_object()
        
        # Only allow clearing if table is occupied or ordering
        if table.status in ['occupied', 'ordering', 'preparing']:
            table.status = 'available'
            table.save()
            return Response({
                'success': True,
                'message': f'Table {table.number} has been cleared and is now available.',
                'table': TableSerializer(table).data
            })
        else:
            return Response({
                'success': False,
                'message': f'Table {table.number} is already {table.status}.'
            }, status=status.HTTP_400_BAD_REQUEST)
    @extend_schema(tags=['Customer API'], request=QRCodeScanSerializer, responses={200: OpenApiTypes.OBJECT})
    @action(detail=False, methods=['post'], url_path='scan-qr')
    def scan_qr(self, request):
        """
        Scan QR code endpoint - returns table info and menu without authentication.
        
        Expected payload: {"qr_code_data": "restaurant:<uuid>|table:<uuid>"}
        """
        serializer = QRCodeScanSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        qr_code_data = serializer.validated_data['qr_code_data']
        
        # Parse QR code data: "restaurant:<uuid>|table:<uuid>"
        try:
            parts = qr_code_data.split('|')
            restaurant_part = None
            table_part = None
            
            for part in parts:
                if part.startswith('restaurant:'):
                    restaurant_part = part.split(':', 1)[1]
                elif part.startswith('table:'):
                    table_part = part.split(':', 1)[1]  # Keep as string since it's UUID
            
            if not restaurant_part or not table_part:
                return Response({
                    'error': 'Invalid QR code format'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Fetch restaurant and table
            try:
                restaurant = Restaurant.objects.get(id=restaurant_part)
            except Restaurant.DoesNotExist:
                return Response({
                    'error': 'Restaurant not found'
                }, status=status.HTTP_404_NOT_FOUND)
            
            try:
                table = Table.objects.get(id=table_part, restaurant=restaurant)
            except Table.DoesNotExist:
                return Response({
                    'error': 'Table not found'
                }, status=status.HTTP_404_NOT_FOUND)
            
            # Prepare response with table info and menu
            from core.services.cache_services import get_cached_menu
            
            response_data = {
                'success': True,
                'table': TableSerializer(table).data,
                'restaurant': RestaurantSerializer(restaurant).data,
                'menu': {
                    'categories': get_cached_menu(restaurant)
                }
            }
            
            print(f"✅ QR code scanned successfully for table {table.number} in restaurant {restaurant.name}")
            
            return Response(response_data, status=status.HTTP_200_OK)
        
        except ValueError as e:
            return Response({
                'error': f'Invalid QR code data format: {str(e)}'
            }, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            print(f"❌ Error processing QR code scan: {str(e)}")
            return Response({
                'error': f'Error processing QR code: {str(e)}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@extend_schema(tags=['Customer API'], responses={200: OpenApiTypes.OBJECT})
@api_view(['GET'])
def validate_table_qr(request):
    """
    Validate QR params + Check table status
    """
    restaurant_id = request.GET.get('restaurant')
    table_number = request.GET.get('table')

    try:
        restaurant = Restaurant.objects.get(id=restaurant_id)
        table = Table.objects.get(restaurant=restaurant, number=table_number)
    except (Restaurant.DoesNotExist, Table.DoesNotExist):
        return Response({'error': 'Invalid QR. Please scan table QR.'}, status=404)

    if table.status == 'dirty':
        return Response({
            'valid': False,
            'message': f'Table {table_number} needs cleaning. Please wait.',
            'status': table.status
        })

    if table.status not in ['available', 'ordering']:
        return Response({
            'valid': False,
            'message': f'Table {table_number} is {table.status}.',
            'status': table.status
        })

    # ✅ Mark table occupied
    table.status = 'ordering'
    table.save()

    return Response({
        'valid': True,
        'restaurant': {
            'id': str(restaurant.id),
            'name': restaurant.name
        },
        'table': {
            'number': table.number,
            'status': table.status,
            'capacity': table.capacity
        },
        'message': f'Welcome to Table {table.number}!'
    })

@extend_schema(
    tags=['Customer API'], 
    responses={
        200: inline_serializer(
            name='DirtyTableReportResponse',
            fields={
                'success': serializers.BooleanField(),
                'message': serializers.CharField()
            }
        )
    }
)
@api_view(['POST'])
@permission_classes([permissions.AllowAny])
def report_dirty_table(request, table_id):
    """Customer reports a table needs cleaning"""
    from websocket.services import broadcast_cleanup_request
    try:
        table = Table.objects.get(id=table_id)
        # Always allow reporting if table is scanned
        table.status = 'dirty'
        table.save()
        
        broadcast_cleanup_request(table.restaurant.id, table.number)
        
        return Response({'success': True, 'message': 'Cleanup request sent to staff.'})
    except Table.DoesNotExist:
        return Response({'error': 'Table not found'}, status=404)


@extend_schema(tags=['Waiter API'], responses={200: TableStatusSerializer(many=True)})
@api_view(['GET'])
@permission_classes([WaiterPermission])
def waiter_tables(request):
    """GET /api/waiter/tables/ → Status grid"""
    from django.db import connection
    
    restaurant = request.user.restaurant
    
    # Fetch tables
    tables = Table.objects.filter(restaurant=restaurant).order_by('number')
    
    # Use raw SQL to count ready orders (database has table_id, not table_number)
    with connection.cursor() as cursor:
        for table in tables:
            cursor.execute(
                """
                SELECT COUNT(*) FROM orders_order 
                WHERE table_id = %s AND status = 'ready'
                """,
                [table.id]
            )
            ready_count = cursor.fetchone()[0]
            table.annotated_ready_orders_count = ready_count
    
    print(f"✅ Fetched {tables.count()} tables for restaurant: {restaurant.name}")
    for table in tables:
        print(f"  Table {table.number}: {table.status} ({table.annotated_ready_orders_count} ready orders)")
    
    return Response(TableStatusSerializer(tables, many=True).data)

@extend_schema(tags=['Waiter API'], request=UpdateTableStatusSerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['PATCH'])
@permission_classes([WaiterPermission])
def update_table_status(request, table_number):
    """PATCH /api/waiter/tables/<number>/ → Update status"""
    from websocket.services import broadcast_table_update
    try:
        table = Table.objects.get(restaurant=request.user.restaurant, number=table_number)
        table.status = request.data['status']
        table.notes = request.data.get('notes', table.notes)
        table.save()
        
        # Broadcast update via WebSocket
        broadcast_table_update(request.user.restaurant.id, table.number, table.status)
        
        return Response({'status': table.status})
    except Table.DoesNotExist:
        return Response({'error': 'Table not found'}, status=404)


# ============================================================================
# STAFF INVITATION ENDPOINTS
# ============================================================================

@extend_schema(tags=['Admin: Staff'], request=StaffInviteCreateSerializer, responses={201: OpenApiTypes.OBJECT})
@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def create_staff_invite(request):
    """
    Admin creates staff invitation with QR code
    POST /api/restaurants/staff-invite/
    Body: {email: "staff@example.com", role: "kitchen" or "waiter"}
    Returns: {id, email, role, qr_code_url, expires_at}
    """
    # Ensure user is admin with a restaurant
    user = cast(User, request.user)
    restaurant = user.get_owned_restaurant()
    
    if not restaurant:
        return Response({
            'error': 'Only restaurant owners can create staff invitations.'
        }, status=status.HTTP_403_FORBIDDEN)
    
    if user.role != 'admin':
        return Response({
            'error': 'Only admins can create staff invitations.'
        }, status=status.HTTP_403_FORBIDDEN)
    
    serializer = StaffInviteCreateSerializer(data=request.data, context={'request': request})
    
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    # Create invitation
    invite = serializer.save(restaurant=restaurant)
    
    # Return response with invitation details
    response_serializer = StaffInviteSerializer(invite)
    
    return Response({
        'success': True,
        'message': f'Staff invitation created for {invite.email} as {invite.get_role_display()}',
        'invite': response_serializer.data
    }, status=status.HTTP_201_CREATED)


@extend_schema(responses={200: OpenApiTypes.OBJECT})
@api_view(['DELETE'])
@permission_classes([permissions.IsAuthenticated])
def delete_staff_invite(request, invite_id):
    """
    Delete a staff invitation
    DELETE /api/restaurants/staff-invite/<uuid>/
    """
    user = cast(User, request.user)
    restaurant = user.get_owned_restaurant()
    
    if not restaurant:
        return Response({
            'error': 'Only restaurant owners can delete staff invitations.'
        }, status=status.HTTP_403_FORBIDDEN)
    
    try:
        invite = StaffInvite.objects.get(id=invite_id, restaurant=restaurant)
        invite.delete()
        return Response({
            'success': True,
            'message': 'Invitation deleted successfully.'
        }, status=status.HTTP_200_OK)
    except StaffInvite.DoesNotExist:
        return Response({
            'error': 'Invitation not found.'
        }, status=status.HTTP_404_NOT_FOUND)


@extend_schema(tags=['Admin: Staff'], responses={200: StaffInviteSerializer(many=True)})
@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def list_staff_invites(request):
    """
    Admin lists all staff invitations (pending, claimed, expired)
    GET /api/restaurants/staff-invites/
    """
    user = cast(User, request.user)
    restaurant = user.get_owned_restaurant()
    
    if not restaurant:
        return Response({
            'error': 'Only restaurant owners can view staff invitations.'
        }, status=status.HTTP_403_FORBIDDEN)
    
    invites = StaffInvite.objects.filter(restaurant=restaurant).order_by('-created_at')
    serializer = StaffInviteSerializer(invites, many=True)
    
    return Response({
        'success': True,
        'count': invites.count(),
        'invites': serializer.data
    })


@extend_schema(responses={200: OpenApiTypes.OBJECT})
@api_view(['GET'])
@permission_classes([permissions.AllowAny])
def get_invite_details(request, invite_id):
    """
    Get invitation details (email) for QR code confirmation
    GET /api/restaurants/invite-details/<uuid>/
    Returns: {email: "staff@example.com", is_claimed: false, is_expired: false}
    Used by frontend to show which email the invitation is for before Google login
    """
    try:
        invite = StaffInvite.objects.get(id=invite_id)
        
        # Only return email and status info, not sensitive data
        return Response({
            'success': True,
            'email': invite.email,
            'is_claimed': invite.is_claimed,
            'is_expired': not invite.is_valid(),  # is_valid() returns False if expired
        })
    except StaffInvite.DoesNotExist:
        return Response({
            'success': False,
            'error': 'Invalid invitation',
            'message': 'This QR code is not valid.'
        }, status=status.HTTP_404_NOT_FOUND)


@extend_schema(tags=['Staff: Onboarding'], request=ClaimInviteSerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['POST'])
@permission_classes([permissions.AllowAny])
def claim_staff_invite(request, invite_id):
    """
    Staff claims invitation with Google auth after scanning QR code
    POST /api/restaurants/claim-invite/<uuid>/
    Body: {google_id: "123...", email: "staff@example.com", google_token: "optional"}
    Returns: {user, tokens: {access, refresh}}
    """
    print(f"🔍 BACKEND: claim_staff_invite called with invite_id: {invite_id}")
    print(f"📨 BACKEND: Request data: {request.data}")
    print(f"👤 BACKEND: Request user: {request.user}")
    
    serializer = ClaimInviteSerializer(
        data=request.data,
        context={'invite_id': invite_id}
    )
    
    if not serializer.is_valid():
        print(f"❌ BACKEND: Serializer validation failed: {serializer.errors}")
        # Format validation errors in a user-friendly way
        errors = serializer.errors
        
        # Handle specific invitation validation errors
        if 'non_field_errors' in errors:
            error_messages = errors['non_field_errors']
            for error in error_messages:
                error_str = str(error)
                if 'already been claimed' in error_str:
                    return Response({
                        'success': False,
                        'error': 'Invitation Already Claimed',
                        'message': 'This QR code has already been used by another staff member. Please contact your restaurant manager for a new invitation.',
                        'code': 'INVITATION_CLAIMED'
                    }, status=status.HTTP_400_BAD_REQUEST)
                elif 'expired' in error_str:
                    return Response({
                        'success': False,
                        'error': 'Invitation Expired',
                        'message': 'This QR code has expired. Please ask your restaurant manager to send you a new invitation.',
                        'code': 'INVITATION_EXPIRED'
                    }, status=status.HTTP_400_BAD_REQUEST)
                elif 'Invalid invitation' in error_str:
                    return Response({
                        'success': False,
                        'error': 'Invalid QR Code',
                        'message': 'This QR code is not valid. Please make sure you scanned the correct code from your invitation.',
                        'code': 'INVALID_QR_CODE'
                    }, status=status.HTTP_400_BAD_REQUEST)
                elif 'Please sign in with that email' in error_str or 'is for' in error_str:
                    return Response({
                        'success': False,
                        'error': 'Email Mismatch',
                        'message': error_str,
                        'code': 'EMAIL_MISMATCH'
                    }, status=status.HTTP_400_BAD_REQUEST)
        
        # Generic error for other validation issues
        return Response({
            'success': False,
            'error': 'Validation Error',
            'message': 'Please check your information and try again.',
            'details': errors,
            'code': 'VALIDATION_ERROR'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    print("✅ BACKEND: Serializer validation passed")
    validated_data = serializer.validated_data
    invite = validated_data['invite']
    google_id = validated_data['google_id']
    email = validated_data['email']
    print(f"📋 BACKEND: Validated data - google_id: {google_id}, email: {email}, invite: {invite}")
    
    # Check if user already exists
    try:
        user = User.objects.get(google_id=google_id)
        print(f"👤 BACKEND: Existing user found: {user.email}")
        
        # User exists - check if they're already assigned to another restaurant
        if user.restaurant and user.restaurant != invite.restaurant:
            print(f"❌ BACKEND: User already employed at different restaurant: {user.restaurant.name}")
            return Response({
                'success': False,
                'error': 'Already Employed',
                'message': f'You are already working at {user.restaurant.name}. Please contact support if you need to change restaurants.',
                'code': 'ALREADY_EMPLOYED'
            }, status=status.HTTP_400_BAD_REQUEST)
        
    except User.DoesNotExist:
        print("🆕 BACKEND: User does not exist, creating new user")
        # Create new user for staff
        username = email.split('@')[0]
        base_username = username
        counter = 1
        
        # Ensure unique username
        while User.objects.filter(username=username).exists():
            username = f"{base_username}{counter}"
            counter += 1
        
        user = User.objects.create(
            username=username,
            email=email,
            google_id=google_id,
            is_google_verified=True,
            is_email_verified=True,
            profile_completed=True,
            registration_completed=True,
            is_active=True
        )
    
    # Claim the invitation (assigns restaurant and role to user)
    print(f"🎯 BACKEND: Attempting to claim invitation for user: {user.email}")
    success = invite.claim(user)
    print(f"📊 BACKEND: Claim result: {success}")
    
    if not success:
        # Double-check the invite status for better error messages
        invite.refresh_from_db()
        if invite.is_claimed:
            return Response({
                'success': False,
                'error': 'Invitation Already Claimed',
                'message': 'This QR code was claimed by someone else while you were trying to use it. Please contact your restaurant manager.',
                'code': 'INVITATION_CLAIMED'
            }, status=status.HTTP_400_BAD_REQUEST)
        elif timezone.now() > invite.expires_at:
            return Response({
                'success': False,
                'error': 'Invitation Expired',
                'message': 'This QR code expired while you were trying to use it. Please ask your restaurant manager for a new invitation.',
                'code': 'INVITATION_EXPIRED'
            }, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response({
                'success': False,
                'error': 'Claim Failed',
                'message': 'Unable to claim this invitation. Please try again or contact support.',
                'code': 'CLAIM_FAILED'
            }, status=status.HTTP_400_BAD_REQUEST)
    
    # Generate JWT tokens for immediate login
    refresh = RefreshToken.for_user(user)
    print(f"🎟️ BACKEND: Tokens generated successfully for user: {user.email}")
    
    return Response({
        'success': True,
        'message': f'Welcome to {invite.restaurant.name}! You are now {invite.get_role_display()}.',
        'user': {
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'role': user.role,
            'restaurant_name': user.restaurant.name if user.restaurant else None
        },
        'tokens': {
            'access': str(refresh.access_token),
            'refresh': str(refresh)
        }
    }, status=status.HTTP_200_OK)


@extend_schema(responses={200: StaffUserSerializer(many=True)})
@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def list_staff(request):
    """
    Admin lists all staff members in their restaurant
    GET /api/restaurants/staff/
    """
    user = cast(User, request.user)
    restaurant = user.get_owned_restaurant()
    
    if not restaurant:
        return Response({
            'error': 'Only restaurant owners can view staff.'
        }, status=status.HTTP_403_FORBIDDEN)
    
    # Get all staff assigned to this restaurant (kitchen and waiter)
    staff_members = User.objects.filter(
        restaurant=restaurant,
        role__in=['kitchen', 'waiter']
    ).order_by('role', 'email')
    
    serializer = StaffUserSerializer(staff_members, many=True)
    
    return Response({
        'success': True,
        'count': staff_members.count(),
        'staff': serializer.data
    })


@extend_schema(responses={200: OpenApiTypes.OBJECT})
@api_view(['DELETE'])
@permission_classes([permissions.IsAuthenticated])
def remove_staff(request, staff_id):
    """
    Admin permanently deletes a staff member from the system
    DELETE /api/restaurants/staff/<user_id>/
    This is a permanent deletion - user data will be completely removed
    """
    user = cast(User, request.user)
    restaurant = user.get_owned_restaurant()
    
    if not restaurant:
        return Response({
            'error': 'Only restaurant owners can remove staff.'
        }, status=status.HTTP_403_FORBIDDEN)
    
    try:
        staff_member = User.objects.get(
            id=staff_id,
            restaurant=restaurant,
            role__in=['kitchen', 'waiter']
        )
    except User.DoesNotExist:
        return Response({
            'error': 'Staff member not found or does not belong to your restaurant.'
        }, status=status.HTTP_404_NOT_FOUND)
    
    # Store info before deletion
    staff_name = staff_member.email
    staff_role = staff_member.get_role_display()
    
    # Permanently delete the user
    staff_member.delete()
    
    return Response({
        'success': True,
        'message': f'{staff_name} ({staff_role}) has been permanently deleted from the system.'
    })


@extend_schema(request=ToggleStaffStatusSerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['PATCH'])
@permission_classes([permissions.IsAuthenticated])
def toggle_staff_status(request, staff_id):
    """
    Admin activates or deactivates a staff member
    PATCH /api/restaurants/staff/<user_id>/toggle-status/
    Body: {is_active: true/false}
    Deactivated staff cannot log in
    """
    user = cast(User, request.user)
    restaurant = user.get_owned_restaurant()
    
    if not restaurant:
        return Response({
            'error': 'Only restaurant owners can manage staff.'
        }, status=status.HTTP_403_FORBIDDEN)
    
    try:
        staff_member = User.objects.get(
            id=staff_id,
            restaurant=restaurant,
            role__in=['kitchen', 'waiter']
        )
    except User.DoesNotExist:
        return Response({
            'error': 'Staff member not found or does not belong to your restaurant.'
        }, status=status.HTTP_404_NOT_FOUND)
    
    # Get desired status from request
    new_status = request.data.get('is_active')
    
    if new_status is None:
        return Response({
            'error': 'is_active field is required (true or false)'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    # Validate boolean
    if not isinstance(new_status, bool):
        return Response({
            'error': 'is_active must be a boolean (true or false)'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    # Update status
    old_status = staff_member.is_active
    staff_member.is_active = new_status
    staff_member.save()
    
    status_text = "activated" if new_status else "deactivated"
    
    return Response({
        'success': True,
        'message': f'{staff_member.email} ({staff_member.get_role_display()}) has been {status_text}.',
        'staff': {
            'id': staff_member.id,
            'email': staff_member.email,
            'role': staff_member.role,
            'is_active': staff_member.is_active,
            'previous_status': old_status
        }
    })
