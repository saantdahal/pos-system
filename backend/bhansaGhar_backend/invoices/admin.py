from django.contrib import admin
from .models import Invoice


@admin.register(Invoice)
class InvoiceAdmin(admin.ModelAdmin):
    list_display = [
        'id',
        'restaurant',
        'table_number',
        'status',
        'total',
        'created_at',
        'closed_by'
    ]
    list_filter = ['status', 'restaurant', 'created_at']
    search_fields = ['table_number', 'restaurant__name']
    readonly_fields = [
        'id',
        'created_at',
        'last_updated_at',
        'subtotal',
        'tax',
        'total',
        'items'
    ]
    fieldsets = (
        ('Invoice Info', {
            'fields': ('id', 'restaurant', 'table_number', 'status')
        }),
        ('Pricing', {
            'fields': ('items', 'subtotal', 'tax', 'total')
        }),
        ('Timeline', {
            'fields': ('created_at', 'last_updated_at', 'paid_at', 'closed_at')
        }),
        ('Closure Info', {
            'fields': ('closed_by', 'close_reason')
        }),
    )
    
    def has_add_permission(self, request):
        # Prevent manual invoice creation
        return False
