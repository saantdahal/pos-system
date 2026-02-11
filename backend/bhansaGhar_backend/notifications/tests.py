"""
Unit and integration tests for notification system.
"""

import json
from typing import Any, Dict
from django.test import TestCase, Client
from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework.test import APIClient, APITestCase
from rest_framework import status
from rest_framework.response import Response
from .models import (
    Notification,
    FCMDevice,
    NotificationPreference,
    NotificationCategory,
    NotificationPriority,
)
from .services import NotificationService, NotificationRouter

User = get_user_model()


class NotificationModelTests(TestCase):
    """Test Notification model functionality"""

    def setUp(self) -> None:
        self.user = User.objects.create_user(
            username="testuser",
            email="test@example.com",
            password="testpass123",
            role="admin",
        )

    def test_create_notification(self) -> None:
        """Test creating a notification"""
        notif = Notification.objects.create(
            user=self.user,
            category=NotificationCategory.ORDER,
            title="Test Order",
            message="Test message",
            priority=NotificationPriority.HIGH,
        )
        self.assertEqual(notif.user, self.user)
        self.assertEqual(notif.title, "Test Order")
        self.assertFalse(notif.is_read)

    def test_mark_as_read(self) -> None:
        """Test marking notification as read"""
        notif = Notification.objects.create(
            user=self.user,
            category=NotificationCategory.ORDER,
            title="Test",
            message="Test",
        )
        self.assertFalse(notif.is_read)
        notif.mark_as_read()
        self.assertTrue(notif.is_read)
        self.assertIsNotNone(notif.read_at)

    def test_notification_ordering(self) -> None:
        """Test FCFS ordering (by timestamp)"""
        notif1 = Notification.objects.create(
            user=self.user,
            category=NotificationCategory.ORDER,
            title="First",
            message="First",
        )
        notif2 = Notification.objects.create(
            user=self.user,
            category=NotificationCategory.ORDER,
            title="Second",
            message="Second",
        )
        notifs = Notification.objects.all()
        # Should be ordered by -timestamp (newest first)
        self.assertEqual(notifs[0].id, notif2.id)
        self.assertEqual(notifs[1].id, notif1.id)


class FCMDeviceTests(TestCase):
    """Test FCM Device model"""

    def setUp(self) -> None:
        self.user = User.objects.create_user(
            username="testuser",
            email="test@example.com",
            password="testpass123",
        )

    def test_create_fcm_device(self) -> None:
        """Test creating FCM device"""
        device = FCMDevice.objects.create(
            user=self.user,
            token="test_token_123",
            platform="android",
        )
        self.assertEqual(device.user, self.user)
        self.assertEqual(device.token, "test_token_123")
        self.assertTrue(device.active)

    def test_one_to_one_relationship(self) -> None:
        """Test one-to-one relationship enforcement"""
        FCMDevice.objects.create(
            user=self.user,
            token="token1",
            platform="android",
        )
        # Creating another device for same user should update
        device2, created = FCMDevice.objects.update_or_create(
            user=self.user,
            defaults={"token": "token2", "platform": "ios"},
        )
        self.assertFalse(created)
        self.assertEqual(device2.token, "token2")


class NotificationServiceTests(TestCase):
    """Test NotificationService"""

    def setUp(self) -> None:
        self.user = User.objects.create_user(
            username="testuser",
            email="test@example.com",
            password="testpass123",
            role="kitchen",
        )

    def test_get_unread_notifications(self) -> None:
        """Test retrieving unread notifications"""
        Notification.objects.create(
            user=self.user,
            category=NotificationCategory.ORDER,
            title="Test",
            message="Test",
            is_read=False,
        )
        Notification.objects.create(
            user=self.user,
            category=NotificationCategory.ORDER,
            title="Read",
            message="Read",
            is_read=True,
        )
        unread = NotificationService.get_unread_notifications(self.user)
        self.assertEqual(len(unread), 1)
        self.assertEqual(unread[0].title, "Test")

    def test_mark_as_read(self) -> None:
        """Test marking notification as read via service"""
        notif = Notification.objects.create(
            user=self.user,
            category=NotificationCategory.ORDER,
            title="Test",
            message="Test",
        )
        result = NotificationService.mark_as_read(str(notif.id), self.user)
        self.assertIsNotNone(result)
        # Type guard: result is not None
        if result is not None:
            self.assertTrue(result.is_read)

    def test_bulk_mark_as_read(self) -> None:
        """Test marking multiple notifications as read"""
        for i in range(5):
            Notification.objects.create(
                user=self.user,
                category=NotificationCategory.ORDER,
                title=f"Test {i}",
                message="Test",
            )
        count = NotificationService.bulk_mark_as_read(self.user)
        self.assertEqual(count, 5)
        unread = Notification.objects.filter(user=self.user, is_read=False).count()
        self.assertEqual(unread, 0)

    def test_get_notification_stats(self) -> None:
        """Test getting notification statistics"""
        Notification.objects.create(
            user=self.user,
            category=NotificationCategory.ORDER,
            title="Order",
            message="Test",
            is_read=False,
        )
        Notification.objects.create(
            user=self.user,
            category=NotificationCategory.BARGAIN,
            title="Bargain",
            message="Test",
            is_read=False,
        )
        stats = NotificationService.get_notification_stats(self.user)
        self.assertEqual(stats["total_unread"], 2)
        self.assertEqual(stats["by_category"]["order"], 1)
        self.assertEqual(stats["by_category"]["bargain"], 1)


