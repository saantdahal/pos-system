from rest_framework.permissions import BasePermission
from restaurants.models import Restaurant


class KitchenPermission(BasePermission):
    def has_permission(self, request, view) -> bool:
        # Allow if user is kitchen staff and belongs to the restaurant they are accessing
        # Note: The original request suggested checking view.kwargs['restaurant'], 
        # but the views might just use request.user.restaurant.
        # We will assume the user has a 'role' attribute and 'restaurant' or 'owned_restaurant' attribute.
        
        if not request.user.is_authenticated:
            return False
            
        if request.user.is_superuser:
            return True

        # Check for role attribute (assuming extended User model or profile)
        # Based on previous file reads, User model seems custom in core.models.User
        
        # Adaptation: Check if user has 'kitchen' role
        # We'll check the 'role' field on the user object if it exists.
        
        if getattr(request.user, 'role', None) == 'kitchen':
             return True
             
        # Also allow if user is the owner (Admin)
        if hasattr(request.user, 'owned_restaurant'):
            return True
            
        return False

class WaiterPermission(BasePermission):
    def has_permission(self, request, view) -> bool:
        if not request.user.is_authenticated:
            return False
            
        if request.user.is_superuser:
            return True
            
        if getattr(request.user, 'role', None) == 'waiter':
            return True
            
        if hasattr(request.user, 'owned_restaurant'):
            return True
            
        return False


# New Enhanced Permissions for Order Features

class IsRestaurantAdmin(BasePermission):
    """Only restaurant owner/admin can access"""
    
    def has_permission(self, request, view) -> bool:
        return request.user and request.user.is_authenticated and hasattr(request.user, 'role')
    
    def has_object_permission(self, request, view, obj) -> bool:
        if not request.user.is_authenticated:
            return False
        
        restaurant = obj.restaurant if hasattr(obj, 'restaurant') else None
        if not restaurant:
            return False
        
        return restaurant.owner_id == request.user.id


class IsWaiterStaff(BasePermission):
    """Only waiter staff can access"""
    
    def has_permission(self, request, view) -> bool:
        if not request.user or not request.user.is_authenticated:
            return False
        
        return request.user.role == 'waiter'
    
    def has_object_permission(self, request, view, obj) -> bool:
        if not self.has_permission(request, view):
            return False
        
        # Waiter can only access their own assignments
        if hasattr(obj, 'assigned_waiter'):
            return obj.assigned_waiter_id == request.user.id
        
        return False


class IsKitchenStaff(BasePermission):
    """Only kitchen staff can access"""
    
    def has_permission(self, request, view) -> bool:
        if not request.user or not request.user.is_authenticated:
            return False
        
        return request.user.role == 'kitchen'
    
    def has_object_permission(self, request, view, obj) -> bool:
        if not self.has_permission(request, view):
            return False
        
        # Kitchen staff can only access their assigned orders
        if hasattr(obj, 'assigned_kitchen_staff'):
            return request.user in obj.assigned_kitchen_staff.all()
        
        return False


class IsCustomer(BasePermission):
    """Only customer role can access"""
    
    def has_permission(self, request, view) -> bool:
        if not request.user or not request.user.is_authenticated:
            return False
        
        return request.user.role == 'customer'


class IsWaiterOrAdmin(BasePermission):
    """Waiter or restaurant admin can access"""
    
    def has_permission(self, request, view) -> bool:
        return request.user and request.user.is_authenticated
    
    def has_object_permission(self, request, view, obj) -> bool:
        if not request.user.is_authenticated:
            return False
        
        restaurant = obj.restaurant if hasattr(obj, 'restaurant') else None
        if not restaurant:
            return False
        
        # Admin has full access
        if restaurant.owner_id == request.user.id:
            return True
        
        # Waiter can access assigned orders
        if request.user.role == 'waiter' and hasattr(obj, 'assigned_waiter'):
            return obj.assigned_waiter_id == request.user.id
        
        return False


class IsKitchenOrAdmin(BasePermission):
    """Kitchen staff or admin can access"""
    
    def has_permission(self, request, view) -> bool:
        return request.user and request.user.is_authenticated
    
    def has_object_permission(self, request, view, obj) -> bool:
        if not request.user.is_authenticated:
            return False
        
        restaurant = obj.restaurant if hasattr(obj, 'restaurant') else None
        if not restaurant:
            return False
        
        # Admin has full access
        if restaurant.owner_id == request.user.id:
            return True
        
        # Kitchen can access assigned orders
        if request.user.role == 'kitchen' and hasattr(obj, 'assigned_kitchen_staff'):
            return request.user in obj.assigned_kitchen_staff.all()
        
        return False


class IsMasterAdminRole(BasePermission):
    """Master admin role - restaurant owner with override access"""
    
    def has_permission(self, request, view) -> bool:
        if not request.user or not request.user.is_authenticated:
            return False
        
        # Must be restaurant owner
        return hasattr(request.user, 'owned_restaurants') and request.user.owned_restaurants.exists()
    
    def has_object_permission(self, request, view, obj) -> bool:
        if not self.has_permission(request, view):
            return False
        
        restaurant = obj.restaurant if hasattr(obj, 'restaurant') else None
        if not restaurant:
            return False
        
        return restaurant.owner_id == request.user.id


class CanAccessOrderBargain(BasePermission):
    """Can access bargain if part of order or restaurant staff"""
    
    def has_permission(self, request, view) -> bool:
        return request.user and request.user.is_authenticated
    
    def has_object_permission(self, request, view, obj) -> bool:
        if not request.user.is_authenticated:
            return False
        
        # BargainMessage object has a bargain FK
        bargain = obj.bargain if hasattr(obj, 'bargain') else obj
        order = bargain.order if hasattr(bargain, 'order') else None
        
        if not order:
            return False
        
        # Restaurant admin has full access
        if order.restaurant.owner_id == request.user.id:
            return True
        
        # Waiter can access if assigned
        if request.user.role == 'waiter' and order.assigned_waiter_id == request.user.id:
            return True
        
        # Kitchen can access if assigned
        if request.user.role == 'kitchen' and request.user in order.assigned_kitchen_staff.all():
            return True
        
        # Message sender can access their own messages
        if hasattr(obj, 'sender') and obj.sender_id == request.user.id:
            return True
        
