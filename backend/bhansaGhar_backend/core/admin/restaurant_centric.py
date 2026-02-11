"""
Restaurant-centric admin structure for Sperium Lounge
"""
from django.contrib import admin
from django.urls import path, reverse
from django.shortcuts import render, redirect, get_object_or_404
from django.http import JsonResponse, HttpResponse
from django.template.response import TemplateResponse
from django.utils.html import format_html
from django.db.models import Q, Count, Sum
from datetime import datetime, timedelta
from typing import Optional, Dict, Any

from core.models import User
from restaurants.models import Restaurant, Table, Category, MenuItem, StaffInvite
from orders.models import Order, OrderBargain
from analytics.models import DailyAnalytics


class RestaurantCentricAdminMixin:
    """Mixin to make admin restaurant-centric"""
    
    def get_queryset(self, request):
        qs = super().get_queryset(request)
        user = request.user
        
        if hasattr(user, 'owned_restaurant') and user.owned_restaurant:
            # Restaurant owner sees only their data
            restaurant = user.owned_restaurant
            if hasattr(self.model, 'restaurant'):
                return qs.filter(restaurant=restaurant)
            elif self.model == Restaurant:
                return qs.filter(id=restaurant.id)
        elif user.is_superuser:
            # Superuser sees all
            return qs
        else:
            # Staff sees their restaurant's data
            if hasattr(user, 'restaurant') and user.restaurant:
                restaurant = user.restaurant
                if hasattr(self.model, 'restaurant'):
                    return qs.filter(restaurant=restaurant)
                elif self.model == Restaurant:
                    return qs.filter(id=restaurant.id)
        
        return qs.none()
    
    def has_view_permission(self, request, obj=None):
        if request.user.is_superuser:
            return True
        
        if obj and hasattr(obj, 'restaurant'):
            user_restaurant = getattr(request.user, 'owned_restaurant', None) or getattr(request.user, 'restaurant', None)
            return obj.restaurant == user_restaurant
        
        return super().has_view_permission(request, obj)
    
    def has_change_permission(self, request, obj=None):
        if request.user.is_superuser:
            return True
            
        if obj and hasattr(obj, 'restaurant'):
            user_restaurant = getattr(request.user, 'owned_restaurant', None)
            return obj.restaurant == user_restaurant
            
        return super().has_change_permission(request, obj)


class RestaurantCentricAdmin(RestaurantCentricAdminMixin, admin.ModelAdmin):
    """Base admin class for restaurant-centric models"""
    
    def get_restaurant_context(self, request) -> Dict[str, Any]:
        """Get restaurant-specific context"""
        user = request.user
        restaurant = None
        
        if hasattr(user, 'owned_restaurant') and user.owned_restaurant:
            restaurant = user.owned_restaurant
        elif hasattr(user, 'restaurant') and user.restaurant:
            restaurant = user.restaurant
            
        if not restaurant:
            return {}
            
        # Get restaurant statistics
        orders_today = Order.objects.filter(
            restaurant=restaurant,
            created_at__date=datetime.now().date()
        ).count()
        
        active_orders = Order.objects.filter(
            restaurant=restaurant,
            status__in=['pending', 'preparing', 'bargain', 'ready']
        ).count()
        
        total_staff = User.objects.filter(restaurant=restaurant).count()
        total_tables = Table.objects.filter(restaurant=restaurant).count()
        total_menu_items = MenuItem.objects.filter(category__restaurant=restaurant).count()
        
        daily_revenue = Order.objects.filter(
            restaurant=restaurant,
            created_at__date=datetime.now().date(),
            status='served'
        ).aggregate(total=Sum('subtotal'))['total'] or 0
        
        return {
            'restaurant': restaurant,
            'restaurant_stats': {
                'orders_today': orders_today,
                'active_orders': active_orders,
                'total_staff': total_staff,
                'total_tables': total_tables,
                'total_menu_items': total_menu_items,
                'daily_revenue': daily_revenue,
            }
        }


class RestaurantAdmin(RestaurantCentricAdmin):
    list_display = ['name', 'type', 'address', 'phone', 'is_active', 'created_at']
    list_filter = ['type', 'is_active', 'created_at']
    search_fields = ['name', 'address', 'phone']
    readonly_fields = ['id', 'created_at']
    
    fieldsets = (
        ('Basic Information', {
            'fields': ('name', 'type', 'description')
        }),
        ('Location', {
            'fields': ('address', 'latitude', 'longitude')
        }),
        ('Contact & Operations', {
            'fields': ('phone', 'operating_hours', 'tables_capacity')
        }),
        ('Status', {
            'fields': ('is_active',)
        }),
        ('System Information', {
            'fields': ('id', 'created_at'),
            'classes': ('collapse',)
        })
    )
    
    def get_readonly_fields(self, request, obj=None):
        readonly = list(super().get_readonly_fields(request, obj))
        
        # Restaurant owners can't change certain fields
        if not request.user.is_superuser:
            readonly.extend(['owner'])
            
        return readonly


