"""
Admin mixins for shared functionality
"""


class AdminFilterMixin:
    """Mixin for restaurant-based filtering in admin"""
    
    def get_queryset(self, request):  # type: ignore[no-untyped-def]
        qs = super().get_queryset(request)  # type: ignore[misc]
        
        # Super admin sees everything
        if request.user.is_superuser:
            return qs
        
        # Restaurant owner sees only their restaurant data
        if hasattr(request.user, 'owned_restaurant'):
            restaurant = request.user.owned_restaurant
            return qs.filter(restaurant=restaurant)
        
        # Staff sees their restaurant data
        if request.user.restaurant:
            return qs.filter(restaurant=request.user.restaurant)
        
        return qs.none()
    
    def get_search_fields(self, request=None):
        """Override in child classes"""
        return []
