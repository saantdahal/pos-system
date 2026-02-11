"""
Signals for customer app - handles automatic deletion of old images from Cloudinary
"""
from django.db.models.signals import pre_save
from django.dispatch import receiver
from django.core.files.storage import default_storage
import logging

from .models import LandingPage, AppCard

logger = logging.getLogger(__name__)


@receiver(pre_save, sender=LandingPage)
def delete_old_landing_page_images(sender, instance, **kwargs):
    """
    Delete old images from Cloudinary when new images are uploaded to LandingPage
    """
    try:
        # Get the old instance from database (if it exists)
        old_instance = LandingPage.objects.filter(pk=instance.pk).first()
        
        if not old_instance:
            return
        
        # Image fields to check
        image_fields = [
            'navbar_logo_image',
            'hero_image',
            'info_banner_image',
            'feature_1_icon_image',
            'feature_2_icon_image',
            'feature_3_icon_image',
            'about_image',
        ]
        
        for field_name in image_fields:
            old_image = getattr(old_instance, field_name)
            new_image = getattr(instance, field_name)
            
            # Check if image has changed
            if old_image and old_image != new_image:
                try:
                    # Delete old image from Cloudinary
                    if old_image.name:
                        print(f"🗑️ Deleting old {field_name}: {old_image.name}")
                        default_storage.delete(old_image.name)
                        logger.info(f"Successfully deleted old {field_name}: {old_image.name}")
                except Exception as e:
                    logger.warning(f"Error deleting old {field_name}: {e}")
                    print(f"⚠️ Error deleting old {field_name}: {e}")
    
    except Exception as e:
        logger.error(f"Error in delete_old_landing_page_images signal: {e}")
        print(f"❌ Error in delete_old_landing_page_images: {e}")


@receiver(pre_save, sender=AppCard)
def delete_old_app_card_images(sender, instance, **kwargs):
    """
    Delete old images from Cloudinary when new images are uploaded to AppCard
    """
    try:
        # Get the old instance from database (if it exists)
        old_instance = AppCard.objects.filter(pk=instance.pk).first()
        
        if not old_instance:
            return
        
        # Image fields to check
        image_fields = ['icon_image']
        
        for field_name in image_fields:
            old_image = getattr(old_instance, field_name)
            new_image = getattr(instance, field_name)
            
            # Check if image has changed
            if old_image and old_image != new_image:
                try:
                    # Delete old image from Cloudinary
                    if old_image.name:
                        print(f"🗑️ Deleting old AppCard {field_name}: {old_image.name}")
                        default_storage.delete(old_image.name)
                        logger.info(f"Successfully deleted old AppCard {field_name}: {old_image.name}")
                except Exception as e:
                    logger.warning(f"Error deleting old AppCard {field_name}: {e}")
                    print(f"⚠️ Error deleting old AppCard {field_name}: {e}")
    
    except Exception as e:
        logger.error(f"Error in delete_old_app_card_images signal: {e}")
        print(f"❌ Error in delete_old_app_card_images: {e}")
