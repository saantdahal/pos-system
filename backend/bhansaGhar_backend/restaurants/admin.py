from django.contrib import admin
from .models import Restaurant, RestaurantType, Category, MenuItem, Table, StaffInvite, RestaurantGallery
from customer.models import SocialMediaLink, Testimonial
from django.db.models import Q
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from core.models import User

class TableInline(admin.TabularInline):
    model = Table
    extra = 0
    fields = ['number', 'capacity', 'status', 'is_active', 'created_at']
    readonly_fields = ['created_at']
    ordering = ['number']
    show_change_link = True

class RestaurantGalleryInline(admin.TabularInline):
    model = RestaurantGallery
    extra = 1
    fields = ['image', 'title', 'description', 'position', 'is_active']
    ordering = ['position']

class SocialMediaLinkInline(admin.TabularInline):
    """Inline editor for social media links within Restaurant admin"""
    model = SocialMediaLink
    extra = 1
    fields = ('platform', 'icon', 'url', 'order', 'is_active')
    ordering = ('order',)

    def get_queryset(self, request):
        """Only show social links for the current restaurant"""
        qs = super().get_queryset(request)
        # Get the restaurant ID from the URL
        if hasattr(request, 'resolver_match') and 'object_id' in request.resolver_match.kwargs:
            restaurant_id = request.resolver_match.kwargs['object_id']
            return qs.filter(restaurant_id=restaurant_id)
        return qs.none()  # Don't show any if we can't determine the restaurant

    def save_new(self, obj, parent):
        """Ensure the social link is associated with the correct restaurant"""
        obj.restaurant = parent
        obj.landing_page = None  # Make sure it's not associated with landing page
        super().save_new(obj, parent)

class TestimonialInline(admin.TabularInline):
    """Inline editor for testimonials within Restaurant admin"""
    model = Testimonial
    extra = 1
    fields = ('author_name', 'rating', 'text', 'order', 'is_active')
    ordering = ('order',)

    def get_queryset(self, request):
        """Only show testimonials for the current restaurant"""
        qs = super().get_queryset(request)
        # Get the restaurant ID from the URL
        if hasattr(request, 'resolver_match') and 'object_id' in request.resolver_match.kwargs:
            restaurant_id = request.resolver_match.kwargs['object_id']
            return qs.filter(restaurant_id=restaurant_id)
        return qs.none()  # Don't show any if we can't determine the restaurant

    def save_new(self, obj, parent):
        """Ensure the testimonial is associated with the correct restaurant"""
        obj.restaurant = parent
        super().save_new(obj, parent)

@admin.register(RestaurantType)
class RestaurantTypeAdmin(admin.ModelAdmin):
    list_display = ['name', 'display_name', 'is_active', 'created_at']
    list_filter = ['is_active']
    search_fields = ['name', 'display_name']

@admin.register(Restaurant)
class RestaurantAdmin(admin.ModelAdmin):
    list_display = ['name', 'owner', 'type', 'phone', 'tables_count', 'is_active', 'created_at']
    list_filter = ['type', 'is_active', 'created_at']
    search_fields = ['name', 'owner__username', 'phone']
    readonly_fields = ['id', 'created_at']
    inlines = [RestaurantGalleryInline, TableInline, TestimonialInline, SocialMediaLinkInline]
    fieldsets = (
        ('🏪 Basic Information', {
            'fields': ('name', 'owner', 'type')
        }),
        ('🎯 Hero Section', {
            'fields': ('description', 'hero_image'),
            'description': 'Content displayed in the hero/banner section of the public menu.'
        }),
        ('ℹ️ About Section', {
            'fields': ('about',),
            'description': 'About text displayed below the hero section.'
        }),
        ('📍 Location Section', {
            'fields': ('address', 'latitude', 'longitude'),
            'description': 'Address and coordinates for the location/map section.'
        }),
        ('📞 Contact Information', {
            'fields': ('phone',),
            'description': 'Phone number displayed in hero, location, and footer sections.'
        }),
        ('🕐 Operating Hours', {
            'fields': ('operating_hours',),
            'description': 'Hours displayed in the schedule section.'
        }),
        ('🪑 Capacity', {
            'fields': ('tables_capacity',),
            'description': 'Total table capacity (displayed as stats in about section).'
        }),
        ('✅ Status', {
            'fields': ('is_active',),
            'description': 'Enable/disable this restaurant.'
        }),
    )

    def tables_count(self, obj):
        """Display the number of tables for this restaurant"""
        return obj.tables.count()
    tables_count.short_description = 'Tables' # type: ignore

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'restaurant', 'position', 'created_at']
    list_filter = ['restaurant', 'created_at']
    search_fields = ['name', 'restaurant__name']
    ordering = ['restaurant', 'position']
    list_editable = ['position']
    readonly_fields = ['id', 'created_at']

    def get_queryset(self, request):
        qs = super().get_queryset(request)
        if request.user.is_superuser:
            return qs
        # For restaurant owners, only show their categories
        try:
            if request.user.is_authenticated:
                owned_restaurant = request.user.get_owned_restaurant()
                if owned_restaurant:
                    return qs.filter(restaurant=owned_restaurant)
        except AttributeError:
            pass
        return qs.none()

    def formfield_for_foreignkey(self, db_field, request, **kwargs):
        if db_field.name == "restaurant":
            if not request.user.is_superuser and request.user.is_authenticated:
                try:
                    owned_restaurant = request.user.get_owned_restaurant()
                    if owned_restaurant:
                        # Restaurant owners can only assign to their own restaurant
                        kwargs["queryset"] = Restaurant.objects.filter(owner=request.user)
                except AttributeError:
                    pass
        return super().formfield_for_foreignkey(db_field, request, **kwargs)

