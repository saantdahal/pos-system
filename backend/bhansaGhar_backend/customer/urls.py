from django.urls import path
from . import views, api

app_name = 'customer'
urlpatterns = [
    # ========== LANDING PAGE ROUTE ==========
    # Dynamic landing page with restaurants and customizable content
    path('', views.landing_page_view, name='landing_page'),
    
    # API endpoint for content pages (Privacy, Terms, etc.)
    path('api/content-page/<slug:slug>/', views.content_page_api, name='content_page_api'),
    
    # ========== PUBLIC WEBSITE ROUTES ==========
    # Homepage - List all restaurants (NEW DEFAULT)
    path('restaurants/', views.restaurant_list, name='restaurant_list'),
    path('restaurants/list/', views.restaurant_list, name='restaurant_list_alt'),
    
    # Public restaurant landing page (browsing only, no ordering)
    path('restaurant/<slug:slug>/', views.public_restaurant, name='public_restaurant'),
    
    # QR scan endpoint (table validation and session setup)
    path('restaurant/<slug:slug>/qr/<int:table_number>/', views.scan_qr, name='scan_qr'),
    
    # Gated menu (full ordering with session validation)
    path('restaurant/<slug:slug>/qr/<int:table_number>/menu/', views.gated_menu, name='gated_menu'),
    
    # Gated cart API (session-secured order placement)
    path('restaurant/<slug:slug>/qr/<int:table_number>/api/cart/', views.PublicCartView.as_view(), name='public_cart_api'),

    # ========== LEGACY QR-BASED VIEWS (kept for backward compatibility) ==========
    path('legacy/menu/<uuid:table_id>/', views.menu_view, name='customer_menu'),
    path('legacy/menu/', views.menu_view, name='customer_menu_no_table'),
    path('legacy/orders/<uuid:table_id>/', views.orders_view, name='customer_orders'),
    path('legacy/orders/', views.orders_view, name='customer_orders_no_table'),
    path('legacy/cart/<uuid:table_id>/', views.CartView.as_view(), name='customer_cart'),
    path('legacy/cart/', views.CartView.as_view(), name='customer_cart_no_table'),
    path('legacy/leave/', views.leave_table, name='leave_table'),

    # ========== ADMIN API ROUTES ==========
    # Get/Update restaurant content for admin panel
    path('api/admin/restaurant/<slug:slug>/', api.admin_restaurant_content, name='admin_restaurant_content'),
    
    # Upload menu images
    path('api/admin/upload-image/', api.admin_upload_menu_image, name='admin_upload_image'),
    
    # Add menu item
    path('api/admin/restaurant/<slug:slug>/menu-item/', api.admin_add_menu_item, name='admin_add_menu_item'),
    
    # Get list of admin's restaurants
    path('api/admin/restaurants/', api.admin_restaurant_list, name='admin_restaurants'),
    
    # ========== SUPER ADMIN API ROUTES - LANDING PAGE MANAGEMENT ==========
    # Landing page management (GET/UPDATE for super admin)
    path('api/admin/landing-page/', views.landing_page_admin_view, name='landing_page_admin'),
    
    # App cards management (LIST/CREATE for super admin)
    path('api/admin/app-cards/', views.app_cards_admin_view, name='app_cards_admin'),
    
    # Individual app card management (GET/UPDATE/DELETE for super admin)
    path('api/admin/app-cards/<int:pk>/', views.app_cards_detail_view, name='app_card_detail'),
    
    # ========== PUBLIC API ROUTES (NO AUTH) ==========
    # Get restaurant data for public browsing
    path('api/public/restaurant/<slug:slug>/', api.public_restaurant_data, name='public_restaurant_data'),
    
    # Public landing page data (for frontend)
    path('api/public/landing-page/', views.landing_page_public_view, name='landing_page_public'),
    
    # Public app cards (for frontend)
    path('api/public/app-cards/', views.app_cards_public_view, name='app_cards_public'),
]
