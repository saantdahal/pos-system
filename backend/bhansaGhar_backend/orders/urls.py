from django.urls import path
from . import views

urlpatterns = [
    # Kitchen
    path('kitchen/orders/', views.kitchen_live_orders, name='kitchen-orders'),
    path('kitchen/orders/<uuid:order_id>/prep/', views.start_order_prep, name='kitchen-start-prep'),
    path('kitchen/orders/<uuid:order_id>/bargain/', views.kitchen_bargain, name='kitchen-bargain'),
    path('kitchen/orders/<uuid:order_id>/ready/', views.mark_order_ready, name='kitchen-ready'),
    
    # Customer
    path('customer/bargain/<uuid:bargain_id>/', views.customer_bargain_response, name='customer-bargain-response'),
    
    # Auto-Assignment & Staff Management
    path('orders/<uuid:order_id>/auto-assign-waiter/', views.auto_assign_waiter, name='auto-assign-waiter'),
    path('waiter/heartbeat/', views.waiter_heartbeat, name='waiter-heartbeat'),
    path('waiter/assigned-orders/', views.waiter_assigned_orders, name='waiter-assigned-orders'),
    
    # Bargain Chat System
    path('bargains/<uuid:bargain_id>/messages/', views.get_bargain_messages, name='get-bargain-messages'),
    path('bargains/<uuid:bargain_id>/messages/send/', views.send_bargain_message, name='send-bargain-message'),
    path('bargains/<uuid:bargain_id>/accept/', views.accept_bargain_offer, name='accept-bargain'),
    path('bargains/<uuid:bargain_id>/reject/', views.reject_bargain_offer, name='reject-bargain'),
    
    # Admin Master Role
    path('admin/orders/<uuid:order_id>/reassign-staff/', views.admin_reassign_staff, name='admin-reassign-staff'),
    path('admin/orders/<uuid:order_id>/takeover/', views.admin_takeover_order, name='admin-takeover'),
    path('admin/staff/status/', views.admin_staff_status, name='admin-staff-status'),
]
