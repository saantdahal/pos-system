from django.contrib import admin
from django.contrib.admin.sites import AdminSite
from django.urls import path, URLPattern, URLResolver
from django.shortcuts import render
from django.template.response import TemplateResponse
from django.http import HttpResponse
from django.db.models import Sum, Count, Avg, Q
from django.utils.html import format_html
from .models import User, WebsiteData
from .activities.activity_models import ActivityLog
from .admin.utils import (
    AnalyticsAggregator, 
    AdminFilterMixin, 
    get_admin_dashboard_context
)
from restaurants.models import Restaurant, Table, Category, MenuItem, StaffInvite, RestaurantType
from orders.models import Order, OrderBargain
from admin_interface.models import Theme

# ============================================================================
# CUSTOM ADMIN SITE WITH PROFESSIONAL DASHBOARD
# ============================================================================

class SperiumAdminSite(AdminSite):
    site_header = "🍽️ Sperium Lounge Administration"
    site_title = "Sperium Admin Panel"
    index_title = "Dashboard"
    site_url = None  # type: ignore[assignment]  # Remove the "View site" link

    def get_urls(self) -> list[URLResolver]:
        urls = super().get_urls()
        custom_urls: list[URLPattern] = [
            path('dashboard/', self.admin_view(self.dashboard_view), name='dashboard'),
        ]
        return custom_urls + urls  # type: ignore[return-value]

    def dashboard_view(self, request):
        """Render professional analytics dashboard"""
        context = get_admin_dashboard_context(request)
        context.update(self.each_context(request))
        context['is_super_admin'] = request.user.is_superuser
        return render(request, 'admin/dashboard.html', context)

    def index(self, request, extra_context=None) -> TemplateResponse:
        """
        Override the default index view to show our custom dashboard
        """
        # Redirect to dashboard view
        return self.dashboard_view(request)  # type: ignore[return-value]

# Create the custom admin site
admin_site = SperiumAdminSite(name='sperium_admin')

# ============================================================================
# USER ADMIN
# ============================================================================

class UserAdmin(admin.ModelAdmin):
    """Admin interface for User model"""
    list_display = ['username', 'email', 'phone', 'role_badge', 'restaurant', 'is_active_badge', 'date_joined']
    list_filter = ['role', 'is_email_verified', 'is_active', 'date_joined']
    search_fields = ['username', 'email', 'phone']
    readonly_fields = ['google_id', 'email_verification_code', 'email_verification_expires_at', 'last_code_sent_at', 'id']
    ordering = ['-date_joined']
    
    fieldsets = (
        ('👤 Basic Information', {
            'fields': ('id', 'username', 'email', 'phone', 'address', 'latitude', 'longitude')
        }),
        ('🔐 Verification & Status', {
            'fields': ('is_google_verified', 'is_email_verified', 'profile_completed', 'is_active')
        }),
        ('🏪 Restaurant Assignment', {
            'fields': ('role', 'restaurant')
        }),
        ('🔑 Permissions', {
            'fields': ('is_staff', 'is_superuser', 'groups', 'user_permissions')
        }),
        ('📅 Important dates', {
            'fields': ('last_login', 'date_joined')
        }),
    )
    
    def role_badge(self, obj):
        """Display role as colored badge"""
        # Check if user is a super admin first
        if obj.is_superuser:
            return format_html(
                '<span style="background: #9333ea; color: white; padding: 5px 10px; border-radius: 4px; font-weight: 600; font-size: 11px;">👑 Super Admin</span>'
            )
        
        colors = {
            'admin': '#10b981',
            'kitchen': '#3b82f6',
            'waiter': '#f59e0b',
        }
        color = colors.get(obj.role, '#6b7280')
        role_display = obj.get_role_display() if obj.role else 'No Role'
        return format_html(
            '<span style="background: {}; color: white; padding: 5px 10px; border-radius: 4px; font-weight: 600; font-size: 11px;">{}</span>',
            color,
            role_display
        )
    role_badge.short_description = 'Role'  # type: ignore[attr-defined]
    
    def is_active_badge(self, obj):
        """Display active status as badge"""
        if obj.is_active:
            return format_html('<span style="color: #10b981; font-weight: 600;">✓ Active</span>')
        else:
            return format_html('<span style="color: #ef4444; font-weight: 600;">✗ Inactive</span>')
    is_active_badge.short_description = 'Status'  # type: ignore[attr-defined]

