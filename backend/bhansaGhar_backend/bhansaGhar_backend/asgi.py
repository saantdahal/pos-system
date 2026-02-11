import os
import django
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
from channels.security.websocket import AllowedHostsOriginValidator

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'bhansaGhar_backend.settings')

# Initialize Django
django.setup()

# Import routing and middleware after Django setup
from websocket.routing import websocket_urlpatterns
from websocket.middleware import JWTAuthMiddleware

# Django application for HTTP
django_asgi_app = get_asgi_application()

# Protocol router
application = ProtocolTypeRouter({
    "http": django_asgi_app,
    "websocket": AllowedHostsOriginValidator(
        JWTAuthMiddleware(
            AuthMiddlewareStack(
                URLRouter(
                    websocket_urlpatterns
                )
            )
        )
    ),
})
