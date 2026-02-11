"""
Staff-related admin configurations
"""
from django.contrib import admin
from django.utils.html import format_html

from restaurants.models import StaffInvite
from .mixins import AdminFilterMixin


class StaffInviteAdmin(AdminFilterMixin, admin.ModelAdmin):  # type: ignore[misc]
    list_display = ['invite_id', 'restaurant', 'email_display', 'role_display', 'status_badge', 'expiry_status', 'created_at']
    list_filter = ['restaurant', 'role', 'status', 'created_at']
    search_fields = ['email', 'restaurant__name']
    readonly_fields = ['id', 'qr_code_image', 'qr_url', 'created_at']
    ordering = ['-created_at']
    
    fieldsets = (
        ('📧 Invitation Details', {'fields': ('id', 'restaurant', 'email')}),
        ('👤 Role Assignment', {'fields': ('role',)}),
        ('⏰ Validity', {'fields': ('expires_at',)}),
        ('📊 Status', {'fields': ('status', 'is_claimed', 'claimed_by', 'claimed_at')}),
        ('🔗 QR Code', {'fields': ('qr_code_image', 'qr_url')}),
        ('⏱️ Timestamps', {'fields': ('created_at',)}),
    )
    
    def invite_id(self, obj):
        return format_html('<code style="background: #f3f4f6; padding: 4px 8px; border-radius: 4px; font-family: monospace; font-size: 11px;">{}</code>', str(obj.id)[:8])
    invite_id.short_description = 'Invite ID'  # type: ignore[attr-defined]
    
    def email_display(self, obj):
        return format_html('<strong>{}</strong>', obj.email)
    email_display.short_description = 'Email'  # type: ignore[attr-defined]
    
    def role_display(self, obj):
        role_colors = {
            'kitchen': '#f59e0b',
            'waiter': '#8b5cf6',
        }
        color = role_colors.get(obj.role, '#6b7280')
        role_labels = {
            'kitchen': '👨‍🍳 Kitchen',
            'waiter': '🤵 Waiter',
        }
        label = role_labels.get(obj.role, obj.get_role_display())
        return format_html(
            '<span style="background: {}; color: white; padding: 5px 10px; border-radius: 20px; font-weight: 600; font-size: 12px;">{}</span>',
            color, label
        )
    role_display.short_description = 'Role'  # type: ignore[attr-defined]
    
    def status_badge(self, obj):
        status_colors = {
            'pending': '#f59e0b',
            'claimed': '#10b981',
            'expired': '#6b7280',
        }
        color = status_colors.get(obj.status, '#6b7280')
        return format_html(
            '<span style="background: {}; color: white; padding: 5px 12px; border-radius: 20px; font-weight: 600; font-size: 12px;">{}</span>',
            color, obj.get_status_display()
        )
    status_badge.short_description = 'Status'  # type: ignore[attr-defined]
    
    def expiry_status(self, obj):
        from django.utils import timezone
        now = timezone.now()
        
        if obj.expires_at < now:
            return format_html('<span style="color: #ef4444;">⏰ Expired</span>')
        
        return format_html('<span style="color: #10b981;">✓ Valid</span>')
    expiry_status.short_description = 'Expiry'  # type: ignore[attr-defined]
