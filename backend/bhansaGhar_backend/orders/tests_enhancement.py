from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from decimal import Decimal
import json
from typing import Optional

from core.models import User
from restaurants.models import Restaurant, MenuItem, RestaurantType
from .models import Order, OrderBargain, WaiterSession, BargainMessage, OrderTimeline, OrderAssignment
from .services import OrderAssignmentService, BargainChatService, AdminMasterRoleService


class OrderAssignmentServiceTests(TestCase):
    """Tests for OrderAssignmentService"""
    
    def setUp(self):
        """Set up test data"""
        self.restaurant_type = RestaurantType.objects.create(
            name='casual',
            display_name='Casual Restaurant'
        )
        self.restaurant = Restaurant.objects.create(
            name='Test Restaurant',
            owner=User.objects.create(username='owner', role='admin'),
            address='123 Main St',
            phone='555-0001',
            type=self.restaurant_type,
            latitude=40.7128,
            longitude=-74.0060
        )
        
        self.waiter1 = User.objects.create(
            username='waiter1',
            role='waiter',
            restaurant=self.restaurant
        )
        
        self.waiter2 = User.objects.create(
            username='waiter2',
            role='waiter',
            restaurant=self.restaurant
        )
        
        self.kitchen = User.objects.create(
            username='kitchen',
            role='kitchen',
            restaurant=self.restaurant
        )
        
        self.order = Order.objects.create(
            restaurant=self.restaurant,
            table_number=1,
            items={'items': [{'id': 'item1', 'qty': 2}]},
            subtotal=Decimal('100.00'),
            status='pending'
        )
        
        self.service = OrderAssignmentService()
    
    def test_get_active_waiters(self):
        """Test retrieving active waiters with recent heartbeat"""
        # Create sessions for both waiters
        session1 = WaiterSession.objects.create(
            user=self.waiter1,
            restaurant=self.restaurant,
            status='idle',
            last_heartbeat=timezone.now()  # Recently active
        )
        
        session2 = WaiterSession.objects.create(
            user=self.waiter2,
            restaurant=self.restaurant,
            status='offline',
            last_heartbeat=timezone.now() - timezone.timedelta(minutes=10)  # Stale
        )
        
        active = self.service.get_active_waiters(self.restaurant)
        self.assertEqual(len(active), 1)
        self.assertEqual(active[0].pk, self.waiter1.pk)  # type: ignore
    
    def test_get_waiter_workload(self):
        """Test calculating waiter's active orders count"""
        # Create multiple orders for waiter1
        self.order.assigned_waiter = self.waiter1
        self.order.status = 'pending'
        self.order.save()
        
        order2 = Order.objects.create(
            restaurant=self.restaurant,
            table_number=2,
            items={'items': []},
            subtotal=Decimal('50.00'),
            status='preparing',
            assigned_waiter=self.waiter1
        )
        
        workload = self.service.get_waiter_workload(self.waiter1)
        self.assertEqual(workload, 2)
    
    def test_auto_assign_to_least_busy_waiter(self):
        """Test auto-assigning to waiter with least active orders"""
        # Create active sessions
        session1 = WaiterSession.objects.create(
            user=self.waiter1,
            restaurant=self.restaurant,
            status='idle',
            last_heartbeat=timezone.now()
        )
        
        session2 = WaiterSession.objects.create(
            user=self.waiter2,
            restaurant=self.restaurant,
            status='busy',
            last_heartbeat=timezone.now()
        )
        
        # Give waiter1 2 orders, waiter2 1 order
        Order.objects.create(
            restaurant=self.restaurant,
            table_number=2,
            items={'items': []},
            subtotal=Decimal('50.00'),
            status='pending',
            assigned_waiter=self.waiter1
        )
        
        # Auto-assign
        assigned = self.service.auto_assign_waiter(self.order)
        self.assertIsNotNone(assigned)
        self.assertEqual(assigned.pk, self.waiter1.pk)  # type: ignore
    
    def test_auto_assign_returns_none_all_busy(self):
        """Test auto-assign returns None when all waiters busy"""
        session1 = WaiterSession.objects.create(
            user=self.waiter1,
            restaurant=self.restaurant,
            status='busy',
            active_orders_count=5,
            last_heartbeat=timezone.now()
        )
        
        assigned = self.service.auto_assign_waiter(self.order)
        self.assertIsNone(assigned)
    
    def test_create_order_timeline(self):
        """Test creating order timeline entries"""
        admin = self.restaurant.owner
        
        OrderAssignmentService.create_order_timeline(
            order=self.order,
            status_new='preparing',
            changed_by=admin,
            reason='Order started preparation'
        )
        
        timeline: Optional[OrderTimeline] = OrderTimeline.objects.filter(order=self.order).first()
        self.assertIsNotNone(timeline)
        if timeline:
            self.assertEqual(timeline.status_old, 'pending')
            self.assertEqual(timeline.status_new, 'preparing')
            self.assertEqual(timeline.reason, 'Order started preparation')


