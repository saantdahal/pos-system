"""
Comprehensive tests for the QR Restaurant Ordering Flow.

Run with: python manage.py test orders.tests
"""

from django.test import TestCase, TransactionTestCase
from django.utils import timezone
from rest_framework.test import APIClient
from rest_framework.response import Response
from datetime import timedelta
import uuid

from core.models import User
from restaurants.models import Restaurant, RestaurantType, Table, Category, MenuItem
from orders.models import Order, OrderBargain


class OrderFlowSetup(TransactionTestCase):
    """Base setup for order flow tests."""

    def setUp(self):
        """Create test data."""
        # Create restaurant type
        self.restaurant_type = RestaurantType.objects.create(
            name='momo_house',
            display_name='Momo House'
        )

        # Create user
        self.user = User.objects.create_user(
            username='admin@momohouse.com',
            email='admin@momohouse.com',
            password='testpass123',
            is_superuser=False
        )

        # Create restaurant
        self.restaurant = Restaurant.objects.create(
            owner=self.user,
            name='Momo House',
            type=self.restaurant_type,
            address='123 Main St',
            latitude=27.7172,
            longitude=85.3240,
            phone='+977-1234567890',
            tables_capacity=5
        )

        # Create table
        self.table = Table.objects.create(
            restaurant=self.restaurant,
            number=5,
            capacity=4,
            status='available'
        )

        # Create category
        self.category = Category.objects.create(
            restaurant=self.restaurant,
            name='Momos',
            position=0
        )

        # Create menu items
        self.item1 = MenuItem.objects.create(
            restaurant=self.restaurant,
            category=self.category,
            name='Chicken Momo',
            description='Steamed chicken dumplings',
            base_price='150.00',
            discount_percentage='0.00',
            stock_quantity=10,
            position=0
        )

        self.item2 = MenuItem.objects.create(
            restaurant=self.restaurant,
            category=self.category,
            name='Vegetable Momo',
            description='Steamed vegetable dumplings',
            base_price='100.00',
            discount_percentage='0.00',
            stock_quantity=1,
            position=1
        )

        self.client = APIClient()


class CustomerOrderCreationTest(OrderFlowSetup):
    """Test customer order creation flow."""

    def test_create_order_success(self):
        """Test successful order creation."""
        payload = {
            'restaurant_id': str(self.restaurant.id),
            'table_id': str(self.table.id),
            'session_id': 'browser-session-123',
            'customer_name': 'John Doe',
            'items': [
                {
                    'menu_item_id': self.item1.pk,
                    'quantity': 2,
                    'special_notes': 'Very spicy'
                }
            ]
        }

        response: Response = self.client.post('/api/orders/', payload, format='json')  # type: ignore
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data['status'], 'pending')