class NotificationPreferenceTests(TestCase):
    """Test NotificationPreference model"""

    def setUp(self) -> None:
        self.user = User.objects.create_user(
            username="testuser",
            email="test@example.com",
            password="testpass123",
        )

    def test_create_preference(self) -> None:
        """Test creating notification preferences"""
        prefs = NotificationPreference.objects.create(user=self.user)
        self.assertTrue(prefs.order_notifications)
        self.assertTrue(prefs.fcm_enabled)

    def test_is_category_enabled(self) -> None:
        """Test checking if category is enabled"""
        prefs = NotificationPreference.objects.create(
            user=self.user,
            order_notifications=True,
            bargain_notifications=False,
        )
        self.assertTrue(prefs.is_category_enabled(NotificationCategory.ORDER))
        self.assertFalse(prefs.is_category_enabled(NotificationCategory.BARGAIN))


class NotificationAPITests(APITestCase):
    """Test notification REST API endpoints"""

    def setUp(self) -> None:
        self.client = APIClient()
        self.user = User.objects.create_user(
            username="testuser",
            email="test@example.com",
            password="testpass123",
            role="admin",
        )
        self.client.force_authenticate(user=self.user)

    def test_list_notifications(self) -> None:
        """Test GET /api/notifications/"""
        Notification.objects.create(
            user=self.user,
            category=NotificationCategory.ORDER,
            title="Test",
            message="Test",
        )
        response = self.client.get("/api/notifications/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIsNotNone(response.data)  # type: ignore
        self.assertIn("results", response.data)  # type: ignore

    def test_mark_notification_read(self) -> None:
        """Test PATCH /api/notifications/<id>/read/"""
        notif = Notification.objects.create(
            user=self.user,
            category=NotificationCategory.ORDER,
            title="Test",
            message="Test",
        )
        self.assertFalse(notif.is_read)
        
        response = self.client.patch(f"/api/notifications/{notif.id}/read/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIsNotNone(response.data)  # type: ignore
        
        # Refresh from DB to verify
        notif.refresh_from_db()
        self.assertTrue(notif.is_read)
        self.assertIsNotNone(notif.read_at)

    def test_get_notification_stats(self) -> None:
        """Test GET /api/notifications/stats/"""
        Notification.objects.create(
            user=self.user,
            category=NotificationCategory.ORDER,
            title="Test",
            message="Test",
        )
        response = self.client.get("/api/notifications/stats/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIsNotNone(response.data)  # type: ignore
        self.assertEqual(response.data.get("total_unread"), 1)  # type: ignore

    def test_register_fcm_device(self) -> None:
        """Test POST /api/notifications/fcm/register/"""
        response = self.client.post(
            "/api/notifications/fcm/register/",
            {
                "token": "test_fcm_token",
                "platform": "android",
            },
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIsNotNone(response.data)  # type: ignore
        self.assertTrue(response.data.get("success"))  # type: ignore

    def test_notification_preferences(self) -> None:
        """Test GET/PATCH /api/notifications/preferences/"""
        response = self.client.get("/api/notifications/preferences/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIsNotNone(response.data)  # type: ignore

        # Update preferences
        response = self.client.patch(
            "/api/notifications/preferences/",
            {"order_notifications": False},
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIsNotNone(response.data)  # type: ignore
        
        # Verify the response structure
        preferences_data = response.data.get("preferences")  # type: ignore
        self.assertIsNotNone(preferences_data)
        self.assertFalse(preferences_data.get("order_notifications"))


class NotificationSignalTests(TestCase):
    """Test Django signals for notifications"""

    def test_auto_create_preferences(self) -> None:
        """Test that preferences are auto-created for new users"""
        user = User.objects.create_user(
            username="newuser",
            email="new@example.com",
            password="pass123",
        )
        prefs_exists = NotificationPreference.objects.filter(user=user).exists()
        self.assertTrue(prefs_exists)
