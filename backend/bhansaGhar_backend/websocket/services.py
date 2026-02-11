import logging
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync

logger = logging.getLogger(__name__)

from django.utils import timezone

def broadcast_table_update(restaurant_id, table_number, status):
    """
    Broadcast table status update to all waiters in a restaurant.
    """
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)(
        f'waiter_{restaurant_id}',
        {
            'type': 'table_status_update',
            'table_number': table_number,
            'status': status,
            'timestamp': timezone.now().isoformat()
        }
    )
    logger.info(f"📡 Broadcast table_update: Table {table_number} is {status} for restaurant {restaurant_id}")

def broadcast_order_update(restaurant_id, order_id, status):
    """
    Broadcast order update to waiters and kitchen.
    """
    channel_layer = get_channel_layer()
    payload = {
        'type': 'order_update',
        'order_id': str(order_id),
        'status': status,
        'timestamp': timezone.now().isoformat()
    }
    
    # Notify Waiters
    async_to_sync(channel_layer.group_send)(f'waiter_{restaurant_id}', payload)
    
    # Notify Kitchen
    async_to_sync(channel_layer.group_send)(f'kitchen_{restaurant_id}', payload)
    
    # If ready, send specific pickup notification
    if status == 'ready':
        async_to_sync(channel_layer.group_send)(
            f'waiter_{restaurant_id}',
            {
                'type': 'ready_for_pickup',
                'order_id': str(order_id),
                'status': 'ready',
                'timestamp': timezone.now().isoformat()
            }
        )
        
    logger.info(f"📡 Broadcast order_update: Order {order_id} is {status} for restaurant {restaurant_id}")

def broadcast_kitchen_ping(restaurant_id, order_id, message):
    """
    Ping kitchen from waiter.
    """
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)(
        f'kitchen_{restaurant_id}',
        {
            'type': 'kitchen_ping',
            'order_id': str(order_id),
            'message': message,
            'timestamp': timezone.now().isoformat()
        }
    )
    logger.info(f"📡 Kitchen Ping: Order {order_id} at restaurant {restaurant_id} - {message}")

def broadcast_bargain(restaurant_id, bargain_id):
    """Broadcast new bargain to kitchen/waiter (if needed)"""
    pass

def broadcast_bargain_resolution(restaurant_id, bargain_id):
    """Broadcast bargain resolution to kitchen"""
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)(
        f'kitchen_{restaurant_id}',
        {
            'type': 'bargain_resolution',
            'bargain_id': str(bargain_id),
            'timestamp': timezone.now().isoformat()
        }
    )

def broadcast_cleanup_request(restaurant_id, table_number):
    """Broadcast cleanup request to waiters"""
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)(
        f'waiter_{restaurant_id}',
        {
            'type': 'cleanup_request',
            'table_number': table_number,
            'timestamp': timezone.now().isoformat()
        }
    )
    logger.info(f"🧹 Broadcast cleanup_request: Table {table_number} needs cleanup at restaurant {restaurant_id}")

def broadcast_cleanup_request(restaurant_id, table_number):
    """Broadcast cleanup request to waiters"""
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)(
        f'waiter_{restaurant_id}',
        {
            'type': 'cleanup_request',
            'table_number': table_number
        }
    )
    logger.info(f"🧹 Broadcast cleanup_request: Table {table_number} needs cleanup at restaurant {restaurant_id}")
