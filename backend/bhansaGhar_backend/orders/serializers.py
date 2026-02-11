from rest_framework import serializers
from .models import (
    Order, OrderBargain, OrderServeLog, BaseOrderStatus, BaseBargainStatus,
    WaiterSession, BargainMessage, OrderTimeline, OrderAssignment
)
from restaurants.models import Table, MenuItem
from core.models import User
from drf_spectacular.utils import extend_schema_field

class BargainSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderBargain
        fields = ['id', 'item_id', 'customer_qty', 'kitchen_qty', 'status', 'kitchen_message', 'customer_response', 'resolved_at']

class OrderKitchenSerializer(serializers.ModelSerializer):
    bargains = serializers.SerializerMethodField()
    table_number = serializers.IntegerField(read_only=True)

    class Meta:
        model = Order
        fields = '__all__'

    @extend_schema_field(BargainSerializer(many=True))
    def get_bargains(self, obj):
        bargains = obj.bargains.all()
        return BargainSerializer(bargains, many=True).data

class TableStatusSerializer(serializers.ModelSerializer):
    ready_orders_count = serializers.SerializerMethodField()
    class Meta:
        model = Table
        fields = ['number', 'status', 'capacity', 'notes', 'ready_orders_count']
    
    @extend_schema_field(serializers.IntegerField())
    def get_ready_orders_count(self, obj):
        # Use annotated value if available to avoid N+1
        if hasattr(obj, 'annotated_ready_orders_count'):
            return obj.annotated_ready_orders_count
        return Order.objects.filter(
            restaurant=obj.restaurant, 
            table_number=obj.number, 
            status='ready'
        ).count()

class WaiterOrderSerializer(serializers.ModelSerializer):
    prep_time = serializers.SerializerMethodField()
    table_status = serializers.CharField(source='get_table_status', read_only=True)
    
    class Meta:
        model = Order
        fields = ['id', 'table_number', 'items', 'status', 'prep_time', 'table_status', 'customer_notes']

    @extend_schema_field(serializers.CharField())
    def get_prep_time(self, obj):
        return obj.created_at.strftime("%I:%M %p")

    def get_table_status(self, obj):
        # Use context map if available to avoid N+1
        table_status_map = self.context.get('table_status_map')
        if table_status_map and obj.table_number in table_status_map:
            return table_status_map[obj.table_number]
            
        try:
            table = Table.objects.get(restaurant=obj.restaurant, number=obj.table_number)
            return table.status
        except Table.DoesNotExist:
            return "unknown"

class TableOrderSerializer(serializers.ModelSerializer):
    class Meta:
        model = Order
        fields = ['id', 'status', 'items', 'subtotal', 'created_at']

class BargainRequestSerializer(serializers.Serializer):
    item_id = serializers.UUIDField()
    customer_qty = serializers.IntegerField()
    kitchen_qty = serializers.IntegerField()
    message = serializers.CharField(required=False, allow_blank=True)

class CustomerBargainResponseSerializer(serializers.Serializer):
    session_id = serializers.CharField()
    status = serializers.ChoiceField(choices=BaseBargainStatus.choices)
    response = serializers.CharField(required=False, allow_blank=True)

class EmptySerializer(serializers.Serializer):
    pass


# New Serializers for Order Enhancement Features

