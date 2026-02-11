import json
import logging
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.utils import timezone
from datetime import timedelta

logger = logging.getLogger(__name__)


class TableOrderConsumer(AsyncWebsocketConsumer):
    """
    WebSocket consumer for real-time order updates on customer tables.
    
    Connection: ws://localhost/ws/table/{table_id}/
    
    Messages sent to client:
    - new_order: New order placed at this table
    - status_update: Order status changed
    - new_bargain: Kitchen asking for negotiation
    - bargain_response: Customer's response to bargain
    """

    async def connect(self):
        """Handle WebSocket connection."""
        self.table_id = self.scope['url_route']['kwargs'].get('table_id')
        self.table_group_name = f"table_{self.table_id}"
        
        if not self.table_id:
            await self.close(code=4000)
            return
        
        # Verify table exists
        if not await self.table_exists():
            await self.close(code=4001)
            return
        
        # Add to group
        await self.channel_layer.group_add(
            self.table_group_name,
            self.channel_name
        )
        
        await self.accept()
        logger.info(f"✓ Table {self.table_id} WebSocket connected")

    async def disconnect(self, close_code):
        """Handle WebSocket disconnection."""
        await self.channel_layer.group_discard(
            self.table_group_name,
            self.channel_name
        )
        logger.info(f"✗ Table {self.table_id} WebSocket disconnected: {close_code}")

    async def receive(self, text_data):
        """Handle incoming messages from client."""
        try:
            data = json.loads(text_data)
            message_type = data.get('type')
            
            if message_type == 'ping':
                # Heartbeat
                await self.send(text_data=json.dumps({'type': 'pong'}))
            elif message_type == 'subscribe':
                # Subscribe to specific order
                order_id = data.get('order_id')
                await self.send(text_data=json.dumps({
                    'type': 'subscribed',
                    'order_id': order_id
                }))
            else:
                logger.warning(f"Unknown message type: {message_type}")
        except json.JSONDecodeError:
            logger.error("Invalid JSON received")
        except Exception as e:
            logger.error(f"Error in receive: {str(e)}")

    # Event handlers (called via group_send)

    async def new_order(self, event):
        """Send new order notification to customer."""
        await self.send(text_data=json.dumps({
            'type': 'new_order',
            'order_id': event['order_id'],
            'table_number': event['table_number'],
            'status': event['status'],
            'items': event.get('items', []),
            'created_at': event.get('created_at'),
            'message': '✅ Your order has been placed and sent to kitchen'
        }))
        logger.info(f"New order notification sent to table {self.table_id}")

    async def status_update(self, event):
        """Send order status update to customer."""
        status = event['status']
        
        status_messages = {
            'preparing': '🔥 Kitchen is preparing your order',
            'bargain': '💬 Kitchen needs to discuss your order',
            'ready': '✅ Your order is ready!',
            'served': '🎉 Your order has been served',
            'cancelled': '❌ Your order has been cancelled'
        }
        
        await self.send(text_data=json.dumps({
            'type': 'status_update',
            'order_id': event['order_id'],
            'status': status,
            'message': status_messages.get(status, f'Order status: {status}'),
            'updated_at': event.get('updated_at')
        }))
        logger.info(f"Status update sent to table {self.table_id}: {status}")

    async def new_bargain(self, event):
        """Send bargain negotiation request to customer."""
        action_messages = {
            'reduce_qty': 'We only have {available} left, can you take {available}?',
            'substitute': 'We are out of this item. Would you like a substitute?',
            'cancel_item': 'We are out of this item. Should we cancel it?'
        }
        
        await self.send(text_data=json.dumps({
            'type': 'new_bargain',
            'bargain_id': event['bargain_id'],
            'order_id': event['order_id'],
            'action_type': event['action_type'],
            'requested_quantity': event.get('requested_quantity'),
            'available_quantity': event.get('available_quantity'),
            'staff_message': event.get('staff_message'),
            'message': '💬 Kitchen has a question about your order'
        }))
        logger.info(f"Bargain sent to table {self.table_id}")

    async def bargain_response(self, event):
        """Send bargain response confirmation."""
        await self.send(text_data=json.dumps({
            'type': 'bargain_response',
            'bargain_id': event['bargain_id'],
            'response': event['response'],
            'message': f"✅ Your response has been sent to kitchen"
        }))
        logger.info(f"Bargain response sent to table {self.table_id}")

    # Helper methods

    @database_sync_to_async
    def table_exists(self):
        """Verify table exists in database."""
        from restaurants.models import Table
        return Table.objects.filter(id=self.table_id).exists()


