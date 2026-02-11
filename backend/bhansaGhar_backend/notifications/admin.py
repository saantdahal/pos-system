from django.contrib import admin
from .models import Notification, FCMDevice, NotificationLog, NotificationPreference


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = [
        'id',
        'user',
        'category',
        'title',
        'priority',
        'timestamp',
        'is_read',
        'fcm_sent',
        'ws_sent',
    ]
    list_filter = [
        'category',
        'priority',
        'is_read',
        'fcm_sent',
        'ws_sent',
        'timestamp',
    ]
    search_fields = ['user__username', 'title', 'message']
    readonly_fields = [
        'id',
        'timestamp',
        'read_at',
        'fcm_sent_at',
        'ws_sent_at',
    ]
    fieldsets = (
        ('Basic Info', {
            'fields': ('id', 'user', 'category', 'title', 'message', 'data')
        }),
        ('Priority & Timing', {
            'fields': ('priority', 'timestamp')
        }),
        ('Read Status', {
            'fields': ('is_read', 'read_at')
        }),
        ('Delivery Status', {
            'fields': (
                'ws_sent',
                'ws_sent_at',
                'fcm_sent',
                'fcm_sent_at',
                'fcm_failed',
                'fcm_error',
            )
        }),
    )
    date_hierarchy = 'timestamp'
    ordering = ['-timestamp']


@admin.register(FCMDevice)
class FCMDeviceAdmin(admin.ModelAdmin):
    list_display = ['id', 'user', 'platform', 'active', 'updated_at']
    list_filter = ['platform', 'active', 'updated_at']
    search_fields = ['user__username', 'token']
    readonly_fields = ['id', 'created_at', 'updated_at']
    fieldsets = (
        ('User Device', {
            'fields': ('id', 'user', 'token', 'platform')
        }),
        ('Status', {
            'fields': ('active', 'created_at', 'updated_at')
        }),
    )


@admin.register(NotificationLog)
class NotificationLogAdmin(admin.ModelAdmin):
    list_display = [
        'id',
        'notification',
        'delivery_type',
        'status',
        'timestamp',
    ]
    list_filter = ['delivery_type', 'status', 'timestamp']
    search_fields = ['notification__id', 'notification__title']
    readonly_fields = ['id', 'timestamp']
    date_hierarchy = 'timestamp'
    ordering = ['-timestamp']


@admin.register(NotificationPreference)
class NotificationPreferenceAdmin(admin.ModelAdmin):
    list_display = [
        'user',
        'fcm_enabled',
        'websocket_enabled',
        'dnd_enabled',
        'updated_at',
    ]
    list_filter = [
        'fcm_enabled',
        'websocket_enabled',
        'dnd_enabled',
        'updated_at',
    ]
    search_fields = ['user__username']
    readonly_fields = ['id', 'created_at', 'updated_at']
    fieldsets = (
        ('User', {
            'fields': ('id', 'user')
        }),
        ('Category Preferences', {
            'fields': (
                'order_notifications',
                'bargain_notifications',
                'table_notifications',
                'staff_notifications',
                'stock_notifications',
                'revenue_notifications',
            )
        }),
        ('Delivery Method', {
            'fields': ('fcm_enabled', 'websocket_enabled')
        }),
        ('Do Not Disturb', {
            'fields': ('dnd_enabled', 'dnd_start_time', 'dnd_end_time')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
