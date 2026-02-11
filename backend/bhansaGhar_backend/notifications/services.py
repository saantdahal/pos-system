"""
Notification Service - Handles hybrid delivery via WebSocket + FCM.
FCFS queue implementation with role-based category routing.
"""

import json
import logging
from typing import Optional, Dict, Any
from django.contrib.auth import get_user_model
from django.utils import timezone
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync
from .models import (
    Notification,
    FCMDevice,
    NotificationLog,
    NotificationPreference,
    NotificationCategory,
    NotificationPriority,
)

User = get_user_model()
logger = logging.getLogger(__name__)

try:
    import firebase_admin
    from firebase_admin import messaging
    FCM_AVAILABLE = True
except (ImportError, ModuleNotFoundError):
    FCM_AVAILABLE = False  # type: ignore
    logger.warning("firebase_admin not installed. FCM notifications will be skipped.")


class NotificationService:
    """
    Main service for creating and delivering notifications.
    Handles both WebSocket (online) and FCM (offline) delivery.
    """

    @staticmethod
    def create_and_send(
        user,
        category: str,
        title: str,
        message: str,
        data: Optional[Dict[str, Any]] = None,
        priority: int = NotificationPriority.MEDIUM,
    ) -> Optional[Notification]:
        """
        Create a notification and send via WebSocket + FCM.

        Args:
            user: User instance
            category: NotificationCategory choice
            title: Notification title
            message: Notification message
            data: Additional data (order_id, table_number, etc.)
            priority: Priority level (1-5)

        Returns:
            Notification instance or None if creation failed
        """
        try:
            # Check user preferences
            prefs = NotificationPreference.objects.get_or_create(user=user)[0]
            if not prefs.is_category_enabled(category):
                logger.info(f"Notification skipped: {user.username} disabled {category}")
                return None

            # Create notification in database
            notification = Notification.objects.create(
                user=user,
                category=category,
                title=title,
                message=message,
                data=data or {},
                priority=priority,
            )

            # Send via WebSocket (online users)
            NotificationService._send_websocket(notification)

            # Send via FCM (background delivery)
            NotificationService._send_fcm(notification)

            logger.info(
                f"Notification created: {notification.id} for {user.username}"
            )
            return notification

        except Exception as e:
            logger.error(f"Error creating notification: {str(e)}", exc_info=True)
            return None

    @staticmethod
    def _send_websocket(notification: Notification) -> bool:
        """
        Send notification via WebSocket to online users.
        Uses Django Channels group messaging.
        """
        try:
            channel_layer = get_channel_layer()
            user_group = f"user_{notification.user.id}"  # type: ignore

            # Prepare WebSocket message
            ws_message = {
                "type": "user_notification",
                "notification": {
                    "id": str(notification.id),
                    "category": notification.category,
                    "title": notification.title,
                    "message": notification.message,
                    "data": notification.data,
                    "priority": notification.priority,
                    "timestamp": notification.timestamp.isoformat(),
                },
            }

            # Send to user group (non-blocking)
            async_to_sync(channel_layer.group_send)(user_group, ws_message)  # type: ignore

            # Mark as sent
            notification.mark_ws_sent()

            # Log delivery
            NotificationLog.objects.create(
                notification=notification,
                delivery_type="websocket",
                status="sent",
            )

            logger.debug(f"WebSocket sent: {notification.id}")
            return True

        except Exception as e:
            logger.error(f"WebSocket delivery failed: {str(e)}", exc_info=True)
            NotificationLog.objects.create(
                notification=notification,
                delivery_type="websocket",
                status="failed",
                error_message=str(e),
            )
            return False

    @staticmethod
    def _send_fcm(notification: Notification) -> bool:
        """
        Send notification via Firebase Cloud Messaging (FCM).
        Works for offline users and background delivery.
        """
        if not FCM_AVAILABLE:
            logger.debug("FCM not available, skipping FCM delivery")
            return False

        try:
            # Get user's FCM device
            fcm_device = FCMDevice.objects.filter(
                user=notification.user, active=True
            ).first()

            if not fcm_device:
                logger.debug(f"No FCM device for user {notification.user.username}")
                return False

            # Check user preferences
            prefs = NotificationPreference.objects.get_or_create(
                user=notification.user
            )[0]
            if not prefs.fcm_enabled:
                logger.debug(f"FCM disabled for user {notification.user.username}")
                return False

            # Build FCM message
            fcm_message = messaging.Message(  # type: ignore
                notification=messaging.Notification(  # type: ignore
                    title=notification.title,
                    body=notification.message,
                ),
                data={
                    "notification_id": str(notification.id),
                    "category": notification.category,
                    "priority": str(notification.priority),
                    **notification.data,  # Include additional data
                },
                token=fcm_device.token,
                android=messaging.AndroidConfig(  # type: ignore
                    priority="high",
                    notification=messaging.AndroidNotification(  # type: ignore
                        click_action="FLUTTER_NOTIFICATION_CLICK",
                        channel_id="default",
                    ),
                ),
                apns=messaging.APNSConfig(  # type: ignore
                    payload=messaging.APNSPayload(  # type: ignore
                        aps=messaging.Aps(  # type: ignore
                            alert=messaging.ApsAlert(  # type: ignore
                                title=notification.title,
                                body=notification.message,
                            ),
                            sound="default",
                            badge=1,
                        )
                    )
                ),
            )

            # Send via FCM
            response = messaging.send(fcm_message)  # type: ignore
            notification.mark_fcm_sent()

            # Log delivery
            NotificationLog.objects.create(
                notification=notification,
                delivery_type="fcm",
                status="sent",
            )

            logger.info(f"FCM sent: {notification.id} (response: {response})")
            return True

        except messaging.UnregisteredError:  # type: ignore
            logger.warning(
                f"FCM device unregistered for user {notification.user.username}"
            )
            notification.mark_fcm_failed("Device unregistered")
            if fcm_device:  # type: ignore
                fcm_device.active = False  # type: ignore
                fcm_device.save()  # type: ignore
            return False

        except messaging.InvalidArgumentError as e:  # type: ignore
            logger.error(f"FCM invalid argument: {str(e)}")
            notification.mark_fcm_failed(f"Invalid argument: {str(e)}")
            return False

        except Exception as e:
            logger.error(f"FCM delivery failed: {str(e)}", exc_info=True)
            notification.mark_fcm_failed(str(e))
            NotificationLog.objects.create(
                notification=notification,
                delivery_type="fcm",
                status="failed",
                error_message=str(e),
            )
            return False

    @staticmethod
    def mark_as_read(notification_id: str, user) -> Optional[Notification]:
        """Mark notification as read"""
        try:
            notification = Notification.objects.get(id=notification_id, user=user)
            notification.mark_as_read()
            logger.debug(f"Notification marked read: {notification_id}")
            return notification
        except Notification.DoesNotExist:
            logger.warning(
                f"Notification not found: {notification_id} for user {user.username}"
            )
            return None

    @staticmethod
    def bulk_mark_as_read(user, category: Optional[str] = None):
        """Mark all unread notifications as read (optionally by category)"""
        query = Notification.objects.filter(user=user, is_read=False)
        if category:
            query = query.filter(category=category)

        count = query.update(is_read=True, read_at=timezone.now())
        logger.info(f"Marked {count} notifications as read for {user.username}")
        return count

    @staticmethod
    def get_unread_notifications(
        user, category: Optional[str] = None, limit: int = 50
    ):
        """Get unread notifications in FCFS order"""
        query = Notification.objects.filter(user=user, is_read=False)
        if category:
            query = query.filter(category=category)

        return query.order_by("-timestamp")[:limit]

    @staticmethod
    def get_notification_stats(user) -> Dict[str, Any]:
        """Get notification statistics for user"""
        notifications = Notification.objects.filter(user=user, is_read=False)

        stats = {
            "total_unread": notifications.count(),
            "by_category": {},
        }

        # Count by category
        for category in NotificationCategory.choices:
            category_code = category[0]
            count = notifications.filter(category=category_code).count()
            if count > 0:
                stats["by_category"][category_code] = count

        return stats

    @staticmethod
    def cleanup_old_notifications(days: int = 30):
        """Remove read notifications older than X days"""
        from datetime import timedelta

        cutoff_date = timezone.now() - timedelta(days=days)
        deleted_count, _ = Notification.objects.filter(
            is_read=True, timestamp__lt=cutoff_date
        ).delete()
        logger.info(f"Cleaned up {deleted_count} old notifications")
        return deleted_count