class KitchenConsumer(AsyncWebsocketConsumer):
    """
    WebSocket consumer for kitchen staff real-time notifications.
    
    Connection: ws://localhost/ws/kitchen/{restaurant_id}/
    
    Messages sent to staff:
    - new_order: New order placed
    - status_update: Order status changed
    - bargain_response: Customer response to bargain
    """

    async def connect(self):
        """Handle WebSocket connection."""
        self.restaurant_id = self.scope['url_route']['kwargs'].get('restaurant_id')
        self.user = self.scope['user']
        self.kitchen_group_name = f"kitchen_{self.restaurant_id}"
        
        if not self.restaurant_id:
            await self.close(code=4000)
            return
        
        # Verify user is authenticated and has access to this restaurant
        if not await self.user_has_access():
            await self.close(code=4003)
            return
        
        # Add to kitchen group
        await self.channel_layer.group_add(
            self.kitchen_group_name,
            self.channel_name
        )
        
        await self.accept()
        logger.info(f"✓ Kitchen {self.restaurant_id} WebSocket connected - User: {self.user.username}")

    async def disconnect(self, close_code):
        """Handle WebSocket disconnection."""
        await self.channel_layer.group_discard(
            self.kitchen_group_name,
            self.channel_name
        )
        logger.info(f"✗ Kitchen {self.restaurant_id} WebSocket disconnected: {close_code}")

    async def receive(self, text_data):
        """Handle incoming messages from kitchen staff."""
        try:
            data = json.loads(text_data)
            message_type = data.get('type')
            
            if message_type == 'ping':
                await self.send(text_data=json.dumps({'type': 'pong'}))
            elif message_type == 'order_status_change':
                # Kitchen updating order status
                order_id = data.get('order_id')
                new_status = data.get('status')
                await self.handle_order_status_change(order_id, new_status)
            else:
                logger.warning(f"Unknown message type from kitchen: {message_type}")
        except json.JSONDecodeError:
            logger.error("Invalid JSON from kitchen")
        except Exception as e:
            logger.error(f"Error in kitchen receive: {str(e)}")

    # Event handlers (called via group_send)

    async def new_order(self, event):
        """Send new order to kitchen staff."""
        await self.send(text_data=json.dumps({
            'type': 'new_order',
            'order_id': event['order_id'],
            'table_number': event['table_number'],
            'status': event['status'],
            'items': event.get('items', []),
            'created_at': event.get('created_at'),
            'alert': '🔔 New order received!',
            'timestamp': timezone.now().isoformat()
        }))
        logger.info(f"New order alert sent to kitchen {self.restaurant_id}")

    async def status_update(self, event):
        """Send status update to kitchen staff."""
        await self.send(text_data=json.dumps({
            'type': 'status_update',
            'order_id': event['order_id'],
            'status': event['status'],
            'updated_at': event.get('updated_at'),
            'message': f'Order status changed to {event["status"]}'
        }))
        logger.info(f"Status update sent to kitchen: {event['status']}")

    async def bargain_response(self, event):
        """Send bargain response to kitchen staff."""
        await self.send(text_data=json.dumps({
            'type': 'bargain_response',
            'bargain_id': event['bargain_id'],
            'order_id': event['order_id'],
            'response': event['response'],
            'accepted_quantity': event.get('accepted_quantity'),
            'message': f"Customer has {event['response']} the negotiation"
        }))
        logger.info(f"Bargain response sent to kitchen")

    async def order_update(self, event):
        """Send order update to kitchen staff."""
        await self.send(text_data=json.dumps({
            'type': 'order_update',
            'order_id': event['order_id'],
            'status': event['status']
        }))

    async def kitchen_ping(self, event):
        """Send waiter ping to kitchen staff."""
        await self.send(text_data=json.dumps({
            'type': 'kitchen_ping',
            'order_id': event['order_id'],
            'message': event['message']
        }))

    # Helper methods

    @database_sync_to_async
    def user_has_access(self):
        """Verify user has access to this restaurant."""
        if self.user.is_anonymous:
            return False
        
        if self.user.is_superuser:
            return True
        
        # Check if user is admin/staff of this restaurant
        if hasattr(self.user, 'owned_restaurant'):
            return str(self.user.owned_restaurant.id) == str(self.restaurant_id)
        
        return False

    async def handle_order_status_change(self, order_id, new_status):
        """Handle order status change from kitchen."""
        # This would be called when kitchen staff manually updates status
        logger.info(f"Kitchen requesting status change - Order: {order_id}, Status: {new_status}")
        # Implementation depends on your REST endpoint design