# ============================================================================
# ACTIVITY LOG ADMIN
# ============================================================================

class ActivityLogAdmin(admin.ModelAdmin):
    """Admin interface for activity logs"""
    list_display = ('user', 'activity_type_badge', 'description', 'restaurant', 'created_at')
    list_filter = ('activity_type', 'created_at', 'user__role', 'restaurant')
    search_fields = ('user__username', 'description', 'related_object_id')
    readonly_fields = ('id', 'created_at', 'user', 'activity_type', 'description', 
                      'related_object_type', 'related_object_id', 'metadata', 
                      'ip_address', 'user_agent', 'restaurant')
    date_hierarchy = 'created_at'
    ordering = ['-created_at']
    
    fieldsets = (
        ('📝 Activity Information', {
            'fields': ('id', 'user', 'activity_type', 'description', 'restaurant')
        }),
        ('🔗 Related Object', {
            'fields': ('related_object_type', 'related_object_id', 'metadata')
        }),
        ('🌍 System Information', {
            'fields': ('ip_address', 'user_agent')
        }),
        ('⏰ Timestamps', {
            'fields': ('created_at',)
        }),
    )
    
    def activity_type_badge(self, obj):
        """Display activity type with color coding"""
        colors = {
            'CREATE': '#10b981',
            'UPDATE': '#3b82f6',
            'DELETE': '#ef4444',
            'LOGIN': '#f59e0b',
        }
        color = colors.get(obj.activity_type, '#6b7280')
        return format_html(
            '<span style="background: {}; color: white; padding: 4px 8px; border-radius: 3px; font-weight: 600; font-size: 11px;">{}</span>',
            color,
            obj.activity_type
        )
    activity_type_badge.short_description = 'Activity Type'  # type: ignore[attr-defined]
    
    def has_add_permission(self, request):
        return False  # Activities are created automatically
    
    def has_delete_permission(self, request, obj=None):
        return False  # Prevent deletion of activity logs


# ============================================================================
# RESTAURANT NESTED ADMIN
# ============================================================================

class TableInline(admin.TabularInline):
    """Inline tables for restaurant"""
    model = Table
    extra = 0
    fields = ['number', 'capacity', 'is_available']
    max_num = 50


class StaffInline(admin.TabularInline):
    """Inline staff members for restaurant"""
    model = User
    extra = 0
    fields = ['username', 'email', 'role', 'is_active']
    fk_name = 'restaurant'
    max_num = 50


class MenuItemInline(admin.TabularInline):
    """Inline menu items for category"""
    model = MenuItem
    extra = 0
    fields = ['name', 'price', 'vegetarian', 'is_available']
    max_num = 100


class CategoryInline(admin.TabularInline):
    """Inline categories for restaurant"""
    model = Category
    extra = 0
    fields = ['name', 'description']
    max_num = 20


class RestaurantAdmin(AdminFilterMixin, admin.ModelAdmin):  # type: ignore[misc]
    list_display = ['restaurant_name', 'owner_name', 'type', 'active_status', 'staff_count', 'tables_capacity', 'created_at']
    list_filter = ['is_active', 'type', 'created_at']
    search_fields = ['name', 'owner__username', 'address']
    readonly_fields = ['id', 'created_at']
    ordering = ['-created_at']
    inlines = [CategoryInline, TableInline, StaffInline]
    
    fieldsets = (
        ('🏪 Restaurant Information', {
            'fields': ('id', 'name', 'owner', 'type', 'phone')
        }),
        ('📍 Location', {
            'fields': ('address', 'latitude', 'longitude')
        }),
        ('📊 Details', {
            'fields': ('description', 'tables_capacity', 'operating_hours')
        }),
        ('⚙️ Status', {
            'fields': ('is_active',)
        }),
        ('⏰ Timestamps', {
            'fields': ('created_at',)
        }),
    )
    
    def restaurant_name(self, obj):
        return format_html('<strong>{}</strong>', obj.name)
    restaurant_name.short_description = 'Restaurant'  # type: ignore[attr-defined]
    
    def owner_name(self, obj):
        return obj.owner.username if obj.owner else '—'
    owner_name.short_description = 'Owner'  # type: ignore[attr-defined]
    
    def active_status(self, obj):
        if obj.is_active:
            return format_html('<span style="color: #10b981; font-weight: 600;">✓ Active</span>')
        else:
            return format_html('<span style="color: #ef4444; font-weight: 600;">✗ Inactive</span>')
    active_status.short_description = 'Status'  # type: ignore[attr-defined]
    
    def staff_count(self, obj):
        count = obj.staff.count()
        return format_html(
            '<span style="background: #dbeafe; color: #0c4a6e; padding: 3px 8px; border-radius: 3px; font-weight: 600;">{}</span>',
            count
        )
    staff_count.short_description = 'Staff'  # type: ignore[attr-defined]


