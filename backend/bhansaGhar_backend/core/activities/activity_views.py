from rest_framework import status
from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.authentication import JWTAuthentication
from drf_spectacular.utils import extend_schema, OpenApiParameter
from drf_spectacular.types import OpenApiTypes
from django.utils import timezone
from datetime import timedelta
from django.db.models import Q

from .activity_models import ActivityLog
from .activity_serializers import ActivityLogSerializer, ActivityLogDetailSerializer, ActivityStatsSerializer
from .activity_utils import (
    get_user_today_activities,
    get_restaurant_today_activities,
    get_restaurant_staff_activities,
    get_activity_stats_for_user,
    get_activity_stats_for_restaurant,
    get_staff_activities_breakdown,
)


@extend_schema(
    tags=['Activity Logs'],
    description='Get current user\'s activities for today',
    responses={200: ActivityLogSerializer(many=True)},
)
@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def my_today_activities(request):
    """
    Get current user's activities for today.
    Available to: Waiter, Kitchen Staff, Admin
    """
    activities = get_user_today_activities(request.user)
    serializer = ActivityLogSerializer(activities, many=True)
    return Response(serializer.data)


@extend_schema(
    tags=['Activity Logs'],
    description='Get all activities for current user (with date filtering)',
    parameters=[
        OpenApiParameter(
            name='days',
            description='Number of days to retrieve activities for (default: 7)',
            required=False,
            type=OpenApiTypes.INT,
        ),
        OpenApiParameter(
            name='activity_type',
            description='Filter by activity type',
            required=False,
            type=OpenApiTypes.STR,
        ),
    ],
    responses={200: ActivityLogSerializer(many=True)},
)
@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def my_activities(request):
    """
    Get current user's activities with filtering options.
    Available to: Waiter, Kitchen Staff, Admin
    """
    days = int(request.query_params.get('days', 7))
    activity_type = request.query_params.get('activity_type', None)
    
    start_date = timezone.now() - timedelta(days=days)
    
    activities = ActivityLog.objects.filter(
        user=request.user,
        created_at__gte=start_date,
    ).order_by('-created_at')
    
    if activity_type:
        activities = activities.filter(activity_type=activity_type)
    
    serializer = ActivityLogSerializer(activities, many=True)
    return Response(serializer.data)


@extend_schema(
    tags=['Activity Logs'],
    description='Get activity statistics for current user',
    responses={200: ActivityStatsSerializer()},
)
@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def my_activity_stats(request):
    """
    Get activity statistics for current user.
    Available to: Waiter, Kitchen Staff, Admin
    """
    days = int(request.query_params.get('days', 7))
    stats = get_activity_stats_for_user(request.user, days=days)
    
    # Serialize the recent activities
    stats['recent_activities'] = ActivityLogSerializer(stats['recent_activities'], many=True).data
    
    return Response(stats)