class WaiterConsumer(AsyncWebsocketConsumer):
    """
    WebSocket consumer for waiter/server staff.
    
    Connection: ws://localhost/ws/waiter/{restaurant_id}/
    
    Messages sent:
    - table_status_update: Table status changed
    - ready_for_pickup: Order ready for pickup
    - table_needs_attention: Table needs something
    """

    async def connect(self):
        """Handle WebSocket connection."""
        self.restaurant_id = self.scope['url_route']['kwargs'].get('restaurant_id')
        self.user = self.scope['user']
        self.waiter_group_name = f"waiter_{self.restaurant_id}"
        
        if not self.restaurant_id:
            await self.close(code=4000)
            return
        
        if not await self.user_has_access():
            await self.close(code=4003)
            return
        
        # Add to waiter group
        await self.channel_layer.group_add(
            self.waiter_group_name,
            self.channel_name
        )
        
        await self.accept()
        logger.info(f"✓ Waiter {self.restaurant_id} WebSocket connected - User: {self.user.username}")

    async def disconnect(self, close_code):
        """Handle WebSocket disconnection."""
        await self.channel_layer.group_discard(
            self.waiter_group_name,
            self.channel_name
        )
        logger.info(f"✗ Waiter {self.restaurant_id} disconnected")

    async def receive(self, text_data):
        """Handle messages from waiter."""
        try:
            data = json.loads(text_data)
            message_type = data.get('type')
            
            if message_type == 'ping':
                await self.send(text_data=json.dumps({'type': 'pong'}))
            else:
                logger.warning(f"Unknown message type from waiter: {message_type}")
        except json.JSONDecodeError:
            logger.error("Invalid JSON from waiter")
        except Exception as e:
            logger.error(f"Error in waiter receive: {str(e)}")

    # Event handlers

    async def table_status_update(self, event):
        """Send table status update to waiter."""
        await self.send(text_data=json.dumps({
            'type': 'table_status_update',
            'table_number': event.get('table_number'),
            'status': event.get('status'),
            'timestamp': event.get('timestamp'),
            'message': f"Table {event.get('table_number')} is now {event.get('status')}"
        }))

    async def ready_for_pickup(self, event):
        """Notify waiter that order is ready for pickup."""
        await self.send(text_data=json.dumps({
            'type': 'ready_for_pickup',
            'order_id': event.get('order_id'),
            'table_number': event.get('table_number'),
            'timestamp': event.get('timestamp'),
            'message': f"🔔 Order for Table {event.get('table_number')} is ready!"
        }))

    async def order_update(self, event):
        """Send order update to waiter."""
        await self.send(text_data=json.dumps({
            'type': 'order_update',
            'order_id': event['order_id'],
            'status': event['status'],
            'timestamp': event.get('timestamp')
        }))

    async def cleanup_request(self, event):
        """Notify waiter that table needs cleanup."""
        await self.send(text_data=json.dumps({
            'type': 'cleanup_request',
            'table_number': event.get('table_number'),
            'timestamp': event.get('timestamp'),
            'message': f"🧹 Table {event.get('table_number')} needs cleanup!"
        }))

    # Helper methods

    @database_sync_to_async
    def user_has_access(self):
        """Verify user has access to this restaurant."""
        if self.user.is_anonymous:
            return False
        
        if self.user.is_superuser:
            return True
        
        if hasattr(self.user, 'owned_restaurant'):
            return str(self.user.owned_restaurant.id) == str(self.restaurant_id)
        
        return False
