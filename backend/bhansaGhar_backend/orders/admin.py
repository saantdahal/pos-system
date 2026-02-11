from django.contrib import admin
from .models import Order, OrderBargain, OrderServeLog, WaiterSession, BargainMessage, OrderTimeline, OrderAssignment


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ['id', 'restaurant', 'table_display', 'status', 'assigned_waiter', 'created_at']
    list_filter = ['restaurant', 'status', 'created_at']
    search_fields = ['id', 'restaurant__name', 'table__number', 'customer_notes']
    readonly_fields = ['id', 'created_at', 'updated_at', 'session_id']
    
    fieldsets = (
        ('Order Info', {
            'fields': ('id', 'restaurant', 'table', 'session_id', 'status')
        }),
        ('Items & Pricing', {
            'fields': ('items', 'subtotal')
        }),
        ('Assignments', {
            'fields': ('assigned_waiter', 'assigned_kitchen_staff')
        }),
        ('Customer Notes', {
            'fields': ('customer_notes',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at')
        })
    )
    
    def table_display(self, obj):
        if obj.table:
            return f"Table {obj.table.number}"
        return "No Table"
    table_display.short_description = 'Table'


@admin.register(OrderBargain)
class OrderBargainAdmin(admin.ModelAdmin):
    list_display = ['id', 'order', 'order_item_id', 'action_type', 'customer_response', 'created_at']
    list_filter = ['action_type', 'customer_response', 'created_at']
    search_fields = ['order__id', 'staff_message']
    readonly_fields = ['created_at', 'answered_at']
    
    fieldsets = (
        ('Bargain Info', {
            'fields': ('order', 'order_item_id', 'action_type')
        }),
        ('Quantities', {
            'fields': ('requested_quantity', 'available_quantity', 'accepted_quantity')
        }),
        ('Messages', {
            'fields': ('staff_message', 'customer_message', 'customer_response')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'answered_at', 'expires_at')
        })
    )


@admin.register(OrderServeLog)
class OrderServeLogAdmin(admin.ModelAdmin):
    list_display = ['order', 'table_status_before', 'served_at']
    list_filter = ['table_status_before', 'served_at']
    search_fields = ['order__id', 'waiter_notes']
    readonly_fields = ['served_at']


@admin.register(WaiterSession)
class WaiterSessionAdmin(admin.ModelAdmin):
    list_display = ['user', 'restaurant', 'status', 'active_orders_count', 'last_heartbeat']
    list_filter = ['restaurant', 'status', 'last_heartbeat']
    search_fields = ['user__username', 'restaurant__name']
    readonly_fields = ['created_at', 'updated_at', 'last_heartbeat']


@admin.register(BargainMessage)
class BargainMessageAdmin(admin.ModelAdmin):
    list_display = ['bargain', 'sender_type', 'sender', 'status', 'created_at']
    list_filter = ['sender_type', 'status', 'created_at']
    search_fields = ['bargain__id', 'message']
    readonly_fields = ['created_at', 'read_at']


@admin.register(OrderTimeline)
class OrderTimelineAdmin(admin.ModelAdmin):
    list_display = ['order', 'status_old', 'status_new', 'changed_by', 'created_at']
    list_filter = ['status_new', 'created_at']
    search_fields = ['order__id', 'reason']
    readonly_fields = ['created_at']


@admin.register(OrderAssignment)
class OrderAssignmentAdmin(admin.ModelAdmin):
    list_display = ['order', 'assigned_user', 'task_type', 'status', 'assigned_at']
    list_filter = ['task_type', 'status', 'assigned_at']
    search_fields = ['order__id', 'assigned_user__username']
    readonly_fields = ['assigned_at']
