from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    RestaurantViewSet, RestaurantTypeViewSet, CategoryViewSet, MenuItemViewSet, TableViewSet,
    create_restaurant, get_restaurant, update_restaurant, validate_table_qr, report_dirty_table,
    create_staff_invite, list_staff_invites, delete_staff_invite, get_invite_details, claim_staff_invite, list_staff, remove_staff, toggle_staff_status
)

router = DefaultRouter()
router.register(r'restaurants', RestaurantViewSet, basename='restaurant')
router.register(r'restaurant-types', RestaurantTypeViewSet, basename='restaurant-type')
router.register(r'categories', CategoryViewSet, basename='category')
router.register(r'menu-items', MenuItemViewSet, basename='menu-item')
router.register(r'tables', TableViewSet, basename='table')

urlpatterns = [
    path('', include(router.urls)),
    path('create/', create_restaurant, name='create_restaurant'),
    path('my-restaurant/', get_restaurant, name='get_restaurant'),
    path('update/', update_restaurant, name='update_restaurant'),
    path('validate-table-qr/', validate_table_qr, name='validate_table_qr'),
    path('tables/<uuid:table_id>/report-dirty/', report_dirty_table, name='report_dirty_table'),
    
    # Staff invitation endpoints
    path('staff-invite/', create_staff_invite, name='create_staff_invite'),
    path('staff-invites/', list_staff_invites, name='list_staff_invites'),
    path('staff-invite/<uuid:invite_id>/', delete_staff_invite, name='delete_staff_invite'),
    path('invite-details/<uuid:invite_id>/', get_invite_details, name='get_invite_details'),
    path('claim-invite/<uuid:invite_id>/', claim_staff_invite, name='claim_staff_invite'),
    path('staff/', list_staff, name='list_staff'),
    path('staff/<int:staff_id>/', remove_staff, name='remove_staff'),
    path('staff/<int:staff_id>/toggle-status/', toggle_staff_status, name='toggle_staff_status'),
]
