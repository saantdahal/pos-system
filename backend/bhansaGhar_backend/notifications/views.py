"""
REST API endpoints for notifications.
Provides CRUD operations and FCM device registration.
"""

import logging
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.pagination import PageNumberPagination
from django.db.models import Q
from .models import Notification, FCMDevice, NotificationPreference, NotificationCategory
from .serializers import (
    NotificationSerializer,
    NotificationDetailSerializer,
    FCMDeviceSerializer,
    NotificationPreferenceSerializer,
    NotificationStatsSerializer,
)
from .services import NotificationService, NotificationRouter

logger = logging.getLogger(__name__)


class NotificationPagination(PageNumberPagination):
    """Custom pagination for notification lists"""

    page_size = 50
    page_size_query_param = "page_size"
    max_page_size = 100


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def list_notifications(request):
    """
    GET /api/notifications/ - Get unread notifications in FCFS order

    Query params:
    - category: Filter by category (order, bargain, table, staff, stock, revenue)
    - is_read: Filter by read status (true/false)
    - page: Page number (default 1)
    - page_size: Items per page (default 50, max 100)
    """
    try:
        # Build query
        query = Notification.objects.filter(user=request.user)

        # Filter by category
        category = request.query_params.get("category")
        if category:
            query = query.filter(category=category)

        # Filter by read status
        is_read = request.query_params.get("is_read")
        if is_read is not None:
            is_read_bool = is_read.lower() == "true"
            query = query.filter(is_read=is_read_bool)
        else:
            # Default: unread only
            query = query.filter(is_read=False)

        # Order by timestamp (FCFS)
        query = query.order_by("-timestamp")

        # Paginate
        paginator = NotificationPagination()
        page = paginator.paginate_queryset(query, request)

        if page is not None:
            serializer = NotificationSerializer(page, many=True)
            return paginator.get_paginated_response(serializer.data)

        serializer = NotificationSerializer(query, many=True)
        return Response(serializer.data)

    except Exception as e:
        logger.error(f"Error listing notifications: {str(e)}", exc_info=True)
        return Response(
            {"error": "Failed to fetch notifications"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def notification_detail(request, notification_id):
    """
    GET /api/notifications/{id}/ - Get notification details
    """
    try:
        notification = Notification.objects.get(id=notification_id, user=request.user)
        serializer = NotificationDetailSerializer(notification)
        return Response(serializer.data)
    except Notification.DoesNotExist:
        return Response(
            {"error": "Notification not found"},
            status=status.HTTP_404_NOT_FOUND,
        )
    except Exception as e:
        logger.error(f"Error fetching notification: {str(e)}", exc_info=True)
        return Response(
            {"error": "Failed to fetch notification"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


@api_view(["PATCH"])
@permission_classes([IsAuthenticated])
def mark_notification_read(request, notification_id):
    """
    PATCH /api/notifications/{id}/read/ - Mark notification as read
    """
    try:
        notification = NotificationService.mark_as_read(notification_id, request.user)
        if notification:
            serializer = NotificationSerializer(notification)
            return Response(serializer.data)
        return Response(
            {"error": "Notification not found"},
            status=status.HTTP_404_NOT_FOUND,
        )
    except Exception as e:
        logger.error(f"Error marking notification read: {str(e)}", exc_info=True)
        return Response(
            {"error": "Failed to mark notification as read"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def mark_all_notifications_read(request):
    """
    POST /api/notifications/mark-all-read/ - Mark all unread notifications as read

    Query params:
    - category: Optional, mark only specific category as read
    """
    try:
        category = request.query_params.get("category")
        count = NotificationService.bulk_mark_as_read(request.user, category=category)
        return Response(
            {
                "success": True,
                "marked_count": count,
                "message": f"Marked {count} notifications as read",
            }
        )
    except Exception as e:
        logger.error(
            f"Error marking all notifications read: {str(e)}", exc_info=True
        )
        return Response(
            {"error": "Failed to mark notifications as read"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


@api_view(["DELETE"])
@permission_classes([IsAuthenticated])
def delete_notification(request, notification_id):
    """
    DELETE /api/notifications/{id}/ - Delete notification
    """
    try:
        notification = Notification.objects.get(id=notification_id, user=request.user)
        notification.delete()
        return Response({"success": True, "message": "Notification deleted"})
    except Notification.DoesNotExist:
        return Response(
            {"error": "Notification not found"},
            status=status.HTTP_404_NOT_FOUND,
        )
    except Exception as e:
        logger.error(f"Error deleting notification: {str(e)}", exc_info=True)
        return Response(
            {"error": "Failed to delete notification"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def notification_stats(request):
    """
    GET /api/notifications/stats/ - Get notification statistics

    Returns:
    {
        "total_unread": 12,
        "by_category": {
            "order": 5,
            "table": 4,
            "stock": 2,
            "staff": 1
        }
    }
    """
    try:
        stats = NotificationService.get_notification_stats(request.user)
        serializer = NotificationStatsSerializer(stats)
        return Response(serializer.data)
    except Exception as e:
        logger.error(f"Error getting notification stats: {str(e)}", exc_info=True)
        return Response(
            {"error": "Failed to fetch statistics"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def register_fcm_device(request):
    """
    POST /api/notifications/fcm/register/ - Register FCM device token

    Body:
    {
        "token": "fcm_device_token_here",
        "platform": "android"  # or "ios" or "web"
    }
    """
    try:
        token = request.data.get("token")
        platform = request.data.get("platform", "android")

        if not token:
            return Response(
                {"error": "FCM token is required"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if platform not in ["android", "ios", "web"]:
            return Response(
                {"error": "Invalid platform. Choose from: android, ios, web"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Create or update FCM device
        fcm_device, created = FCMDevice.objects.update_or_create(
            user=request.user,
            defaults={
                "token": token,
                "platform": platform,
                "active": True,
            },
        )

        serializer = FCMDeviceSerializer(fcm_device)
        message = "FCM device registered" if created else "FCM device updated"
        return Response(
            {
                "success": True,
                "message": message,
                "device": serializer.data,
            },
            status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
        )

    except Exception as e:
        logger.error(f"Error registering FCM device: {str(e)}", exc_info=True)
        return Response(
            {"error": "Failed to register FCM device"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def get_fcm_device(request):
    """
    GET /api/notifications/fcm/device/ - Get current FCM device info
    """
    try:
        fcm_device = FCMDevice.objects.get(user=request.user)
        serializer = FCMDeviceSerializer(fcm_device)
        return Response(serializer.data)
    except FCMDevice.DoesNotExist:
        return Response(
            {"message": "No FCM device registered"},
            status=status.HTTP_404_NOT_FOUND,
        )
    except Exception as e:
        logger.error(f"Error fetching FCM device: {str(e)}", exc_info=True)
        return Response(
            {"error": "Failed to fetch FCM device"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


@api_view(["DELETE"])
@permission_classes([IsAuthenticated])
def unregister_fcm_device(request):
    """
    DELETE /api/notifications/fcm/device/ - Unregister FCM device
    """
    try:
        fcm_device = FCMDevice.objects.get(user=request.user)
        fcm_device.delete()
        return Response(
            {
                "success": True,
                "message": "FCM device unregistered",
            }
        )
    except FCMDevice.DoesNotExist:
        return Response(
            {"error": "FCM device not found"},
            status=status.HTTP_404_NOT_FOUND,
        )
    except Exception as e:
        logger.error(f"Error unregistering FCM device: {str(e)}", exc_info=True)
        return Response(
            {"error": "Failed to unregister FCM device"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


@api_view(["GET", "PATCH"])
@permission_classes([IsAuthenticated])
def notification_preferences(request):
    """
    GET /api/notifications/preferences/ - Get notification preferences
    PATCH /api/notifications/preferences/ - Update notification preferences

    Preferences:
    {
        "order_notifications": true,
        "bargain_notifications": true,
        "table_notifications": true,
        "staff_notifications": true,
        "stock_notifications": true,
        "revenue_notifications": true,
        "fcm_enabled": true,
        "websocket_enabled": true,
        "dnd_enabled": false,
        "dnd_start_time": "22:00:00",
        "dnd_end_time": "08:00:00"
    }
    """
    try:
        prefs, _ = NotificationPreference.objects.get_or_create(user=request.user)

        if request.method == "GET":
            serializer = NotificationPreferenceSerializer(prefs)
            return Response(serializer.data)

        elif request.method == "PATCH":
            serializer = NotificationPreferenceSerializer(
                prefs, data=request.data, partial=True
            )
            if serializer.is_valid():
                serializer.save()
                return Response(
                    {
                        "success": True,
                        "message": "Preferences updated",
                        "preferences": serializer.data,
                    }
                )
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    except Exception as e:
        logger.error(f"Error managing preferences: {str(e)}", exc_info=True)
        return Response(
            {"error": "Failed to manage preferences"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )
