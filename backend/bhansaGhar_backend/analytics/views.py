from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from django.utils import timezone
from datetime import timedelta

from .permissions import AdminPermission, KitchenPermission, WaiterPermission, AnalyticsAccessPermission
from .services import AnalyticsService
from .serializers import (
    AdminAnalyticsSerializer,
    KitchenAnalyticsSerializer,
    WaiterAnalyticsSerializer,
    DateRangeAnalyticsSerializer,
)


@api_view(['GET'])
@permission_classes([AdminPermission])
def admin_analytics(request):
    """
    Admin dashboard analytics
    Query params:
    - days: number of days to analyze (default: 30)
    """
    try:
        restaurant = request.user.owned_restaurant
        if not restaurant:
            return Response(
                {'error': 'No restaurant found for user'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        days = int(request.query_params.get('days', 30))
        metrics = AnalyticsService.get_admin_metrics(restaurant, days)
        
        serializer = AdminAnalyticsSerializer(metrics)
        return Response(serializer.data, status=status.HTTP_200_OK)
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([AdminPermission])
def admin_analytics_daterange(request):
    """
    Admin analytics for specific date range
    Query params:
    - days: number of days (default: 30)
    """
    try:
        restaurant = request.user.owned_restaurant
        if not restaurant:
            return Response(
                {'error': 'No restaurant found for user'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        days = int(request.query_params.get('days', 30))
        metrics = AnalyticsService.get_date_range_metrics(restaurant, days)
        
        if not metrics:
            return Response(
                {'error': 'No analytics data available'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        serializer = DateRangeAnalyticsSerializer(metrics)
        return Response(serializer.data, status=status.HTTP_200_OK)
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([KitchenPermission])
def kitchen_analytics(request):
    """
    Kitchen staff analytics
    Query params:
    - days: number of days to analyze (default: 7)
    """
    try:
        restaurant = request.user.restaurant
        if not restaurant:
            return Response(
                {'error': 'No restaurant assigned for user'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        days = int(request.query_params.get('days', 7))
        metrics = AnalyticsService.get_kitchen_metrics(restaurant, days)
        
        serializer = KitchenAnalyticsSerializer(metrics)
        return Response(serializer.data, status=status.HTTP_200_OK)
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([WaiterPermission])
def waiter_analytics(request):
    """
    Waiter staff analytics
    Query params:
    - days: number of days to analyze (default: 7)
    """
    try:
        restaurant = request.user.restaurant
        if not restaurant:
            return Response(
                {'error': 'No restaurant assigned for user'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        days = int(request.query_params.get('days', 7))
        metrics = AnalyticsService.get_waiter_metrics(restaurant, days)
        
        serializer = WaiterAnalyticsSerializer(metrics)
        return Response(serializer.data, status=status.HTTP_200_OK)
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([AdminPermission])
def today_snapshot(request):
    """
    Today's quick snapshot for admin
    """
    try:
        restaurant = request.user.owned_restaurant
        if not restaurant:
            return Response(
                {'error': 'No restaurant found for user'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        today = timezone.now().date()
        metrics = AnalyticsService.calculate_daily_analytics(restaurant, today)
        
        return Response(
            {
                'date': today,
                'metrics': metrics
            },
            status=status.HTTP_200_OK
        )
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def analytics_overview(request):
    """
    Get analytics based on user role
    """
    if not hasattr(request.user, 'role') or not request.user.role:
        return Response(
            {'error': 'User role not set'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    if request.user.role == 'admin':
        return admin_analytics(request)
    elif request.user.role == 'kitchen':
        return kitchen_analytics(request)
    elif request.user.role == 'waiter':
        return waiter_analytics(request)
    else:
        return Response(
            {'error': 'Unknown role'},
            status=status.HTTP_400_BAD_REQUEST
        )


@api_view(['POST'])
@permission_classes([AdminPermission])
def update_daily_analytics_manual(request):
    """
    Manually trigger daily analytics calculation
    Admin only
    """
    try:
        restaurant = request.user.owned_restaurant
        if not restaurant:
            return Response(
                {'error': 'No restaurant found for user'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        date = request.data.get('date')
        if date:
            from datetime import datetime
            date = datetime.fromisoformat(date).date()
        else:
            date = timezone.now().date()
        
        daily_analytics, created = AnalyticsService.save_daily_analytics(restaurant, date)
        
        action = 'created' if created else 'updated'
        return Response(
            {
                'message': f'Daily analytics {action} successfully',
                'date': daily_analytics.date,
                'total_orders': daily_analytics.total_orders,
                'total_revenue': str(daily_analytics.total_revenue)
            },
            status=status.HTTP_200_OK
        )
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
