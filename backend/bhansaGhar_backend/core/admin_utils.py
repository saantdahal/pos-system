"""
Admin utilities for analytics, filtering, and dashboard data aggregation
"""
from django.db.models import Sum, Count, Avg, Q, F, Max, Min
from django.utils import timezone
from django.utils.safestring import mark_safe
from datetime import timedelta, datetime
from decimal import Decimal
from restaurants.models import Restaurant
from orders.models import Order, BaseOrderStatus
from analytics.models import DailyAnalytics, HourlyAnalytics, TopItem
from invoices.models import Invoice
from core.models import User
import json


class DecimalEncoder(json.JSONEncoder):
    """Custom JSON encoder that handles Decimal types"""
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super().default(obj)


class AnalyticsAggregator:
    """Aggregates analytics data for admin dashboard"""
    
    @staticmethod
    def get_overall_stats(days=30):
        """Get overall platform statistics"""
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
    def get_today_stats(restaurant_id=None):
        """Get today's aggregated restaurant statistics"""
        today = timezone.now().date()
        
        orders = Order.objects.filter(created_at__date=today)
        if restaurant_id:
            orders = orders.filter(restaurant_id=restaurant_id)
        
        # Get active orders (not served/cancelled)
        active_orders = orders.exclude(
            status__in=[BaseOrderStatus.SERVED, BaseOrderStatus.CANCELLED]
        )
        
        # Calculate daily revenue
        daily_revenue = float(orders.aggregate(Sum('subtotal'))['subtotal__sum'] or 0)
        
        # Get aggregated restaurant data
        if restaurant_id:
            restaurant = Restaurant.objects.get(id=restaurant_id)
            total_staff = restaurant.staff.count()
            total_tables = restaurant.tables_capacity
            total_menu_items = restaurant.menu_items.count()
        else:
            # For super admin, aggregate across all restaurants
            restaurants = Restaurant.objects.filter(is_active=True)
            total_staff = User.objects.filter(
                role__in=['kitchen', 'waiter'],
                is_active=True,
                restaurant__in=restaurants
            ).distinct().count()
            total_tables = restaurants.aggregate(Sum('tables_capacity'))['tables_capacity__sum'] or 0
            total_menu_items = sum(r.menu_items.count() for r in restaurants)
        
        return {
            'orders_today': orders.count(),
            'active_orders': active_orders.count(),
            'daily_revenue': daily_revenue,
            'total_staff': total_staff,
            'total_tables': total_tables,
            'total_menu_items': total_menu_items,
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
            # Get active orders (not served/cancelled)
            active_orders = orders.exclude(
                status__in=[BaseOrderStatus.SERVED, BaseOrderStatus.CANCELLED]
            ).count()
            invoices = restaurant.invoice_set.all() if hasattr(restaurant, 'invoice_set') else Invoice.objects.filter(restaurant=restaurant)  # type: ignore[attr-defined]
            
            stat = {
                'id': str(restaurant.id),
                'name': restaurant.name,
                'owner': restaurant.owner.username if restaurant.owner else 'N/A',
                'total_orders': orders.count(),
                'active_orders': active_orders,
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
        from orders.models import OrderBargain
        
        bargains = OrderBargain.objects.all()
        
        if restaurant_id:
            bargains = bargains.filter(order__restaurant_id=restaurant_id)
        
        total = bargains.count()
        accepted = bargains.filter(customer_response='accepted').count()
        rejected = bargains.filter(customer_response='rejected').count()
        pending = bargains.filter(customer_response='pending').count()
        
        success_rate = (accepted / total * 100) if total > 0 else 0
        
        return {
            'total': total,
            'accepted': accepted,
            'rejected': rejected,
            'pending': pending,
            'success_rate': round(success_rate, 2),
        }


class AdminFilterMixin:
    """Mixin for restaurant-based filtering in admin"""
    
    def get_queryset(self, request):  # type: ignore[no-untyped-def]
        qs = super().get_queryset(request)  # type: ignore[misc]
        
        # Super admin sees everything
        if request.user.is_superuser:
            return qs
        
        # Restaurant owner sees only their restaurant data
        if hasattr(request.user, 'owned_restaurant'):
            restaurant = request.user.owned_restaurant
            return qs.filter(restaurant=restaurant)
        
        # Staff sees their restaurant data
        if request.user.restaurant:
            return qs.filter(restaurant=request.user.restaurant)
        
        return qs.none()
    
    def get_search_fields(self, request=None):
        """Override in child classes"""
        return []


class RestaurantListFilter:
    """Filter by restaurant in admin list view"""
    title = 'Restaurant'
    parameter_name = 'restaurant'
    
    def lookups(self, request, model_admin):
        if request.user.is_superuser:
            restaurants = Restaurant.objects.filter(is_active=True)
        else:
            if hasattr(request.user, 'owned_restaurant'):
                return [(request.user.owned_restaurant.id, request.user.owned_restaurant.name)]
            return []
        
        return [(r.id, r.name) for r in restaurants]
    
    def queryset(self, request, queryset):
        if self.value():  # type: ignore[attr-defined]
            return queryset.filter(restaurant__id=self.value())  # type: ignore[attr-defined]
        return queryset


def get_admin_dashboard_context(request):
    """Generate context data for admin dashboard template"""
    context = {
        'overall_stats': AnalyticsAggregator.get_overall_stats(),
        'overall_restaurant_stats': AnalyticsAggregator.get_today_stats(),
        'restaurant_stats': AnalyticsAggregator.get_restaurant_stats(),
        'order_breakdown': AnalyticsAggregator.get_order_status_breakdown(),
        'daily_revenue': AnalyticsAggregator.get_daily_revenue_chart(),
        'top_items': AnalyticsAggregator.get_top_items(),
        'staff_performance': AnalyticsAggregator.get_staff_performance(),
        'hourly_dist': AnalyticsAggregator.get_hourly_distribution(),
        'bargain_metrics': AnalyticsAggregator.get_bargain_metrics(),
    }
    
    # JSON encode chart data for safe template rendering
    chart_data = {
        'revenueLabels': context['daily_revenue'].get('labels', []),
        'revenueData': context['daily_revenue'].get('revenue', []),
        'orderPending': context['order_breakdown'].get('pending', 0),
        'orderPreparing': context['order_breakdown'].get('preparing', 0),
        'orderBargain': context['order_breakdown'].get('bargain', 0),
        'orderReady': context['order_breakdown'].get('ready', 0),
        'orderServed': context['order_breakdown'].get('served', 0),
        'orderCancelled': context['order_breakdown'].get('cancelled', 0),
        'hourlyLabels': context['hourly_dist'].get('hours', []),
        'hourlyData': context['hourly_dist'].get('orders', []),
        'bargainAccepted': context['bargain_metrics'].get('accepted', 0),
        'bargainRejected': context['bargain_metrics'].get('rejected', 0),
        'bargainPending': context['bargain_metrics'].get('pending', 0),
    }
    context['chart_data_json'] = mark_safe(json.dumps(chart_data, cls=DecimalEncoder))
    
    # Filter by restaurant if not superuser
    if not request.user.is_superuser:
        if hasattr(request.user, 'owned_restaurant'):
            restaurant_id = request.user.owned_restaurant.id
        elif request.user.restaurant:
            restaurant_id = request.user.restaurant.id
        else:
            restaurant_id = None
        
        if restaurant_id:
            context['overall_restaurant_stats'] = AnalyticsAggregator.get_today_stats(restaurant_id)
            context['restaurant_stats'] = AnalyticsAggregator.get_restaurant_stats(restaurant_id)
            context['order_breakdown'] = AnalyticsAggregator.get_order_status_breakdown(restaurant_id)
            context['daily_revenue'] = AnalyticsAggregator.get_daily_revenue_chart(restaurant_id=restaurant_id)
            context['top_items'] = AnalyticsAggregator.get_top_items(restaurant_id)
            context['staff_performance'] = AnalyticsAggregator.get_staff_performance(restaurant_id)
            context['hourly_dist'] = AnalyticsAggregator.get_hourly_distribution(restaurant_id)
            context['bargain_metrics'] = AnalyticsAggregator.get_bargain_metrics(restaurant_id)
            
            # Re-encode chart data for filtered view
            chart_data = {
                'revenueLabels': context['daily_revenue'].get('labels', []),
                'revenueData': context['daily_revenue'].get('revenue', []),
                'orderPending': context['order_breakdown'].get('pending', 0),
                'orderPreparing': context['order_breakdown'].get('preparing', 0),
                'orderBargain': context['order_breakdown'].get('bargain', 0),
                'orderReady': context['order_breakdown'].get('ready', 0),
                'orderServed': context['order_breakdown'].get('served', 0),
                'orderCancelled': context['order_breakdown'].get('cancelled', 0),
                'hourlyLabels': context['hourly_dist'].get('hours', []),
                'hourlyData': context['hourly_dist'].get('orders', []),
                'bargainAccepted': context['bargain_metrics'].get('accepted', 0),
                'bargainRejected': context['bargain_metrics'].get('rejected', 0),
                'bargainPending': context['bargain_metrics'].get('pending', 0),
            }
            context['chart_data_json'] = mark_safe(json.dumps(chart_data, cls=DecimalEncoder))
    
    return context
