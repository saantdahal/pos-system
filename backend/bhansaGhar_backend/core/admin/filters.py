"""
Admin filters and custom filter classes
"""
from django.contrib.admin import SimpleListFilter
from restaurants.models import Restaurant


class RestaurantListFilter(SimpleListFilter):
    """Filter by restaurant in admin list view"""
    title = 'Restaurant'
    parameter_name = 'restaurant'
    
    def lookups(self, request, model_admin):
        if request.user.is_superuser:
            restaurants = Restaurant.objects.filter(is_active=True)
        else:
            if hasattr(request.user, 'owned_restaurant'):
                return [(request.user.owned_restaurant.id, request.user.owned_restaurant.name)]
            return []
        
        return [(r.id, r.name) for r in restaurants]
    
    def queryset(self, request, queryset):
        if self.value():  # type: ignore[attr-defined]
            return queryset.filter(restaurant__id=self.value())  # type: ignore[attr-defined]
        return queryset