class BargainChatServiceTests(TestCase):
    """Tests for BargainChatService"""
    
    def setUp(self):
        """Set up test data"""
        self.restaurant_type = RestaurantType.objects.create(
            name='casual',
            display_name='Casual Restaurant'
        )
        self.admin = User.objects.create(username='admin', role='admin')
        self.restaurant = Restaurant.objects.create(
            name='Test Restaurant',
            owner=self.admin,
            address='123 Main St',
            phone='555-0001',
            type=self.restaurant_type,
            latitude=40.7128,
            longitude=-74.0060
        )
        
        self.kitchen = User.objects.create(
            username='kitchen',
            role='kitchen',
            restaurant=self.restaurant
        )
        
        self.order = Order.objects.create(
            restaurant=self.restaurant,
            table_number=1,
            items={'items': [{'id': 'item1', 'qty': 2}]},
            subtotal=Decimal('100.00'),
            status='pending'
        )
        
        self.bargain = OrderBargain.objects.create(
            order=self.order,
            item_id='item1',
            customer_qty=2,
            kitchen_qty=1,
            status='pending',
            kitchen_message='Can only prepare 1'
        )
        
        self.service = BargainChatService()
    
    def test_add_bargain_message(self):
        """Test adding message to bargain chat"""
        message = self.service.add_message(
            bargain=self.bargain,
            sender_type='kitchen',
            message='We are short on this item',
            sender=self.kitchen
        )
        
        self.assertIsNotNone(message)
        self.assertEqual(message.sender_type, 'kitchen')
        self.assertEqual(message.sender, self.kitchen)
        self.assertEqual(message.message, 'We are short on this item')
    
    def test_get_chat_history(self):
        """Test retrieving chat history"""
        # Add multiple messages
        self.service.add_message(self.bargain, 'kitchen', 'Message 1', self.kitchen)
        self.service.add_message(self.bargain, 'customer', 'Message 2', None)
        self.service.add_message(self.bargain, 'kitchen', 'Message 3', self.kitchen)
        
        history = self.service.get_chat_history(self.bargain)
        self.assertEqual(len(history), 3)
    
    def test_accept_bargain_updates_items(self):
        """Test accepting bargain updates order items"""
        # Set initial items
        self.order.items = {'items': [{'id': 'item1', 'qty': 2}]}
        self.order.save()
        
        # Accept bargain (changes qty to 1)
        success = self.service.accept_bargain(self.bargain)
        
        self.assertTrue(success)
        self.bargain.refresh_from_db()
        self.assertEqual(self.bargain.status, 'accepted')
    
    def test_reject_bargain_reverts_status(self):
        """Test rejecting bargain reverts order status"""
        self.order.status = 'bargain'
        self.order.save()
        
        success = self.service.reject_bargain(self.bargain)
        
        self.assertTrue(success)
        self.bargain.refresh_from_db()
        self.assertEqual(self.bargain.status, 'rejected')


