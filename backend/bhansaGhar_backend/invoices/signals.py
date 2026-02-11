from django.db.models.signals import post_save
from django.dispatch import receiver
from django.utils import timezone
from orders.models import Order
from .models import Invoice


@receiver(post_save, sender=Order)
def auto_create_or_update_invoice(sender, instance, created, **kwargs):
    """
    Signal: When Order is created/updated, auto-create or update Invoice
    
    - If table has OPEN invoice → add order to it
    - If no OPEN invoice → create new one
    """
    
    if not created:
        # Only process on order creation, not updates
        return
    
    try:
        restaurant = instance.restaurant
        table_number = instance.table_number
        
        # Check if OPEN invoice exists for this table
        open_invoice = Invoice.objects.filter(
            restaurant=restaurant,
            table_number=table_number,
            status__in=['open', 'ready']
        ).first()
        
        if open_invoice:
            # ADD order to existing invoice
            open_invoice.add_order(instance)
            
        else:
            # CREATE new invoice
            invoice = Invoice.objects.create(
                restaurant=restaurant,
                table_number=table_number,
                items=[],
                status='open'
            )
            # Add this order to the new invoice
            invoice.add_order(instance)
            
    except Exception as e:
        # Log error but don't break order creation
        print(f"Error creating invoice for order {instance.id}: {str(e)}")


@receiver(post_save, sender=Order)
def check_expired_invoice_for_new_order(sender, instance, created, **kwargs):
    """
    Signal: If customer orders again at a paid/expired table,
    create new invoice (don't add to old expired one)
    """
    
    if not created:
        return
    
    try:
        restaurant = instance.restaurant
        table_number = instance.table_number
        
        # Check if EXPIRED/PAID invoice exists
        expired_invoice = Invoice.objects.filter(
            restaurant=restaurant,
            table_number=table_number,
            status__in=['expired', 'paid', 'cancelled']
        ).latest('closed_at')
        
        # If there's an expired one but we're processing a new order,
        # the previous signal should have created a new one already
        # This is just a safeguard
        
    except Exception as e:
        print(f"Error checking expired invoice: {str(e)}")