class WaiterSessionSerializer(serializers.ModelSerializer):
    user_name = serializers.CharField(source='user.get_full_name', read_only=True)
    restaurant_name = serializers.CharField(source='restaurant.name', read_only=True)
    is_active = serializers.SerializerMethodField()
    
    class Meta:
        model = WaiterSession
        fields = [
            'id', 'user', 'user_name', 'restaurant', 'restaurant_name',
            'status', 'active_orders_count', 'last_heartbeat', 'is_active',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    @extend_schema_field(serializers.BooleanField())
    def get_is_active(self, obj):
        return obj.is_active()


class BargainMessageSerializer(serializers.ModelSerializer):
    sender_name = serializers.SerializerMethodField()
    
    class Meta:
        model = BargainMessage
        fields = [
            'id', 'bargain', 'sender_type', 'sender', 'sender_name',
            'message', 'status', 'created_at', 'read_at'
        ]
        read_only_fields = ['id', 'created_at', 'read_at']
    
    @extend_schema_field(serializers.CharField())
    def get_sender_name(self, obj):
        if obj.sender:
            return obj.sender.get_full_name() or obj.sender.username
        elif obj.sender_type == 'customer':
            return 'Customer'
        return 'System'


class OrderTimelineSerializer(serializers.ModelSerializer):
    changed_by_name = serializers.CharField(source='changed_by.get_full_name', read_only=True)
    
    class Meta:
        model = OrderTimeline
        fields = [
            'id', 'order', 'status_old', 'status_new', 'changed_by',
            'changed_by_name', 'reason', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class OrderAssignmentSerializer(serializers.ModelSerializer):
    assigned_user_name = serializers.CharField(source='assigned_user.get_full_name', read_only=True)
    
    class Meta:
        model = OrderAssignment
        fields = [
            'id', 'order', 'assigned_user', 'assigned_user_name', 'task_type',
            'status', 'assigned_at', 'started_at', 'completed_at'
        ]
        read_only_fields = ['id', 'assigned_at', 'started_at', 'completed_at']


class EnhancedBargainSerializer(serializers.ModelSerializer):
    """Enhanced bargain serializer with full message history"""
    messages = serializers.SerializerMethodField()
    
    class Meta:
        model = OrderBargain
        fields = [
            'id', 'order', 'item_id', 'customer_qty', 'kitchen_qty',
            'status', 'kitchen_message', 'customer_response', 'messages',
            'created_at', 'resolved_at'
        ]
        read_only_fields = ['id', 'created_at', 'resolved_at']
    
    @extend_schema_field(BargainMessageSerializer(many=True))
    def get_messages(self, obj):
        messages = obj.messages.all().order_by('created_at')
        return BargainMessageSerializer(messages, many=True).data


class EnhancedOrderSerializer(serializers.ModelSerializer):
    """Enhanced order serializer with assignments and timeline"""
    assigned_waiter_name = serializers.CharField(source='assigned_waiter.get_full_name', read_only=True)
    assigned_kitchen_staff_names = serializers.SerializerMethodField()
    timeline = serializers.SerializerMethodField()
    bargains = serializers.SerializerMethodField()
    assignments = serializers.SerializerMethodField()
    
    class Meta:
        model = Order
        fields = [
            'id', 'restaurant', 'table_number', 'session_id', 'status',
            'items', 'subtotal', 'customer_notes', 'assigned_waiter',
            'assigned_waiter_name', 'assigned_kitchen_staff',
            'assigned_kitchen_staff_names', 'timeline', 'bargains',
            'assignments', 'created_at', 'updated_at'
        ]
        read_only_fields = [
            'id', 'restaurant', 'session_id', 'created_at', 'updated_at'
        ]
    
    @extend_schema_field(serializers.ListField(child=serializers.CharField()))
    def get_assigned_kitchen_staff_names(self, obj):
        return [staff.get_full_name() or staff.username for staff in obj.assigned_kitchen_staff.all()]
    
    @extend_schema_field(OrderTimelineSerializer(many=True))
    def get_timeline(self, obj):
        timeline = obj.timeline.all().order_by('-created_at')[:20]
        return OrderTimelineSerializer(timeline, many=True).data
    
    @extend_schema_field(EnhancedBargainSerializer(many=True))
    def get_bargains(self, obj):
        bargains = obj.bargains.all()
        return EnhancedBargainSerializer(bargains, many=True).data
    
    @extend_schema_field(OrderAssignmentSerializer(many=True))
    def get_assignments(self, obj):
        assignments = obj.assignments.all().order_by('-assigned_at')
        return OrderAssignmentSerializer(assignments, many=True).data


class AutoAssignSerializer(serializers.Serializer):
    """Request/Response for auto-assigning waiters"""
    order_id = serializers.UUIDField()
    waiter_id = serializers.IntegerField(required=False, allow_null=True)
    force_admin = serializers.BooleanField(default=False)


class BargainChatMessageSerializer(serializers.Serializer):
    """Request for sending bargain chat messages"""
    bargain_id = serializers.UUIDField()
    message = serializers.CharField(max_length=500)
    sender_type = serializers.ChoiceField(choices=['kitchen', 'customer', 'admin'])


class StaffReassignmentSerializer(serializers.Serializer):
    """Admin staff reassignment"""
    order_id = serializers.UUIDField()
    new_waiter_id = serializers.IntegerField(required=False, allow_null=True)
    remove_kitchen_staff = serializers.ListField(
        child=serializers.IntegerField(), required=False, default=[]
    )
    add_kitchen_staff = serializers.ListField(
        child=serializers.IntegerField(), required=False, default=[]
    )
    reason = serializers.CharField(max_length=255, required=False)

