"""
URL routing for notification endpoints.
"""

from django.urls import path
from .views import (
    list_notifications,
    notification_detail,
    mark_notification_read,
    mark_all_notifications_read,
    delete_notification,
    notification_stats,
    register_fcm_device,
    get_fcm_device,
    unregister_fcm_device,
    notification_preferences,
)

app_name = "notifications"

urlpatterns = [
    # Notification management
    path("", list_notifications, name="list_notifications"),
    path("<uuid:notification_id>/", notification_detail, name="notification_detail"),
    path("<uuid:notification_id>/read/", mark_notification_read, name="mark_read"),
    path("mark-all-read/", mark_all_notifications_read, name="mark_all_read"),
    path("<uuid:notification_id>/delete/", delete_notification, name="delete"),
    path("stats/", notification_stats, name="stats"),
    # FCM device management
    path("fcm/register/", register_fcm_device, name="fcm_register"),
    path("fcm/device/", get_fcm_device, name="fcm_device"),
    path("fcm/device/unregister/", unregister_fcm_device, name="fcm_unregister"),
    # Preferences
    path("preferences/", notification_preferences, name="preferences"),
]
