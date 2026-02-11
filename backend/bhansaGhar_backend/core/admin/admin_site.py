"""
Custom admin site configuration for Sperium Lounge
Super Admin Dashboard with Restaurant Management
"""
from django.contrib.admin.sites import AdminSite
from django.urls import path, URLPattern, URLResolver
from django.shortcuts import render
from django.template.response import TemplateResponse
from django.http import JsonResponse
from django.db import models
from django.db.models import Sum, Count, Avg, Q
from datetime import datetime, timedelta
from django.utils import timezone
import json

from .utils import get_admin_dashboard_context, AnalyticsAggregator
from restaurants.models import Restaurant, MenuItem, Table, Category
from orders.models import Order, OrderBargain
from invoices.models import Invoice
# from core.models import User  # Removed to avoid circular import issues


class SperiumAdminSite(AdminSite):
    """Custom admin site with professional super admin dashboard"""
    site_header = "🍽️ Sperium Lounge Administration"
    site_title = "Sperium Admin Panel"
    index_title = "Dashboard"
    site_url = None  # type: ignore[assignment]  # Remove the "View site" link

    def get_urls(self) -> list[URLResolver]:
        urls = super().get_urls()
        custom_urls: list[URLPattern] = [
            path('dashboard/', self.admin_view(self.dashboard_view), name='dashboard'),
            path('restaurant-dashboard/<uuid:restaurant_id>/', self.admin_view(self.restaurant_dashboard_view), name='restaurant_dashboard'),
            path('restaurant/<uuid:restaurant_id>/', self.admin_view(self.restaurant_detail_dashboard_view), name='restaurant_detail_dashboard'),
            path('restaurant/update/', self.admin_view(self.update_restaurant_view), name='update_restaurant'),
            path('api/restaurant-stats/<uuid:restaurant_id>/', self.admin_view(self.restaurant_stats_api), name='restaurant_stats_api'),
            path('api/current-restaurant/', self.admin_view(self.current_restaurant_api), name='current_restaurant_api'),
            path('api/dashboard-data/', self.admin_view(self.dashboard_data_api), name='dashboard_data_api'),
        ]
        return custom_urls + urls  # type: ignore[return-value]

    def dashboard_view(self, request):
        """Render super admin dashboard with real-time data"""
        user = request.user
        
        # Build comprehensive dashboard context
        context = self._build_dashboard_context(request)
        context.update(self.each_context(request))
        
        template = 'admin/dashboard.html'
        return render(request, template, context)

    def restaurant_dashboard_view(self, request, restaurant_id):
        """Render individual restaurant dashboard"""
        try:
            restaurant = Restaurant.objects.get(id=restaurant_id)
        except Restaurant.DoesNotExist:
            from django.shortcuts import redirect
            return redirect('/admin/')
        
        # Check permissions
        user = request.user
        if not user.is_superuser:
            user_restaurant = getattr(user, 'owned_restaurant', None) or getattr(user, 'restaurant', None)
            if restaurant != user_restaurant:
                from django.shortcuts import redirect
                return redirect('/admin/')
        
        # Build restaurant-specific context
        context = self._build_restaurant_context(restaurant)
        context.update(self.each_context(request))
        context['is_super_admin'] = user.is_superuser
        
        template = 'admin/restaurant_dashboard.html'
        return render(request, template, context)

    def restaurant_detail_dashboard_view(self, request, restaurant_id):
        """Render dedicated restaurant detail dashboard with all restaurant-specific data"""
        try:
            restaurant = Restaurant.objects.get(id=restaurant_id)
        except Restaurant.DoesNotExist:
            from django.shortcuts import redirect
            return redirect('/admin/dashboard/')
        
        # Check permissions - only super admin or restaurant owner/staff can view
        user = request.user
        if not user.is_superuser:
            user_restaurant = getattr(user, 'owned_restaurant', None) or getattr(user, 'restaurant', None)
            if restaurant != user_restaurant:
                from django.shortcuts import redirect
                return redirect('/admin/dashboard/')
        
        # Build comprehensive restaurant-specific context
        context = self._build_restaurant_detail_context(restaurant)
        context.update(self.each_context(request))
        
        template = 'admin/restaurant_detail_dashboard.html'
        return render(request, template, context)

    def update_restaurant_view(self, request):
        """AJAX view to update restaurant details"""
        if request.method != 'POST':
            return JsonResponse({'success': False, 'error': 'Method not allowed'})
        
        restaurant_id = request.POST.get('restaurant_id')
        if not restaurant_id:
            return JsonResponse({'success': False, 'error': 'Restaurant ID required'})
        
        try:
            restaurant = Restaurant.objects.get(id=restaurant_id)
        except Restaurant.DoesNotExist:
            return JsonResponse({'success': False, 'error': 'Restaurant not found'})
        
        # Check permissions
        user = request.user
        if not user.is_superuser:
            user_restaurant = getattr(user, 'owned_restaurant', None) or getattr(user, 'restaurant', None)
            if restaurant != user_restaurant:
                return JsonResponse({'success': False, 'error': 'Permission denied'})
        
        try:
            # Update restaurant fields
            restaurant.name = request.POST.get('name', restaurant.name)
            restaurant.address = request.POST.get('address', restaurant.address)
            restaurant.phone = request.POST.get('phone', restaurant.phone)
            restaurant.description = request.POST.get('description', restaurant.description)
            restaurant.about = request.POST.get('about', restaurant.about)
            
            # Handle numeric fields
            if request.POST.get('tables_capacity'):
                restaurant.tables_capacity = int(request.POST.get('tables_capacity'))
            if request.POST.get('latitude'):
                restaurant.latitude = float(request.POST.get('latitude'))
            if request.POST.get('longitude'):
                restaurant.longitude = float(request.POST.get('longitude'))
            
            # Handle boolean field
            restaurant.is_active = request.POST.get('is_active') == 'true'
            
            # Handle foreign key
            if request.POST.get('type'):
                from restaurants.models import RestaurantType
                try:
                    restaurant.type = RestaurantType.objects.get(id=request.POST.get('type'))
                except RestaurantType.DoesNotExist:
                    pass
            
            # Handle file upload
            if request.FILES.get('hero_image'):
                restaurant.hero_image = request.FILES.get('hero_image')
            
            restaurant.save()
            
            return JsonResponse({'success': True})
            
        except Exception as e:
            return JsonResponse({'success': False, 'error': str(e)})

    def _build_restaurant_context(self, restaurant):
        """Build context for individual restaurant dashboard"""
        from core.models import User  # Import here to avoid circular import issues
        today = timezone.now().date()
        thirty_days_ago = today - timedelta(days=30)
        
        # Get restaurant-specific data
        r_orders = Order.objects.filter(restaurant=restaurant)
        r_orders_30d = r_orders.filter(created_at__date__gte=thirty_days_ago)
        r_users = User.objects.filter(Q(restaurant=restaurant) | Q(owned_restaurant=restaurant))
        
        # Restaurant data
        restaurant_data = {
            'id': str(restaurant.id),
            'name': restaurant.name,
            'address': restaurant.address or '',
            'owner': restaurant.owner.username if restaurant.owner else 'N/A',
            'is_active': restaurant.is_active,
            'tables_capacity': restaurant.tables_capacity,
            'phone': restaurant.phone or '',
            'description': restaurant.description or '',
            'about': restaurant.about or '',
            'latitude': restaurant.latitude,
            'longitude': restaurant.longitude,
            'type': restaurant.type,
            'hero_image': restaurant.hero_image,
        }
        
        # Today's statistics
        orders_today = r_orders.filter(created_at__date=today)
        today_stats = {
            'orders_today': orders_today.count(),
            'active_orders': r_orders.filter(status__in=['pending', 'preparing', 'bargain', 'ready']).count(),
            'daily_revenue': float(orders_today.filter(status='served').aggregate(Sum('subtotal'))['subtotal__sum'] or 0),
            'total_tables': Table.objects.filter(restaurant=restaurant).count(),
            'total_menu_items': MenuItem.objects.filter(restaurant=restaurant).count(),
        }
        
        # 30-day statistics
        stats = {
            'total_orders': r_orders_30d.count(),
            'total_revenue': float(r_orders_30d.filter(status='served').aggregate(Sum('subtotal'))['subtotal__sum'] or 0),
            'avg_order_value': float(r_orders_30d.aggregate(Avg('subtotal'))['subtotal__avg'] or 0),
            'staff_count': r_users.filter(role__in=['kitchen', 'waiter', 'admin']).count(),
        }
        
        # Order breakdown
        order_breakdown = {
            'pending': orders_today.filter(status='pending').count(),
            'preparing': orders_today.filter(status='preparing').count(),
            'ready': orders_today.filter(status='ready').count(),
            'served': orders_today.filter(status='served').count(),
            'cancelled': orders_today.filter(status='cancelled').count(),
        }
        
        # Bargain metrics
        r_bargains = OrderBargain.objects.filter(order__restaurant=restaurant)
        total_bargains = r_bargains.count()
        bargain_metrics = {
            'total': total_bargains,
            'accepted': r_bargains.filter(customer_response='accepted').count(),
            'rejected': r_bargains.filter(customer_response='rejected').count(),
            'pending': r_bargains.filter(customer_response='pending').count(),
            'success_rate': round((r_bargains.filter(customer_response='accepted').count() / total_bargains * 100) if total_bargains > 0 else 0, 2),
        }
        
        # Charts data
        daily_revenue = self._get_daily_revenue(r_orders, thirty_days_ago, today)
        hourly_dist = self._get_hourly_distribution(r_orders.filter(created_at__date=today))
        top_items = self._get_top_items(r_orders_30d)
        staff_performance = self._get_staff_performance(r_users, r_orders)
        
        # Restaurant types for edit form
        from restaurants.models import RestaurantType
        restaurant_types = RestaurantType.objects.all()
        
        return {
            'restaurant_data': restaurant_data,
            'today_stats': today_stats,
            'stats': stats,
            'order_breakdown': order_breakdown,
            'bargain_metrics': bargain_metrics,
            'daily_revenue': daily_revenue,
            'hourly_dist': hourly_dist,
            'top_items': top_items,
            'staff_performance': staff_performance,
            'restaurant_types': restaurant_types,
        }

    def _build_restaurant_detail_context(self, restaurant):
        """Build comprehensive context for dedicated restaurant detail dashboard"""
        from core.models import User
        today = timezone.now().date()
        thirty_days_ago = today - timedelta(days=30)
        
        # Get restaurant-specific data
        r_orders = Order.objects.filter(restaurant=restaurant)
        r_orders_30d = r_orders.filter(created_at__date__gte=thirty_days_ago)
        r_users = User.objects.filter(Q(restaurant=restaurant) | Q(owned_restaurant=restaurant))
        
        # Restaurant data
        restaurant_data = {
            'id': str(restaurant.id),
            'name': restaurant.name,
            'address': restaurant.address or '',
            'owner': restaurant.owner.username if restaurant.owner else 'N/A',
            'is_active': restaurant.is_active,
            'tables_capacity': restaurant.tables_capacity,
            'phone': restaurant.phone or '',
            'description': restaurant.description or '',
            'about': restaurant.about or '',
            'latitude': restaurant.latitude,
            'longitude': restaurant.longitude,
            'type': restaurant.type,
            'hero_image': restaurant.hero_image,
        }
        
        # Today's statistics
        orders_today = r_orders.filter(created_at__date=today)
        today_stats = {
            'orders_today': orders_today.count(),
            'active_orders': r_orders.filter(status__in=['pending', 'preparing', 'bargain', 'ready']).count(),
            'daily_revenue': float(orders_today.filter(status='served').aggregate(Sum('subtotal'))['subtotal__sum'] or 0),
            'total_tables': Table.objects.filter(restaurant=restaurant).count(),
            'total_menu_items': MenuItem.objects.filter(restaurant=restaurant).count(),
        }
        
        # 30-day statistics
        stats = {
            'total_orders': r_orders_30d.count(),
            'total_revenue': float(r_orders_30d.filter(status='served').aggregate(Sum('subtotal'))['subtotal__sum'] or 0),
            'avg_order_value': float(r_orders_30d.aggregate(Avg('subtotal'))['subtotal__avg'] or 0),
            'staff_count': r_users.filter(role__in=['kitchen', 'waiter', 'admin']).count(),
            'total_menu_items': MenuItem.objects.filter(restaurant=restaurant).count(),
        }
        
        # Order breakdown
        order_breakdown = {
            'pending': r_orders.filter(status='pending').count(),
            'preparing': r_orders.filter(status='preparing').count(),
            'ready': r_orders.filter(status='ready').count(),
            'served': r_orders.filter(status='served').count(),
            'cancelled': r_orders.filter(status='cancelled').count(),
        }
        
        # Bargain metrics
        r_bargains = OrderBargain.objects.filter(order__restaurant=restaurant)
        total_bargains = r_bargains.count()
        bargain_metrics = {
            'total': total_bargains,
            'accepted': r_bargains.filter(customer_response='accepted').count(),
            'rejected': r_bargains.filter(customer_response='rejected').count(),
            'pending': r_bargains.filter(customer_response='pending').count(),
            'success_rate': round((r_bargains.filter(customer_response='accepted').count() / total_bargains * 100) if total_bargains > 0 else 0, 2),
        }
        
        # Charts data
        daily_revenue = self._get_daily_revenue(r_orders, thirty_days_ago, today)
        hourly_dist = self._get_hourly_distribution(r_orders.filter(created_at__date=today))
        top_items = self._get_top_items(r_orders_30d)
        staff_performance = self._get_staff_performance(r_users, r_orders)
        
        # Get menu categories and items
        menu_categories = Category.objects.filter(restaurant=restaurant)
        menu_categories_with_counts = []
        for cat in menu_categories:
            menu_categories_with_counts.append({
                'id': str(cat.id),
                'name': cat.name,
                'menu_items_count': MenuItem.objects.filter(category=cat).count(),
            })
        
        menu_items = MenuItem.objects.filter(restaurant=restaurant).select_related('category')[:20]
        
        # Get recent orders
        recent_orders = r_orders.order_by('-created_at')[:10]
        
        # Get recent invoices
        recent_invoices = Invoice.objects.filter(restaurant=restaurant).order_by('-created_at')[:10]
        
        # Get staff members
        staff_list = r_users.filter(role__in=['kitchen', 'waiter', 'admin']).order_by('-is_active')[:15]
        
        # Get tables
        tables = Table.objects.filter(restaurant=restaurant)
        tables_count = tables.count()
        
        return {
            'restaurant_data': restaurant_data,
            'today_stats': today_stats,
            'stats': stats,
            'order_breakdown': order_breakdown,
            'bargain_metrics': bargain_metrics,
            'daily_revenue': daily_revenue,
            'hourly_dist': hourly_dist,
            'top_items': top_items,
            'staff_performance': staff_performance,
            'menu_categories': menu_categories_with_counts,
            'menu_items': menu_items,
            'recent_orders': recent_orders,
            'recent_invoices': recent_invoices,
            'staff_list': staff_list,
            'tables': tables,
            'tables_count': tables_count,
            'restaurant_name': restaurant.name,
        }

    def _build_dashboard_context(self, request):
        """Build comprehensive dashboard context with real data"""
        from core.models import User
        user = request.user
        today = timezone.now().date()
        thirty_days_ago = today - timedelta(days=30)
        
        # Determine if user is super admin or restaurant admin
        is_super_admin = user.is_superuser
        user_restaurant = None
        
        if not is_super_admin:
            if hasattr(user, 'owned_restaurant') and user.owned_restaurant:
                user_restaurant = user.owned_restaurant
            elif hasattr(user, 'restaurant') and user.restaurant:
                user_restaurant = user.restaurant
        
        # Get all restaurants or filter by user's restaurant
        if is_super_admin:
            restaurants = Restaurant.objects.filter(is_active=True)
            all_orders = Order.objects.all()
            all_invoices = Invoice.objects.all()
            all_users = User.objects.filter(is_active=True)
        else:
            restaurants = Restaurant.objects.filter(id=user_restaurant.id) if user_restaurant else Restaurant.objects.none()
            all_orders = Order.objects.filter(restaurant=user_restaurant) if user_restaurant else Order.objects.none()
            all_invoices = Invoice.objects.filter(restaurant=user_restaurant) if user_restaurant else Invoice.objects.none()
            all_users = User.objects.filter(Q(restaurant=user_restaurant) | Q(owned_restaurant=user_restaurant)).filter(is_active=True) if user_restaurant else User.objects.none()
        
        # === OVERALL STATISTICS ===
        orders_30d = all_orders.filter(created_at__date__gte=thirty_days_ago)
        overall_stats = {
            'total_restaurants': restaurants.count(),
            'total_orders': orders_30d.count(),
            'total_revenue': float(orders_30d.filter(status='served').aggregate(Sum('subtotal'))['subtotal__sum'] or 0),
            'total_invoices': all_invoices.filter(created_at__date__gte=thirty_days_ago).count(),
            'total_users': all_users.count(),
            'active_staff': all_users.filter(role__in=['kitchen', 'waiter']).count(),
            'avg_order_value': float(orders_30d.aggregate(Avg('subtotal'))['subtotal__avg'] or 0),
        }
        
        # === OVERALL RESTAURANT STATISTICS (Today's) ===
        orders_today = all_orders.filter(created_at__date=today)
        overall_restaurant_stats = {
            'orders_today': orders_today.count(),
            'active_orders': all_orders.filter(status__in=['pending', 'preparing', 'bargain', 'ready']).count(),
            'total_staff': all_users.filter(role__in=['kitchen', 'waiter', 'admin']).count(),
            'total_tables': Table.objects.filter(restaurant__in=restaurants).count() if is_super_admin else (Table.objects.filter(restaurant=user_restaurant).count() if user_restaurant else 0),
            'total_menu_items': MenuItem.objects.filter(restaurant__in=restaurants).count() if is_super_admin else (MenuItem.objects.filter(restaurant=user_restaurant).count() if user_restaurant else 0),
            'daily_revenue': float(orders_today.filter(status='served').aggregate(Sum('subtotal'))['subtotal__sum'] or 0),
        }
        
        # === PER-RESTAURANT STATISTICS ===
        restaurant_stats = []
        for restaurant in restaurants:
            r_orders = Order.objects.filter(restaurant=restaurant)
            r_staff = User.objects.filter(restaurant=restaurant)
            restaurant_stats.append({
                'id': str(restaurant.id),
                'name': restaurant.name,
                'owner': restaurant.owner.username if restaurant.owner else 'N/A',
                'total_orders': r_orders.count(),
                'total_revenue': float(r_orders.filter(status='served').aggregate(Sum('subtotal'))['subtotal__sum'] or 0),
                'total_staff': r_staff.count(),
                'tables_capacity': restaurant.tables_capacity,
                'is_active': restaurant.is_active,
                'orders_today': r_orders.filter(created_at__date=today).count(),
                'active_orders': r_orders.filter(status__in=['pending', 'preparing', 'bargain', 'ready']).count(),
            })
        
        # === ORDER STATUS BREAKDOWN ===
        order_breakdown = {
            'pending': all_orders.filter(status='pending').count(),
            'preparing': all_orders.filter(status='preparing').count(),
            'bargain': all_orders.filter(status='bargain').count(),
            'ready': all_orders.filter(status='ready').count(),
            'served': all_orders.filter(status='served').count(),
            'cancelled': all_orders.filter(status='cancelled').count(),
        }
        
        # === DAILY REVENUE CHART (Last 30 days) ===
        daily_revenue_data = self._get_daily_revenue(all_orders, thirty_days_ago, today)
        
        # === HOURLY DISTRIBUTION ===
        hourly_dist = self._get_hourly_distribution(all_orders.filter(created_at__date=today))
        
        # === BARGAIN METRICS ===
        try:
            if is_super_admin:
                all_bargains = OrderBargain.objects.all()
            else:
                all_bargains = OrderBargain.objects.filter(order__restaurant=user_restaurant) if user_restaurant else OrderBargain.objects.none()
            
            total_bargains = all_bargains.count()
            bargain_metrics = {
                'total': total_bargains,
                'accepted': all_bargains.filter(status='accepted').count(),
                'rejected': all_bargains.filter(status='rejected').count(),
                'pending': all_bargains.filter(status='pending').count(),
                'success_rate': round((all_bargains.filter(status='accepted').count() / total_bargains * 100) if total_bargains > 0 else 0, 2),
            }
        except Exception as e:
            # Handle case where OrderBargain table or status field doesn't exist
            bargain_metrics = {
                'total': 0,
                'accepted': 0,
                'rejected': 0,
                'pending': 0,
                'success_rate': 0,
            }
        
        # === TOP SELLING ITEMS ===
        top_items = self._get_top_items(all_orders.filter(created_at__date__gte=thirty_days_ago))
        
        # === STAFF PERFORMANCE ===
        staff_performance = self._get_staff_performance(all_users, all_orders)
        return {
            'is_super_admin': is_super_admin,
            'user_restaurant': user_restaurant,
            'overall_stats': overall_stats,
            'overall_restaurant_stats': overall_restaurant_stats,
            'restaurant_stats': restaurant_stats,
            'order_breakdown': order_breakdown,
            'daily_revenue': daily_revenue_data,
            'hourly_dist': hourly_dist,
            'bargain_metrics': bargain_metrics,
            'top_items': top_items,
            'staff_performance': staff_performance,
            'last_updated': timezone.now().strftime('%Y-%m-%d %H:%M:%S'),
        }
    
    def _get_daily_revenue(self, orders_qs, start_date, end_date):
        """Calculate daily revenue for chart"""
        from collections import defaultdict
        
        # Get orders grouped by date
        daily_data = orders_qs.filter(
            created_at__date__gte=start_date,
            created_at__date__lte=end_date,
            status='served'
        ).values('created_at__date').annotate(
            total=Sum('subtotal'),
            count=Count('id')
        ).order_by('created_at__date')
        
        # Create date range
        date_range = []
        current = start_date
        while current <= end_date:
            date_range.append(current)
            current += timedelta(days=1)
        
        # Map data to dates
        revenue_map = {d['created_at__date']: float(d['total'] or 0) for d in daily_data}
        orders_map = {d['created_at__date']: d['count'] for d in daily_data}
        
        return {
            'labels': [d.strftime('%Y-%m-%d') for d in date_range],
            'revenue': [revenue_map.get(d, 0) for d in date_range],
            'orders': [orders_map.get(d, 0) for d in date_range],
        }
    
    def _get_hourly_distribution(self, orders_qs):
        """Get hourly order distribution for today"""
        from django.db.models.functions import ExtractHour
        
        hourly_data = orders_qs.annotate(
            hour=ExtractHour('created_at')
        ).values('hour').annotate(
            count=Count('id'),
            revenue=Sum('subtotal')
        ).order_by('hour')
        
        hours = [f"{h:02d}:00" for h in range(24)]
        orders_by_hour = [0] * 24
        revenue_by_hour = [0.0] * 24
        
        for h in hourly_data:
            if h['hour'] is not None:
                orders_by_hour[h['hour']] = h['count'] or 0
                revenue_by_hour[h['hour']] = float(h['revenue'] or 0)
        
        return {
            'hours': hours,
            'orders': orders_by_hour,
            'revenue': revenue_by_hour,
        }
    
    def _get_top_items(self, orders_qs, limit=10):
        """Get top selling items from orders"""
        from collections import defaultdict
        
        item_sales = defaultdict(lambda: {'quantity': 0, 'revenue': 0.0, 'name': ''})
        
        for order in orders_qs.filter(status='served'):
            items = order.items or []
            if isinstance(items, str):
                try:
                    items = json.loads(items)
                except:
                    items = []
            
            for item in items:
                item_id = item.get('item_id') or item.get('id')
                qty = item.get('qty') or item.get('quantity', 1)
                price = float(item.get('price', 0))
                name = item.get('name', f'Item {item_id}')
                
                if item_id:
                    item_sales[item_id]['quantity'] += qty
                    item_sales[item_id]['revenue'] += price * qty
                    item_sales[item_id]['name'] = name
        
        # Sort by quantity and get top items
        sorted_items = sorted(item_sales.items(), key=lambda x: x[1]['quantity'], reverse=True)[:limit]
        
        return [
            {
                'rank': idx + 1,
                'name': data['name'],
                'quantity': data['quantity'],
                'revenue': data['revenue'],
            }
            for idx, (item_id, data) in enumerate(sorted_items)
        ]
    
    def _get_staff_performance(self, users_qs, orders_qs):
        """Get staff performance metrics"""
        performance = []
        
        # Get waiters
        waiters = users_qs.filter(role='waiter')
        for waiter in waiters:
            orders_handled = orders_qs.filter(assigned_waiter=waiter).count()
            served_orders = orders_qs.filter(assigned_waiter=waiter, status='served').count()
            performance.append({
                'name': waiter.username,
                'role': 'Waiter',
                'orders': orders_handled,
                'served': served_orders,
                'status': 'Active' if waiter.is_active else 'Inactive',
            })
        
        # Get kitchen staff
        kitchen_staff = users_qs.filter(role='kitchen')
        for staff in kitchen_staff:
            orders_handled = orders_qs.filter(assigned_kitchen_staff=staff).count()
            performance.append({
                'name': staff.username,
                'role': 'Kitchen',
                'orders': orders_handled,
                'served': 0,
                'status': 'Active' if staff.is_active else 'Inactive',
            })
        
        return sorted(performance, key=lambda x: x['orders'], reverse=True)
    
    def restaurant_stats_api(self, request, restaurant_id):
        """API endpoint for specific restaurant statistics (AJAX)"""
        from core.models import User
        try:
            restaurant = Restaurant.objects.get(id=restaurant_id)
            
            # Check permissions
            user = request.user
            if not user.is_superuser:
                user_restaurant = getattr(user, 'owned_restaurant', None) or getattr(user, 'restaurant', None)
                if restaurant != user_restaurant:
                    return JsonResponse({'error': 'Permission denied'}, status=403)
            
            today = timezone.now().date()
            thirty_days_ago = today - timedelta(days=30)
            
            # Get restaurant-specific data
            r_orders = Order.objects.filter(restaurant=restaurant)
            r_orders_30d = r_orders.filter(created_at__date__gte=thirty_days_ago)
            r_users = User.objects.filter(Q(restaurant=restaurant) | Q(owned_restaurant=restaurant))
            
            # Overall stats for this restaurant
            stats = {
                'restaurant_id': str(restaurant.id),
                'restaurant_name': restaurant.name,
                'overall_stats': {
                    'total_orders': r_orders_30d.count(),
                    'total_revenue': float(r_orders_30d.filter(status='served').aggregate(Sum('subtotal'))['subtotal__sum'] or 0),
                    'total_users': r_users.count(),
                    'avg_order_value': float(r_orders_30d.aggregate(Avg('subtotal'))['subtotal__avg'] or 0),
                },
                'today_stats': {
                    'orders_today': r_orders.filter(created_at__date=today).count(),
                    'active_orders': r_orders.filter(status__in=['pending', 'preparing', 'bargain', 'ready']).count(),
                    'total_tables': Table.objects.filter(restaurant=restaurant).count(),
                    'total_menu_items': MenuItem.objects.filter(restaurant=restaurant).count(),
                    'daily_revenue': float(r_orders.filter(created_at__date=today, status='served').aggregate(Sum('subtotal'))['subtotal__sum'] or 0),
                },
                'order_breakdown': {
                    'pending': r_orders.filter(status='pending').count(),
                    'preparing': r_orders.filter(status='preparing').count(),
                    'bargain': r_orders.filter(status='bargain').count(),
                    'ready': r_orders.filter(status='ready').count(),
                    'served': r_orders.filter(status='served').count(),
                    'cancelled': r_orders.filter(status='cancelled').count(),
                },
                'daily_revenue': self._get_daily_revenue(r_orders, thirty_days_ago, today),
                'hourly_dist': self._get_hourly_distribution(r_orders.filter(created_at__date=today)),
                'top_items': self._get_top_items(r_orders_30d),
                'staff_performance': self._get_staff_performance(r_users, r_orders),
            }
            
            # Bargain metrics
            r_bargains = OrderBargain.objects.filter(order__restaurant=restaurant)
            total_bargains = r_bargains.count()
            stats['bargain_metrics'] = {
                'total': total_bargains,
                'accepted': r_bargains.filter(customer_response='accepted').count(),
                'rejected': r_bargains.filter(customer_response='rejected').count(),
                'pending': r_bargains.filter(customer_response='pending').count(),
                'success_rate': round((r_bargains.filter(customer_response='accepted').count() / total_bargains * 100) if total_bargains > 0 else 0, 2),
            }
            
            return JsonResponse(stats)
            
        except Restaurant.DoesNotExist:
            return JsonResponse({'error': 'Restaurant not found'}, status=404)
    
    def dashboard_data_api(self, request):
        """API endpoint to get dashboard data (for AJAX refresh)"""
        restaurant_id = request.GET.get('restaurant_id')
        
        if restaurant_id:
            return self.restaurant_stats_api(request, restaurant_id)
        
        # Return full dashboard context as JSON
        context = self._build_dashboard_context(request)
        
        # Remove non-serializable items
        return JsonResponse({
            'overall_stats': context['overall_stats'],
            'overall_restaurant_stats': context['overall_restaurant_stats'],
            'restaurant_stats': context['restaurant_stats'],
            'order_breakdown': context['order_breakdown'],
            'daily_revenue': context['daily_revenue'],
            'hourly_dist': context['hourly_dist'],
            'bargain_metrics': context['bargain_metrics'],
            'top_items': context['top_items'],
            'staff_performance': context['staff_performance'],
            'last_updated': context['last_updated'],
        })
    
    def current_restaurant_api(self, request):
        """API endpoint for current user's restaurant"""
        user = request.user
        restaurant = None
        
        if hasattr(user, 'owned_restaurant') and user.owned_restaurant:
            restaurant = user.owned_restaurant
        elif hasattr(user, 'restaurant') and user.restaurant:
            restaurant = user.restaurant
            
        if restaurant:
            return JsonResponse({
                'restaurant': {
                    'id': str(restaurant.id),
                    'name': restaurant.name,
                    'address': restaurant.address
                }
            })
        
        return JsonResponse({'restaurant': None})

    def index(self, request, extra_context=None) -> TemplateResponse:
        """Override the default index view to show restaurant dashboard"""
        return self.dashboard_view(request)  # type: ignore[return-value]