class RestaurantTypeAdmin(admin.ModelAdmin):
    list_display = ['display_name', 'is_active']
    list_filter = ['is_active']
    search_fields = ['name', 'display_name']


# ============================================================================
# TABLE ADMIN
# ============================================================================

class TableAdmin(AdminFilterMixin, admin.ModelAdmin):  # type: ignore[misc]
    list_display = ['table_number', 'restaurant', 'capacity', 'availability_status', 'qr_generated']
    list_filter = ['restaurant']
    search_fields = ['number', 'restaurant__name']
    readonly_fields = ['id', 'qr_code_preview', 'created_at']
    ordering = ['restaurant', 'number']
    
    fieldsets = (
        ('🪑 Table Information', {
            'fields': ('id', 'restaurant', 'number', 'capacity')
        }),
        ('📋 QR Code', {
            'fields': ('qr_code', 'qr_code_preview')
        }),
        ('⚙️ Status', {
            'fields': ('is_available',)
        }),
        ('⏰ Timestamps', {
            'fields': ('created_at',)
        }),
    )
    
    def table_number(self, obj):
        return format_html('<strong>Table {}</strong>', obj.number)
    table_number.short_description = 'Table'  # type: ignore[attr-defined]
    
    def availability_status(self, obj):
        if obj.is_available:
            return format_html('<span style="color: #10b981; font-weight: 600;">✓ Available</span>')
        else:
            return format_html('<span style="color: #f59e0b; font-weight: 600;">◉ Occupied</span>')
    availability_status.short_description = 'Status'  # type: ignore[attr-defined]
    
    def qr_generated(self, obj):
        if obj.qr_code:
            return format_html('<span style="color: #10b981; font-weight: 600;">✓ Generated</span>')
        else:
            return format_html('<span style="color: #ef4444; font-weight: 600;">✗ Pending</span>')
    qr_generated.short_description = 'QR Code'  # type: ignore[attr-defined]
    
    def qr_code_preview(self, obj):
        if obj.qr_code:
            return format_html(
                '<img src="{}" style="width: 200px; height: 200px; border: 1px solid #ddd; padding: 10px; border-radius: 8px;" />',
                obj.qr_code.url
            )
        return "—"
    qr_code_preview.short_description = 'QR Code Preview'  # type: ignore[attr-defined]


# ============================================================================
# CATEGORY & MENU ITEM ADMIN
# ============================================================================

class CategoryAdmin(AdminFilterMixin, admin.ModelAdmin):  # type: ignore[misc]
    list_display = ['category_name', 'restaurant', 'item_count', 'created_at']
    list_filter = ['restaurant', 'created_at']
    search_fields = ['name', 'restaurant__name']
    readonly_fields = ['id', 'created_at']
    inlines = [MenuItemInline]
    ordering = ['-created_at']
    
    fieldsets = (
        ('📂 Category Information', {
            'fields': ('id', 'restaurant', 'name', 'description')
        }),
        ('⏰ Timestamps', {
            'fields': ('created_at',)
        }),
    )
    
    def category_name(self, obj):
        return format_html('<strong>{}</strong>', obj.name)
    category_name.short_description = 'Category'  # type: ignore[attr-defined]
    
    def item_count(self, obj):
        count = obj.menuitems.count()
        return format_html(
            '<span style="background: #d1fae5; color: #065f46; padding: 3px 8px; border-radius: 3px; font-weight: 600;">{} items</span>',
            count
        )
    item_count.short_description = 'Items'  # type: ignore[attr-defined]


