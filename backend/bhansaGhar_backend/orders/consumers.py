from channels.generic.websocket import AsyncWebsocketConsumer
import json
from channels.db import database_sync_to_async

class OrderConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.restaurant_id = self.scope['url_route']['kwargs']['restaurant_id']
        self.role_group = self.scope['url_route']['kwargs']['role']  # kitchen/waiter
        
        # Verify permissions could be done here, but for now we accept and rely on the group structure
        # In production, check self.scope['user']
        
        await self.channel_layer.group_add(f'{self.role_group}_{self.restaurant_id}', self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(f'{self.role_group}_{self.restaurant_id}', self.channel_name)

    # Receive message from WebSocket (if needed for bidirectional)
    async def receive(self, text_data):
        pass

    # Broadcast handlers
    async def order_update(self, event):
        await self.send(text_data=json.dumps(event))

    async def bargain_update(self, event):
        await self.send(text_data=json.dumps(event))

    async def bargain_resolution(self, event):
        await self.send(text_data=json.dumps(event))
