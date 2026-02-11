from django.db import models
from django.db.models import Sum, Count, Avg, Q
from restaurants.models import Restaurant
from django.utils import timezone
from decimal import Decimal


class DailyAnalytics(models.Model):
    """
    Aggregated daily metrics for analytics dashboard
    """
    restaurant = models.ForeignKey(
        Restaurant,
        on_delete=models.CASCADE,
        related_name='daily_analytics'
    )
    date = models.DateField(auto_now=False)
    
    # Revenue metrics
    total_orders = models.IntegerField(default=0)
    total_revenue = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=Decimal('0.00')
    )
    
    # Prep time metrics (in seconds)
    avg_prep_time_seconds = models.IntegerField(null=True, blank=True)
    min_prep_time_seconds = models.IntegerField(null=True, blank=True)
    max_prep_time_seconds = models.IntegerField(null=True, blank=True)
    
    # Table metrics
    tables_turnover = models.FloatField(default=0)  # Tables served per day
    unique_tables_served = models.IntegerField(default=0)
    
    # Bargain metrics
    bargain_orders_count = models.IntegerField(default=0)
    bargain_success_rate = models.FloatField(default=0)  # % accepted / total bargains
    
    # Order status breakdown
    pending_orders = models.IntegerField(default=0)
    preparing_orders = models.IntegerField(default=0)
    ready_orders = models.IntegerField(default=0)
    served_orders = models.IntegerField(default=0)
    cancelled_orders = models.IntegerField(default=0)
    
    # Waiter metrics (in seconds)
    avg_serve_time_seconds = models.IntegerField(null=True, blank=True)
    
    # Peak hours
    peak_hour = models.IntegerField(null=True, blank=True)  # Hour (0-23)
    peak_hour_orders = models.IntegerField(default=0)
    
    # Staff performance
    active_kitchen_staff = models.IntegerField(default=0)
    active_waiters = models.IntegerField(default=0)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ('restaurant', 'date')
        ordering = ['-date']
        indexes = [
            models.Index(fields=['restaurant', 'date']),
        ]
    
    def __str__(self):
        return f"{self.restaurant.name} - {self.date}"


class HourlyAnalytics(models.Model):
    """
    Hourly breakdown for real-time analytics
    """
    restaurant = models.ForeignKey(
        Restaurant,
        on_delete=models.CASCADE,
        related_name='hourly_analytics'
    )
    date = models.DateField(auto_now=False)
    hour = models.IntegerField(choices=[(h, f"{h:02d}:00") for h in range(24)])
    
    # Orders in this hour
    total_orders = models.IntegerField(default=0)
    total_revenue = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=Decimal('0.00')
    )
    
    # Avg prep time (seconds)
    avg_prep_time_seconds = models.IntegerField(null=True, blank=True)
    
    # Bargains
    bargain_orders = models.IntegerField(default=0)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ('restaurant', 'date', 'hour')
        ordering = ['-date', '-hour']
        indexes = [
            models.Index(fields=['restaurant', 'date', 'hour']),
        ]
    
    def __str__(self):
        return f"{self.restaurant.name} - {self.date} {self.hour:02d}:00"


class TopItem(models.Model):
    """
    Top selling items per restaurant per date
    """
    restaurant = models.ForeignKey(
        Restaurant,
        on_delete=models.CASCADE,
        related_name='top_items'
    )
    date = models.DateField(auto_now=False)
    item_id = models.IntegerField()  # MenuItem ID from menu
    item_name = models.CharField(max_length=255)
    
    total_quantity = models.IntegerField(default=0)
    total_revenue = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=Decimal('0.00')
    )
    
    rank = models.IntegerField()  # 1-10
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        unique_together = ('restaurant', 'date', 'item_id')
        ordering = ['-date', 'rank']
        indexes = [
            models.Index(fields=['restaurant', 'date', 'rank']),
        ]
    
    def __str__(self):
        return f"{self.item_name} - {self.total_quantity} units"