class MenuItemAdmin(AdminFilterMixin, admin.ModelAdmin):  # type: ignore[misc]
    list_display = ['item_name', 'restaurant', 'category', 'price_display', 'vegetarian_status', 'availability_status']
    list_filter = ['restaurant', 'category']
    search_fields = ['name', 'restaurant__name', 'category__name']
    readonly_fields = ['id', 'image_preview', 'created_at']
    ordering = ['-created_at']
    
    fieldsets = (
        ('🍽️ Item Information', {
            'fields': ('id', 'restaurant', 'category', 'name', 'description')
        }),
        ('💰 Pricing', {
            'fields': ('price',)
        }),
        ('🖼️ Media', {
            'fields': ('image', 'image_preview')
        }),
        ('🌿 Details', {
            'fields': ('vegetarian', 'spice_level', 'is_available')
        }),
        ('⏰ Timestamps', {
            'fields': ('created_at',)
        }),
    )
    
    def item_name(self, obj):
        return format_html('<strong>{}</strong>', obj.name)
    item_name.short_description = 'Item'  # type: ignore[attr-defined]
    
    def price_display(self, obj):
        return format_html('<strong style="color: #10b981;">${}</strong>', obj.price)
    price_display.short_description = 'Price'  # type: ignore[attr-defined]
    
    def vegetarian_status(self, obj):
        if obj.vegetarian:
            return format_html('<span style="color: #10b981; font-weight: 600;">🌿 Vegetarian</span>')
        else:
            return format_html('<span style="color: #6b7280; font-weight: 600;">🍖 Non-Veg</span>')
    vegetarian_status.short_description = 'Type'  # type: ignore[attr-defined]
    
    def availability_status(self, obj):
        if obj.is_available:
            return format_html('<span style="color: #10b981; font-weight: 600;">✓ Available</span>')
        else:
            return format_html('<span style="color: #ef4444; font-weight: 600;">✗ Unavailable</span>')
    availability_status.short_description = 'Status'  # type: ignore[attr-defined]
    
    def image_preview(self, obj):
        if obj.image:
            return format_html(
                '<img src="{}" style="width: 200px; height: 150px; object-fit: cover; border-radius: 8px;" />',
                obj.image.url
            )
        return "—"
    image_preview.short_description = 'Image Preview'  # type: ignore[attr-defined]


# ============================================================================
# ORDER & BARGAIN ADMIN
# ============================================================================

class OrderBargainInline(admin.TabularInline):
    """Inline bargains for orders"""
    model = OrderBargain
    extra = 0
    fields = ['item_id', 'customer_qty', 'kitchen_qty', 'status']
    max_num = 50


class OrderAdmin(AdminFilterMixin, admin.ModelAdmin):  # type: ignore[misc]
    list_display = ['order_id', 'restaurant', 'table', 'status_badge', 'subtotal_display', 'created_at']
    list_filter = ['restaurant', 'status', 'created_at']
    search_fields = ['id', 'restaurant__name', 'table_number']
    readonly_fields = ['id', 'created_at', 'updated_at']
    inlines = [OrderBargainInline]
    ordering = ['-created_at']
    date_hierarchy = 'created_at'
    
    fieldsets = (
        ('📋 Order Information', {
            'fields': ('id', 'restaurant', 'table_number', 'session_id')
        }),
        ('🍽️ Items & Status', {
            'fields': ('items', 'status')
        }),
        ('💰 Payment', {
            'fields': ('subtotal', 'customer_notes')
        }),
        ('👥 Assignments', {
            'fields': ('assigned_waiter', 'assigned_kitchen_staff')
        }),
        ('⏰ Timestamps', {
            'fields': ('created_at', 'updated_at')
        }),
    )
    
    def order_id(self, obj):
        return format_html('<strong>#{}</strong>', str(obj.id)[:8])
    order_id.short_description = 'Order'  # type: ignore[attr-defined]
    
    def table(self, obj):
        return format_html('<strong>Table {}</strong>', obj.table_number)
    table.short_description = 'Table'  # type: ignore[attr-defined]
    
    def status_badge(self, obj):
        colors = {
            'pending': '#f59e0b',
            'preparing': '#3b82f6',
            'bargain': '#ef4444',
            'ready': '#6366f1',
            'served': '#10b981',
            'cancelled': '#6b7280',
        }
        color = colors.get(obj.status, '#6b7280')
        return format_html(
            '<span style="background: {}; color: white; padding: 4px 8px; border-radius: 3px; font-weight: 600; font-size: 11px;">{}</span>',
            color,
            obj.get_status_display()
        )
    status_badge.short_description = 'Status'  # type: ignore[attr-defined]
    
    def subtotal_display(self, obj):
        return format_html('<strong style="color: #10b981;">${}</strong>', obj.subtotal)
    subtotal_display.short_description = 'Amount'  # type: ignore[attr-defined]


