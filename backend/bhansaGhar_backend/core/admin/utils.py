"""
Admin utilities for analytics and dashboard data aggregation
"""
from django.db.models import Sum, Count, Avg
from django.utils import timezone
from datetime import timedelta

from restaurants.models import MenuItem, Restaurant
from orders.models import Order, BaseOrderStatus, OrderBargain, BaseBargainStatus
from analytics.models import DailyAnalytics, HourlyAnalytics, TopItem
from invoices.models import Invoice
from ..models import User


class AnalyticsAggregator:
    """Aggregates analytics data for admin dashboard"""
    
    @staticmethod
    def get_overall_stats(days=None):
        """Get overall platform statistics"""
        if days is not None:
            end_date = timezone.now().date()
            start_date = end_date - timedelta(days=days)
            orders = Order.objects.filter(
                created_at__date__gte=start_date,
                created_at__date__lte=end_date
            )
            invoices = Invoice.objects.filter(
                created_at__date__gte=start_date,
                created_at__date__lte=end_date
            )
        else:
            orders = Order.objects.all()
            invoices = Invoice.objects.all()
        
        return {
            'total_restaurants': Restaurant.objects.filter(is_active=True).count(),
            'total_orders': orders.count(),
            'total_revenue': float(orders.aggregate(Sum('subtotal'))['subtotal__sum'] or 0),
            'total_invoices': invoices.count(),
            'total_users': User.objects.filter(is_active=True).count(),
            'active_staff': User.objects.filter(role__in=['kitchen', 'waiter'], is_active=True).count(),
            'avg_order_value': float(orders.aggregate(Avg('subtotal'))['subtotal__avg'] or 0),
        }
    
    @staticmethod
    def get_overall_restaurant_stats():
        """Get overall restaurant statistics"""
        return {
            'orders_today': Order.objects.filter(created_at__date=timezone.now().date()).count(),
            'active_orders': Order.objects.filter(status__in=['pending', 'preparing', 'ready']).count(),
            'total_staff': User.objects.filter(is_staff=True).count(),
            'total_tables': Restaurant.objects.aggregate(Sum('tables_capacity'))['tables_capacity__sum'] or 0,
            'total_menu_items': MenuItem.objects.count(),
            'daily_revenue': Order.objects.filter(created_at__date=timezone.now().date()).aggregate(Sum('subtotal'))['subtotal__sum'] or 0,
        }
    
    @staticmethod
    def get_restaurant_stats(restaurant_id=None):
        """Get statistics per restaurant"""
        restaurants = Restaurant.objects.filter(is_active=True)
        
        if restaurant_id:
            restaurants = restaurants.filter(id=restaurant_id)
        
        stats = []
        for restaurant in restaurants:
            orders = restaurant.orders.all()  # type: ignore[attr-defined]
            invoices = restaurant.invoice_set.all() if hasattr(restaurant, 'invoice_set') else Invoice.objects.filter(restaurant=restaurant)  # type: ignore[attr-defined]
            
            stat = {
                'id': str(restaurant.id),
                'name': restaurant.name,
                'owner': restaurant.owner.username if restaurant.owner else 'N/A',
                'total_orders': orders.count(),
                'total_revenue': float(orders.aggregate(Sum('subtotal'))['subtotal__sum'] or 0),
                'total_staff': restaurant.staff.count(),  # type: ignore[attr-defined]
                'tables_capacity': restaurant.tables_capacity,
                'is_active': restaurant.is_active,
            }
            stats.append(stat)
        
        return stats
    
    @staticmethod
    def get_order_status_breakdown(restaurant_id=None):
        """Get order status breakdown"""
        orders = Order.objects.all()
        
        if restaurant_id:
            orders = orders.filter(restaurant_id=restaurant_id)
        
        return {
            'pending': orders.filter(status=BaseOrderStatus.PENDING).count(),
            'preparing': orders.filter(status=BaseOrderStatus.PREPARING).count(),
            'ready': orders.filter(status=BaseOrderStatus.READY).count(),
            'served': orders.filter(status=BaseOrderStatus.SERVED).count(),
            'cancelled': orders.filter(status=BaseOrderStatus.CANCELLED).count(),
        }
    
    @staticmethod
    def get_daily_revenue_chart(days=30, restaurant_id=None):
        """Get daily revenue for chart"""
        end_date = timezone.now().date()
        start_date = end_date - timedelta(days=days)
        
        daily_data = DailyAnalytics.objects.filter(
            date__gte=start_date,
            date__lte=end_date
        )
        
        if restaurant_id:
            daily_data = daily_data.filter(restaurant_id=restaurant_id)
        
        daily_data = daily_data.order_by('date').values('date').annotate(
            total=Sum('total_revenue'),
            orders=Sum('total_orders')
        )
        
        return {
            'labels': [str(d['date']) for d in daily_data],
            'revenue': [float(d['total'] or 0) for d in daily_data],
            'orders': [d['orders'] or 0 for d in daily_data],
        }
    
    @staticmethod
    def get_top_items(restaurant_id=None, limit=10):
        """Get top selling items"""
        items = TopItem.objects.filter(
            date=timezone.now().date() - timedelta(days=7)
        )
        
        if restaurant_id:
            items = items.filter(restaurant_id=restaurant_id)
        
        items = items.order_by('rank')[:limit]
        
        return [{
            'rank': item.rank,
            'name': item.item_name,
            'quantity': item.total_quantity,
            'revenue': float(item.total_revenue or 0),
        } for item in items]
    
    @staticmethod
    def get_staff_performance(restaurant_id=None):
        """Get staff performance metrics"""
        staff = User.objects.filter(role__in=['kitchen', 'waiter'])
        
        if restaurant_id:
            staff = staff.filter(restaurant_id=restaurant_id)
        
        performance = []
        for user in staff:
            if user.role == 'waiter':
                orders_handled = user.assigned_waiter_orders.count()  # type: ignore[attr-defined]
                performance.append({
                    'name': user.username,
                    'role': 'Waiter',
                    'orders': orders_handled,
                    'status': 'Active' if user.is_active else 'Inactive',
                })
            elif user.role == 'kitchen':
                orders_handled = user.assigned_kitchen_orders.count()  # type: ignore[attr-defined]
                performance.append({
                    'name': user.username,
                    'role': 'Kitchen',
                    'orders': orders_handled,
                    'status': 'Active' if user.is_active else 'Inactive',
                })
        
        return sorted(performance, key=lambda x: x['orders'], reverse=True)
    
    @staticmethod
    def get_hourly_distribution(restaurant_id=None):
        """Get hourly order distribution"""
        hourly = HourlyAnalytics.objects.filter(
            date=timezone.now().date()
        )
        
        if restaurant_id:
            hourly = hourly.filter(restaurant_id=restaurant_id)
        
        hourly = hourly.order_by('hour').values('hour').annotate(
            orders=Sum('total_orders'),
            revenue=Sum('total_revenue')
        )
        
        hours = [f"{h:02d}:00" for h in range(24)]
        orders_by_hour = [0] * 24
        revenue_by_hour: list[float] = [0.0] * 24
        
        for h in hourly:
            hour = h['hour']
            orders_by_hour[hour] = h['orders'] or 0
            revenue_by_hour[hour] = float(h['revenue'] or 0)
        
        return {
            'hours': hours,
            'orders': orders_by_hour,
            'revenue': revenue_by_hour,
        }
    
    @staticmethod
    def get_bargain_metrics(restaurant_id=None):
        """Get bargain success metrics"""
        bargains = OrderBargain.objects.all()
        
        if restaurant_id:
            bargains = bargains.filter(order__restaurant_id=restaurant_id)
        
        total = bargains.count()
        accepted = bargains.filter(status=BaseBargainStatus.ACCEPTED).count()
        rejected = bargains.filter(status=BaseBargainStatus.REJECTED).count()
        pending = bargains.filter(status=BaseBargainStatus.PENDING).count()
        
        success_rate = (accepted / total * 100) if total > 0 else 0
        
        return {
            'total': total,
            'accepted': accepted,
            'rejected': rejected,
            'pending': pending,
            'success_rate': round(success_rate, 2),
        }


