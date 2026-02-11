import logging
from django.core.cache import cache

logger = logging.getLogger(__name__)

CACHE_TTL = 60 * 60 * 24  # 24 hours
MENU_CACHE_KEY = "restaurant_menu_{}"


class CacheService:
    """Service for cache operations."""
    
    @staticmethod
    def get(key):
        """Get value from cache."""
        return cache.get(key)
    
    @staticmethod
    def set(key, value, timeout=CACHE_TTL):
        """Set value in cache."""
        cache.set(key, value, timeout)
    
    @staticmethod
    def delete(key):
        """Delete value from cache."""
        cache.delete(key)
    
    @staticmethod
    def clear():
        """Clear all cache."""
        cache.clear()


def clear_cache():
    """Clear all cache."""
    CacheService.clear()


def get_cached_data(key):
    """Get cached data by key."""
    return CacheService.get(key)


def set_cache(key, value, timeout=CACHE_TTL):
    """Set cached data by key."""
    CacheService.set(key, value, timeout)


def get_cached_menu(restaurant):
    """
    Get menu from cache or DB.
    """
    from restaurants.serializers import CategoryWithItemsSerializer
    
    cache_key = MENU_CACHE_KEY.format(restaurant.id)
    cached_data = cache.get(cache_key)
    
    if cached_data:
        logger.info(f"🚀 Menu Cache HIT for restaurant {restaurant.id}")
        return cached_data
    
    logger.info(f"🐢 Menu Cache MISS for restaurant {restaurant.id}")
    
    # Pre-fetch everything to avoid N+1
    categories = restaurant.categories.all().prefetch_related('items').order_by('position')
    data = CategoryWithItemsSerializer(categories, many=True).data
    
    cache.set(cache_key, data, CACHE_TTL)
    return data

def invalidate_menu_cache(restaurant_id):
    """
    Invalidate menu cache for a specific restaurant.
    """
    cache_key = MENU_CACHE_KEY.format(restaurant_id)
    cache.delete(cache_key)
    logger.info(f"♻️ Menu cache INVALIDATED for restaurant {restaurant_id}")
