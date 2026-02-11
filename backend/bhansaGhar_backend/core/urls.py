from django.urls import path
from . import views
from .activities import activity_views
from .services import health_check, ready_check
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    # Health checks (no auth required)
    path('health/', health_check, name='health_check'),
    path('ready/', ready_check, name='ready_check'),
    
    path('auth/google/', views.google_auth, name='google_auth'),
    path('auth/send-code/', views.send_verification_code, name='send_verification_code'),
    path('auth/verify-code/', views.verify_email_code, name='verify_email_code'),
    path('auth/resend-code/', views.resend_verification_code, name='resend_verification_code'),
    path('profile/complete/', views.complete_profile, name='complete_profile'),
    path('mode/select/', views.select_mode, name='select_mode'),
    path('status/', views.admin_status, name='admin_status'),
    path('test/', views.test_user, name='test_user'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    
    # User Profile management
    path('profile/', views.user_profile, name='user_profile'),
    path('profile/staff/', views.staff_profile, name='staff_profile'),
    path('profile/staff/update/', views.update_staff_profile, name='update_staff_profile'),
    path('profile/staff/update-email/request/', views.request_staff_email_update, name='request_staff_email_update'),
    path('profile/staff/update-email/verify/', views.verify_staff_email_update, name='verify_staff_email_update'),
    path('profile/update-mode/', views.update_mode, name='update_mode'),
    path('profile/update-email/request/', views.request_email_update, name='request_email_update'),
    path('profile/update-email/verify/', views.verify_email_update, name='verify_email_update'),
    
    # Staff login & logout
    path('google-login/', views.google_login, name='google_login'),
    path('logout/', views.logout, name='logout'),
    
    # Activity Logs
    path('activities/today/', activity_views.my_today_activities, name='my_today_activities'),
    path('activities/', activity_views.my_activities, name='my_activities'),
    path('activities/stats/', activity_views.my_activity_stats, name='my_activity_stats'),
    path('activities/restaurant/today/', activity_views.restaurant_today_activities, name='restaurant_today_activities'),
    path('activities/restaurant/', activity_views.restaurant_activities, name='restaurant_activities'),
    path('activities/restaurant/stats/', activity_views.restaurant_activity_stats, name='restaurant_activity_stats'),
    path('activities/restaurant/staff-breakdown/', activity_views.staff_activity_breakdown, name='staff_activity_breakdown'),
    path('activities/restaurant/staff/<int:user_id>/', activity_views.staff_member_activities, name='staff_member_activities'),
    
    # Website Data Management
    path('website/data/', views.website_data, name='website_data'),
    path('website/<str:restaurant_slug>/', views.website_data_public, name='website_data_public'),
]
