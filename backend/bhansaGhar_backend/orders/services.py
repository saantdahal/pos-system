"""
Order Assignment & Management Service
Handles auto-assignment of staff, workload balancing, and order workflow
"""

from django.utils import timezone
from django.db.models import Q, Count
from datetime import timedelta
from typing import Optional, List
from django.db.models import QuerySet
from core.models import User
from restaurants.models import Restaurant
from .models import (
    Order, WaiterSession, OrderAssignment, OrderTimeline, 
    BaseOrderStatus, OrderBargain, BargainMessage
)
import logging

logger = logging.getLogger(__name__)


class OrderAssignmentService:
    """Service for order assignment and staff management"""
    
    @staticmethod
    def get_active_waiters(restaurant: Restaurant):
        """
        Get all active waiters for a restaurant
        Returns waiters with recent heartbeat (< 5 min ago)
        """
        five_min_ago = timezone.now() - timedelta(minutes=5)
        
        sessions = WaiterSession.objects.filter(
            restaurant=restaurant,
            status__in=['idle', 'busy'],
            last_heartbeat__gt=five_min_ago
        ).select_related('user')
        
        return [s.user for s in sessions]
    
    @staticmethod
    def get_waiter_workload(waiter: User) -> int:
        """Get count of active orders assigned to waiter"""
        return Order.objects.filter(
            assigned_waiter=waiter,
            status__in=['pending', 'preparing', 'ready']
        ).count()
    
    @staticmethod
    def auto_assign_waiter(order: Order) -> Optional[User]:
        """
        Auto-assign a free waiter to the order
        
        Precedence:
        1. Find waiter with lowest active orders
        2. If all busy, check who will be free soonest
        3. If no waiters, return None (admin notified)
        """
        restaurant = order.restaurant
        
        # Get active waiters
        active_waiters = OrderAssignmentService.get_active_waiters(restaurant)
        
        if not active_waiters:
            logger.warning(f"No active waiters for restaurant {restaurant.id}")
            return None
        
        # Find waiter with minimum workload
        waiter_workload = [
            (w, OrderAssignmentService.get_waiter_workload(w))
            for w in active_waiters
        ]
        
        # Sort by workload (ascending)
        waiter_workload.sort(key=lambda x: x[1])
        best_waiter, workload = waiter_workload[0]
        
        # Check if overwhelmed (more than 5 active orders)
        if workload >= 5:
            logger.warning(
                f"All waiters busy for restaurant {restaurant.id}. "
                f"Best waiter has {workload} orders"
            )
            return None
        
        return best_waiter
    
    @staticmethod
    def assign_order_to_waiter(order: Order, waiter: User) -> bool:
        """
        Assign order to specific waiter
        Creates OrderAssignment record and updates order
        """
        try:
            # Update order
            order.assigned_waiter = waiter
            order.save()
            
            # Create assignment record
            OrderAssignment.objects.create(
                order=order,
                assigned_user=waiter,
                task_type='serve',
                status='pending'
            )
            
            # Log timeline
            OrderTimeline.objects.create(
                order=order,
                status_old=order.status,
                status_new=order.status,
                changed_by=waiter,
                reason=f"Auto-assigned to waiter {waiter.username}"
            )
            
            logger.info(f"Order {order.id} assigned to waiter {waiter.username}")
            return True
        except Exception as e:
            logger.error(f"Error assigning order {order.id} to waiter: {str(e)}")
            return False
    
    @staticmethod
    def get_available_kitchen_staff(restaurant: Restaurant):
        """
        Get active kitchen staff for a restaurant
        """
        five_min_ago = timezone.now() - timedelta(minutes=5)
        
        # Get kitchen staff with recent activity
        kitchen_staff = User.objects.filter(
            restaurant=restaurant,
            role='kitchen',
            last_login__gt=five_min_ago
        )
        
        return kitchen_staff
    
    @staticmethod
    def create_order_timeline(
        order: Order,
        status_new: str,
        changed_by: Optional[User] = None,
        reason: str = ""
    ):
        """Create a timeline entry for order status change"""
        status_old = order.status
        
        OrderTimeline.objects.create(
            order=order,
            status_old=status_old,
            status_new=status_new,
            changed_by=changed_by,
            reason=reason or f"Status changed to {status_new}"
        )
    
    @staticmethod
    def update_order_status(
        order: Order,
        new_status: str,
        changed_by: Optional[User] = None,
        reason: str = ""
    ) -> bool:
        """
        Update order status and create timeline entry
        """
        try:
            old_status = order.status
            order.status = new_status
            order.save()
            
            OrderAssignmentService.create_order_timeline(
                order,
                new_status,
                changed_by,
                reason
            )
            
            logger.info(f"Order {order.id}: {old_status} → {new_status}")
            return True
        except Exception as e:
            logger.error(f"Error updating order {order.id} status: {str(e)}")
            return False