class OrderAdmin(RestaurantCentricAdmin):
    list_display = ['id', 'restaurant_name', 'table_display', 'status', 'assigned_waiter', 'subtotal', 'created_at']
    list_filter = ['status', 'created_at', 'assigned_waiter']
    search_fields = ['id', 'customer_notes', 'session_id', 'table__number']
    readonly_fields = ['id', 'created_at', 'updated_at']
    
    fieldsets = (
        ('Order Information', {
            'fields': ('id', 'restaurant', 'table', 'session_id', 'status')
        }),
        ('Items & Pricing', {
            'fields': ('items', 'subtotal', 'customer_notes')
        }),
        ('Staff Assignment', {
            'fields': ('assigned_waiter', 'assigned_kitchen_staff')
        }),
        ('Timeline', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        })
    )
    
    def restaurant_name(self, obj):
        return obj.restaurant.name
    restaurant_name.short_description = 'Restaurant'
    
    def table_display(self, obj):
        if obj.table:
            return f"Table {obj.table.number}"
        return "No Table"
    table_display.short_description = 'Table'
    
    def get_queryset(self, request):
        return super().get_queryset(request).select_related('restaurant', 'assigned_waiter', 'table')
    
    def changelist_view(self, request, extra_context=None):
        extra_context = extra_context or {}
        extra_context.update(self.get_restaurant_context(request))
        return super().changelist_view(request, extra_context)


class TableAdmin(RestaurantCentricAdmin):
    list_display = ['number', 'restaurant_name', 'capacity', 'status', 'qr_code_display']
    list_filter = ['status', 'capacity']
    search_fields = ['number']
    readonly_fields = ['qr_code_url']
    
    def restaurant_name(self, obj):
        return obj.restaurant.name
    restaurant_name.short_description = 'Restaurant'
    
    def qr_code_display(self, obj):
        if obj.qr_code_url:
            return format_html('<img src="{}" width="50" height="50" />', obj.qr_code_url)
        return "No QR Code"
    qr_code_display.short_description = 'QR Code'


class CategoryAdmin(RestaurantCentricAdmin):
    list_display = ['name', 'restaurant_name', 'position', 'menu_items_count', 'created_at']
    list_filter = ['created_at']
    search_fields = ['name']
    ordering = ['position']
    
    def restaurant_name(self, obj):
        return obj.restaurant.name
    restaurant_name.short_description = 'Restaurant'
    
    def menu_items_count(self, obj):
        return obj.items.count()
    menu_items_count.short_description = 'Menu Items'


class MenuItemAdmin(RestaurantCentricAdmin):
    list_display = ['name', 'category', 'base_price', 'stock_quantity', 'is_available', 'position']
    list_filter = ['category']
    search_fields = ['name', 'description']
    ordering = ['category', 'position']
    
    def get_queryset(self, request):
        return super().get_queryset(request).select_related('category__restaurant')
    
    def formfield_for_foreignkey(self, db_field, request, **kwargs):
        if db_field.name == "category":
            user = request.user
            restaurant = getattr(user, 'owned_restaurant', None) or getattr(user, 'restaurant', None)
            if restaurant:
                kwargs["queryset"] = Category.objects.filter(restaurant=restaurant)
        return super().formfield_for_foreignkey(db_field, request, **kwargs)


class StaffInviteAdmin(RestaurantCentricAdmin):
    list_display = ['email', 'restaurant_name', 'role', 'status', 'created_at', 'expires_at']
    list_filter = ['role', 'status', 'created_at']
    search_fields = ['email']
    readonly_fields = ['qr_code_image', 'created_at', 'expires_at']
    
    def restaurant_name(self, obj):
        return obj.restaurant.name
    restaurant_name.short_description = 'Restaurant'


class OrderBargainAdmin(RestaurantCentricAdminMixin, admin.ModelAdmin):
    list_display = ['order', 'restaurant_name', 'order_item_id', 'action_type', 'customer_response', 'created_at']
    list_filter = ['action_type', 'customer_response', 'created_at']
    search_fields = ['order__id', 'staff_message', 'customer_message']
    
    def restaurant_name(self, obj):
        return obj.order.restaurant.name
    restaurant_name.short_description = 'Restaurant'
    
    def get_queryset(self, request):
        return super().get_queryset(request).select_related('order__restaurant')
