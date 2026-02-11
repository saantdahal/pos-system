from django.db import models
from django.conf import settings
from django.utils import timezone
from decimal import Decimal
import json


class Invoice(models.Model):
    STATUS_CHOICES = [
        ('open', 'Open - Accepting Orders'),
        ('ready', 'Ready for Payment'),
        ('paid', 'Paid'),
        ('expired', 'Expired - Session Closed'),
        ('cancelled', 'Cancelled')
    ]
    
    # Reference
    restaurant = models.ForeignKey(
        'restaurants.Restaurant',
        on_delete=models.CASCADE,
        related_name='invoices'
    )
    table_number = models.IntegerField()
    
    # Order items accumulate here
    items = models.JSONField(default=list)  # [{'order_id': 1, 'items': [...], 'price': 100, 'created_at': '...'}]
    
    # Pricing
    subtotal = models.DecimalField(max_digits=10, decimal_places=2, default=Decimal('0.00'))
    tax = models.DecimalField(max_digits=10, decimal_places=2, default=Decimal('0.00'))
    total = models.DecimalField(max_digits=10, decimal_places=2, default=Decimal('0.00'))
    
    # Status
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='open'
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    last_updated_at = models.DateTimeField(auto_now=True)
    paid_at = models.DateTimeField(null=True, blank=True)
    closed_at = models.DateTimeField(null=True, blank=True)
    
    # Who closed it
    closed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name='closed_invoices'
    )
    close_reason = models.CharField(
        max_length=50,
        choices=[
            ('customer_left', 'Customer Left Table'),
            ('waiter_cleared', 'Waiter Cleared Table'),
            ('admin_closed', 'Admin Closed'),
            ('cancelled', 'Cancelled')
        ],
        null=True,
        blank=True
    )
    
    class Meta:
        app_label = 'invoices'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['restaurant', 'table_number', 'status']),
            models.Index(fields=['status', 'created_at']),
        ]
    
    def __str__(self):
        return f"Invoice #{self.pk} - Table {self.table_number} ({self.status})"
    
    def add_order(self, order_instance, tax_rate=0.10):
        """
        Add order to invoice and update totals
        
        Args:
            order_instance: Order model instance
            tax_rate: Tax percentage (default 10%)
        """
        if self.status not in ['open', 'ready']:
            raise ValueError(f"Cannot add order to {self.status} invoice")
        
        # Add to items
        order_item = {
            'order_id': order_instance.pk,
            'items': order_instance.items if hasattr(order_instance, 'items') else [],
            'price': float(order_instance.total),
            'created_at': order_instance.created_at.isoformat(),
        }
        
        self.items.append(order_item)
        
        # Recalculate totals
        self.subtotal = sum(float(item['price']) for item in self.items)
        self.tax = round(self.subtotal * tax_rate, 2)
        self.total = self.subtotal + self.tax
        
        self.save()
    
    def close_table(self, closed_by, reason='waiter_cleared'):
        """
        Close table session (manual expiration)
        
        Args:
            closed_by: User who is closing
            reason: Reason for closing
        """
        self.status = 'expired'
        self.closed_by = closed_by
        self.closed_at = timezone.now()
        self.close_reason = reason
        self.save()
    
    def mark_paid(self):
        """Mark invoice as paid"""
        self.status = 'paid'
        self.paid_at = timezone.now()
        self.save()
    
    def can_close(self, user):
        """
        Check if user can close this invoice
        
        Args:
            user: User instance
            
        Returns:
            bool: True if user can close
        """
        # Admin can always close
        if user.is_staff or user.is_superuser:
            return True
        
        # Waiter (staff) can close
        if hasattr(user, 'waiter') or hasattr(user, 'restaurant_staff'):
            return True
        
        # Customer can only close their own (if we add customer tracking)
        return False
