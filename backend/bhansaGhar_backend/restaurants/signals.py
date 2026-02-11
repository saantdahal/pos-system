from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from .models import Category, MenuItem, Restaurant
from core.services.cache_services import invalidate_menu_cache
from core.models import WebsiteData
import logging

logger = logging.getLogger(__name__)

@receiver(post_save, sender=Restaurant)
def create_website_data_on_restaurant_creation(sender, instance, created, **kwargs):
    """
    Create WebsiteData object when a restaurant is created
    """
    if created:
        try:
            WebsiteData.objects.get_or_create(
                restaurant=instance,
                defaults={
                    'website_title': instance.name,
                    'website_description': instance.description or f"Welcome to {instance.name}",
                    'contact_phone': instance.phone,
                    'contact_email': instance.owner.email if instance.owner else None,
                    'hero_title': f"Welcome to {instance.name}",
                    'hero_subtitle': instance.description or "Delicious food served fresh",
                    'about_title': "About Us",
                    'about_content': instance.about or f"Welcome to {instance.name}. We serve delicious food with passion and dedication.",
                    'footer_text': f"© {instance.name}. All rights reserved.",
                }
            )
            logger.info(f"🌐 WebsiteData created for restaurant: {instance.name}")
        except Exception as e:
            logger.error(f"Error creating WebsiteData for restaurant {instance.name}: {str(e)}")

@receiver([post_save, post_delete], sender=Category)
def invalidate_menu_cache_on_category_change(sender, instance, **kwargs):
    """
    Invalidate menu cache when a category is created, updated, or deleted.
    """
    invalidate_menu_cache(instance.restaurant.id)
    logger.info(f"♻️ Menu cache invalidated due to Category change: {instance.name}")

@receiver([post_save, post_delete], sender=MenuItem)
def invalidate_menu_cache_on_menu_item_change(sender, instance, **kwargs):
    """
    Invalidate menu cache when a menu item is created, updated, or deleted.
    """
    invalidate_menu_cache(instance.restaurant.id)
    logger.info(f"♻️ Menu cache invalidated due to MenuItem change: {instance.name}")
