"""
Activity log admin configuration
"""
from django.contrib import admin
from django.utils.html import format_html

from ..activities.activity_models import ActivityLog


class ActivityLogAdmin(admin.ModelAdmin):
    """Admin interface for activity logs"""
    list_display = ('user', 'activity_type_badge', 'description', 'restaurant', 'created_at')
    list_filter = ('activity_type', 'created_at', 'user__role', 'restaurant')
    search_fields = ('user__username', 'description', 'related_object_id')
    readonly_fields = ('id', 'created_at', 'user', 'activity_type', 'description', 
                      'related_object_type', 'related_object_id', 'metadata', 
                      'ip_address', 'user_agent', 'restaurant')
    date_hierarchy = 'created_at'
    ordering = ['-created_at']
    
    fieldsets = (
        ('📝 Activity Information', {
            'fields': ('id', 'user', 'activity_type', 'description', 'restaurant')
        }),
        ('🔗 Related Object', {
            'fields': ('related_object_type', 'related_object_id', 'metadata')
        }),
        ('🌍 System Information', {
            'fields': ('ip_address', 'user_agent')
        }),
        ('⏰ Timestamps', {
            'fields': ('created_at',)
        }),
    )
    
    def activity_type_badge(self, obj):
        """Display activity type with color coding"""
        colors = {
            'CREATE': '#10b981',
            'UPDATE': '#3b82f6',
            'DELETE': '#ef4444',
            'LOGIN': '#f59e0b',
        }
        color = colors.get(obj.activity_type, '#6b7280')
        return format_html(
            '<span style="background: {}; color: white; padding: 4px 8px; border-radius: 3px; font-weight: 600; font-size: 11px;">{}</span>',
            color,
            obj.activity_type
        )
    activity_type_badge.short_description = 'Activity Type'  # type: ignore[attr-defined]
    
    def has_add_permission(self, request):
        return False  # Activities are created automatically
    
    def has_delete_permission(self, request, obj=None):
        return False  # Prevent deletion of activity logs
