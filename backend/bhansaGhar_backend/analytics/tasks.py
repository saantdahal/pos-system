try:
    from celery import shared_task
except ImportError:
    # Celery not installed, provide no-op decorator
    def shared_task(*args, **kwargs):  # type: ignore
        def decorator(func):  # type: ignore
            return func
        if args and callable(args[0]):
            return args[0]
        return decorator

from django.utils import timezone
from restaurants.models import Restaurant
from .services import AnalyticsService
from .models import HourlyAnalytics, TopItem
import logging

logger = logging.getLogger(__name__)


@shared_task(name='analytics.update_daily_analytics')
def update_daily_analytics():
    """
    Celery task to update daily analytics for all restaurants
    Run daily (e.g., at midnight)
    """
    try:
        date = timezone.now().date()
        restaurants = Restaurant.objects.filter(is_active=True)
        
        for restaurant in restaurants:
            try:
                daily_analytics, created = AnalyticsService.save_daily_analytics(
                    restaurant,
                    date
                )
                logger.info(
                    f"{'Created' if created else 'Updated'} daily analytics "
                    f"for {restaurant.name} on {date}"
                )
            except Exception as e:
                logger.error(
                    f"Error updating daily analytics for {restaurant.name}: {str(e)}"
                )
        
        return f"Daily analytics updated for {restaurants.count()} restaurants"
    except Exception as e:
        logger.error(f"Error in update_daily_analytics task: {str(e)}")
        raise


@shared_task(name='analytics.update_hourly_analytics')
def update_hourly_analytics():
    """
    Celery task to update hourly analytics
    Run every hour
    """
    try:
        now = timezone.now()
        date = now.date()
        hour = now.hour
        
        restaurants = Restaurant.objects.filter(is_active=True)
        
        for restaurant in restaurants:
            try:
                # Get metrics for this hour
                metrics = AnalyticsService.calculate_daily_analytics(restaurant, date)
                
                # Create or update hourly analytics
                HourlyAnalytics.objects.update_or_create(
                    restaurant=restaurant,
                    date=date,
                    hour=hour,
                    defaults={
                        'total_orders': metrics.get('total_orders', 0),
                        'total_revenue': metrics.get('total_revenue', 0),
                        'avg_prep_time_seconds': metrics.get('avg_prep_time_seconds'),
                        'bargain_orders': metrics.get('bargain_orders_count', 0),
                    }
                )
                logger.info(
                    f"Updated hourly analytics for {restaurant.name} "
                    f"on {date} {hour:02d}:00"
                )
            except Exception as e:
                logger.error(
                    f"Error updating hourly analytics for {restaurant.name}: {str(e)}"
                )
        
        return f"Hourly analytics updated for {restaurants.count()} restaurants"
    except Exception as e:
        logger.error(f"Error in update_hourly_analytics task: {str(e)}")
        raise


@shared_task(name='analytics.update_top_items')
def update_top_items():
    """
    Celery task to update top items for each restaurant
    Run daily
    """
    try:
        date = timezone.now().date()
        restaurants = Restaurant.objects.filter(is_active=True)
        
        for restaurant in restaurants:
            try:
                # Get top items
                top_items = AnalyticsService.get_top_items(restaurant, days=7, limit=10)
                
                # Clear old entries for this date
                TopItem.objects.filter(restaurant=restaurant, date=date).delete()
                
                # Create new top items
                for idx, item in enumerate(top_items, 1):
                    TopItem.objects.create(
                        restaurant=restaurant,
                        date=date,
                        item_id=item['item_id'],
                        item_name=item['item_name'],
                        total_quantity=item['total_quantity'],
                        total_revenue=item['total_revenue'],
                        rank=idx
                    )
                
                logger.info(f"Updated top items for {restaurant.name}")
            except Exception as e:
                logger.error(f"Error updating top items for {restaurant.name}: {str(e)}")
        
        return f"Top items updated for {restaurants.count()} restaurants"
    except Exception as e:
        logger.error(f"Error in update_top_items task: {str(e)}")
        raise


@shared_task(name='analytics.cleanup_old_analytics')
def cleanup_old_analytics(days=90):
    """
    Celery task to cleanup old analytics data (older than N days)
    Run weekly
    """
    try:
        from datetime import timedelta
        cutoff_date = timezone.now().date() - timedelta(days=days)
        
        # Delete old hourly analytics
        deleted_hourly, _ = HourlyAnalytics.objects.filter(
            date__lt=cutoff_date
        ).delete()
        
        # Delete old top items
        deleted_items, _ = TopItem.objects.filter(
            date__lt=cutoff_date
        ).delete()
        
        logger.info(
            f"Cleanup: Deleted {deleted_hourly} hourly analytics "
            f"and {deleted_items} top items older than {cutoff_date}"
        )
        
        return f"Deleted {deleted_hourly} hourly records and {deleted_items} top items"
    except Exception as e:
        logger.error(f"Error in cleanup_old_analytics task: {str(e)}")
        raise