class OrderBargainAdmin(admin.ModelAdmin):
    list_display = ['bargain_id', 'order', 'order_item_id', 'quantities', 'response_badge', 'created_at']
    list_filter = ['action_type', 'customer_response', 'created_at']
    search_fields = ['order__id', 'order_item_id']
    readonly_fields = ['created_at', 'answered_at']
    ordering = ['-created_at']
    
    fieldsets = (
        ('🛒 Bargain Information', {
            'fields': ('order', 'order_item_id', 'action_type')
        }),
        ('📊 Quantities', {
            'fields': ('requested_quantity', 'available_quantity', 'accepted_quantity')
        }),
        ('💬 Messages', {
            'fields': ('staff_message', 'customer_message', 'customer_response')
        }),
        ('⏰ Timestamps', {
            'fields': ('created_at', 'answered_at', 'expires_at')
        }),
    )
    
    def bargain_id(self, obj):
        return format_html('<strong>#{}</strong>', str(obj.id)[:8])
    bargain_id.short_description = 'Bargain'  # type: ignore[attr-defined]
    
    def quantities(self, obj):
        return format_html(
            'Requested: <strong>{}</strong> | Available: <strong>{}</strong>',
            obj.requested_quantity,
            obj.available_quantity
        )
    quantities.short_description = 'Quantities'  # type: ignore[attr-defined]
    
    def response_badge(self, obj):
        colors = {
            'accepted': '#10b981',
            'rejected': '#ef4444',
            'pending': '#f59e0b',
        }
        color = colors.get(obj.customer_response, '#6b7280')
        return format_html(
            '<span style="background: {}; color: white; padding: 5px 10px; border-radius: 4px; font-weight: 600; font-size: 11px;">{}</span>',
            color,
            obj.get_customer_response_display() or 'Unknown'
        )
    response_badge.short_description = 'Response'  # type: ignore[attr-defined]


# ============================================================================
# STAFF INVITE ADMIN
# ============================================================================

class StaffInviteAdmin(AdminFilterMixin, admin.ModelAdmin):  # type: ignore[misc]
    list_display = ['invite_id', 'restaurant', 'email', 'role', 'status_badge', 'created_at']
    list_filter = ['restaurant', 'status', 'role', 'created_at']
    search_fields = ['email', 'restaurant__name']
    readonly_fields = ['id', 'qr_code_preview', 'created_at']
    ordering = ['-created_at']
    
    fieldsets = (
        ('📧 Invite Information', {
            'fields': ('id', 'restaurant', 'email', 'role')
        }),
        ('📋 QR Code', {
            'fields': ('qr_code_image', 'qr_code_preview')
        }),
        ('⚙️ Status', {
            'fields': ('status',)
        }),
        ('⏰ Timestamps', {
            'fields': ('created_at',)
        }),
    )
    
    def invite_id(self, obj):
        return format_html('<strong>#{}</strong>', str(obj.id)[:8])
    invite_id.short_description = 'Invite'  # type: ignore[attr-defined]
    
    def status_badge(self, obj):
        colors = {
            'pending': '#f59e0b',
            'claimed': '#10b981',
            'expired': '#ef4444',
        }
        color = colors.get(obj.status, '#6b7280')
        return format_html(
            '<span style="background: {}; color: white; padding: 4px 8px; border-radius: 3px; font-weight: 600; font-size: 11px;">{}</span>',
            color,
            obj.get_status_display()
        )
    status_badge.short_description = 'Status'  # type: ignore[attr-defined]
    
    def qr_code_preview(self, obj):
        if obj.qr_code_image:
            return format_html(
                '<img src="{}" style="width: 150px; height: 150px; border: 1px solid #ddd; padding: 10px; border-radius: 8px;" />',
                obj.qr_code_image.url
            )
        return "—"
    qr_code_preview.short_description = 'QR Code Preview'  # type: ignore[attr-defined]


