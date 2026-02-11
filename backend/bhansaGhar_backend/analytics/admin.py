from django.contrib import admin
from .models import DailyAnalytics, HourlyAnalytics, TopItem


@admin.register(DailyAnalytics)
class DailyAnalyticsAdmin(admin.ModelAdmin):
    list_display = [
        'restaurant', 'date', 'total_orders', 'total_revenue',
        'avg_prep_time_seconds', 'bargain_success_rate'
    ]
    list_filter = ['restaurant', 'date']
    search_fields = ['restaurant__name']
    readonly_fields = ['created_at', 'updated_at']
    ordering = ['-date']
    
    fieldsets = (
        ('Basic Info', {
            'fields': ('restaurant', 'date')
        }),
        ('Revenue Metrics', {
            'fields': ('total_orders', 'total_revenue')
        }),
        ('Prep Time Metrics', {
            'fields': ('avg_prep_time_seconds', 'min_prep_time_seconds', 'max_prep_time_seconds')
        }),
        ('Table Metrics', {
            'fields': ('tables_turnover', 'unique_tables_served')
        }),
        ('Bargain Metrics', {
            'fields': ('bargain_orders_count', 'bargain_success_rate')
        }),
        ('Order Status', {
            'fields': (
                'pending_orders', 'preparing_orders', 'ready_orders',
                'served_orders', 'cancelled_orders'
            )
        }),
        ('Waiter Metrics', {
            'fields': ('avg_serve_time_seconds',)
        }),
        ('Peak Hours', {
            'fields': ('peak_hour', 'peak_hour_orders')
        }),
        ('Staff', {
            'fields': ('active_kitchen_staff', 'active_waiters')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at')
        })
    )


@admin.register(HourlyAnalytics)
class HourlyAnalyticsAdmin(admin.ModelAdmin):
    list_display = [
        'restaurant', 'date', 'hour', 'total_orders', 'total_revenue',
        'avg_prep_time_seconds'
    ]
    list_filter = ['restaurant', 'date', 'hour']
    search_fields = ['restaurant__name']
    readonly_fields = ['created_at', 'updated_at']
    ordering = ['-date', '-hour']


@admin.register(TopItem)
class TopItemAdmin(admin.ModelAdmin):
    list_display = [
        'item_name', 'restaurant', 'date', 'rank',
        'total_quantity', 'total_revenue'
    ]
    list_filter = ['restaurant', 'date', 'rank']
    search_fields = ['restaurant__name', 'item_name']
    readonly_fields = ['created_at']
    ordering = ['-date', 'rank']
