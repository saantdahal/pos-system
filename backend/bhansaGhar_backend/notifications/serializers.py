from rest_framework import serializers
from .models import Notification, FCMDevice, NotificationPreference


class NotificationSerializer(serializers.ModelSerializer):
    """Serialize notification objects for API responses"""
    category_display = serializers.CharField(source='get_category_display', read_only=True)
    priority_display = serializers.CharField(source='get_priority_display', read_only=True)
    
    class Meta:
        model = Notification
        fields = [
            'id',
            'category',
            'category_display',
            'title',
            'message',
            'data',
            'priority',
            'priority_display',
            'timestamp',
            'is_read',
            'read_at',
            'fcm_sent',
            'ws_sent',
        ]
        read_only_fields = [
            'id',
            'category_display',
            'priority_display',
            'timestamp',
            'read_at',
            'fcm_sent',
            'ws_sent',
        ]


class NotificationDetailSerializer(NotificationSerializer):
    """Extended serializer with full delivery details"""
    class Meta(NotificationSerializer.Meta):
        fields = NotificationSerializer.Meta.fields + [
            'fcm_sent_at',
            'fcm_failed',
            'fcm_error',
            'ws_sent_at',
        ]
        read_only_fields = NotificationSerializer.Meta.read_only_fields + [
            'fcm_sent_at',
            'fcm_failed',
            'fcm_error',
            'ws_sent_at',
        ]


class FCMDeviceSerializer(serializers.ModelSerializer):
    """Serialize FCM device registration"""
    platform_display = serializers.CharField(source='get_platform_display', read_only=True)
    
    class Meta:
        model = FCMDevice
        fields = [
            'id',
            'token',
            'platform',
            'platform_display',
            'active',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at', 'platform_display']


class NotificationPreferenceSerializer(serializers.ModelSerializer):
    """Serialize notification preferences"""
    class Meta:
        model = NotificationPreference
        fields = [
            'id',
            'order_notifications',
            'bargain_notifications',
            'table_notifications',
            'staff_notifications',
            'stock_notifications',
            'revenue_notifications',
            'fcm_enabled',
            'websocket_enabled',
            'dnd_enabled',
            'dnd_start_time',
            'dnd_end_time',
            'updated_at',
        ]
        read_only_fields = ['id', 'updated_at']


class NotificationStatsSerializer(serializers.Serializer):
    """Serialize notification statistics"""
    total_unread = serializers.IntegerField()
    by_category = serializers.DictField(child=serializers.IntegerField())
    
    class Meta:
        fields = ['total_unread', 'by_category']