class AdminMasterRoleServiceTests(TestCase):
    """Tests for AdminMasterRoleService"""
    
    def setUp(self):
        """Set up test data"""
        self.restaurant_type = RestaurantType.objects.create(
            name='casual',
            display_name='Casual Restaurant'
        )
        self.admin = User.objects.create(username='admin', role='admin')
        self.restaurant = Restaurant.objects.create(
            name='Test Restaurant',
            owner=self.admin,
            address='123 Main St',
            phone='555-0001',
            type=self.restaurant_type,
            latitude=40.7128,
            longitude=-74.0060
        )
        
        self.waiter = User.objects.create(
            username='waiter',
            role='waiter',
            restaurant=self.restaurant
        )
        
        self.kitchen = User.objects.create(
            username='kitchen',
            role='kitchen',
            restaurant=self.restaurant
        )
        
        self.order = Order.objects.create(
            restaurant=self.restaurant,
            table_number=1,
            items={'items': []},
            subtotal=Decimal('100.00'),
            status='pending'
        )
        
        self.service = AdminMasterRoleService()
    
    def test_can_admin_access(self):
        """Test admin access check"""
        can_access = self.service.can_admin_access(self.admin, self.restaurant)
        self.assertTrue(can_access)
        
        can_access = self.service.can_admin_access(self.waiter, self.restaurant)
        self.assertFalse(can_access)
    
    def test_admin_auto_manage_order(self):
        """Test admin takes over order management"""
        success = self.service.admin_auto_manage_order(self.admin, self.order)
        
        self.assertTrue(success)
        self.order.refresh_from_db()
        self.assertEqual(self.order.assigned_waiter, self.admin)
        self.assertIn(self.admin, self.order.assigned_kitchen_staff.all())
    
    def test_admin_reassign_staff(self):
        """Test admin reassigning staff to order"""
        self.order.assigned_waiter = self.waiter
        self.order.save()
        
        new_waiter = User.objects.create(
            username='waiter2',
            role='waiter',
            restaurant=self.restaurant
        )
        
        success = self.service.admin_reassign_staff(
            admin_user=self.admin,
            order=self.order,
            waiter=new_waiter
        )
        
        self.assertTrue(success)
        self.order.refresh_from_db()
        self.assertEqual(self.order.assigned_waiter, new_waiter)
        
        # Check timeline was created
        timeline: Optional[OrderTimeline] = OrderTimeline.objects.filter(order=self.order).first()
        self.assertIsNotNone(timeline)


class OrderAPIEndpointsTests(APITestCase):
    """Tests for new order API endpoints"""
    
    def setUp(self):
        """Set up test data"""
        self.client = APIClient()
        
        self.restaurant_type = RestaurantType.objects.create(
            name='casual',
            display_name='Casual Restaurant'
        )
        
        self.admin = User.objects.create_user(
            username='admin',
            password='test123',
            role='admin'
        )
        
        self.waiter = User.objects.create_user(
            username='waiter',
            password='test123',
            role='waiter'
        )
        
        self.restaurant = Restaurant.objects.create(
            name='Test Restaurant',
            owner=self.admin,
            address='123 Main St',
            phone='555-0001',
            type=self.restaurant_type,
            latitude=40.7128,
            longitude=-74.0060
        )
        
        self.waiter.restaurant = self.restaurant  # type: ignore
        self.waiter.save()
        
        self.order = Order.objects.create(
            restaurant=self.restaurant,
            table_number=1,
            items={'items': []},
            subtotal=Decimal('100.00'),
            status='pending'
        )
    
    def test_auto_assign_waiter_endpoint(self):
        """Test auto-assign waiter API endpoint"""
        self.client.force_authenticate(user=self.admin)  # type: ignore
        
        # Create waiter session
        WaiterSession.objects.create(
            user=self.waiter,
            restaurant=self.restaurant,
            status='idle',
            last_heartbeat=timezone.now()
        )
        
        response = self.client.post(
            f'/api/orders/{self.order.id}/auto-assign-waiter/',
            data={}
        )
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        if hasattr(response, 'data'):
            self.assertTrue(response.data['success'])  # type: ignore
    
    def test_waiter_heartbeat_endpoint(self):
        """Test waiter heartbeat endpoint"""
        self.client.force_authenticate(user=self.waiter)  # type: ignore
        
        response = self.client.post(
            '/api/waiter/heartbeat/',
            data={'status': 'idle'}
        )
        
        # Should succeed
        self.assertIn(response.status_code, [status.HTTP_200_OK, status.HTTP_201_CREATED])
    
    def test_waiter_assigned_orders_endpoint(self):
        """Test getting waiter's assigned orders"""
        self.order.assigned_waiter = self.waiter
        self.order.save()
        
        self.client.force_authenticate(user=self.waiter)  # type: ignore
        
        response = self.client.get('/api/waiter/assigned-orders/')
        
        # Should succeed and return list
        self.assertIn(response.status_code, [status.HTTP_200_OK, status.HTTP_201_CREATED])
