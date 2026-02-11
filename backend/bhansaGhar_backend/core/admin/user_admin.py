"""
User model admin configuration
"""
from django.contrib import admin
from django.utils.html import format_html

from ..models import User


class UserAdmin(admin.ModelAdmin):
    """Admin interface for User model"""
    list_display = ['username', 'email', 'phone', 'role_badge', 'restaurant', 'is_active_badge', 'date_joined']
    list_filter = ['role', 'is_email_verified', 'is_active', 'date_joined']
    search_fields = ['username', 'email', 'phone']
    readonly_fields = ['google_id', 'email_verification_code', 'email_verification_expires_at', 'last_code_sent_at', 'id']
    ordering = ['-date_joined']
    
    fieldsets = (
        ('👤 Basic Information', {
            'fields': ('id', 'username', 'email', 'phone', 'address', 'latitude', 'longitude')
        }),
        ('🔐 Verification & Status', {
            'fields': ('is_google_verified', 'is_email_verified', 'profile_completed', 'is_active')
        }),
        ('🏪 Restaurant Assignment', {
            'fields': ('role', 'restaurant')
        }),
        ('🔑 Permissions', {
            'fields': ('is_staff', 'is_superuser', 'groups', 'user_permissions')
        }),
        ('📅 Important dates', {
            'fields': ('last_login', 'date_joined')
        }),
    )
    
    def role_badge(self, obj):
        """Display role as colored badge"""
        # Check if user is a super admin first
        if obj.is_superuser:
            return format_html(
                '<span style="background: #9333ea; color: white; padding: 5px 10px; border-radius: 4px; font-weight: 600; font-size: 11px;">👑 Super Admin</span>'
            )
        
        colors = {
            'admin': '#10b981',
            'kitchen': '#3b82f6',
            'waiter': '#f59e0b',
        }
        color = colors.get(obj.role, '#6b7280')
        role_display = obj.get_role_display() if obj.role else 'No Role'
        return format_html(
            '<span style="background: {}; color: white; padding: 5px 10px; border-radius: 4px; font-weight: 600; font-size: 11px;">{}</span>',
            color,
            role_display
        )
    role_badge.short_description = 'Role'  # type: ignore[attr-defined]
    
    def is_active_badge(self, obj):
        """Display active status as badge"""
        if obj.is_active:
            return format_html('<span style="color: #10b981; font-weight: 600;">✓ Active</span>')
        else:
            return format_html('<span style="color: #ef4444; font-weight: 600;">✗ Inactive</span>')
    is_active_badge.short_description = 'Status'  # type: ignore[attr-defined]
