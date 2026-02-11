from rest_framework import serializers
from drf_spectacular.utils import extend_schema_field
from .activity_models import ActivityLog, ActivityType
from django.contrib.auth import get_user_model

User = get_user_model()


class ActivityLogSerializer(serializers.ModelSerializer):
    """Serializer for displaying activity logs"""
    activity_type_display = serializers.SerializerMethodField()
    user_name = serializers.CharField(source='user.username', read_only=True)
    user_role = serializers.CharField(source='user.role', read_only=True)
    
    class Meta:
        model = ActivityLog
        fields = [
            'id', 'user', 'user_name', 'user_role', 'restaurant',
            'activity_type', 'activity_type_display', 'description',
            'related_object_type', 'related_object_id', 'metadata',
            'created_at'
        ]
        read_only_fields = [f for f in fields if f != 'activity_type_display']
    
    @extend_schema_field(serializers.CharField())
    def get_activity_type_display(self, obj):
        return obj.get_activity_type_display()


class ActivityLogDetailSerializer(serializers.ModelSerializer):
    """Detailed serializer for activity logs"""
    activity_type_display = serializers.SerializerMethodField()
    user_details = serializers.SerializerMethodField()
    
    class Meta:
        model = ActivityLog
        fields = [
            'id', 'user', 'user_details', 'restaurant',
            'activity_type', 'activity_type_display', 'description',
            'related_object_type', 'related_object_id', 'metadata',
            'ip_address', 'user_agent', 'created_at'
        ]
        read_only_fields = fields
    
    @extend_schema_field(serializers.CharField())
    def get_activity_type_display(self, obj):
        return obj.get_activity_type_display()
    
    def get_user_details(self, obj):
        return {
            'id': obj.user.id,
            'username': obj.user.username,
            'email': obj.user.email,
            'role': obj.user.role,
            'first_name': obj.user.first_name,
            'last_name': obj.user.last_name,
        }


class ActivityStatsSerializer(serializers.Serializer):
    """Serializer for activity statistics"""
    total_activities = serializers.IntegerField()
    activities_today = serializers.IntegerField()
    recent_activities = ActivityLogSerializer(many=True)
    activity_breakdown = serializers.DictField(child=serializers.IntegerField())
