from django.db import models
from django.utils import timezone
import uuid
from restaurants.models import Restaurant, Table
from core.models import User

class BaseOrderStatus(models.TextChoices):
    PENDING = 'pending', 'Pending'
    PREPARING = 'preparing', 'Preparing'
    BARGAIN = 'bargain', 'Bargain'
    READY = 'ready', 'Ready'
    SERVED = 'served', 'Served'
    CANCELLED = 'cancelled', 'Cancelled'

class Order(models.Model):
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    restaurant = models.ForeignKey(Restaurant, on_delete=models.CASCADE, related_name='orders')
    table = models.ForeignKey(Table, on_delete=models.CASCADE, related_name='orders', null=True, blank=True)
    customer_name = models.CharField(max_length=100, blank=True, null=True)
    customer_phone = models.CharField(max_length=15, blank=True, null=True)
    session_id = models.CharField(max_length=255)  # Anonymous customer
    status = models.CharField(max_length=20, choices=BaseOrderStatus.choices, default=BaseOrderStatus.PENDING)
    subtotal = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    tax_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    discount_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    total_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    customer_notes = models.TextField(blank=True)
    prepared_at = models.DateTimeField(null=True, blank=True)
    served_at = models.DateTimeField(null=True, blank=True)
    
    # Staff assignments
    assigned_waiter = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='assigned_waiter_orders'
    )
    assigned_kitchen_staff = models.ManyToManyField(
        User,
        blank=True,
        related_name='assigned_kitchen_orders'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['restaurant', 'status']),
            models.Index(fields=['assigned_waiter', 'status']),
        ]

    def __str__(self):
        return f"Order {self.id} - Table {self.table.number if self.table else 'N/A'}"

class BaseBargainStatus(models.TextChoices):
    ACCEPTED = 'accepted', 'Accepted'
    REJECTED = 'rejected', 'Rejected'
    PENDING = 'pending', 'Pending'

class OrderBargain(models.Model):
    ACTION_TYPE_CHOICES = [
        ('quantity_adjustment', 'Quantity Adjustment'),
        ('availability', 'Availability Issue'),
        ('substitution', 'Substitution Request'),
    ]
    
    CUSTOMER_RESPONSE_CHOICES = [
        ('accepted', 'Accepted'),
        ('rejected', 'Rejected'),
        ('pending', 'Pending'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, serialize=False)
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='bargains')
    order_item_id = models.BigIntegerField(default=0)  # Reference to OrderItem
    action_type = models.CharField(max_length=20, choices=ACTION_TYPE_CHOICES, default='quantity_adjustment')
    requested_quantity = models.IntegerField(default=0)  # Requested
    available_quantity = models.IntegerField(default=0)  # Available
    accepted_quantity = models.IntegerField(null=True, blank=True)
    staff_message = models.TextField(default='')
    customer_message = models.TextField(blank=True, null=True)
    customer_response = models.CharField(max_length=20, choices=CUSTOMER_RESPONSE_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    answered_at = models.DateTimeField(null=True, blank=True)
    expires_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"Bargain for Order {self.order.id} - Item {self.order_item_id}"

class OrderServeLog(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='serve_logs')
    table_status_before = models.CharField(max_length=20)
    served_items = models.JSONField()  # {"item1": true, "item2": false}
    waiter_notes = models.TextField(blank=True)
    served_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Serve Log for Order {self.order.id} at {self.served_at}"

# ============= NEW MODELS FOR ENHANCEMENTS =============

class WaiterSession(models.Model):
    """
    Track waiter availability and active status
    """
    WAITER_STATUS_CHOICES = [
        ('idle', 'Idle - Available'),
        ('busy', 'Busy - Active Orders'),
        ('on_break', 'On Break'),
        ('offline', 'Offline'),
    ]
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='waiter_session')
    restaurant = models.ForeignKey(Restaurant, on_delete=models.CASCADE, related_name='waiter_sessions')
    status = models.CharField(max_length=20, choices=WAITER_STATUS_CHOICES, default='offline')
    
    active_orders_count = models.IntegerField(default=0)
    last_heartbeat = models.DateTimeField(auto_now=True)
    
    session_started_at = models.DateTimeField(auto_now_add=True)
    session_ended_at = models.DateTimeField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ('user', 'restaurant')
        indexes = [
            models.Index(fields=['restaurant', 'status']),
            models.Index(fields=['last_heartbeat']),
        ]
    
    def is_active(self):
        """Check if waiter is still active (heartbeat within 5 minutes)"""
        five_min_ago = timezone.now() - timezone.timedelta(minutes=5)
        return self.last_heartbeat > five_min_ago and self.status != 'offline'
    
    def __str__(self):
        return f"{self.user.username} - {self.status}"


class BargainMessage(models.Model):
    """
    Chat messages for bargain negotiation
    """
    SENDER_TYPE_CHOICES = [
        ('kitchen', 'Kitchen Staff'),
        ('customer', 'Customer'),
        ('admin', 'Admin'),
    ]
    
    MESSAGE_STATUS_CHOICES = [
        ('sent', 'Sent'),
        ('delivered', 'Delivered'),
        ('read', 'Read'),
    ]
    
    bargain = models.ForeignKey(OrderBargain, on_delete=models.CASCADE, related_name='messages')
    sender_type = models.CharField(max_length=20, choices=SENDER_TYPE_CHOICES)
    sender = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    
    message = models.TextField()
    status = models.CharField(max_length=20, choices=MESSAGE_STATUS_CHOICES, default='sent')
    
    created_at = models.DateTimeField(auto_now_add=True)
    read_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        ordering = ['created_at']
        indexes = [
            models.Index(fields=['bargain', 'created_at']),
        ]
    
    def __str__(self):
        return f"Message from {self.sender_type} on {self.created_at}"


class OrderTimeline(models.Model):
    """
    Track all status changes and events for an order
    """
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='timeline')
    
    status_old = models.CharField(max_length=20, null=True, blank=True)
    status_new = models.CharField(max_length=20)
    
    changed_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    reason = models.TextField(blank=True)  # Why status changed
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['created_at']
        indexes = [
            models.Index(fields=['order', 'created_at']),
        ]
    
    def __str__(self):
        return f"{self.order.id}: {self.status_old} → {self.status_new}"


class OrderAssignment(models.Model):
    """
    Track who (waiter/kitchen staff) is assigned to which order task
    """
    TASK_TYPE_CHOICES = [
        ('prep', 'Preparation'),
        ('serve', 'Service'),
    ]
    
    ASSIGNMENT_STATUS_CHOICES = [
        ('pending', 'Pending Assignment'),
        ('accepted', 'Accepted'),
        ('in_progress', 'In Progress'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    ]
    
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='assignments')
    assigned_user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    task_type = models.CharField(max_length=20, choices=TASK_TYPE_CHOICES)
    
    status = models.CharField(max_length=20, choices=ASSIGNMENT_STATUS_CHOICES, default='pending')
    
    assigned_at = models.DateTimeField(auto_now_add=True)
    accepted_at = models.DateTimeField(null=True, blank=True)
    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    notes = models.TextField(blank=True)
    
    class Meta:
        ordering = ['assigned_at']
        indexes = [
            models.Index(fields=['order', 'task_type']),
            models.Index(fields=['assigned_user', 'status']),
        ]
    
    def __str__(self):
        return f"Order {self.order.id} - {self.task_type} ({self.status})"
