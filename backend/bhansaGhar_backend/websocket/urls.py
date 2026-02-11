from django.urls import path
from . import consumers

# HTTP routes (if any WebSocket upgrades needed via HTTP first)
urlpatterns = [
    # Add any REST endpoints here if needed
]

# WebSocket routes (configured in routing.py)
# Available connections:
# - ws://localhost/ws/table/{table_id}/ (Customer)
# - ws://localhost/ws/kitchen/{restaurant_id}/ (Kitchen Staff)
# - ws://localhost/ws/waiter/{restaurant_id}/ (Waiter/Server)