@admin.register(MenuItem)
class MenuItemAdmin(admin.ModelAdmin):
    list_display = ['name', 'category', 'restaurant', 'base_price', 'discount_percentage', 'current_price_display', 'stock_quantity', 'is_available_display']
    list_filter = ['category__restaurant']
    search_fields = ['name', 'category__name', 'category__restaurant__name']

    def restaurant(self, obj):
        return obj.category.restaurant.name
    restaurant.short_description = 'Restaurant' # type: ignore

    def current_price_display(self, obj):
        return obj.current_price
    current_price_display.short_description = 'Current Price' # type: ignore

    def is_available_display(self, obj):
        return obj.is_available
    is_available_display.short_description = 'Available' # type: ignore
    is_available_display.boolean = True # type: ignore


@admin.register(Table)
class TableAdmin(admin.ModelAdmin):
    list_display = ['number', 'restaurant', 'status', 'capacity', 'is_active', 'qr_code_url_display', 'created_at']
    list_filter = ['restaurant', 'status', 'is_active', 'created_at']
    search_fields = ['number', 'restaurant__name']
    readonly_fields = ['id', 'qr_code_image', 'qr_url', 'qr_code_url', 'created_at', 'updated_at']
    ordering = ['restaurant', 'number']
    
    fieldsets = (
        ('Basic Information', {
            'fields': ('restaurant', 'number', 'capacity', 'status', 'is_active')
        }),
        ('QR Code Information', {
            'fields': ('qr_code_image', 'qr_url', 'qr_code_url'),
            'classes': ('collapse',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )

    def get_queryset(self, request):
        qs = super().get_queryset(request)
        if request.user.is_superuser:
            return qs
        # For restaurant owners, only show their tables
        try:
            if request.user.is_authenticated:
                owned_restaurant = request.user.get_owned_restaurant()
                if owned_restaurant:
                    return qs.filter(restaurant=owned_restaurant)
        except AttributeError:
            pass
        return qs.none()

    def qr_code_url_display(self, obj):
        """Display QR code URL as a clickable link"""
        if obj.qr_code_url:
            return f'<a href="{obj.qr_code_url}" target="_blank">View QR Code</a>'
        return 'No QR Code'
    qr_code_url_display.short_description = 'QR Code' # type: ignore
    qr_code_url_display.allow_tags = True # type: ignore

    def formfield_for_foreignkey(self, db_field, request, **kwargs):
        if db_field.name == "restaurant":
            if not request.user.is_superuser and request.user.is_authenticated:
                try:
                    owned_restaurant = request.user.get_owned_restaurant()
                    if owned_restaurant:
                        # Restaurant owners can only assign to their own restaurant
                        kwargs["queryset"] = Restaurant.objects.filter(owner=request.user)
                except AttributeError:
                    pass
        return super().formfield_for_foreignkey(db_field, request, **kwargs)


@admin.register(StaffInvite)
class StaffInviteAdmin(admin.ModelAdmin):
    list_display = ['email', 'role', 'restaurant', 'status', 'is_claimed', 'created_at', 'expires_at']
    list_filter = ['role', 'status', 'is_claimed', 'created_at']
    search_fields = ['email', 'restaurant__name']
    readonly_fields = ['id', 'qr_code_image', 'qr_url', 'is_claimed', 'claimed_by', 'claimed_at', 'created_at']
    fieldsets = (
        ('Invitation Details', {
            'fields': ('restaurant', 'email', 'role')
        }),
        ('QR Code', {
            'fields': ('qr_code_image', 'qr_url')
        }),
        ('Status', {
            'fields': ('status', 'is_claimed', 'claimed_by', 'claimed_at', 'expires_at')
        }),
        ('Metadata', {
            'fields': ('id', 'created_at')
        }),
    )
    
    def get_queryset(self, request):
        """Filter invites by restaurant owner"""
        qs = super().get_queryset(request)
        if request.user.is_superuser:
            return qs
        # Only show invites for the user's restaurant
        try:
            owned_restaurant = request.user.get_owned_restaurant()
            if owned_restaurant:
                return qs.filter(restaurant=owned_restaurant)
        except AttributeError:
            pass
        return qs.none()


@admin.register(RestaurantGallery)
class RestaurantGalleryAdmin(admin.ModelAdmin):
    list_display = ['restaurant', 'title', 'position', 'is_active', 'created_at']
    list_filter = ['restaurant', 'is_active', 'created_at']
    search_fields = ['restaurant__name', 'title', 'description']
    readonly_fields = ['id', 'created_at']
    fields = ['restaurant', 'image', 'title', 'description', 'position', 'is_active', 'created_at']
    ordering = ['restaurant', 'position']
    
    def get_queryset(self, request):
        """Filter gallery by restaurant owner"""
        qs = super().get_queryset(request)
        if request.user.is_superuser:
            return qs
        try:
            owned_restaurant = request.user.get_owned_restaurant()
            if owned_restaurant:
                return qs.filter(restaurant=owned_restaurant)
        except AttributeError:
            pass
        return qs.none()
