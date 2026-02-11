"""
Restaurant-related admin configurations
"""
from django.contrib import admin
from django.utils.html import format_html

from restaurants.models import Restaurant, Table, Category, MenuItem, RestaurantType
from .mixins import AdminFilterMixin
from .inlines import TableInline, StaffInline, CategoryInline, MenuItemInline


class RestaurantAdmin(AdminFilterMixin, admin.ModelAdmin):  # type: ignore[misc]
    list_display = ['restaurant_name', 'owner_name', 'type', 'active_status', 'staff_count', 'tables_capacity', 'created_at']
    list_filter = ['is_active', 'type', 'created_at']
    search_fields = ['name', 'owner__username', 'address']
    readonly_fields = ['id', 'created_at']
    ordering = ['-created_at']
    inlines = [CategoryInline, TableInline, StaffInline]
    
    fieldsets = (
        ('🏪 Restaurant Information', {'fields': ('id', 'name', 'owner', 'type', 'phone')}),
        ('📍 Location', {'fields': ('address', 'latitude', 'longitude')}),
        ('📊 Details', {'fields': ('description', 'tables_capacity', 'operating_hours')}),
        ('⚙️ Status', {'fields': ('is_active',)}),
        ('⏰ Timestamps', {'fields': ('created_at',)}),
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
        return format_html('<span style="color: #ef4444; font-weight: 600;">✗ Inactive</span>')
    active_status.short_description = 'Status'  # type: ignore[attr-defined]
    
    def staff_count(self, obj):
        count = obj.staff.count()  # type: ignore[attr-defined]
        return format_html('<span style="background: #dbeafe; color: #0c4a6e; padding: 3px 8px; border-radius: 3px; font-weight: 600;">{}</span>', count)
    staff_count.short_description = 'Staff'  # type: ignore[attr-defined]


class RestaurantTypeAdmin(admin.ModelAdmin):
    list_display = ['display_name', 'is_active']
    list_filter = ['is_active']
    search_fields = ['name', 'display_name']


class TableAdmin(AdminFilterMixin, admin.ModelAdmin):  # type: ignore[misc]
    list_display = ['table_number', 'restaurant', 'capacity', 'availability_status', 'qr_generated']
    list_filter = ['restaurant']
    search_fields = ['number', 'restaurant__name']
    readonly_fields = ['id', 'qr_code_preview', 'created_at']
    ordering = ['restaurant', 'number']
    
    fieldsets = (
        ('🪑 Table Information', {'fields': ('id', 'restaurant', 'number', 'capacity')}),
        ('📋 QR Code', {'fields': ('qr_code', 'qr_code_preview')}),
        ('⚙️ Status', {'fields': ('is_available',)}),
        ('⏰ Timestamps', {'fields': ('created_at',)}),
    )
    
    def table_number(self, obj):
        return format_html('<strong>Table {}</strong>', obj.number)
    table_number.short_description = 'Table'  # type: ignore[attr-defined]
    
    def availability_status(self, obj):
        if obj.is_available:
            return format_html('<span style="color: #10b981; font-weight: 600;">✓ Available</span>')
        return format_html('<span style="color: #f59e0b; font-weight: 600;">◉ Occupied</span>')
    availability_status.short_description = 'Status'  # type: ignore[attr-defined]
    
    def qr_generated(self, obj):
        if obj.qr_code:
            return format_html('<span style="color: #10b981; font-weight: 600;">✓ Generated</span>')
        return format_html('<span style="color: #ef4444; font-weight: 600;">✗ Pending</span>')
    qr_generated.short_description = 'QR Code'  # type: ignore[attr-defined]
    
    def qr_code_preview(self, obj):
        if obj.qr_code:
            return format_html('<img src="{}" style="width: 200px; height: 200px; border: 1px solid #ddd; padding: 10px; border-radius: 8px;" />', obj.qr_code.url)
        return "—"
    qr_code_preview.short_description = 'QR Code Preview'  # type: ignore[attr-defined]


class CategoryAdmin(AdminFilterMixin, admin.ModelAdmin):  # type: ignore[misc]
    list_display = ['category_name', 'restaurant', 'item_count', 'created_at']
    list_filter = ['restaurant', 'created_at']
    search_fields = ['name', 'restaurant__name']
    readonly_fields = ['id', 'created_at']
    inlines = [MenuItemInline]
    ordering = ['-created_at']
    
    fieldsets = (
        ('📂 Category Information', {'fields': ('id', 'restaurant', 'name', 'description')}),
        ('⏰ Timestamps', {'fields': ('created_at',)}),
    )
    
    def category_name(self, obj):
        return format_html('<strong>{}</strong>', obj.name)
    category_name.short_description = 'Category'  # type: ignore[attr-defined]
    
    def item_count(self, obj):
        count = obj.menuitems.count()
        return format_html('<span style="background: #d1fae5; color: #065f46; padding: 3px 8px; border-radius: 3px; font-weight: 600;">{} items</span>', count)
    item_count.short_description = 'Items'  # type: ignore[attr-defined]


class MenuItemAdmin(AdminFilterMixin, admin.ModelAdmin):  # type: ignore[misc]
    list_display = ['item_name', 'restaurant', 'category', 'price_display', 'stock_display', 'availability_status']
    list_filter = ['restaurant', 'category']
    search_fields = ['name', 'restaurant__name', 'category__name']
    readonly_fields = ['id', 'image_preview', 'created_at']
    ordering = ['-created_at']
    
    fieldsets = (
        ('🍽️ Item Information', {'fields': ('id', 'restaurant', 'category', 'name', 'description')}),
        ('💰 Pricing', {'fields': ('base_price', 'discount_percentage')}),
        ('📦 Stock', {'fields': ('stock_quantity',)}),
        ('🖼️ Media', {'fields': ('image', 'image_preview')}),
        ('📊 Position', {'fields': ('position',)}),
        ('⏰ Timestamps', {'fields': ('created_at',)}),
    )
    
    def item_name(self, obj):
        return format_html('<strong>{}</strong>', obj.name)
    item_name.short_description = 'Item'  # type: ignore[attr-defined]
    
    def price_display(self, obj):
        current_price = obj.current_price
        if obj.has_offer:
            return format_html(
                '<span style="color: #ef4444; text-decoration: line-through;">${:.2f}</span> '
                '<strong style="color: #10b981;">${:.2f}</strong>',
                obj.base_price, current_price
            )
        return format_html('<strong style="color: #10b981;">${:.2f}</strong>', current_price)
    price_display.short_description = 'Price'  # type: ignore[attr-defined]
    
    def stock_display(self, obj):
        if obj.stock_quantity is None:
            return format_html('<span style="color: #10b981; font-weight: 600;">∞ Unlimited</span>')
        elif obj.stock_quantity == 0:
            return format_html('<span style="color: #ef4444; font-weight: 600;">⚠ Out of Stock</span>')
        else:
            return format_html('<span style="color: #3b82f6; font-weight: 600;">{} items</span>', obj.stock_quantity)
    stock_display.short_description = 'Stock'  # type: ignore[attr-defined]
    
    def availability_status(self, obj):
        if obj.is_available:
            return format_html('<span style="color: #10b981; font-weight: 600;">✓ Available</span>')
        return format_html('<span style="color: #ef4444; font-weight: 600;">✗ Unavailable</span>')
    availability_status.short_description = 'Status'  # type: ignore[attr-defined]
    
    def image_preview(self, obj):
        if obj.image:
            return format_html('<img src="{}" style="width: 200px; height: 150px; object-fit: cover; border-radius: 8px;" />', obj.image.url)
        return "—"
    image_preview.short_description = 'Image Preview'  # type: ignore[attr-defined]
