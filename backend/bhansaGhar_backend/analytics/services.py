from django.db.models import Sum, Count, Avg, F, Q, DecimalField
from django.utils import timezone
from django.db.models.functions import Extract
from datetime import timedelta
from orders.models import Order, OrderBargain, OrderServeLog
from restaurants.models import Table, Restaurant
from core.models import User
from .models import DailyAnalytics, HourlyAnalytics, TopItem


class AnalyticsService:
    """
    Core analytics service for generating metrics
    """
    
    @staticmethod
    def calculate_daily_analytics(restaurant, date=None):
        """
        Calculate all daily metrics for a restaurant
        Returns dict with all metrics
        """
        if date is None:
            date = timezone.now().date()
        
        # Get all orders for the day
        orders = Order.objects.filter(
            restaurant=restaurant,
            created_at__date=date
        )
        
        # Basic metrics
        total_orders = orders.count()
        total_revenue = orders.aggregate(Sum('subtotal'))['subtotal__sum'] or 0
        
        # Prep time metrics (in seconds)
        ready_orders = orders.filter(status__in=['ready', 'served'])
        prep_times = []
        avg_prep_time_seconds = None
        min_prep_time_seconds = None
        max_prep_time_seconds = None
        
        if ready_orders.exists():
            prep_times_data = ready_orders.values('created_at', 'updated_at')
            prep_times = [
                int((item['updated_at'] - item['created_at']).total_seconds())
                for item in prep_times_data
                if item['updated_at'] and item['created_at']
            ]
            
            if prep_times:
                avg_prep_time_seconds = sum(prep_times) // len(prep_times)
                min_prep_time_seconds = min(prep_times)
                max_prep_time_seconds = max(prep_times)
        
        # Table metrics
        unique_tables_served = orders.values('table_number').distinct().count()
        tables_turnover = unique_tables_served
        
        # Bargain metrics
        bargains = OrderBargain.objects.filter(order__in=orders)
        bargain_orders_count = bargains.count()
        bargain_accepted = bargains.filter(status='accepted').count()
        bargain_success_rate = (
            (bargain_accepted / bargain_orders_count * 100) 
            if bargain_orders_count > 0 else 0
        )
        
        # Order status breakdown
        status_breakdown = {
            'pending': orders.filter(status='pending').count(),
            'preparing': orders.filter(status='preparing').count(),
            'ready': orders.filter(status='ready').count(),
            'served': orders.filter(status='served').count(),
            'cancelled': orders.filter(status='cancelled').count(),
        }
        
        # Waiter metrics - average serve time (from serve logs)
        serve_logs = OrderServeLog.objects.filter(order__in=orders)
        avg_serve_time_seconds = None
        if serve_logs.exists():
            serve_times = []
            for log in serve_logs:
                if log.order.updated_at and log.served_at:
                    serve_times.append(
                        int((log.served_at - log.order.updated_at).total_seconds())
                    )
            if serve_times:
                avg_serve_time_seconds = sum(serve_times) // len(serve_times)
        
        # Peak hour calculation
        peak_hour = None
        peak_hour_orders = 0
        if orders.exists():
            hourly_orders = orders.annotate(
                hour=Extract('created_at', 'hour')
            ).values('hour').annotate(count=Count('id')).order_by('-count').first()
            
            if hourly_orders:
                peak_hour = hourly_orders['hour']
                peak_hour_orders = hourly_orders['count']
        
        # Staff metrics
        staff_users = User.objects.filter(restaurant=restaurant)
        active_kitchen_staff = staff_users.filter(role='kitchen').count()
        active_waiters = staff_users.filter(role='waiter').count()
        
        return {
            'total_orders': total_orders,
            'total_revenue': float(total_revenue),
            'avg_prep_time_seconds': avg_prep_time_seconds,
            'min_prep_time_seconds': min_prep_time_seconds,
            'max_prep_time_seconds': max_prep_time_seconds,
            'tables_turnover': tables_turnover,
            'unique_tables_served': unique_tables_served,
            'bargain_orders_count': bargain_orders_count,
            'bargain_success_rate': bargain_success_rate,
            'pending_orders': status_breakdown['pending'],
            'preparing_orders': status_breakdown['preparing'],
            'ready_orders': status_breakdown['ready'],
            'served_orders': status_breakdown['served'],
            'cancelled_orders': status_breakdown['cancelled'],
            'avg_serve_time_seconds': avg_serve_time_seconds,
            'peak_hour': peak_hour,
            'peak_hour_orders': peak_hour_orders,
            'active_kitchen_staff': active_kitchen_staff,
            'active_waiters': active_waiters,
        }
    
    @staticmethod
    def save_daily_analytics(restaurant, date=None):
        """
        Calculate and save daily analytics
        """
        if date is None:
            date = timezone.now().date()
        
        metrics = AnalyticsService.calculate_daily_analytics(restaurant, date)
        
        daily_analytics, created = DailyAnalytics.objects.update_or_create(
            restaurant=restaurant,
            date=date,
            defaults=metrics
        )
        
        return daily_analytics, created
    
    @staticmethod
    def get_date_range_metrics(restaurant, days=30):
        """
        Get aggregated metrics for a date range (last N days)
        """
        end_date = timezone.now().date()
        start_date = end_date - timedelta(days=days-1)
        
        analytics = DailyAnalytics.objects.filter(
            restaurant=restaurant,
            date__range=[start_date, end_date]
        )
        
        if not analytics.exists():
            return None
        
        total_revenue = analytics.aggregate(Sum('total_revenue'))['total_revenue__sum'] or 0
        total_orders = analytics.aggregate(Sum('total_orders'))['total_orders__sum'] or 0
        avg_prep_time = analytics.aggregate(Avg('avg_prep_time_seconds'))['avg_prep_time_seconds__avg'] or 0
        avg_serve_time = analytics.aggregate(Avg('avg_serve_time_seconds'))['avg_serve_time_seconds__avg'] or 0
        total_bargains = analytics.aggregate(Sum('bargain_orders_count'))['bargain_orders_count__sum'] or 0
        avg_bargain_rate = analytics.aggregate(Avg('bargain_success_rate'))['bargain_success_rate__avg'] or 0
        
        # Daily breakdown
        daily_breakdown = list(
            analytics.values('date').annotate(
                revenue=F('total_revenue'),
                orders=F('total_orders')
            ).order_by('date')
        )
        
        # Hourly breakdown
        hourly_analytics = HourlyAnalytics.objects.filter(
            restaurant=restaurant,
            date__range=[start_date, end_date]
        ).values('hour').annotate(
            total_orders=Sum('total_orders'),
            total_revenue=Sum('total_revenue'),
            avg_prep_time=Avg('avg_prep_time_seconds')
        ).order_by('hour')
        
        return {
            'period': f"{start_date} to {end_date}",
            'days': days,
            'total_revenue': float(total_revenue),
            'total_orders': total_orders,
            'avg_revenue_per_order': float(total_revenue / total_orders) if total_orders > 0 else 0,
            'avg_prep_time_minutes': round(avg_prep_time / 60, 2) if avg_prep_time else 0,
            'avg_serve_time_minutes': round(avg_serve_time / 60, 2) if avg_serve_time else 0,
            'total_bargains': total_bargains,
            'avg_bargain_rate': round(avg_bargain_rate, 2),
            'daily_breakdown': daily_breakdown,
            'hourly_breakdown': list(hourly_analytics),
        }
    
    @staticmethod
    def get_top_items(restaurant, days=7, limit=10):
        """
        Get top selling items
        """
        end_date = timezone.now().date()
        start_date = end_date - timedelta(days=days-1)
        
        # Try to get from TopItem model first (cached)
        top_items = TopItem.objects.filter(
            restaurant=restaurant,
            date__range=[start_date, end_date]
        ).values(
            'item_id', 'item_name'
        ).annotate(
            total_quantity=Sum('total_quantity'),
            total_revenue=Sum('total_revenue')
        ).order_by('-total_quantity')[:limit]
        
        if top_items.exists():
            return list(top_items)
        
        # Fallback: calculate from orders
        orders = Order.objects.filter(
            restaurant=restaurant,
            created_at__date__range=[start_date, end_date]
        )
        
        # Parse JSON items field
        from decimal import Decimal
        top_items_data = {}
        for order in orders:
            if order.items and isinstance(order.items, list):
                for item in order.items:
                    item_id = item.get('item_id')
                    qty = item.get('qty', 0)
                    if item_id not in top_items_data:
                        top_items_data[item_id] = {
                            'qty': 0,
                            'revenue': Decimal('0.00')
                        }
                    top_items_data[item_id]['qty'] += qty
                    # Convert to Decimal for proper calculation
                    total_qty = sum([i.get('qty', 0) for i in order.items])
                    if total_qty > 0:
                        item_revenue = order.subtotal * Decimal(str(qty / total_qty))
                        top_items_data[item_id]['revenue'] += item_revenue
        
        sorted_items = sorted(
            top_items_data.items(),
            key=lambda x: x[1]['qty'],
            reverse=True
        )[:limit]
        
        return [
            {
                'item_id': item_id,
                'item_name': f"Item {item_id}",
                'total_quantity': data['qty'],
                'total_revenue': float(data['revenue'])
            }
            for item_id, data in sorted_items
        ]
    
    @staticmethod
    def get_kitchen_metrics(restaurant, days=7):
        """
        Kitchen staff specific metrics
        """
        end_date = timezone.now().date()
        start_date = end_date - timedelta(days=days-1)
        
        analytics = DailyAnalytics.objects.filter(
            restaurant=restaurant,
            date__range=[start_date, end_date]
        )
        
        total_orders = analytics.aggregate(Sum('total_orders'))['total_orders__sum'] or 0
        avg_prep_time = analytics.aggregate(Avg('avg_prep_time_seconds'))['avg_prep_time_seconds__avg'] or 0
        total_bargains = analytics.aggregate(Sum('bargain_orders_count'))['bargain_orders_count__sum'] or 0
        avg_bargain_rate = analytics.aggregate(Avg('bargain_success_rate'))['bargain_success_rate__avg'] or 0
        
        # Orders per hour
        orders_per_hour = total_orders / (days * 24) if total_orders > 0 else 0
        
        # Peak hours heatmap
        hourly_data = HourlyAnalytics.objects.filter(
            restaurant=restaurant,
            date__range=[start_date, end_date]
        ).values('hour').annotate(
            avg_orders=Avg('total_orders'),
            avg_prep_time=Avg('avg_prep_time_seconds')
        ).order_by('hour')
        
        return {
            'total_orders': total_orders,
            'orders_per_hour': round(orders_per_hour, 2),
            'avg_prep_time_minutes': round(avg_prep_time / 60, 2) if avg_prep_time else 0,
            'total_bargains': total_bargains,
            'bargain_success_rate': round(avg_bargain_rate, 2),
            'hourly_breakdown': list(hourly_data),
            'top_items': AnalyticsService.get_top_items(restaurant, days, 5),
        }
    
    @staticmethod
    def get_waiter_metrics(restaurant, days=7):
        """
        Waiter staff specific metrics
        """
        end_date = timezone.now().date()
        start_date = end_date - timedelta(days=days-1)
        
        analytics = DailyAnalytics.objects.filter(
            restaurant=restaurant,
            date__range=[start_date, end_date]
        )
        
        total_tables_served = analytics.aggregate(Sum('unique_tables_served'))['unique_tables_served__sum'] or 0
        total_days = analytics.count()
        avg_serve_time = analytics.aggregate(Avg('avg_serve_time_seconds'))['avg_serve_time_seconds__avg'] or 0
        
        # Tables turnover per day
        tables_turnover_per_day = total_tables_served / total_days if total_days > 0 else 0
        
        # Current table status distribution
        tables = Table.objects.filter(restaurant=restaurant)
        table_status_dist = {
            'available': tables.filter(status='available').count(),
            'occupied': tables.filter(status='occupied').count(),
            'dirty': tables.filter(status='dirty').count(),
        }
        
        # Daily breakdown
        daily_breakdown = list(
            analytics.values('date').annotate(
                tables_served=F('unique_tables_served'),
                serve_time_minutes=F('avg_serve_time_seconds')
            ).order_by('-date')
        )
        
        return {
            'total_tables_served': total_tables_served,
            'avg_tables_per_day': round(tables_turnover_per_day, 2),
            'avg_serve_time_minutes': round(avg_serve_time / 60, 2) if avg_serve_time else 0,
            'current_table_status': table_status_dist,
            'total_tables': tables.count(),
            'daily_breakdown': daily_breakdown,
        }
    
    @staticmethod
    def get_admin_metrics(restaurant, days=30):
        """
        Admin/Owner specific metrics - comprehensive business view
        """
        end_date = timezone.now().date()
        start_date = end_date - timedelta(days=days-1)
        
        analytics = DailyAnalytics.objects.filter(
            restaurant=restaurant,
            date__range=[start_date, end_date]
        )
        
        total_revenue = analytics.aggregate(Sum('total_revenue'))['total_revenue__sum'] or 0
        total_orders = analytics.aggregate(Sum('total_orders'))['total_orders__sum'] or 0
        avg_revenue_per_order = (total_revenue / total_orders) if total_orders > 0 else 0
        
        # Revenue trend
        revenue_trend = list(
            analytics.values('date').annotate(
                revenue=F('total_revenue'),
                orders=F('total_orders')
            ).order_by('date')
        )
        
        # Staff performance (orders per staff member)
        kitchen_staff = User.objects.filter(restaurant=restaurant, role='kitchen')
        waiter_staff = User.objects.filter(restaurant=restaurant, role='waiter')
        
        return {
            'total_revenue': float(total_revenue),
            'total_orders': total_orders,
            'avg_revenue_per_order': float(avg_revenue_per_order),
            'revenue_trend': revenue_trend,
            'top_items': AnalyticsService.get_top_items(restaurant, days, 10),
            'kitchen_staff_count': kitchen_staff.count(),
            'waiter_staff_count': waiter_staff.count(),
            'days': days,
        }
