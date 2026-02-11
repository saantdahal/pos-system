"""
Django signals for notifications.
Auto-create notification preferences for new users.
"""

import logging
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth import get_user_model
from .models import NotificationPreference

User = get_user_model()
logger = logging.getLogger(__name__)


@receiver(post_save, sender=User)
def create_notification_preferences(sender, instance, created, **kwargs):
    """
    Auto-create notification preferences when a new user is created.
    """
    if created:
        try:
            NotificationPreference.objects.get_or_create(user=instance)
            logger.info(f"Notification preferences created for {instance.username}")
        except Exception as e:
            logger.error(
                f"Error creating notification preferences: {str(e)}", exc_info=True
            )
