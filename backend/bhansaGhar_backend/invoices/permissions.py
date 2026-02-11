from rest_framework import permissions


class IsAdminOrWaiter(permissions.BasePermission):
    """Allow access to admin and waiter staff only"""
    
    def has_permission(self, request, view):
        return bool(
            request.user and
            (request.user.is_staff or request.user.is_superuser)
        )


class CanCloseInvoice(permissions.BasePermission):
    """Allow closing invoice for admin, waiter, or customer of the table"""
    
    def has_object_permission(self, request, view, obj):
        # Admin/Superuser can close
        if request.user.is_staff or request.user.is_superuser:
            return True
        
        # Waiter can close
        if hasattr(request.user, 'waiter'):
            return True
        
        # In future: customer of table can request to close
        return False


class CanViewInvoice(permissions.BasePermission):
    """Allow viewing invoice for admin, waiter, or related customer"""
    
    def has_object_permission(self, request, view, obj):
        # Admin/Superuser can view
        if request.user.is_staff or request.user.is_superuser:
            return True
        
        # Waiter can view
        if hasattr(request.user, 'waiter'):
            return True
        
        # In future: customer can view their own invoice
        return True  # For now, allow anonymous customers
