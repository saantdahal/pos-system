import logging
from channels.db import database_sync_to_async
from django.contrib.auth.models import AnonymousUser
from rest_framework_simplejwt.tokens import AccessToken
from django.contrib.auth import get_user_model

User = get_user_model()
logger = logging.getLogger(__name__)

@database_sync_to_async
def get_user_from_token(token_key):
    try:
        token = AccessToken(token_key)
        user_id = token['user_id']
        return User.objects.get(id=user_id)
    except Exception as e:
        logger.error(f"WebSocket Auth Error: {str(e)}")
        return AnonymousUser()

class JWTAuthMiddleware:
    """
    Custom middleware for JWT authentication in Django Channels.
    Expects token in the query string: ws://.../?token=<jwt_token>
    """
    def __init__(self, app):
        self.app = app

    async def __call__(self, scope, receive, send):
        query_string = scope.get("query_string", b"").decode("utf-8")
        token_key = None
        
        for param in query_string.split("&"):
            if param.startswith("token="):
                token_key = param.split("=")[1]
                break
        
        if token_key:
            scope['user'] = await get_user_from_token(token_key)
        else:
            scope['user'] = AnonymousUser()
            
        return await self.app(scope, receive, send)
