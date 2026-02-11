from django.test import TestCase
from django.utils import timezone
from django.contrib.auth import get_user_model
from datetime import timedelta, datetime
from decimal import Decimal

from restaurants.models import Restaurant, RestaurantType
from orders.models import Order, OrderBargain, OrderServeLog
from analytics.services import AnalyticsService
from analytics.models import DailyAnalytics, HourlyAnalytics

User = get_user_model()


class AnalyticsServiceTestCase(TestCase):
    
    def setUp(self):
        """Set up test data"""
        # Create restaurant
        self.restaurant_type = RestaurantType.objects.create(
            name='test_type',
            display_name='Test Type'
        )
        
        self.owner = User.objects.create_user(
            username='owner',
            email='owner@test.com',
            role='admin'
        )
        
        self.restaurant = Restaurant.objects.create(
            owner=self.owner,
            name='Test Restaurant',
            type=self.restaurant_type,
            address='123 Test St',
            latitude=0.0,
            longitude=0.0,
            tables_capacity=10
        )
        
        # Create staff
        self.kitchen_staff = User.objects.create_user(
            username='kitchen',
            email='kitchen@test.com',
            role='kitchen',
            restaurant=self.restaurant
        )
        
        self.waiter = User.objects.create_user(
            username='waiter',
            email='waiter@test.com',
            role='waiter',
            restaurant=self.restaurant
        )
    
    def test_calculate_daily_analytics(self):
        """Test daily analytics calculation"""
        today = timezone.now().date()
        
        # Create test orders
        order1 = Order.objects.create(
            restaurant=self.restaurant,
            table_number=1,
            session_id='session1',
            status='served',
            items=[{'item_id': 1, 'qty': 2}],
            subtotal=Decimal('100.00'),
            created_at=timezone.now() - timedelta(hours=2),
            updated_at=timezone.now() - timedelta(hours=1)
        )
        
        order2 = Order.objects.create(
            restaurant=self.restaurant,
            table_number=2,
            session_id='session2',
            status='ready',
            items=[{'item_id': 2, 'qty': 1}],
            subtotal=Decimal('50.00'),
            created_at=timezone.now() - timedelta(hours=1),
            updated_at=timezone.now()
        )
        
        # Calculate metrics
        metrics = AnalyticsService.calculate_daily_analytics(self.restaurant, today)
        
        # Assertions
        self.assertEqual(metrics['total_orders'], 2)
        self.assertEqual(float(metrics['total_revenue']), 150.0)
        self.assertEqual(metrics['unique_tables_served'], 2)
        self.assertIsNotNone(metrics['avg_prep_time_seconds'])
    
    def test_save_daily_analytics(self):
        """Test saving daily analytics"""
        today = timezone.now().date()
        
        # Create test order
        Order.objects.create(
            restaurant=self.restaurant,
            table_number=1,
            session_id='session1',
            status='served',
            items=[{'item_id': 1, 'qty': 2}],
            subtotal=Decimal('100.00')
        )
        
        # Save analytics
        daily_analytics, created = AnalyticsService.save_daily_analytics(
            self.restaurant,
            today
        )
        
        # Assertions
        self.assertTrue(created)
        self.assertEqual(daily_analytics.total_orders, 1)
        self.assertEqual(daily_analytics.total_revenue, Decimal('100.00'))
        self.assertEqual(daily_analytics.date, today)
        
        # Test update
        daily_analytics2, created2 = AnalyticsService.save_daily_analytics(
            self.restaurant,
            today
        )
        
        self.assertFalse(created2)
        self.assertEqual(daily_analytics.pk, daily_analytics2.pk)
    
    def test_get_top_items(self):
        """Test getting top items"""
        # Create orders with items
        for i in range(5):
            Order.objects.create(
                restaurant=self.restaurant,
                table_number=i+1,
                session_id=f'session{i}',
                status='served',
                items=[{'item_id': 1, 'qty': 10}, {'item_id': 2, 'qty': 5}],
                subtotal=Decimal('100.00')
            )
        
        # Get top items
        top_items = AnalyticsService.get_top_items(self.restaurant, days=7)
        
        # Assertions
        self.assertIsNotNone(top_items)
        self.assertTrue(len(top_items) > 0)
    
    def test_get_kitchen_metrics(self):
        """Test kitchen metrics"""
        # Create test orders
        Order.objects.create(
            restaurant=self.restaurant,
            table_number=1,
            session_id='session1',
            status='ready',
            items=[{'item_id': 1, 'qty': 2}],
            subtotal=Decimal('100.00')
        )
        
        # Get metrics
        metrics = AnalyticsService.get_kitchen_metrics(self.restaurant)
        
        # Assertions
        self.assertIn('total_orders', metrics)
        self.assertIn('orders_per_hour', metrics)
        self.assertIn('avg_prep_time_minutes', metrics)
        self.assertIn('bargain_success_rate', metrics)
    
    def test_get_waiter_metrics(self):
        """Test waiter metrics"""
        # Create test orders
        Order.objects.create(
            restaurant=self.restaurant,
            table_number=1,
            session_id='session1',
            status='served',
            items=[{'item_id': 1, 'qty': 2}],
            subtotal=Decimal('100.00')
        )
        
        # Get metrics
        metrics = AnalyticsService.get_waiter_metrics(self.restaurant)
        
        # Assertions
        self.assertIn('total_tables_served', metrics)
        self.assertIn('avg_tables_per_day', metrics)
        self.assertIn('current_table_status', metrics)
    
    def test_get_admin_metrics(self):
        """Test admin metrics"""
        # Create test orders
        Order.objects.create(
            restaurant=self.restaurant,
            table_number=1,
            session_id='session1',
            status='served',
            items=[{'item_id': 1, 'qty': 2}],
            subtotal=Decimal('100.00')
        )
        
        # Get metrics
        metrics = AnalyticsService.get_admin_metrics(self.restaurant)
        
        # Assertions
        self.assertIn('total_revenue', metrics)
        self.assertIn('total_orders', metrics)
        self.assertIn('avg_revenue_per_order', metrics)
        self.assertIn('revenue_trend', metrics)
        self.assertIn('top_items', metrics)
