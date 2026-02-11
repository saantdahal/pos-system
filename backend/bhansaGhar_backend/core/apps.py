from django.apps import AppConfig


class CoreConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'core'
    
    def ready(self) -> None:
        """Register signals and show startup messages when app is ready"""
        import core.signals  # noqa: F401
        
        # Register admin models (safe - done after Django is ready)
        try:
            self._register_admin_models()
        except Exception as e:
            # If admin registration fails, log but don't crash
            import logging
            logger = logging.getLogger(__name__)
            logger.warning(f"Admin registration skipped: {e}")
        
        # Only print once on startup and only when running the server
        import os
        
        # RUN_MAIN is set by Django's autoreloader for the main process
        if os.environ.get('RUN_MAIN') == 'true':
            # We use a small delay or just print directly
            # This will show up in the terminal when runserver starts
            from core.signals import _generate_collection_safe
            _generate_collection_safe()
    
    def _register_admin_models(self) -> None:
        """Register all admin models with the custom admin site"""
        from core.models import User
        from restaurants.models import Restaurant, RestaurantType, Table, Category, MenuItem, StaffInvite
        from orders.models import Order, OrderBargain
        from analytics.models import DailyAnalytics, HourlyAnalytics, TopItem
        from core.activities.activity_models import ActivityLog

        from core.admin.admin_site import admin_site
        from core.admin import (
            ActivityLogAdmin,
            RestaurantCentricRestaurantAdmin, RestaurantTypeAdmin, RestaurantCentricTableAdmin, 
            RestaurantCentricCategoryAdmin, RestaurantCentricMenuItemAdmin,
            RestaurantCentricOrderAdmin, RestaurantCentricOrderBargainAdmin,
            DailyAnalyticsAdmin, HourlyAnalyticsAdmin, TopItemAdmin,
            RestaurantCentricStaffInviteAdmin,
            UserAdmin,
        )

        
        # Unregister from default admin if already registered
        try:
            from django.contrib import admin
            admin.site.unregister(User)
        except Exception:
            pass
        
        # Register with both admin sites
        from django.contrib import admin
        admin.site.register(User, UserAdmin)  # Register with default admin site for /admin/core/user/
        admin_site.register(User, UserAdmin)  # Register with custom admin site
        admin_site.register(ActivityLog, ActivityLogAdmin)
        admin_site.register(Restaurant, RestaurantCentricRestaurantAdmin)
        admin_site.register(RestaurantType, RestaurantTypeAdmin)
        admin_site.register(Table, RestaurantCentricTableAdmin)
        admin_site.register(Category, RestaurantCentricCategoryAdmin)
        admin_site.register(MenuItem, RestaurantCentricMenuItemAdmin)
        admin_site.register(StaffInvite, RestaurantCentricStaffInviteAdmin)
        admin_site.register(Order, RestaurantCentricOrderAdmin)
        admin_site.register(OrderBargain, RestaurantCentricOrderBargainAdmin)
        admin_site.register(DailyAnalytics, DailyAnalyticsAdmin)
        admin_site.register(HourlyAnalytics, HourlyAnalyticsAdmin)
        admin_site.register(TopItem, TopItemAdmin)

        
        # Register WebsiteData with custom admin site
        from django.contrib import admin
        from .models import WebsiteData
        
        class WebsiteDataAdmin(admin.ModelAdmin):
            """Admin interface for website data management"""
            list_display = ('restaurant', 'website_title', 'is_active', 'updated_at')
            list_filter = ('is_active', 'updated_at', 'show_menu_online', 'show_reservations_online')
            search_fields = ('restaurant__name', 'website_title')
            readonly_fields = ('id', 'created_at', 'updated_at')
            
            fieldsets = (
                ('🏪 Restaurant', {
                    'fields': ('restaurant',)
                }),
                ('🌐 Website Settings', {
                    'fields': ('website_title', 'website_description', 'website_keywords', 'is_active')
                }),
                ('🎨 Branding', {
                    'fields': ('logo', 'favicon', 'primary_color', 'secondary_color')
                }),
                ('📱 Social Media', {
                    'fields': ('facebook_url', 'instagram_url', 'twitter_url', 'whatsapp_number')
                }),
                ('📞 Contact Information', {
                    'fields': ('contact_email', 'contact_phone', 'contact_whatsapp')
                }),
                ('🎯 Hero Section', {
                    'fields': ('hero_title', 'hero_subtitle', 'hero_cta_button_text', 'hero_cta_button_link'),
                    'classes': ('collapse',)
                }),
                ('ℹ️ About Section', {
                    'fields': ('about_title', 'about_content', 'about_image'),
                    'classes': ('collapse',)
                }),
                ('⭐ Features', {
                    'fields': (
                        'feature_1_title', 'feature_1_description', 'feature_1_icon',
                        'feature_2_title', 'feature_2_description', 'feature_2_icon',
                        'feature_3_title', 'feature_3_description', 'feature_3_icon'
                    ),
                    'classes': ('collapse',)
                }),
                ('📧 Newsletter & Contact', {
                    'fields': ('enable_newsletter', 'enable_contact_form')
                }),
                ('🔧 Functionality', {
                    'fields': ('show_menu_online', 'show_reservations_online')
                }),
                ('📝 Footer', {
                    'fields': ('footer_text',)
                }),
                ('⏰ Timestamps', {
                    'fields': ('created_at', 'updated_at'),
                    'classes': ('collapse',)
                }),
            )
            
            def has_add_permission(self, request):
                """Prevent manual addition - auto-created with restaurant"""
                return False
        
        admin_site.register(WebsiteData, WebsiteDataAdmin)
