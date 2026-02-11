from django.contrib import admin
from django import forms
from django.forms import Textarea
from django.db import models
from .models import (
    LandingPage, ContentPage, FooterLink, SocialMediaPlatform, 
    SocialMediaLink, AppCard, Testimonial
)


class SocialMediaPlatformAdmin(admin.ModelAdmin):
    """Admin for managing default social media platforms"""
    list_display = ('name', 'platform_key', 'icon_display', 'position', 'is_active')
    list_editable = ('position', 'is_active')
    fieldsets = (
        ('Platform Information', {
            'fields': ('name', 'platform_key')
        }),
        ('Icon', {
            'fields': ('icon',)
        }),
        ('URL Configuration', {
            'fields': ('url_placeholder',)
        }),
        ('Status & Order', {
            'fields': ('is_active', 'position')
        }),
        ('Metadata', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    readonly_fields = ('created_at', 'updated_at')
    search_fields = ('name', 'platform_key')
    ordering = ('position',)

    def icon_display(self, obj):
        """Display icon in list view"""
        if obj.icon.startswith('<svg') or obj.icon.startswith('http'):
            # For SVG or URL links, show as truncated text
            display_text = obj.icon[:50] + '...' if len(obj.icon) > 50 else obj.icon
            return f'<span title="{obj.icon}">{display_text}</span>'
        else:
            # For emojis, display as emoji
            return f'<div style="font-size: 24px;">{obj.icon}</div>'
    icon_display.short_description = 'Icon'
    icon_display.allow_tags = True

    def get_queryset(self, request):
        """Only superusers can manage platforms"""
        qs = super().get_queryset(request)
        if not request.user.is_superuser:
            qs = qs.none()
        return qs

    def get_readonly_fields(self, request, obj=None):
        """Lock platform_key after creation for non-superusers"""
        readonly = list(super().get_readonly_fields(request, obj))
        if obj and not request.user.is_superuser:
            readonly.extend(['platform_key'])
        return readonly


class SocialMediaLinkAdmin(admin.ModelAdmin):
    """Admin for managing social media links"""
    list_display = ('platform', 'restaurant', 'landing_page', 'url', 'order', 'is_active')
    list_filter = ('platform', 'is_active', 'restaurant')
    search_fields = ('url', 'restaurant__name', 'landing_page__brand_name')
    ordering = ('order', 'platform')

    def get_readonly_fields(self, request, obj=None):
        """Lock platform field after link creation"""
        readonly = []
        if obj:  # Editing existing object
            readonly = ['platform']
        return readonly

    def get_queryset(self, request):
        """Filter social links based on user permissions"""
        qs = super().get_queryset(request)
        if not request.user.is_superuser:
            # Regular users/admins can only see their own restaurant's links
            if hasattr(request.user, 'restaurant'):
                qs = qs.filter(restaurant=request.user.restaurant)
        return qs


class LandingPageAdmin(admin.ModelAdmin):
    """Admin for managing landing page content - Super Admin Only"""
    list_display = ('brand_name', 'updated_at')
    fieldsets = (
        ('Brand', {
            'fields': ('brand_name', 'logo', 'navbar_logo_image')
        }),
        ('Hero Section', {
            'fields': ('hero_title', 'hero_subtitle', 'hero_image', 'hero_cta_text', 'hero_cta_link'),
            'description': 'Upload high-quality images for the hero section background'
        }),
        ('Stats', {
            'fields': (
                ('stat_2_label', 'stat_2_value'),
                ('stat_3_label', 'stat_3_value'),
                ('stat_4_label', 'stat_4_value'),
            )
        }),
        ('Info Banner', {
            'fields': ('info_banner_icon', 'info_banner_image', 'info_banner_text'),
            'description': 'Optional: Upload a background image for the info banner'
        }),
        ('Features', {
            'fields': (
                'features_subtitle',
                ('feature_1_icon', 'feature_1_icon_image', 'feature_1_title', 'feature_1_description'),
                ('feature_2_icon', 'feature_2_icon_image', 'feature_2_title', 'feature_2_description'),
                ('feature_3_icon', 'feature_3_icon_image', 'feature_3_title', 'feature_3_description'),
            ),
            'description': 'You can use either emoji icons or upload icon images. Images take precedence over emojis.'
        }),
        ('About', {
            'fields': ('about_title', 'about_description', 'about_description_2', 'about_image')
        }),
        ('Highlights', {
            'fields': ('highlight_1', 'highlight_2', 'highlight_3', 'highlight_4')
        }),
        ('CTA', {
            'fields': ('cta_title', 'cta_description', 'cta_button_text')
        }),
        ('Footer', {
            'fields': (
                'footer_tagline',
                'footer_text',
                ('footer_section_company_title', 'footer_section_for_restaurants_title'),
                ('footer_section_legal_title', 'footer_section_quick_links_title'),
                'footer_section_support_title',
            )
        }),
        ('Settings', {
            'fields': ('is_active',)
        }),
    )
    readonly_fields = ('created_at', 'updated_at')
    search_fields = ('brand_name',)

    def get_queryset(self, request):
        """Only superusers can access landing page"""
        qs = super().get_queryset(request)
        if not request.user.is_superuser:
            qs = qs.none()
        return qs

    def has_add_permission(self, request):
        """Only superusers can add - and only if doesn't exist"""
        if not request.user.is_superuser:
            return False
        # Only allow adding if no instance exists
        from .models import LandingPage
        return not LandingPage.objects.exists()

    def has_delete_permission(self, request, obj=None):
        """Only superusers can delete"""
        return request.user.is_superuser

    def has_change_permission(self, request, obj=None):
        """Only superusers can change"""
        return request.user.is_superuser


class ContentPageAdmin(admin.ModelAdmin):
    """Admin for managing content pages"""
    list_display = ('title', 'slug', 'is_active', 'updated_at')
    list_filter = ('is_active', 'created_at')
    search_fields = ('title', 'slug', 'content')
    prepopulated_fields = {'slug': ('title',)}
    fieldsets = (
        ('Content', {
            'fields': ('title', 'slug', 'content')
        }),
        ('Settings', {
            'fields': ('is_active',)
        }),
        ('Metadata', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    readonly_fields = ('created_at', 'updated_at')


class FooterLinkAdmin(admin.ModelAdmin):
    """Admin for managing footer links"""
    list_display = ('title', 'section', 'order', 'is_active')
    list_filter = ('section', 'is_active')
    search_fields = ('title', 'url')
    list_editable = ('order', 'is_active')
    fieldsets = (
        ('Link Info', {
            'fields': ('section', 'title', 'url')
        }),
        ('Settings', {
            'fields': ('order', 'is_active')
        }),
        ('Metadata', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    readonly_fields = ('created_at', 'updated_at')
    ordering = ('section', 'order')


class AppCardAdmin(admin.ModelAdmin):
    """Admin for managing app cards - Super Admin Only"""
    list_display = ('title', 'get_icon_display', 'order', 'is_active')
    list_editable = ('order', 'is_active')
    list_filter = ('is_active',)
    search_fields = ('title', 'description')
    fieldsets = (
        ('App Info', {
            'fields': ('icon', 'icon_svg', 'icon_image', 'title', 'description')
        }),
        ('Links', {
            'fields': ('ios_link', 'android_link')
        }),
        ('Settings', {
            'fields': ('order', 'is_active')
        }),
        ('Metadata', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    readonly_fields = ('created_at', 'updated_at')
    ordering = ('order',)
    
    # Use Textarea widget for icon_svg field to allow pasting full SVG code
    formfield_overrides = {
        models.TextField: {'widget': Textarea(attrs={'rows': 10, 'cols': 80})}
    }

    def get_icon_display(self, obj):
        """Display icon type in list view"""
        if obj.icon_image:
            return '🖼️ Image'
        elif obj.icon_svg:
            return '✏️ SVG'
        else:
            return f'{obj.icon} Emoji'
    get_icon_display.short_description = 'Icon Type'

    def get_queryset(self, request):
        """Only superusers can access app cards"""
        qs = super().get_queryset(request)
        if not request.user.is_superuser:
            qs = qs.none()
        return qs

    def has_change_permission(self, request, obj=None):
        """Only superusers can change"""
        return request.user.is_superuser


class TestimonialAdmin(admin.ModelAdmin):
    """Admin for managing testimonials"""
    list_display = ('author_name', 'restaurant', 'get_rating_stars', 'order', 'is_active')
    list_filter = ('restaurant', 'rating', 'is_active', 'created_at')
    search_fields = ('author_name', 'text', 'restaurant__name')
    list_editable = ('order', 'is_active')
    fieldsets = (
        ('Testimonial', {
            'fields': ('restaurant', 'author_name', 'rating', 'text')
        }),
        ('Settings', {
            'fields': ('order', 'is_active')
        }),
        ('Metadata', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    readonly_fields = ('created_at', 'updated_at')
    ordering = ('restaurant', 'order')

    def get_rating_stars(self, obj):
        """Display rating as stars"""
        return '⭐' * obj.rating
    get_rating_stars.short_description = 'Rating'


# Register models
admin.site.register(LandingPage, LandingPageAdmin)
admin.site.register(ContentPage, ContentPageAdmin)
admin.site.register(FooterLink, FooterLinkAdmin)
admin.site.register(SocialMediaPlatform, SocialMediaPlatformAdmin)
admin.site.register(SocialMediaLink, SocialMediaLinkAdmin)
admin.site.register(AppCard, AppCardAdmin)
admin.site.register(Testimonial, TestimonialAdmin)