# Create the custom admin site instance
admin_site = SperiumAdminSite(name='sperium_admin')

# Register User model with custom admin site
from .user_admin import UserAdmin
from django.contrib.auth.models import User
admin_site.register(User, UserAdmin)

# Register Invoice model with custom admin site
from invoices.admin import InvoiceAdmin
from invoices.models import Invoice
admin_site.register(Invoice, InvoiceAdmin)

# Register Customer models with custom admin site
from customer.admin import (
    LandingPageAdmin, ContentPageAdmin, FooterLinkAdmin,
    SocialMediaPlatformAdmin, SocialMediaLinkAdmin, AppCardAdmin, TestimonialAdmin
)
from customer.models import (
    LandingPage, ContentPage, FooterLink,
    SocialMediaPlatform, SocialMediaLink, AppCard, Testimonial
)
admin_site.register(LandingPage, LandingPageAdmin)
admin_site.register(ContentPage, ContentPageAdmin)
admin_site.register(FooterLink, FooterLinkAdmin)
admin_site.register(SocialMediaPlatform, SocialMediaPlatformAdmin)
admin_site.register(SocialMediaLink, SocialMediaLinkAdmin)
admin_site.register(AppCard, AppCardAdmin)
admin_site.register(Testimonial, TestimonialAdmin)
