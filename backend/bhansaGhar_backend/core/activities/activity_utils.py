from django.utils import timezone
from datetime import timedelta
from django.db.models import Q, Count
from django.http import HttpRequest
from typing import Optional
import logging

logger = logging.getLogger(__name__)


def get_client_ip(request: Optional[HttpRequest]) -> Optional[str]:
    """Extract client IP from request"""
    if not request:
        return None
    
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0]
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip


def get_user_agent(request: Optional[HttpRequest]) -> Optional[str]:
    """Extract user agent from request"""
    if not request:
        return None
    return request.META.get('HTTP_USER_AGENT', '')


def log_activity(user, activity_type, description, request=None, restaurant=None,
                related_object_type=None, related_object_id=None, metadata=None):
    """
    Main helper function to log user activities.
    
    Args:
        user: The User instance
        activity_type: ActivityType choice value
        description: Human-readable description
        request: Django request object (optional, for IP and user agent)
        restaurant: Restaurant instance (optional, defaults to user's restaurant)
        related_object_type: Type of related object (e.g., 'order', 'menu_item')
        related_object_id: ID of the related object
        metadata: Additional context data as dict
    
    Returns:
        ActivityLog instance or None if error occurs
    """
    # Lazy import to avoid circular dependencies during app initialization
    from .activity_models import ActivityLog
    
    try:
        if not restaurant:
            restaurant = getattr(user, 'restaurant', None) or getattr(user, 'owned_restaurant', None)
        
        ip_address: Optional[str] = get_client_ip(request) if request else None
        user_agent: Optional[str] = get_user_agent(request) if request else None
        
        activity = ActivityLog.create_activity(
            user=user,
            activity_type=activity_type,
            description=description,
            restaurant=restaurant,
            related_object_type=related_object_type,
            related_object_id=related_object_id,
            metadata=metadata,
            ip_address=ip_address,
            user_agent=user_agent,
        )
        return activity
    except Exception as e:
        logger.error(f"Error logging activity for user {user.id}: {str(e)}")
        return None


def get_user_today_activities(user):
    """Get all activities for a user today"""
    from .activity_models import ActivityLog
    
    today_start = timezone.now().replace(hour=0, minute=0, second=0, microsecond=0)
    today_end = today_start + timedelta(days=1)
    
    return ActivityLog.objects.filter(
        user=user,
        created_at__gte=today_start,
        created_at__lt=today_end,
    ).order_by('-created_at')


def get_restaurant_today_activities(restaurant):
    """Get all activities for a restaurant today"""
    from .activity_models import ActivityLog
    
    today_start = timezone.now().replace(hour=0, minute=0, second=0, microsecond=0)
    today_end = today_start + timedelta(days=1)
    
    return ActivityLog.objects.filter(
        restaurant=restaurant,
        created_at__gte=today_start,
        created_at__lt=today_end,
    ).order_by('-created_at')


def get_restaurant_staff_activities(restaurant, user):
    """Get activities for a specific staff member in a restaurant today"""
    from .activity_models import ActivityLog
    
    today_start = timezone.now().replace(hour=0, minute=0, second=0, microsecond=0)
    today_end = today_start + timedelta(days=1)
    
    return ActivityLog.objects.filter(
        user=user,
        restaurant=restaurant,
        created_at__gte=today_start,
        created_at__lt=today_end,
    ).order_by('-created_at')


def get_activity_stats_for_user(user, days=7):
    """Get activity statistics for a user over last N days"""
    from .activity_models import ActivityLog
    
    start_date = timezone.now() - timedelta(days=days)
    
    activities = ActivityLog.objects.filter(
        user=user,
        created_at__gte=start_date,
    )
    
    today_start = timezone.now().replace(hour=0, minute=0, second=0, microsecond=0)
    activities_today = activities.filter(created_at__gte=today_start)
    
    # Activity breakdown by type
    activity_breakdown = dict(
        activities.values('activity_type').annotate(count=Count('id')).values_list('activity_type', 'count')
    )
    
    return {
        'total_activities': activities.count(),
        'activities_today': activities_today.count(),
        'recent_activities': activities[:10],
        'activity_breakdown': activity_breakdown,
    }


def get_activity_stats_for_restaurant(restaurant, days=7):
    """Get activity statistics for a restaurant over last N days"""
    from .activity_models import ActivityLog
    
    start_date = timezone.now() - timedelta(days=days)
    
    activities = ActivityLog.objects.filter(
        restaurant=restaurant,
        created_at__gte=start_date,
    )
    
    today_start = timezone.now().replace(hour=0, minute=0, second=0, microsecond=0)
    activities_today = activities.filter(created_at__gte=today_start)
    
    # Activity breakdown by type
    activity_breakdown = dict(
        activities.values('activity_type').annotate(count=Count('id')).values_list('activity_type', 'count')
    )
    
    return {
        'total_activities': activities.count(),
        'activities_today': activities_today.count(),
        'recent_activities': activities[:10],
        'activity_breakdown': activity_breakdown,
    }


def get_staff_activities_breakdown(restaurant):
    """Get activity breakdown by staff member in a restaurant today"""
    from .activity_models import ActivityLog
    
    today_start = timezone.now().replace(hour=0, minute=0, second=0, microsecond=0)
    
    staff_activities = ActivityLog.objects.filter(
        restaurant=restaurant,
        created_at__gte=today_start,
    ).values('user', 'user__username', 'user__role').annotate(count=Count('id')).order_by('-count')
    
    return staff_activities