class NotificationRouter:
    """
    Route notifications to appropriate users based on role and action.
    Implements role-specific category filtering.
    """

    @staticmethod
    def notify_order_update(order, action: str, **extra_data):
        """
        Notify relevant users when order status changes.

        Actions:
        - created: Notify kitchen + admin
        - ready: Notify waiters + customer
        - completed: Notify admin + customer
        - cancelled: Notify all
        """
        try:
            restaurant = order.restaurant

            if action == "created":
                # Kitchen staff
                kitchen_staff = User.objects.filter(
                    role="kitchen", restaurant=restaurant
                )
                for staff in kitchen_staff:
                    NotificationService.create_and_send(
                        user=staff,
                        category=NotificationCategory.ORDER,
                        title=f"New Order #{order.id}",
                        message=f"Table {order.table_number}: {order.order_items.count()} items",
                        data={
                            "order_id": str(order.id),
                            "table_number": order.table_number,
                            "action": action,
                        },
                        priority=NotificationPriority.HIGH,
                    )

                # Admin
                if restaurant.owner:
                    NotificationService.create_and_send(
                        user=restaurant.owner,
                        category=NotificationCategory.ORDER,
                        title=f"New Order #{order.id}",
                        message=f"Table {order.table_number} placed new order",
                        data={
                            "order_id": str(order.id),
                            "table_number": order.table_number,
                            "action": action,
                        },
                        priority=NotificationPriority.MEDIUM,
                    )

            elif action == "ready":
                # Notify all waiters
                waiters = User.objects.filter(role="waiter", restaurant=restaurant)
                for waiter in waiters:
                    NotificationService.create_and_send(
                        user=waiter,
                        category=NotificationCategory.TABLE,
                        title=f"Table {order.table_number} READY",
                        message=f"Order #{order.id} prepared for pickup",
                        data={
                            "order_id": str(order.id),
                            "table_number": order.table_number,
                            "action": action,
                        },
                        priority=NotificationPriority.URGENT,
                    )

            elif action == "completed":
                # Notify admin
                if restaurant.owner:
                    NotificationService.create_and_send(
                        user=restaurant.owner,
                        category=NotificationCategory.ORDER,
                        title=f"Order #{order.id} Completed",
                        message=f"Table {order.table_number}: Amount {order.total_price}",
                        data={
                            "order_id": str(order.id),
                            "table_number": order.table_number,
                            "action": action,
                            "amount": str(order.total_price),
                        },
                        priority=NotificationPriority.MEDIUM,
                    )

        except Exception as e:
            logger.error(f"Error routing order notification: {str(e)}", exc_info=True)

    @staticmethod
    def notify_staff_activity(restaurant, action: str, staff_user, **extra_data):
        """
        Notify admin about staff activities.

        Actions:
        - logged_in: Staff logged in
        - logged_out: Staff logged out
        - role_assigned: New staff role assigned
        """
        try:
            if restaurant.owner:
                NotificationService.create_and_send(
                    user=restaurant.owner,
                    category=NotificationCategory.STAFF,
                    title=f"Staff {action.replace('_', ' ').title()}",
                    message=f"{staff_user.get_full_name() or staff_user.username} ({staff_user.role})",
                    data={
                        "staff_id": str(staff_user.id),
                        "action": action,
                    },
                    priority=NotificationPriority.MEDIUM,
                )
        except Exception as e:
            logger.error(f"Error routing staff notification: {str(e)}", exc_info=True)

    @staticmethod
    def notify_bargain(order, kitchen_user, **extra_data):
        """Notify kitchen about bargain request"""
        try:
            restaurant = order.restaurant
            kitchen_staff = User.objects.filter(role="kitchen", restaurant=restaurant)

            for staff in kitchen_staff:
                NotificationService.create_and_send(
                    user=staff,
                    category=NotificationCategory.BARGAIN,
                    title=f"Bargain Request #{order.id}",
                    message=f"Table {order.table_number}: Bargain message",
                    data={
                        "order_id": str(order.id),
                        "table_number": order.table_number,
                    },
                    priority=NotificationPriority.HIGH,
                )
        except Exception as e:
            logger.error(f"Error routing bargain notification: {str(e)}", exc_info=True)

    @staticmethod
    def notify_stock_alert(restaurant, item_name: str, quantity: int, **extra_data):
        """Notify kitchen and admin about low stock"""
        try:
            # Kitchen staff
            kitchen_staff = User.objects.filter(role="kitchen", restaurant=restaurant)
            for staff in kitchen_staff:
                NotificationService.create_and_send(
                    user=staff,
                    category=NotificationCategory.STOCK,
                    title="Low Stock Alert",
                    message=f"{item_name}: Only {quantity} left",
                    data={
                        "item_name": item_name,
                        "quantity": quantity,
                    },
                    priority=NotificationPriority.MEDIUM,
                )

            # Admin
            if restaurant.owner:
                NotificationService.create_and_send(
                    user=restaurant.owner,
                    category=NotificationCategory.STOCK,
                    title="Low Stock Alert",
                    message=f"{item_name}: Only {quantity} left",
                    data={
                        "item_name": item_name,
                        "quantity": quantity,
                    },
                    priority=NotificationPriority.MEDIUM,
                )
        except Exception as e:
            logger.error(f"Error routing stock notification: {str(e)}", exc_info=True)
