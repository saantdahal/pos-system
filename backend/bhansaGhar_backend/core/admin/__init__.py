"""
Admin module for Sperium Lounge

Organized structure:
- admin_site.py: Custom admin site configuration
- user_admin.py: User model administration
- restaurant_admin.py: Restaurant and related admin classes
- order_admin.py: Order and bargain admin classes
- analytics_admin.py: Analytics data admin classes
- staff_admin.py: Staff invite admin
- restaurant_centric.py: Restaurant-centric admin base classes
- inlines.py: All inline admin classes
- filters.py: Custom admin filters
- utils.py: Admin utilities & analytics (moved from admin_utils.py)
- landing_page_admin.py: Landing page content admin
"""

from .admin_site import admin_site, SperiumAdminSite
from .user_admin import UserAdmin
from .restaurant_admin import RestaurantAdmin, RestaurantTypeAdmin, TableAdmin, CategoryAdmin, MenuItemAdmin
from .order_admin import OrderAdmin, OrderBargainAdmin
from .analytics_admin import DailyAnalyticsAdmin, HourlyAnalyticsAdmin, TopItemAdmin
from .staff_admin import StaffInviteAdmin
from .activity_admin import ActivityLogAdmin
from .restaurant_centric import (
    RestaurantCentricAdminMixin, 
    RestaurantCentricAdmin,
    RestaurantAdmin as RestaurantCentricRestaurantAdmin,
    OrderAdmin as RestaurantCentricOrderAdmin,
    TableAdmin as RestaurantCentricTableAdmin,
    CategoryAdmin as RestaurantCentricCategoryAdmin,
    MenuItemAdmin as RestaurantCentricMenuItemAdmin,
    StaffInviteAdmin as RestaurantCentricStaffInviteAdmin,
    OrderBargainAdmin as RestaurantCentricOrderBargainAdmin
)

__all__ = [
    'admin_site',
    'SperiumAdminSite',
    'UserAdmin',
    'RestaurantAdmin',
    'RestaurantTypeAdmin',
    'TableAdmin',
    'CategoryAdmin',
    'MenuItemAdmin',
    'OrderAdmin',
    'OrderBargainAdmin',
    'DailyAnalyticsAdmin',
    'HourlyAnalyticsAdmin',
    'TopItemAdmin',
    'StaffInviteAdmin',
    'ActivityLogAdmin',
    # Restaurant-centric classes
    'RestaurantCentricAdminMixin',
    'RestaurantCentricAdmin',
    'RestaurantCentricRestaurantAdmin',
    'RestaurantCentricOrderAdmin',
    'RestaurantCentricTableAdmin',
    'RestaurantCentricCategoryAdmin',
    'RestaurantCentricMenuItemAdmin',
    'RestaurantCentricStaffInviteAdmin',
    'RestaurantCentricOrderBargainAdmin',
]