# ============================================================================
# ANALYTICS ADMIN
# ============================================================================

from analytics.models import DailyAnalytics, HourlyAnalytics, TopItem

class DailyAnalyticsAdmin(AdminFilterMixin, admin.ModelAdmin):  # type: ignore[misc]
    list_display = ['restaurant', 'date', 'total_orders_display', 'total_revenue_display', 'bargain_rate_display']
    list_filter = ['restaurant', 'date']
    search_fields = ['restaurant__name']
    readonly_fields = ['created_at', 'updated_at', 'bargain_success_rate']
    ordering = ['-date', 'restaurant']
    date_hierarchy = 'date'
    
    fieldsets = (
        ('🏪 Restaurant & Date', {
            'fields': ('restaurant', 'date')
        }),
        ('📊 Order Metrics', {
            'fields': ('total_orders', 'total_revenue', 'pending_orders', 'preparing_orders', 'ready_orders', 'served_orders', 'cancelled_orders')
        }),
        ('⏱️ Performance Metrics', {
            'fields': ('avg_prep_time_seconds', 'min_prep_time_seconds', 'max_prep_time_seconds', 'avg_serve_time_seconds')
        }),
        ('🪑 Table Metrics', {
            'fields': ('tables_turnover', 'unique_tables_served')
        }),
        ('🛒 Bargain Metrics', {
            'fields': ('bargain_orders_count', 'bargain_success_rate')
        }),
        ('📈 Peak Hours', {
            'fields': ('peak_hour', 'peak_hour_orders')
        }),
        ('👥 Staff', {
            'fields': ('active_kitchen_staff', 'active_waiters')
        }),
        ('⏰ Timestamps', {
            'fields': ('created_at', 'updated_at')
        }),
    )
    
    def total_orders_display(self, obj):
        return format_html('<strong style="color: #3b82f6;">{}</strong>', obj.total_orders)
    total_orders_display.short_description = 'Orders'  # type: ignore[attr-defined]
    
    def total_revenue_display(self, obj):
        return format_html('<strong style="color: #10b981;">${}</strong>', obj.total_revenue)
    total_revenue_display.short_description = 'Revenue'  # type: ignore[attr-defined]
    
    def bargain_rate_display(self, obj):
        rate = obj.bargain_success_rate or 0
        return format_html(
            '<span style="color: {}; font-weight: 600;">{}%</span>',
            '#10b981' if rate >= 70 else '#f59e0b' if rate >= 50 else '#ef4444',
            f'{rate:.1f}'
        )
    bargain_rate_display.short_description = 'Bargain Success'  # type: ignore[attr-defined]


class HourlyAnalyticsAdmin(AdminFilterMixin, admin.ModelAdmin):  # type: ignore[misc]
    list_display = ['restaurant', 'date', 'hour_display', 'total_orders_display', 'total_revenue_display']
    list_filter = ['restaurant', 'date', 'hour']
    search_fields = ['restaurant__name']
    readonly_fields = ['created_at', 'updated_at']
    ordering = ['-date', '-hour', 'restaurant']
    
    fieldsets = (
        ('🏪 Restaurant & Time', {
            'fields': ('restaurant', 'date', 'hour')
        }),
        ('📊 Metrics', {
            'fields': ('total_orders', 'total_revenue', 'avg_prep_time_seconds')
        }),
        ('⏰ Timestamps', {
            'fields': ('created_at', 'updated_at')
        }),
    )
    
    def hour_display(self, obj):
        return format_html('<strong>{:02d}:00</strong>', obj.hour)
    hour_display.short_description = 'Hour'  # type: ignore[attr-defined]
    
    def total_orders_display(self, obj):
        return format_html('<strong style="color: #3b82f6;">{}</strong>', obj.total_orders)
    total_orders_display.short_description = 'Orders'  # type: ignore[attr-defined]
    
    def total_revenue_display(self, obj):
        return format_html('<strong style="color: #10b981;">${}</strong>', obj.total_revenue or 0)
    total_revenue_display.short_description = 'Revenue'  # type: ignore[attr-defined]


