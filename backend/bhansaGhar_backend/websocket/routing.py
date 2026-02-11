"""
Django Channels routing configuration for WebSocket connections.

This file defines how WebSocket connections are routed to consumers.
"""

from django.urls import re_path
from websocket.consumers import KitchenConsumer, WaiterConsumer, TableOrderConsumer
from notifications.consumers import UserNotificationConsumer

websocket_urlpatterns = [
    # Kitchen WebSocket
    re_path(r'ws/kitchen/(?P<restaurant_id>[0-9a-f-]+)/$', KitchenConsumer.as_asgi()),
    
    # Waiter WebSocket
    re_path(r'ws/waiter/(?P<restaurant_id>[0-9a-f-]+)/$', WaiterConsumer.as_asgi()),
    
    # Customer Table WebSocket
    re_path(r'ws/table/(?P<table_id>[0-9a-f-]+)/$', TableOrderConsumer.as_asgi()),
    
    # User Notifications WebSocket
    re_path(r'ws/notifications/(?P<user_id>[0-9a-f-]+)/$', UserNotificationConsumer.as_asgi()),
]
