from django.urls import path
from . import views

app_name = 'analytics'

urlpatterns = [
    # Admin endpoints
    path('admin/', views.admin_analytics, name='admin-analytics'),
    path('admin/daterange/', views.admin_analytics_daterange, name='admin-analytics-daterange'),
    path('admin/today/', views.today_snapshot, name='today-snapshot'),
    
    # Kitchen endpoints
    path('kitchen/', views.kitchen_analytics, name='kitchen-analytics'),
    
    # Waiter endpoints
    path('waiter/', views.waiter_analytics, name='waiter-analytics'),
    
    # Role-based overview
    path('overview/', views.analytics_overview, name='analytics-overview'),
    
    # Manual trigger (admin only)
    path('update/daily/', views.update_daily_analytics_manual, name='update-daily-analytics'),
]