class TopItemAdmin(AdminFilterMixin, admin.ModelAdmin):  # type: ignore[misc]
    list_display = ['rank_display', 'item_name', 'restaurant', 'date', 'quantity_display', 'revenue_display']
    list_filter = ['restaurant', 'date', 'rank']
    search_fields = ['item_name', 'restaurant__name']
    readonly_fields = ['created_at']
    ordering = ['date', 'restaurant', 'rank']
    date_hierarchy = 'date'
    
    fieldsets = (
        ('🏪 Restaurant & Item', {
            'fields': ('restaurant', 'item_name', 'date')
        }),
        ('🏆 Ranking & Metrics', {
            'fields': ('rank', 'total_quantity', 'total_revenue')
        }),
        ('⏰ Timestamps', {
            'fields': ('created_at',)
        }),
    )
    
    def rank_display(self, obj):
        medals = {1: '🥇', 2: '🥈', 3: '🥉'}
        medal = medals.get(obj.rank, '  ')
        return format_html('<strong>{} #{}</strong>', medal, obj.rank)
    rank_display.short_description = 'Rank'  # type: ignore[attr-defined]
    
    def quantity_display(self, obj):
        return format_html('<strong style="color: #3b82f6;">{}</strong>', obj.total_quantity)
    quantity_display.short_description = 'Qty'  # type: ignore[attr-defined]
    
    def revenue_display(self, obj):
        return format_html('<strong style="color: #10b981;">${}</strong>', obj.total_revenue or 0)
    revenue_display.short_description = 'Revenue'  # type: ignore[attr-defined]


# ============================================================================
# ADMIN SITE REGISTRATION
# ============================================================================

# Note: Admin model registrations are handled in apps.py to ensure
# the restaurant-centric admin classes are used properly.
# See CoreConfig.ready() method in core/apps.py

class WebsiteDataAdmin(admin.ModelAdmin):
    """Admin interface for website data management - organized by public menu sections"""
    list_display = ('restaurant', 'is_active', 'updated_at')
    list_filter = ('is_active', 'updated_at')
    search_fields = ('restaurant__name',)
    readonly_fields = ('id', 'created_at', 'updated_at')

    fieldsets = (
        ('🏪 Restaurant Link', {
            'fields': ('restaurant',),
            'description': 'This links to the restaurant whose data is displayed on the public menu.'
        }),
        ('🌐 Website Status', {
            'fields': ('is_active',),
            'description': 'Enable/disable this restaurant\'s public website.'
        }),
        ('🎨 Branding (Optional)', {
            'fields': ('logo', 'favicon', 'primary_color', 'secondary_color'),
            'classes': ('collapse',),
            'description': 'Optional branding elements for the website.'
        }),
        ('📱 Social Media Links', {
            'fields': ('facebook_url', 'instagram_url', 'twitter_url', 'whatsapp_number'),
            'description': 'Social media links displayed in the footer.'
        }),
        ('📞 Contact Override (Optional)', {
            'fields': ('contact_email', 'contact_phone', 'contact_whatsapp'),
            'classes': ('collapse',),
            'description': 'Override restaurant contact info. Leave blank to use restaurant data.'
        }),
        ('🔧 Website Features', {
            'fields': ('show_menu_online', 'show_reservations_online'),
            'description': 'Control what features are available on the public website.'
        }),
        ('📝 Footer Text', {
            'fields': ('footer_text',),
            'classes': ('collapse',),
            'description': 'Custom footer text. Auto-generated from restaurant name if empty.'
        }),
        ('⏰ Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )

    def has_add_permission(self, request):
        """Prevent manual addition - auto-created with restaurant"""
        return False


# Register models with default admin site
admin.site.register(User, UserAdmin)
admin.site.register(WebsiteData, WebsiteDataAdmin)

