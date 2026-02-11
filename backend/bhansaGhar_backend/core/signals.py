"""
Signals for Core App
Handles server startup tasks like Postman collection generation, activity logging, and image cleanup
"""

import os
import logging
from django.db.models.signals import post_migrate, post_save, pre_save
from django.core.signals import request_started
from django.dispatch import receiver
from django.core.files.storage import default_storage
from .services.postman_generator import create_postman_collection

logger = logging.getLogger(__name__)

# Flag to ensure collection is generated only once
_collection_generated = False


def _generate_collection_safe() -> None:
    """Generate collection with error handling"""
    global _collection_generated
    
    if _collection_generated:
        return
    
    try:
        collection_path = create_postman_collection()
        logger.info(f"✓ Postman collection generated successfully at: {collection_path}")
        print(f"\n✓ Postman collection generated at: {collection_path}")
        print(f"  Import this file in Postman to test all API endpoints")
        
        # Print API Documentation URLs
        from django.conf import settings
        base_url = settings.SITE_URL.rstrip('/')
        print(f"\n📚 API Documentation:")
        print(f"  - Swagger UI: {base_url}/api/docs/")
        print(f"  - ReDoc:      {base_url}/api/redoc/")
        print(f"  - Schema:     {base_url}/api/schema/\n")
        
        _collection_generated = True
    except Exception as e:
        logger.error(f"✗ Failed to generate Postman collection: {str(e)}")
        print(f"\n✗ Error generating Postman collection: {str(e)}\n")


@receiver(post_migrate)
def generate_postman_collection_on_migrate(sender: any, **kwargs: any) -> None:
    """
    Generate Postman collection after migrations are applied
    This runs automatically when Django starts up
    """
    _generate_collection_safe()


@receiver(request_started)
def generate_postman_collection_on_startup(sender: any, **kwargs: any) -> None:
    """
    Fallback: Generate Postman collection on first request if not already generated
    This ensures collection is created even if migrations aren't run during startup
    """
    _generate_collection_safe()


# Activity Logging Signals

@receiver(post_save, sender='orders.Order')
def log_order_activity(sender, instance, created, **kwargs):
    """Log activity when an order is created or updated"""
    from .activities.activity_models import ActivityLog, ActivityType
    from .activities.activity_utils import log_activity
    
    try:
        # Get the user from the request context if available
        # For now, we log order updates/creations separately via view handlers
        pass
    except Exception as e:
        logger.error(f"Error logging order activity: {str(e)}")


@receiver(post_save, sender='orders.OrderBargain')
def log_bargain_activity(sender, instance, created, **kwargs):
    """Log activity when a bargain is created or updated"""
    try:
        # Bargain activities are logged via view handlers for better context
        pass
    except Exception as e:
        logger.error(f"Error logging bargain activity: {str(e)}")

# ============================================================================
# Image Deletion Signals - Clean up old images from Cloudinary
# ============================================================================

@receiver(pre_save, sender='core.WebsiteData')
def delete_old_website_data_images(sender, instance, **kwargs):
    """
    Delete old images from Cloudinary when new images are uploaded to WebsiteData
    """
    try:
        # Get the old instance from database (if it exists)
        old_instance = sender.objects.filter(pk=instance.pk).first()
        
        if not old_instance:
            return
        
        # Image fields to check
        image_fields = ['logo', 'favicon', 'about_image']
        
        for field_name in image_fields:
            old_image = getattr(old_instance, field_name)
            new_image = getattr(instance, field_name)
            
            # Check if image has changed
            if old_image and old_image != new_image:
                try:
                    # Delete old image from Cloudinary
                    if old_image.name:
                        print(f"🗑️ Deleting old WebsiteData {field_name}: {old_image.name}")
                        default_storage.delete(old_image.name)
                        logger.info(f"Successfully deleted old WebsiteData {field_name}: {old_image.name}")
                except Exception as e:
                    logger.warning(f"Error deleting old WebsiteData {field_name}: {e}")
                    print(f"⚠️ Error deleting old WebsiteData {field_name}: {e}")
    
    except Exception as e:
        logger.error(f"Error in delete_old_website_data_images signal: {e}")
        print(f"❌ Error in delete_old_website_data_images: {e}")
