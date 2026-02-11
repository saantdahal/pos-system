from rest_framework import serializers
from .models import Invoice
from django.conf import settings
from django.contrib.auth import get_user_model

User = get_user_model()


class UserBasicSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'first_name', 'last_name', 'email']


class InvoiceSerializer(serializers.ModelSerializer):
    """List view serializer"""
    restaurant_name = serializers.CharField(source='restaurant.name', read_only=True)
    closed_by_info = UserBasicSerializer(source='closed_by', read_only=True)
    
    class Meta:
        model = Invoice
        fields = [
            'id',
            'table_number',
            'restaurant_name',
            'status',
            'subtotal',
            'tax',
            'total',
            'created_at',
            'last_updated_at',
            'paid_at',
            'closed_at',
            'close_reason',
            'closed_by_info'
        ]
        read_only_fields = fields


class InvoiceDetailSerializer(serializers.ModelSerializer):
    """Detailed view serializer with all items"""
    restaurant_name = serializers.CharField(source='restaurant.name', read_only=True)
    restaurant_id = serializers.CharField(source='restaurant.id', read_only=True)
    closed_by_info = UserBasicSerializer(source='closed_by', read_only=True)
    items_count = serializers.SerializerMethodField()
    can_close = serializers.SerializerMethodField()
    
    class Meta:
        model = Invoice
        fields = [
            'id',
            'table_number',
            'restaurant_id',
            'restaurant_name',
            'items',
            'items_count',
            'subtotal',
            'tax',
            'total',
            'status',
            'created_at',
            'last_updated_at',
            'paid_at',
            'closed_at',
            'close_reason',
            'closed_by_info',
            'can_close'
        ]
        read_only_fields = [
            'id', 'items', 'subtotal', 'tax', 'total',
            'created_at', 'last_updated_at', 'paid_at',
            'closed_at', 'close_reason', 'closed_by_info', 'can_close'
        ]
    
    def get_items_count(self, obj):
        return len(obj.items)
    
    def get_can_close(self, obj):
        request = self.context.get('request')
        if not request or not request.user:
            return False
        return obj.can_close(request.user)


class InvoiceCloseSerializer(serializers.Serializer):
    """Serializer for closing invoice"""
    reason = serializers.ChoiceField(
        choices=[
            'customer_left',
            'waiter_cleared',
            'admin_closed',
            'cancelled'
        ]
    )


class InvoiceListSerializer(serializers.ModelSerializer):
    """Minimal serializer for list endpoints"""
    restaurant_name = serializers.CharField(source='restaurant.name', read_only=True)
    
    class Meta:
        model = Invoice
        fields = [
            'id',
            'table_number',
            'restaurant_name',
            'status',
            'total',
            'created_at'
        ]
