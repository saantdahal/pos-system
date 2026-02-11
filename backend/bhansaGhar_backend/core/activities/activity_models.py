from django.db import models
from django.utils import timezone
import uuid


class ActivityType(models.TextChoices):
    """Activity types for logging user actions"""
    # Authentication activities
    LOGIN = 'login', 'User Login'
    LOGOUT = 'logout', 'User Logout'
    
    # Order activities (Waiter/Kitchen/Admin)
    ORDER_CREATED = 'order_created', 'Order Created'
    ORDER_UPDATED = 'order_updated', 'Order Status Updated'
    ORDER_CANCELLED = 'order_cancelled', 'Order Cancelled'
    ORDER_PREPARED = 'order_prepared', 'Order Marked as Prepared'
    ORDER_SERVED = 'order_served', 'Order Marked as Served'
    
    # Bargain activities
    BARGAIN_CREATED = 'bargain_created', 'Bargain Created'
    BARGAIN_ACCEPTED = 'bargain_accepted', 'Bargain Accepted'
    BARGAIN_REJECTED = 'bargain_rejected', 'Bargain Rejected'
    
    # Profile activities
    PROFILE_UPDATED = 'profile_updated', 'Profile Updated'
    MODE_CHANGED = 'mode_changed', 'Mode Changed'
    
    # Menu activities
    MENU_VIEWED = 'menu_viewed', 'Menu Viewed'
    MENU_ITEM_ADDED = 'menu_item_added', 'Menu Item Added'
    MENU_ITEM_UPDATED = 'menu_item_updated', 'Menu Item Updated'
    MENU_ITEM_DELETED = 'menu_item_deleted', 'Menu Item Deleted'
    
    # Staff management (Admin only)
    STAFF_INVITED = 'staff_invited', 'Staff Member Invited'
    STAFF_ADDED = 'staff_added', 'Staff Member Added'
    STAFF_REMOVED = 'staff_removed', 'Staff Member Removed'
    
    # Restaurant activities (Admin)
    RESTAURANT_UPDATED = 'restaurant_updated', 'Restaurant Settings Updated'
    RESTAURANT_CATEGORY_UPDATED = 'restaurant_category_updated', 'Restaurant Category Updated'
    
    # Other activities
    OTHER = 'other', 'Other Activity'


class ActivityLog(models.Model):
    """Model to track all user activities in the system"""
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    user = models.ForeignKey('core.User', on_delete=models.CASCADE, related_name='activity_logs')
    restaurant = models.ForeignKey('restaurants.Restaurant', on_delete=models.CASCADE, related_name='activity_logs', null=True, blank=True)
    
    # Activity details
    activity_type = models.CharField(max_length=50, choices=ActivityType.choices)
    description = models.TextField(help_text="Human-readable description of the activity")
    
    # Related objects (foreign keys for context)
    related_object_type = models.CharField(max_length=50, blank=True, null=True, help_text="Type of related object (e.g., 'order', 'user', 'menu_item')")
    related_object_id = models.CharField(max_length=255, blank=True, null=True, help_text="ID of the related object")
    
    # Metadata for additional context
    metadata = models.JSONField(default=dict, blank=True, help_text="Additional context data for the activity")
    
    # IP and User Agent for security
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(blank=True, null=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    
    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', 'created_at']),
            models.Index(fields=['user', 'activity_type']),
            models.Index(fields=['restaurant', 'created_at']),
            models.Index(fields=['created_at']),
        ]
        verbose_name = 'Activity Log'
        verbose_name_plural = 'Activity Logs'
    
    def __str__(self) -> str:
        # Get display value for activity_type choice
        activity_display = next(
            (label for value, label in ActivityType.choices if value == self.activity_type),
            self.activity_type
        )
        return f"{self.user.username} - {activity_display} at {self.created_at}"
    
    @staticmethod
    def create_activity(user, activity_type, description, restaurant=None, 
                       related_object_type=None, related_object_id=None, 
                       metadata=None, ip_address=None, user_agent=None):
        """Helper method to create an activity log"""
        activity = ActivityLog.objects.create(
            user=user,
            restaurant=restaurant or getattr(user, 'restaurant', None) or getattr(user, 'owned_restaurant', None),
            activity_type=activity_type,
            description=description,
            related_object_type=related_object_type,
            related_object_id=related_object_id,
            metadata=metadata or {},
            ip_address=ip_address,
            user_agent=user_agent,
        )
        return activity