@extend_schema(
    tags=['Activity Logs'],
    description='Get all restaurant activities (Admin only) - today',
    responses={200: ActivityLogDetailSerializer(many=True)},
)
@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def restaurant_today_activities(request):
    """
    Get all activities for current user's restaurant today.
    Available to: Admin only
    """
    user = request.user
    
    # Check if user is admin or owner
    if user.role != 'admin' and not hasattr(user, 'owned_restaurant'):
        return Response(
            {'error': 'Only admin can view restaurant activities'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    # Get the restaurant
    restaurant = getattr(user, 'owned_restaurant', None) or getattr(user, 'restaurant', None)
    if not restaurant:
        return Response(
            {'error': 'User has no associated restaurant'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    activities = get_restaurant_today_activities(restaurant)
    serializer = ActivityLogDetailSerializer(activities, many=True)
    return Response(serializer.data)


@extend_schema(
    tags=['Activity Logs'],
    description='Get all restaurant activities (Admin only) - with filtering',
    parameters=[
        OpenApiParameter(
            name='days',
            description='Number of days to retrieve activities for (default: 7)',
            required=False,
            type=OpenApiTypes.INT,
        ),
        OpenApiParameter(
            name='activity_type',
            description='Filter by activity type',
            required=False,
            type=OpenApiTypes.STR,
        ),
        OpenApiParameter(
            name='user_id',
            description='Filter by specific user',
            required=False,
            type=OpenApiTypes.INT,
        ),
    ],
    responses={200: ActivityLogDetailSerializer(many=True)},
)
@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def restaurant_activities(request):
    """
    Get all activities for current user's restaurant with filtering.
    Available to: Admin only
    """
    user = request.user
    
    # Check if user is admin or owner
    if user.role != 'admin' and not hasattr(user, 'owned_restaurant'):
        return Response(
            {'error': 'Only admin can view restaurant activities'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    # Get the restaurant
    restaurant = getattr(user, 'owned_restaurant', None) or getattr(user, 'restaurant', None)
    if not restaurant:
        return Response(
            {'error': 'User has no associated restaurant'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Apply filters
    days = int(request.query_params.get('days', 7))
    activity_type = request.query_params.get('activity_type', None)
    user_id = request.query_params.get('user_id', None)
    
    start_date = timezone.now() - timedelta(days=days)
    
    activities = ActivityLog.objects.filter(
        restaurant=restaurant,
        created_at__gte=start_date,
    ).order_by('-created_at')
    
    if activity_type:
        activities = activities.filter(activity_type=activity_type)
    
    if user_id:
        activities = activities.filter(user_id=user_id)
    
    serializer = ActivityLogDetailSerializer(activities, many=True)
    return Response(serializer.data)


@extend_schema(
    tags=['Activity Logs'],
    description='Get activity statistics for restaurant (Admin only)',
    responses={200: ActivityStatsSerializer()},
)
@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def restaurant_activity_stats(request):
    """
    Get activity statistics for current user's restaurant.
    Available to: Admin only
    """
    user = request.user
    
    # Check if user is admin or owner
    if user.role != 'admin' and not hasattr(user, 'owned_restaurant'):
        return Response(
            {'error': 'Only admin can view restaurant activities'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    # Get the restaurant
    restaurant = getattr(user, 'owned_restaurant', None) or getattr(user, 'restaurant', None)
    if not restaurant:
        return Response(
            {'error': 'User has no associated restaurant'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    days = int(request.query_params.get('days', 7))
    stats = get_activity_stats_for_restaurant(restaurant, days=days)
    
    # Serialize the recent activities
    stats['recent_activities'] = ActivityLogDetailSerializer(stats['recent_activities'], many=True).data
    
    return Response(stats)


@extend_schema(
    tags=['Activity Logs'],
    description='Get staff activity breakdown for today (Admin only)',
    responses={200: {
        'type': 'array',
        'items': {
            'type': 'object',
            'properties': {
                'user': {'type': 'integer'},
                'user__username': {'type': 'string'},
                'user__role': {'type': 'string'},
                'count': {'type': 'integer'},
            }
        }
    }},
)
@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def staff_activity_breakdown(request):
    """
    Get activity breakdown by staff member for today.
    Shows which staff members have been active and how many activities they've done.
    Available to: Admin only
    """
    user = request.user
    
    # Check if user is admin or owner
    if user.role != 'admin' and not hasattr(user, 'owned_restaurant'):
        return Response(
            {'error': 'Only admin can view staff activity breakdown'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    # Get the restaurant
    restaurant = getattr(user, 'owned_restaurant', None) or getattr(user, 'restaurant', None)
    if not restaurant:
        return Response(
            {'error': 'User has no associated restaurant'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    staff_breakdown = get_staff_activities_breakdown(restaurant)
    
    return Response(list(staff_breakdown))


@extend_schema(
    tags=['Activity Logs'],
    description='Get specific staff member\'s activities for today (Admin only)',
    responses={200: ActivityLogDetailSerializer(many=True)},
)
@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def staff_member_activities(request, user_id):
    """
    Get activities for a specific staff member in current restaurant for today.
    Available to: Admin only
    """
    user = request.user
    
    # Check if user is admin or owner
    if user.role != 'admin' and not hasattr(user, 'owned_restaurant'):
        return Response(
            {'error': 'Only admin can view staff activities'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    # Get the restaurant
    restaurant = getattr(user, 'owned_restaurant', None) or getattr(user, 'restaurant', None)
    if not restaurant:
        return Response(
            {'error': 'User has no associated restaurant'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Get activities for the specific staff member
    from .models import User as UserModel
    try:
        staff_user = UserModel.objects.get(id=user_id, restaurant=restaurant)
    except UserModel.DoesNotExist:
        return Response(
            {'error': 'Staff member not found in this restaurant'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    activities = get_restaurant_staff_activities(restaurant, staff_user)
    serializer = ActivityLogDetailSerializer(activities, many=True)
    return Response(serializer.data)