class BargainChatService:
    """Service for bargain negotiation with chat messages"""
    
    @staticmethod
    def add_message(
        bargain: OrderBargain,
        sender_type: str,
        message: str,
        sender: Optional[User] = None
    ) -> BargainMessage:
        """
        Add a message to bargain chat
        
        sender_type: 'kitchen', 'customer', 'admin'
        """
        msg = BargainMessage.objects.create(
            bargain=bargain,
            sender_type=sender_type,
            sender=sender,
            message=message
        )
        return msg
    
    @staticmethod
    def get_chat_history(bargain: OrderBargain, limit: int = 50) -> QuerySet:
        """Get chat history for a bargain"""
        messages = bargain.messages.all()[:limit]  # type: ignore
        return messages
    
    @staticmethod
    def accept_bargain(bargain: OrderBargain, accepted_by: Optional[User] = None) -> bool:
        """
        Accept bargain - update order items with agreed quantity
        """
        try:
            order = bargain.order
            
            # Update order items with kitchen's agreed quantity
            if order.items and isinstance(order.items, list):
                for item in order.items:
                    if item.get('item_id') == bargain.item_id:  # type: ignore
                        item['qty'] = bargain.kitchen_qty  # type: ignore
                
                order.items = order.items
                order.save()
            
            # Update bargain
            bargain.status = 'accepted'
            bargain.resolved_at = timezone.now()
            bargain.save()
            
            # Add system message
            BargainChatService.add_message(
                bargain,
                'admin',
                f"Bargain accepted - Item quantity updated to {bargain.kitchen_qty}",  # type: ignore
                accepted_by
            )
            
            # Move order back to preparing
            OrderAssignmentService.update_order_status(
                order,
                'preparing',
                accepted_by,
                "Bargain accepted - order resumed"
            )
            
            logger.info(f"Bargain {bargain.id} accepted")  # type: ignore
            return True
        except Exception as e:
            logger.error(f"Error accepting bargain {bargain.id}: {str(e)}")  # type: ignore
            return False
    
    @staticmethod
    def reject_bargain(bargain: OrderBargain, rejected_by: Optional[User] = None, reason: str = "") -> bool:
        """
        Reject bargain - order returns to pending for customer decision
        """
        try:
            bargain.status = 'rejected'
            bargain.resolved_at = timezone.now()
            bargain.save()
            
            # Add system message
            BargainChatService.add_message(
                bargain,
                'admin',
                f"Bargain rejected. {reason}",
                rejected_by
            )
            
            # Move order back to pending (customer can reorder or cancel)
            order = bargain.order
            OrderAssignmentService.update_order_status(
                order,
                'pending',
                rejected_by,
                "Bargain rejected"
            )
            
            logger.info(f"Bargain {bargain.id} rejected")  # type: ignore
            return True
        except Exception as e:
            logger.error(f"Error rejecting bargain {bargain.id}: {str(e)}")  # type: ignore
            return False


class AdminMasterRoleService:
    """Service for admin override and master role access"""
    
    @staticmethod
    def can_admin_access(user: User, restaurant: Restaurant) -> bool:
        """Check if user can access restaurant as admin"""
        if user.role != 'admin':
            return False
        
        # Admin can only access their own restaurant
        return hasattr(user, 'owned_restaurant') and user.owned_restaurant == restaurant
    
    @staticmethod
    def get_admin_order_view(admin_user: User):
        """
        Get all orders for admin's restaurant with full details
        Admin sees everything with staff assignments
        """
        if admin_user.role != 'admin':
            return Order.objects.none()
        
        restaurant = admin_user.owned_restaurant
        if not restaurant:
            return Order.objects.none()
        
        return Order.objects.filter(
            restaurant=restaurant
        ).select_related(
            'assigned_waiter'
        ).prefetch_related(
            'assigned_kitchen_staff',
            'bargains',
            'assignments',
            'timeline'
        ).order_by('-created_at')
    
    @staticmethod
    def admin_auto_manage_order(admin_user: User, order: Order) -> bool:
        """
        Admin takes over order management directly
        This happens when no staff is available
        """
        if not AdminMasterRoleService.can_admin_access(admin_user, order.restaurant):
            logger.warning(f"Unauthorized admin access attempt")
            return False
        
        try:
            # Assign admin as both waiter and kitchen if needed
            if not order.assigned_waiter:
                order.assigned_waiter = admin_user
            
            if not order.assigned_kitchen_staff.exists():
                order.assigned_kitchen_staff.add(admin_user)
            
            order.save()
            
            OrderTimeline.objects.create(
                order=order,
                status_old=order.status,
                status_new=order.status,
                changed_by=admin_user,
                reason="Admin taking over - no staff available"
            )
            
            logger.info(f"Admin {admin_user.username} took over order {order.id}")
            return True
        except Exception as e:
            logger.error(f"Error in admin auto-manage: {str(e)}")
            return False
    
    @staticmethod
    def admin_reassign_staff(
        admin_user: User,
        order: Order,
        waiter: Optional[User] = None,
        kitchen_staff: Optional[list] = None
    ) -> bool:
        """
        Admin manually reassign staff to order
        """
        if not AdminMasterRoleService.can_admin_access(admin_user, order.restaurant):
            return False
        
        try:
            old_waiter = order.assigned_waiter
            
            if waiter:
                order.assigned_waiter = waiter
            
            if kitchen_staff:
                order.assigned_kitchen_staff.set(kitchen_staff)
            
            order.save()
            
            reason = f"Manual reassignment by admin"
            if waiter and waiter != old_waiter:
                reason += f" - Waiter changed from {old_waiter} to {waiter}"
            
            OrderTimeline.objects.create(
                order=order,
                status_old=order.status,
                status_new=order.status,
                changed_by=admin_user,
                reason=reason
            )
            
            logger.info(f"Order {order.id} reassigned by admin")
            return True
        except Exception as e:
            logger.error(f"Error reassigning order: {str(e)}")
            return False