def get_admin_dashboard_context(request):
    """Generate context data for admin dashboard template"""
    context = {
        'overall_stats': AnalyticsAggregator.get_overall_stats(days=None),
        'restaurant_stats': AnalyticsAggregator.get_restaurant_stats(),
        'order_breakdown': AnalyticsAggregator.get_order_status_breakdown(),
        'daily_revenue': AnalyticsAggregator.get_daily_revenue_chart(),
        'top_items': AnalyticsAggregator.get_top_items(),
        'staff_performance': AnalyticsAggregator.get_staff_performance(),
        'hourly_dist': AnalyticsAggregator.get_hourly_distribution(),
        'bargain_metrics': AnalyticsAggregator.get_bargain_metrics(),
    }
    
    # Filter by restaurant if not superuser
    if not request.user.is_superuser:
        if hasattr(request.user, 'owned_restaurant'):
            restaurant_id = request.user.owned_restaurant.id
        elif request.user.restaurant:
            restaurant_id = request.user.restaurant.id
        else:
            restaurant_id = None
        
        if restaurant_id:
            context['restaurant_stats'] = AnalyticsAggregator.get_restaurant_stats(restaurant_id)
            context['order_breakdown'] = AnalyticsAggregator.get_order_status_breakdown(restaurant_id)
            context['daily_revenue'] = AnalyticsAggregator.get_daily_revenue_chart(restaurant_id=restaurant_id)
            context['top_items'] = AnalyticsAggregator.get_top_items(restaurant_id)
            context['staff_performance'] = AnalyticsAggregator.get_staff_performance(restaurant_id)
            context['hourly_dist'] = AnalyticsAggregator.get_hourly_distribution(restaurant_id)
            context['bargain_metrics'] = AnalyticsAggregator.get_bargain_metrics(restaurant_id)
    
    # Set overall restaurant stats for superuser
    if request.user.is_superuser:
        context['overall_restaurant_stats'] = AnalyticsAggregator.get_overall_restaurant_stats()
    
    return context
