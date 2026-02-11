"""
Health check and monitoring endpoints
"""
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status
from django.conf import settings
from django.db import connection
from django_redis import get_redis_connection
import redis
import logging

logger = logging.getLogger(__name__)


@api_view(['GET'])
@permission_classes([AllowAny])
def health_check(request):
    """
    Health check endpoint for Docker/Kubernetes
    Returns status of database and Redis connections
    """
    try:
        # Check database
        db_ok = False
        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
            db_ok = True
        except Exception as e:
            logger.error(f"Database health check failed: {str(e)}")
        
        # Check Redis
        redis_ok = False
        try:
            redis_conn = get_redis_connection('default')
            redis_conn.ping()
            redis_ok = True
        except Exception as e:
            logger.error(f"Redis health check failed: {str(e)}")
        
        if db_ok and redis_ok:
            return Response({
                'status': 'healthy',
                'database': 'connected',
                'redis': 'connected',
                'debug': settings.DEBUG,
            }, status=status.HTTP_200_OK)
        else:
            return Response({
                'status': 'degraded',
                'database': 'connected' if db_ok else 'disconnected',
                'redis': 'connected' if redis_ok else 'disconnected',
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)
    
    except Exception as e:
        logger.exception(f"Health check error: {str(e)}")
        return Response({
            'status': 'unhealthy',
            'error': str(e)
        }, status=status.HTTP_503_SERVICE_UNAVAILABLE)


@api_view(['GET'])
@permission_classes([AllowAny])
def ready_check(request):
    """
    Kubernetes readiness check
    """
    try:
        # Check all critical services
        checks = {
            'database': False,
            'redis': False,
            'app': True,
        }
        
        # Database
        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
            checks['database'] = True
        except Exception:
            pass
        
        # Redis
        try:
            redis_conn = get_redis_connection('default')
            redis_conn.ping()
            checks['redis'] = True
        except Exception:
            pass
        
        all_ready = all(checks.values())
        
        return Response(
            {'ready': all_ready, 'checks': checks},
            status=status.HTTP_200_OK if all_ready else status.HTTP_503_SERVICE_UNAVAILABLE
        )
    except Exception as e:
        logger.exception(f"Ready check error: {str(e)}")
        return Response({
            'ready': False,
            'error': str(e)
        }, status=status.HTTP_503_SERVICE_UNAVAILABLE)
