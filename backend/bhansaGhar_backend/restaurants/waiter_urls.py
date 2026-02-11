from django.urls import path
from restaurants.views import waiter_tables, update_table_status
from orders.views import (
    waiter_ready_orders, table_orders, pickup_order, 
    mark_order_served, ping_kitchen
)

urlpatterns = [
    path('tables/', waiter_tables, name='waiter-tables'),
    path('tables/<int:table_number>/', update_table_status, name='waiter-update-table-status'),
    path('ready-orders/', waiter_ready_orders, name='waiter-ready-orders'),
    path('table/<int:table_number>/orders/', table_orders, name='waiter-table-orders'),
    path('orders/<uuid:order_id>/pickup/', pickup_order, name='waiter-pickup-order'),
    path('orders/<uuid:order_id>/served/', mark_order_served, name='waiter-mark-order-served'),
    path('kitchen-ping/<uuid:order_id>/', ping_kitchen, name='waiter-kitchen-ping'),
]
