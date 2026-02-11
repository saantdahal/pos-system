from django.contrib import admin
from django.urls import path, include
from core.views import docs_hub
from core.schema import AdminSchemaView, KitchenSchemaView, WaiterSchemaView, CustomerSchemaView
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView

# Import custom admin site (imported here to avoid circular imports during app initialization)
from core.admin.admin_site import admin_site

urlpatterns = [
    path('admin/', admin_site.urls),  # Use custom admin site
    
    # API Documentation Hub
    path('api/docs/', docs_hub, name='docs-hub'),
    
    # Role-specific Documentation
    path('api/docs/admin/', SpectacularSwaggerView.as_view(url_name='schema-admin'), name='docs-admin'),
    path('api/docs/kitchen/', SpectacularSwaggerView.as_view(url_name='schema-kitchen'), name='docs-kitchen'),
    path('api/docs/waiter/', SpectacularSwaggerView.as_view(url_name='schema-waiter'), name='docs-waiter'),
    path('api/docs/customer/', SpectacularSwaggerView.as_view(url_name='schema-customer'), name='docs-customer'),

    # Role-specific Schemas
    path('api/schema/admin/', AdminSchemaView.as_view(), name='schema-admin'),
    path('api/schema/kitchen/', KitchenSchemaView.as_view(), name='schema-kitchen'),
    path('api/schema/waiter/', WaiterSchemaView.as_view(), name='schema-waiter'),
    path('api/schema/customer/', CustomerSchemaView.as_view(), name='schema-customer'),

    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),

    path('api/core/', include('core.urls')),
    path('api/restaurants/', include('restaurants.urls')),
    path('api/orders/', include('orders.urls')),
    path('api/waiter/', include('restaurants.waiter_urls')),
    path('api/notifications/', include('notifications.urls')),
    path('api/analytics/', include('analytics.urls')),
    path('api/invoices/', include('invoices.urls')),
    path('ws/', include('websocket.urls')),
    path('', include('customer.urls')),
]
