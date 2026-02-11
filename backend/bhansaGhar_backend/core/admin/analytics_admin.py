"""
Analytics-related admin configurations
"""
from django.contrib import admin
from django.utils.html import format_html

from analytics.models import DailyAnalytics, HourlyAnalytics, TopItem
from .mixins import AdminFilterMixin


class DailyAnalyticsAdmin(AdminFilterMixin, admin.ModelAdmin):  # type: ignore[misc]
    list_display = ['analytics_date', 'restaurant', 'revenue_display', 'order_count', 'avg_order_value', 'total_customers']
    list_filter = ['restaurant', 'date']
    search_fields = ['restaurant__name']
    readonly_fields = ['date', 'created_at']
    ordering = ['-date']
    
    fieldsets = (
        ('📊 Daily Analytics', {'fields': ('date', 'restaurant')}),
        ('💰 Revenue Metrics', {'fields': ('total_revenue', 'total_cost', 'total_profit')}),
        ('📈 Order Metrics', {'fields': ('total_orders', 'avg_order_value', 'completed_orders', 'cancelled_orders')}),
        ('👥 Customer Metrics', {'fields': ('total_customers', 'repeat_customers', 'new_customers')}),
        ('⏰ Timestamps', {'fields': ('created_at',)}),
    )
    
    def analytics_date(self, obj):
        return format_html('<strong>{}</strong>', obj.date.strftime('%Y-%m-%d'))
    analytics_date.short_description = 'Date'  # type: ignore[attr-defined]
    
    def revenue_display(self, obj):
        return format_html('<strong style="color: #10b981;">${:.2f}</strong>', obj.total_revenue)
    revenue_display.short_description = 'Revenue'  # type: ignore[attr-defined]
    
    def order_count(self, obj):
        return format_html('<span style="background: #dbeafe; color: #0c4a6e; padding: 3px 8px; border-radius: 3px; font-weight: 600;">{}</span>', obj.total_orders)
    order_count.short_description = 'Orders'  # type: ignore[attr-defined]
    
    def avg_order_value(self, obj):
        if obj.total_orders > 0:
            avg = obj.total_revenue / obj.total_orders
            return format_html('<strong>${:.2f}</strong>', avg)
        return '—'
    avg_order_value.short_description = 'Avg Value'  # type: ignore[attr-defined]
    
    def total_customers(self, obj):
        return format_html('<span style="background: #fed7aa; color: #92400e; padding: 3px 8px; border-radius: 3px; font-weight: 600;">{}</span>', obj.total_customers)
    total_customers.short_description = 'Customers'  # type: ignore[attr-defined]


class HourlyAnalyticsAdmin(AdminFilterMixin, admin.ModelAdmin):  # type: ignore[misc]
    list_display = ['analytics_hour', 'restaurant', 'hour_display', 'revenue_display', 'orders_count', 'busy_status']
    list_filter = ['restaurant', 'date', 'hour']
    search_fields = ['restaurant__name']
    readonly_fields = ['date', 'created_at']
    ordering = ['-date', '-hour']
    
    fieldsets = (
        ('⏰ Hourly Analytics', {'fields': ('date', 'hour', 'restaurant')}),
        ('💰 Revenue', {'fields': ('revenue',)}),
        ('📈 Orders', {'fields': ('orders_count', 'items_sold')}),
        ('⏱️ Timestamps', {'fields': ('created_at',)}),
    )
    
    def analytics_hour(self, obj):
        return format_html('<strong>{}:00</strong>', str(obj.hour).zfill(2))
    analytics_hour.short_description = 'Time'  # type: ignore[attr-defined]
    
    def hour_display(self, obj):
        return format_html('{} - {} ({}:00 - {}:00)', obj.date, obj.hour, str(obj.hour).zfill(2), str(obj.hour + 1).zfill(2))
    hour_display.short_description = 'Hour Range'  # type: ignore[attr-defined]
    
    def revenue_display(self, obj):
        return format_html('<strong style="color: #10b981;">${:.2f}</strong>', obj.revenue)
    revenue_display.short_description = 'Revenue'  # type: ignore[attr-defined]
    
    def orders_count(self, obj):
        return format_html('<span style="background: #dbeafe; color: #0c4a6e; padding: 3px 8px; border-radius: 3px; font-weight: 600;">{}</span>', obj.orders_count)
    orders_count.short_description = 'Orders'  # type: ignore[attr-defined]
    
    def busy_status(self, obj):
        # Classify busyness based on orders count
        if obj.orders_count >= 10:
            return format_html('<span style="color: #ef4444; font-weight: 600;">🔥 Very Busy</span>')
        elif obj.orders_count >= 5:
            return format_html('<span style="color: #f59e0b; font-weight: 600;">⚡ Busy</span>')
        else:
            return format_html('<span style="color: #10b981; font-weight: 600;">😌 Quiet</span>')
    busy_status.short_description = 'Busyness'  # type: ignore[attr-defined]


class TopItemAdmin(AdminFilterMixin, admin.ModelAdmin):  # type: ignore[misc]
    list_display = ['item_name', 'restaurant', 'rank_display', 'quantity_display', 'revenue_display']
    list_filter = ['restaurant', 'date']
    search_fields = ['restaurant__name', 'item_name']
    readonly_fields = ['date', 'created_at']
    ordering = ['restaurant', 'date', 'rank']
    
    fieldsets = (
        ('📊 Top Item Analytics', {'fields': ('date', 'restaurant')}),
        ('🍽️ Item Information', {'fields': ('rank', 'item_name', 'total_quantity', 'total_revenue')}),
        ('⏰ Timestamps', {'fields': ('created_at',)}),
    )
    
    def rank_display(self, obj):
        return format_html('<span style="background: #dbeafe; color: #0c4a6e; padding: 5px 10px; border-radius: 3px; font-weight: 600;">#{}</span>', obj.rank)
    rank_display.short_description = 'Rank'  # type: ignore[attr-defined]
    
    def quantity_display(self, obj):
        return format_html('<strong>{} units</strong>', obj.total_quantity)
    quantity_display.short_description = 'Quantity'  # type: ignore[attr-defined]
    
    def revenue_display(self, obj):
        return format_html('<strong style="color: #10b981;">${:.2f}</strong>', obj.total_revenue)
    revenue_display.short_description = 'Revenue'  # type: ignore[attr-defined]
