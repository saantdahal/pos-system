"""
WebSocket Consumer for real-time notifications.
Handles user connections and message routing.
"""

import json
import logging
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model

User = get_user_model()
logger = logging.getLogger(__name__)


class UserNotificationConsumer(AsyncWebsocketConsumer):
    """
    WebSocket consumer for user notifications.
    Each connected user is added to a group: user_{user_id}
    """

    async def connect(self):
        """
        Handle WebSocket connection.
        Adds user to notification group.
        """
        try:
            self.user_id = self.scope["url_route"]["kwargs"]["user_id"]  # type: ignore
            self.user_group = f"user_{self.user_id}"

            # Verify user exists
            user = await self.get_user(self.user_id)
            if not user:
                await self.close()
                logger.warning(f"Connection attempt with invalid user_id: {self.user_id}")
                return

            # Add to group
            await self.channel_layer.group_add(self.user_group, self.channel_name)

            # Accept connection
            await self.accept()
            logger.info(f"WebSocket connected: {self.user_id}")

            # Send connected confirmation
            await self.send(
                text_data=json.dumps(
                    {
                        "type": "connection_established",
                        "message": "Connected to notification service",
                        "user_id": self.user_id,
                    }
                )
            )

        except Exception as e:
            logger.error(f"Connection error: {str(e)}", exc_info=True)
            await self.close()

    async def disconnect(self, close_code):  # type: ignore
        """
        Handle WebSocket disconnection.
        Removes user from notification group.
        """
        try:
            await self.channel_layer.group_discard(self.user_group, self.channel_name)
            logger.info(f"WebSocket disconnected: {self.user_id} (code: {close_code})")
        except Exception as e:
            logger.error(f"Disconnect error: {str(e)}", exc_info=True)

    async def receive(self, text_data=None, bytes_data=None):  # type: ignore
        """
        Handle incoming WebSocket messages.
        Currently used for keep-alive/ping messages.
        """
        try:
            if not text_data:
                return
            data = json.loads(text_data)
            message_type = data.get("type")

            if message_type == "ping":
                await self.send(
                    text_data=json.dumps(
                        {
                            "type": "pong",
                            "timestamp": str(timezone.now()),
                        }
                    )
                )
            else:
                logger.debug(f"Received message type: {message_type}")

        except json.JSONDecodeError:
            logger.error("Invalid JSON received")
        except Exception as e:
            logger.error(f"Receive error: {str(e)}", exc_info=True)

    async def user_notification(self, event):
        """
        Handle notification messages from channel layer.
        Sends notification to WebSocket client.
        """
        try:
            # Extract notification data
            notification_data = event.get("notification", {})

            # Send to WebSocket
            await self.send(
                text_data=json.dumps(
                    {
                        "type": "notification",
                        "data": notification_data,
                    }
                )
            )

            logger.debug(
                f"Notification sent to {self.user_id}: {notification_data.get('id')}"
            )

        except Exception as e:
            logger.error(f"Error sending notification: {str(e)}", exc_info=True)

    async def notification_stats(self, event):
        """
        Handle notification stats updates.
        """
        try:
            stats_data = event.get("stats", {})
            await self.send(
                text_data=json.dumps(
                    {
                        "type": "stats_update",
                        "data": stats_data,
                    }
                )
            )
        except Exception as e:
            logger.error(f"Error sending stats: {str(e)}", exc_info=True)

    @database_sync_to_async
    def get_user(self, user_id):
        """Get user from database"""
        try:
            return User.objects.get(id=user_id)
        except User.DoesNotExist:
            return None


# Import timezone for ping/pong
from django.utils import timezone
