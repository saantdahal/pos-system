"""
Order-related admin configurations
"""
from django.contrib import admin
from django.utils.html import format_html
from django.urls import reverse
from django.utils.safestring import mark_safe

from orders.models import Order, OrderBargain
from .mixins import AdminFilterMixin


class OrderAdmin(AdminFilterMixin, admin.ModelAdmin):  # type: ignore[misc]
    list_display = ['order_id', 'restaurant', 'customer_display', 'status_badge', 'total_display', 'created_at']
    list_filter = ['restaurant', 'status', 'created_at']
    search_fields = ['id', 'customer__username', 'restaurant__name', 'table__number']
    readonly_fields = ['id', 'created_at', 'updated_at']
    ordering = ['-created_at']
    
    fieldsets = (
        ('📋 Order Information', {'fields': ('id', 'restaurant', 'table', 'customer')}),
        ('📊 Items & Pricing', {'fields': ('items', 'subtotal', 'tax', 'delivery_fee', 'total')}),
        ('🎟️ Bargain', {'fields': ('bargain',)}),
        ('📍 Status', {'fields': ('status', 'notes')}),
        ('⏰ Timestamps', {'fields': ('created_at', 'updated_at')}),
    )
    
    def order_id(self, obj):
        return format_html('<strong>#{}</strong>', obj.id)
    order_id.short_description = 'Order ID'  # type: ignore[attr-defined]
    
    def customer_display(self, obj):
        if obj.customer:
            return format_html('<strong>{}</strong>', obj.customer.username)
        return format_html('<span style="color: #6b7280;">Anonymous</span>')
    customer_display.short_description = 'Customer'  # type: ignore[attr-defined]
    
    def status_badge(self, obj):
        status_colors = {
            'PENDING': '#f59e0b',
            'CONFIRMED': '#0ea5e9',
            'PREPARING': '#8b5cf6',
            'READY': '#10b981',
            'SERVED': '#10b981',
            'COMPLETED': '#10b981',
            'CANCELLED': '#ef4444',
        }
        color = status_colors.get(obj.status, '#6b7280')
        return format_html(
            '<span style="background: {}; color: white; padding: 5px 12px; border-radius: 20px; font-weight: 600; font-size: 12px;">{}</span>',
            color, obj.get_status_display()
        )
    status_badge.short_description = 'Status'  # type: ignore[attr-defined]
    
    def total_display(self, obj):
        return format_html('<strong style="color: #10b981;">${:.2f}</strong>', obj.total)
    total_display.short_description = 'Total'  # type: ignore[attr-defined]


class OrderBargainAdmin(AdminFilterMixin, admin.ModelAdmin):  # type: ignore[misc]
    list_display = ['bargain_id', 'restaurant', 'discount_display', 'status_badge', 'expiry_status', 'created_at']
    list_filter = ['restaurant', 'is_active', 'created_at']
    search_fields = ['id', 'restaurant__name', 'title']
    readonly_fields = ['id', 'created_at', 'updated_at']
    ordering = ['-created_at']
    
    fieldsets = (
        ('🎟️ Bargain Information', {'fields': ('id', 'restaurant', 'title', 'description')}),
        ('💰 Discount Details', {'fields': ('discount_amount', 'discount_type')}),
        ('⏰ Validity', {'fields': ('valid_from', 'valid_until')}),
        ('⚙️ Status', {'fields': ('is_active',)}),
        ('⏱️ Timestamps', {'fields': ('created_at', 'updated_at')}),
    )
    
    def bargain_id(self, obj):
        return format_html('<strong>#{}</strong>', obj.id)
    bargain_id.short_description = 'Bargain ID'  # type: ignore[attr-defined]
    
    def discount_display(self, obj):
        if obj.discount_type == 'PERCENTAGE':
            return format_html('<strong style="color: #f59e0b;">{:.0f}%</strong>', obj.discount_amount)
        return format_html('<strong style="color: #10b981;">${:.2f}</strong>', obj.discount_amount)
    discount_display.short_description = 'Discount'  # type: ignore[attr-defined]
    
    def status_badge(self, obj):
        if obj.is_active:
            return format_html('<span style="color: #10b981; font-weight: 600;">✓ Active</span>')
        return format_html('<span style="color: #ef4444; font-weight: 600;">✗ Inactive</span>')
    status_badge.short_description = 'Status'  # type: ignore[attr-defined]
    
    def expiry_status(self, obj):
        from django.utils import timezone
        now = timezone.now()
        
        if not obj.valid_until:
            return format_html('<span style="color: #10b981;">∞ No Expiry</span>')
        
        if obj.valid_until < now:
            return format_html('<span style="color: #ef4444;">⏰ Expired</span>')
        
        return format_html('<span style="color: #8b5cf6;">⏱️ Active</span>')
    expiry_status.short_description = 'Expiry'  # type: ignore[attr-defined]
