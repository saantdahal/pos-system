from rest_framework import serializers
from .models import DailyAnalytics, HourlyAnalytics, TopItem


class DailyAnalyticsSerializer(serializers.ModelSerializer):
    class Meta:
        model = DailyAnalytics
        fields = [
            'date', 'total_orders', 'total_revenue', 'avg_prep_time_seconds',
            'min_prep_time_seconds', 'max_prep_time_seconds', 'tables_turnover',
            'unique_tables_served', 'bargain_orders_count', 'bargain_success_rate',
            'pending_orders', 'preparing_orders', 'ready_orders', 'served_orders',
            'cancelled_orders', 'avg_serve_time_seconds', 'peak_hour', 'peak_hour_orders',
            'active_kitchen_staff', 'active_waiters'
        ]


class HourlyAnalyticsSerializer(serializers.ModelSerializer):
    hour_display = serializers.SerializerMethodField()
    
    class Meta:
        model = HourlyAnalytics
        fields = [
            'date', 'hour', 'hour_display', 'total_orders', 'total_revenue',
            'avg_prep_time_seconds', 'bargain_orders'
        ]
    
    def get_hour_display(self, obj):
        return f"{obj.hour:02d}:00"


class TopItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = TopItem
        fields = ['item_id', 'item_name', 'total_quantity', 'total_revenue', 'rank']


class AdminAnalyticsSerializer(serializers.Serializer):
    """
    Serializer for admin dashboard analytics
    """
    total_revenue = serializers.DecimalField(max_digits=12, decimal_places=2)
    total_orders = serializers.IntegerField()
    avg_revenue_per_order = serializers.DecimalField(max_digits=12, decimal_places=2)
    revenue_trend = serializers.ListField()
    top_items = serializers.ListField()
    kitchen_staff_count = serializers.IntegerField()
    waiter_staff_count = serializers.IntegerField()
    days = serializers.IntegerField()


class KitchenAnalyticsSerializer(serializers.Serializer):
    """
    Serializer for kitchen staff analytics
    """
    total_orders = serializers.IntegerField()
    orders_per_hour = serializers.FloatField()
    avg_prep_time_minutes = serializers.FloatField()
    total_bargains = serializers.IntegerField()
    bargain_success_rate = serializers.FloatField()
    hourly_breakdown = serializers.ListField()
    top_items = serializers.ListField()


class WaiterAnalyticsSerializer(serializers.Serializer):
    """
    Serializer for waiter staff analytics
    """
    total_tables_served = serializers.IntegerField()
    avg_tables_per_day = serializers.FloatField()
    avg_serve_time_minutes = serializers.FloatField()
    current_table_status = serializers.DictField()
    total_tables = serializers.IntegerField()
    daily_breakdown = serializers.ListField()


class DateRangeAnalyticsSerializer(serializers.Serializer):
    """
    Serializer for date range analytics
    """
    period = serializers.CharField()
    days = serializers.IntegerField()
    total_revenue = serializers.FloatField()
    total_orders = serializers.IntegerField()
    avg_revenue_per_order = serializers.FloatField()
    avg_prep_time_minutes = serializers.FloatField()
    avg_serve_time_minutes = serializers.FloatField()
    total_bargains = serializers.IntegerField()
    avg_bargain_rate = serializers.FloatField()
    daily_breakdown = serializers.ListField()
    hourly_breakdown = serializers.ListField()
