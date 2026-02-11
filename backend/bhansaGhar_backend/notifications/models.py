import uuid
from django.db import models
from django.contrib.auth import get_user_model
from django.utils import timezone

User = get_user_model()


class NotificationCategory(models.TextChoices):
    """Role-based notification categories"""
    # Admin categories
    ORDER = 'order', 'Order Update'
    STAFF = 'staff', 'Staff Activity'
    REVENUE = 'revenue', 'Revenue'
    STOCK = 'stock', 'Stock Alert'
    
    # Kitchen categories
    BARGAIN = 'bargain', 'Bargain'
    
    # Waiter categories
    TABLE = 'table', 'Table Status'


class NotificationPriority(models.IntegerChoices):
    """Notification priority levels"""
    LOW = 1, 'Low'
    MEDIUM = 2, 'Medium'
    HIGH = 3, 'High'
    URGENT = 5, 'Urgent'


class Notification(models.Model):
    """
    Main notification model with FCFS queue support via timestamp ordering.
    Supports hybrid delivery: WebSocket (online) + FCM Push (offline).
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='notifications'
    )
    category = models.CharField(
        max_length=20,
        choices=NotificationCategory.choices
    )
    title = models.CharField(max_length=200)
    message = models.TextField()
    data = models.JSONField(
        default=dict,
        help_text='Additional data: order_id, table_number, etc.'
    )
    priority = models.IntegerField(
        choices=NotificationPriority.choices,
        default=NotificationPriority.MEDIUM
    )
    
    # Timestamp for FCFS queue ordering
    timestamp = models.DateTimeField(auto_now_add=True, db_index=True)
    
    # Read status tracking
    is_read = models.BooleanField(default=False, db_index=True)
    read_at = models.DateTimeField(null=True, blank=True)
    
    # FCM delivery tracking
    fcm_sent = models.BooleanField(default=False)
    fcm_sent_at = models.DateTimeField(null=True, blank=True)
    fcm_failed = models.BooleanField(default=False)
    fcm_error = models.TextField(blank=True, null=True)
    
    # WebSocket delivery tracking
    ws_sent = models.BooleanField(default=False)
    ws_sent_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        ordering = ['-timestamp']  # FCFS queue - newest first for API, but sorted by timestamp
        indexes = [
            models.Index(fields=['user', '-timestamp']),
            models.Index(fields=['user', 'is_read', '-timestamp']),
            models.Index(fields=['user', 'category', '-timestamp']),
        ]
        verbose_name_plural = "Notifications"
    
    def __str__(self):
        return f"{self.user.username}: {self.title}"
    
    def mark_as_read(self):
        """Mark notification as read"""
        if not self.is_read:
            self.is_read = True
            self.read_at = timezone.now()
            self.save()
    
    def mark_fcm_sent(self):
        """Mark FCM as successfully sent"""
        self.fcm_sent = True
        self.fcm_sent_at = timezone.now()
        self.save()
    
    def mark_fcm_failed(self, error_message=None):
        """Mark FCM as failed"""
        self.fcm_failed = True
        if error_message:
            self.fcm_error = error_message
        self.save()
    
    def mark_ws_sent(self):
        """Mark WebSocket as successfully sent"""
        self.ws_sent = True
        self.ws_sent_at = timezone.now()
        self.save()


class FCMDevice(models.Model):
    """
    Store FCM device tokens for push notifications.
    Each user can have one active device token (or multiple if needed).
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='fcm_device'
    )
    token = models.TextField(
        help_text='Firebase Cloud Messaging device token'
    )
    platform = models.CharField(
        max_length=10,
        choices=[
            ('android', 'Android'),
            ('ios', 'iOS'),
            ('web', 'Web'),
        ],
        default='android'
    )
    active = models.BooleanField(default=True)
    updated_at = models.DateTimeField(auto_now=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name_plural = "FCM Devices"
    
    def __str__(self):
        return f"{self.user.username} - {self.platform}"


class NotificationLog(models.Model):
    """
    Audit log for all notification delivery attempts.
    Useful for debugging and analytics.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    notification = models.ForeignKey(
        Notification,
        on_delete=models.CASCADE,
        related_name='delivery_logs'
    )
    delivery_type = models.CharField(
        max_length=20,
        choices=[
            ('websocket', 'WebSocket'),
            ('fcm', 'Firebase Cloud Messaging'),
        ]
    )
    status = models.CharField(
        max_length=20,
        choices=[
            ('pending', 'Pending'),
            ('sent', 'Sent'),
            ('failed', 'Failed'),
            ('delivered', 'Delivered'),
        ]
    )
    error_message = models.TextField(blank=True, null=True)
    timestamp = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-timestamp']
        verbose_name_plural = "Notification Logs"
    
    def __str__(self):
        return f"{self.notification.id} - {self.delivery_type}: {self.status}"


class NotificationPreference(models.Model):
    """
    User notification preferences - control which categories they receive.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='notification_preferences'
    )
    
    # Category preferences (enabled/disabled)
    order_notifications = models.BooleanField(default=True)
    bargain_notifications = models.BooleanField(default=True)
    table_notifications = models.BooleanField(default=True)
    staff_notifications = models.BooleanField(default=True)
    stock_notifications = models.BooleanField(default=True)
    revenue_notifications = models.BooleanField(default=True)
    
    # Delivery method preferences
    fcm_enabled = models.BooleanField(default=True)
    websocket_enabled = models.BooleanField(default=True)
    
    # Do not disturb
    dnd_enabled = models.BooleanField(default=False)
    dnd_start_time = models.TimeField(null=True, blank=True)
    dnd_end_time = models.TimeField(null=True, blank=True)
    
    updated_at = models.DateTimeField(auto_now=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name_plural = "Notification Preferences"
    
    def __str__(self):
        return f"{self.user.username} preferences"
    
    def is_category_enabled(self, category):
        """Check if a category is enabled"""
        preference_map = {
            NotificationCategory.ORDER: 'order_notifications',
            NotificationCategory.BARGAIN: 'bargain_notifications',
            NotificationCategory.TABLE: 'table_notifications',
            NotificationCategory.STAFF: 'staff_notifications',
            NotificationCategory.STOCK: 'stock_notifications',
            NotificationCategory.REVENUE: 'revenue_notifications',
        }
        return getattr(self, preference_map.get(category, 'order_notifications'), True)
