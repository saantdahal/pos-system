from rest_framework.permissions import BasePermission


class AdminPermission(BasePermission):
    """
    Only restaurant admins/owners can access
    """
    def has_permission(self, request, view) -> bool:  # type: ignore[override]
        return bool(
            request.user
            and request.user.is_authenticated
            and request.user.role == 'admin'
            and request.user.owned_restaurant is not None
        )


class KitchenPermission(BasePermission):
    """
    Only kitchen staff can access
    """
    def has_permission(self, request, view) -> bool:  # type: ignore[override]
        return bool(
            request.user
            and request.user.is_authenticated
            and request.user.role == 'kitchen'
            and request.user.restaurant is not None
        )


class WaiterPermission(BasePermission):
    """
    Only waiter staff can access
    """
    def has_permission(self, request, view) -> bool:  # type: ignore[override]
        return bool(
            request.user
            and request.user.is_authenticated
            and request.user.role == 'waiter'
            and request.user.restaurant is not None
        )


class AnalyticsAccessPermission(BasePermission):
    """
    Access analytics based on user role and restaurant
    """
    def has_permission(self, request, view) -> bool:  # type: ignore[override]
        return bool(
            request.user
            and request.user.is_authenticated
            and request.user.role in ['admin', 'kitchen', 'waiter']
        )
    
    def has_object_permission(self, request, view, obj) -> bool:  # type: ignore[override]
        # Admin can access own restaurant
        if request.user.role == 'admin':
            return bool(obj.restaurant.owner == request.user)
        
        # Kitchen and waiter can access assigned restaurant
        if request.user.role in ['kitchen', 'waiter']:
            return bool(obj.restaurant == request.user.restaurant)
        
        return False
