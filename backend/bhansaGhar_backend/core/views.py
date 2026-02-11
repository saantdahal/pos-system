from datetime import timedelta
from typing import cast, Any, Literal, Dict, Optional
from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import IsAuthenticated, AllowAny, BasePermission
from rest_framework.exceptions import PermissionDenied
from rest_framework.response import Response
from rest_framework import serializers, status
from rest_framework_simplejwt.tokens import RefreshToken, TokenError
from rest_framework_simplejwt.token_blacklist.models import OutstandingToken, BlacklistedToken
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
from drf_spectacular.utils import extend_schema, OpenApiTypes, OpenApiParameter, inline_serializer
import jwt
from django.conf import settings
from django.utils import timezone
from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.views.decorators.csrf import csrf_exempt
from .models import User
from .serializers import (
    GoogleAuthSerializer,
    GoogleLoginSerializer,
    LogoutSerializer,
    GoogleUserSerializer,
    StaffProfileSerializer,
    StaffProfileUpdateSerializer,
    ModeSelectionSerializer,
    ProfileCompleteSerializer,
    SendVerificationCodeSerializer,
    VerifyCodeSerializer,
    ResendCodeSerializer,
    RestaurantCreateSerializer,
    UserUpdateSerializer,
    EmailUpdateSerializer,
    EmailVerifyUpdateSerializer,
    WebsiteDataSerializer,
)
from .models import User, WebsiteData
from restaurants.models import Restaurant


def send_otp_email(email: str, otp_code: str) -> bool:
    """Send OTP verification email to user"""
    try:
        subject = 'Verify Your Email - BhansaGhar'
        html_message = render_to_string('emails/otp_verification.html', {
            'otp_code': otp_code,
        })
        plain_message = f"""
        Welcome to BhansaGhar!

        Your verification code is: {otp_code}

        This code will expire in 10 minutes.

        If you didn't request this verification, please ignore this email.

        Thank you for choosing BhansaGhar!
        """

        send_mail(
            subject=subject,
            message=plain_message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[email],
            html_message=html_message,
            fail_silently=False,
        )
        return True
    except Exception as e:
        print(f"Failed to send OTP email to {email}: {str(e)}\")")
        return False


def send_email_change_otp(new_email: str, old_email: str, otp_code: str, username: str) -> bool:
    """Send email change OTP to the new email address"""
    try:
        subject = 'Email Change Verification - BhansaGhar'
        html_message = render_to_string('emails/email_change_otp.html', {
            'otp_code': otp_code,
            'new_email': new_email,
            'old_email': old_email,
            'username': username,
        })
        plain_message = f"""
        Email Change Verification - BhansaGhar
        
        Hello {username},
        
        You have requested to change your email from {old_email} to {new_email}.
        
        Your verification code is: {otp_code}
        
        This code will expire in 10 minutes.
        
        If you didn't request this change, please ignore this email.
        
        Thank you,
        BhansaGhar Team
        """
        
        send_mail(
            subject=subject,
            message=plain_message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[new_email],
            html_message=html_message,
            fail_silently=False,
        )
        return True
    except Exception as e:
        print(f"Failed to send email change OTP to {new_email}: {str(e)}")
        return False


# Custom permission for fully verified users
class IsFullyVerified(BasePermission):
    """
    Custom permission to only allow access to fully verified users
    (Google verified + Email verified + Profile completed + Registration completed)
    """
    def has_permission(self, request: Any, view: Any) -> Literal[True]:
        if not request.user or not request.user.is_authenticated:
            raise PermissionDenied("User not authenticated")
        
        user = cast(User, request.user)
        if (user.is_google_verified and 
            user.is_email_verified and 
            user.profile_completed and 
            user.registration_completed):
            return True
        raise PermissionDenied("User registration not complete")

class IsRegistrationIncomplete(BasePermission):
    """
    Custom permission to validate incomplete registration stages
    Returns detailed error messages about what's missing
    """
    def has_permission(self, request: Any, view: Any) -> Literal[True]:
        if not request.user or not request.user.is_authenticated:
            raise PermissionDenied("User not authenticated")
        
        user = cast(User, request.user)
        
        # Check each registration stage
        if not user.is_google_verified:
            raise PermissionDenied("User must complete Google authentication first")
        
        if not user.is_email_verified:
            raise PermissionDenied("User must verify email before proceeding")
        
        if not user.profile_completed:
            raise PermissionDenied("User must complete profile before proceeding")
        
        if not user.mode_selection_completed:
            raise PermissionDenied("User must select operation mode before proceeding")
        
        # For online users, restaurant is required
        if user.selected_mode == 'online':
            try:
                if not hasattr(user, 'owned_restaurant') or user.owned_restaurant is None:
                    raise PermissionDenied("Online users must create restaurant to complete registration")
            except AttributeError:
                raise PermissionDenied("Online users must create restaurant to complete registration")
        
        return True

# GOOGLE CLIENT ID (Preferably from settings)
# For now, we will verify the audience against what the client sends or fetch from env
GOOGLE_CLIENT_ID = settings.GOOGLE_CLIENT_ID

@extend_schema(tags=['Admin: Auth'], request=GoogleAuthSerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['POST'])
@authentication_classes([])
@permission_classes([AllowAny])
def google_auth(request: Any) -> Response:
    """Step 1: Google OAuth - Verify ID Token & Create User (inactive until email verified)"""
    print("🔥 GOOGLE AUTH ENDPOINT HIT!")
    print(f"📨 Request method: {request.method}")
    print(f"📨 Request headers: {dict(request.headers)}")
    print(f"📨 Request data keys: {list(request.data.keys()) if request.data else 'None'}")
    print(f"📨 Full request data: {request.data}")

    token = request.data.get('id_token')

    if not token:
        print("❌ No ID token provided in request.data")
        print(f"❌ Available keys in request.data: {list(request.data.keys()) if hasattr(request.data, 'keys') else 'Not a dict'}")
        return Response({'error': 'ID Token required'}, status=400)

    print(f"✅ ID token received (length: {len(token)})")
    print(f"🔍 Token starts with: {token[:50]}...")
    
    try:
        print("🔐 Starting Google token verification...")
        # Verify token
        request_adapter = google_requests.Request()
        
        if settings.DEBUG:
            # In debug mode, decode without verification for development
            import jwt
            id_info = jwt.decode(token, options={"verify_signature": False})
            print("✅ Google token decoded (DEBUG MODE - no verification)")
        else:
            id_info = id_token.verify_oauth2_token(token, request_adapter, audience=GOOGLE_CLIENT_ID)
            print("✅ Google token verified successfully")
        
        print(f"📧 Email from token: {id_info.get('email')}")
        print(f"🆔 Google ID: {id_info.get('sub')}")
        
        # Verify issuer
        if id_info['iss'] not in ['accounts.google.com', 'https://accounts.google.com']:
            print(f"❌ Wrong issuer: {id_info['iss']}")
            raise ValueError('Wrong issuer.')
        print("✅ Issuer verified")

        google_id = id_info['sub']
        email = id_info.get('email')
        
        if not email:
            print("❌ No email in Google token")
            return Response({'error': 'Email required from Google'}, status=400)
        
        print(f"👤 Processing user: {email}")
        # Find or create user (inactive until email verified)
        user_obj, created = User.objects.get_or_create(
            google_id=google_id,
            defaults={
                'username': f'temp_{google_id[:20]}',  # Temporary username
                'email': email,
                'is_google_verified': True,
                'is_active': False,  # User inactive until email verified
                'is_email_verified': False,
            }
        )
        
        user: User = cast(User, user_obj)
        print(f"✅ User {'created' if created else 'found'}: {user.email}")
        print(f"🔍 User status: google_verified={user.is_google_verified}, email_verified={user.is_email_verified}, active={user.is_active}")
        
        # If user exists but not google verified, update
        if not user.is_google_verified:
            user.is_google_verified = True
            user.save()
            print("🔄 Updated existing user to google_verified=True")
        
        # **FIX: Skip verification if email already verified**
        if user.is_email_verified:
            print("✅ User email already verified, skipping verification step")
            
            # Check if user has a restaurant, if so, mark registration as completed
            if user.get_owned_restaurant() is not None and not user.registration_completed:
                user.registration_completed = True
                user.save()
                print("🔄 Updated user registration_completed=True because restaurant exists")
            
            # Generate JWT tokens for already verified user
            refresh = RefreshToken.for_user(user)
            
            return Response({
                'message': 'Welcome back! Email already verified.',
                'email': email,
                'verification_sent': False,
                'already_verified': True,
                'access': str(refresh.access_token),
                'refresh': str(refresh),
                'user_status': {
                    'is_google_verified': user.is_google_verified,
                    'is_email_verified': user.is_email_verified,
                    'profile_completed': user.profile_completed,
                    'mode_selection_completed': user.mode_selection_completed,
                    'registration_completed': user.registration_completed,
                    'is_admin': user.role == 'admin',
                },
                'profile_data': {
                    'username': user.username,
                    'phone': user.phone,
                    'address': user.address,
                    'restaurant_name': user.restaurant_name,
                    'latitude': user.latitude,
                    'longitude': user.longitude,
                },
                'next_step': 'check_registration_status'
            })
        
        # Send verification code for new users
        user.set_verification_code()
        print(f"📱 Generated verification code: {user.email_verification_code}")
        
        # Send email with verification code
        email_sent = send_otp_email(email, user.email_verification_code) # type: ignore
        if not email_sent:
            print("❌ Failed to send verification email")
            return Response({'error': 'Failed to send verification email'}, status=500)
        
        print("📤 Preparing success response")
        return Response({
            'message': 'Google authentication successful. Please verify your email.',
            'email': email,
            'verification_sent': True,
            'verification_code': user.email_verification_code,  # For development
            'user_status': {
                'is_google_verified': user.is_google_verified,
                'is_email_verified': user.is_email_verified,
                'profile_completed': user.profile_completed,
                'is_admin': user.role == 'admin',
            }
        })
        
    except ValueError as e:
        print(f"❌ ValueError during authentication: {str(e)}")
        return Response({'error': f'Invalid token: {str(e)}'}, status=400)
    except Exception as e:
        print(f"💥 Exception during authentication: {str(e)}")
        print(f"💥 Exception type: {type(e).__name__}")
        import traceback
        print(f"💥 Traceback: {traceback.format_exc()}")
        return Response({'error': f'Authentication failed: {str(e)}'}, status=500)
    
@extend_schema(tags=['Admin: Auth'], request=SendVerificationCodeSerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['POST'])
@permission_classes([AllowAny])
def send_verification_code(request: Any) -> Response:
    """Send verification code to email"""
    serializer = SendVerificationCodeSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=400)
    
    validated_data: Dict[str, Any] = cast(Dict[str, Any], serializer.validated_data)
    email: str = validated_data['email']
    
    try:
        user_obj = User.objects.get(email=email, is_google_verified=True)
        user: User = cast(User, user_obj)
        
        if user.is_email_verified:
            return Response({'error': 'Email already verified'}, status=400)
        
        # Generate and send new code
        user.set_verification_code()
        
        # TODO: Send email with verification code
        # For development, return code in response
        return Response({
            'message': 'Verification code sent to your email',
            'temp_code': user.email_verification_code,  # Remove in production
        })
        
    except User.DoesNotExist:
        return Response({'error': 'User not found. Please authenticate with Google first.'}, status=404)
    except Exception as e:
        return Response({'error': f'Failed to send code: {str(e)}'}, status=500)

@extend_schema(tags=['Admin: Auth'], request=VerifyCodeSerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['POST'])
@permission_classes([AllowAny])
def verify_email_code(request: Any) -> Response:
    """Verify email with code"""
    print(f"🔍 verify_email_code called with data: {request.data}")
    
    serializer = VerifyCodeSerializer(data=request.data)
    if not serializer.is_valid():
        print(f"❌ Serializer errors: {serializer.errors}")
        return Response(serializer.errors, status=400)
    
    validated_data: Dict[str, Any] = cast(Dict[str, Any], serializer.validated_data)
    email: str = validated_data['email']
    code: str = validated_data['code']
    
    print(f"✅ Validated data: email={email}, code={code}")
    
    try:
        user_obj = User.objects.get(email=email, is_google_verified=True)
        user: User = cast(User, user_obj)
        
        print(f"✅ Found user: {user.email}, google_verified: {user.is_google_verified}")
        
        verification_result = user.verify_code(code)
        if verification_result['valid']:
            print("✅ Code verification successful")
            
            return Response({
                'message': 'Email verified successfully!',
                'user_status': {
                    'is_google_verified': user.is_google_verified,
                    'is_email_verified': user.is_email_verified,
                    'profile_completed': user.profile_completed,
                    'restaurant_created': hasattr(user, 'owned_restaurant') and user.owned_restaurant is not None,
                    'is_admin': user.role == 'admin',
                },
                'next_step': 'complete_profile'  # Guide user to next step
            })
        else:
            print(f"❌ Code verification failed: {verification_result['reason']}")
            if verification_result['reason'] == 'expired':
                error_message = 'Verification code has expired. Please request a new one.'
            elif verification_result['reason'] == 'invalid':
                error_message = 'Invalid verification code. Please check and try again.'
            else:
                error_message = 'Verification failed. Please try again.'
            return Response({'error': error_message}, status=400)
            
    except User.DoesNotExist:
        print(f"❌ User not found: {email}")
        return Response({'error': 'User not found'}, status=404)
    except Exception as e:
        import traceback
        print(f"💥 Exception in verify_email_code: {str(e)}")
        print(f"💥 Traceback: {traceback.format_exc()}")
        return Response({'error': f'Verification failed: {str(e)}'}, status=500)
    

@extend_schema(tags=['Admin: Auth'], request=ResendCodeSerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['POST'])
def resend_verification_code(request: Any) -> Response:
    """Resend verification code if 2 minutes have passed"""
    serializer = ResendCodeSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=400)
    
    validated_data: Dict[str, Any] = cast(Dict[str, Any], serializer.validated_data)
    email: str = validated_data['email']
    
    try:
        user_obj = User.objects.get(email=email, is_google_verified=True)
        user: User = cast(User, user_obj)
        
        if user.is_email_verified:
            return Response({'error': 'Email already verified'}, status=400)
        
        if not user.can_resend_code():
            remaining_time = (user.last_code_sent_at + timedelta(minutes=2) - timezone.now()).total_seconds() # type: ignore
            return Response({
                'error': 'Please wait before requesting a new code',
                'remaining_seconds': int(remaining_time)
            }, status=429)
        
        # Generate new code
        user.set_verification_code()
        
        # Send email with new code
        email_sent = send_otp_email(email, user.email_verification_code) # type: ignore
        if not email_sent:
            return Response({'error': 'Failed to send verification email'}, status=500)
        
        return Response({
            'message': 'Verification code sent successfully',
        })
        
    except User.DoesNotExist:
        return Response({'error': 'User not found'}, status=404)
    except Exception as e:
        return Response({'error': f'Failed to resend code: {str(e)}'}, status=500)
@extend_schema(tags=['Admin: Profile'], request=ProfileCompleteSerializer, responses={200: OpenApiTypes.OBJECT})
@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def complete_profile(request: Any) -> Response:
    """Step 3: Complete basic profile information (phone, username, address, location)"""
    print(f"🔍 Complete profile called")
    print(f"📨 Request data: {request.data}")
    
    serializer = ProfileCompleteSerializer(data=request.data)
    if serializer.is_valid():
        print("✅ Serializer valid")
        validated_data: Dict[str, Any] = cast(Dict[str, Any], serializer.validated_data)
        email: str = validated_data['email']
        
        try:
            user = User.objects.get(email=email, is_email_verified=True)
        except User.DoesNotExist:
            return Response({'error': 'User not found or not email verified'}, status=404)
        
        # Check if profile already completed
        if user.profile_completed:
            print("⚠️ Profile already completed for this user")
            # Generate JWT tokens even for already completed profiles to maintain auth state
            refresh = RefreshToken.for_user(user)
            return Response({
                'success': True,
                'message': 'Profile already completed. Proceeding to mode selection.',
                'access': str(refresh.access_token),
                'refresh': str(refresh),
                'profile_completed': True,
                'next_step': 'select_mode',
                'user': GoogleUserSerializer(user).data,
                'user_status': {
                    'is_google_verified': user.is_google_verified,
                    'is_email_verified': user.is_email_verified,
                    'profile_completed': user.profile_completed,
                    'selected_mode': user.selected_mode,
                    'mode_selection_completed': user.mode_selection_completed,
                    'registration_completed': user.registration_completed,
                    'is_admin': user.role == 'admin',
                }
            })
        
        # Update user profile with provided data
        user.username = cast(str, validated_data['username'])
        user.phone = cast(str, validated_data['phone'])
        user.address = cast(str, validated_data.get('address', ''))
        user.latitude = cast(Optional[float], validated_data.get('latitude'))
        user.longitude = cast(Optional[float], validated_data.get('longitude'))
        user.restaurant_name = cast(Optional[str], validated_data.get('restaurant_name'))
        user.role = 'admin'  # Set as admin
        user.profile_completed = True
        user.save()
        print(f"✅ Profile completed for user: {user.email}")
        
        # Generate JWT tokens now that profile is complete
        print("🔐 Generating JWT tokens after profile completion...")
        refresh = RefreshToken.for_user(user)
        print("✅ JWT tokens generated successfully")
        
        return Response({
            'success': True,
            'message': 'Profile completed successfully! Now select your mode (online/offline).',
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'user': GoogleUserSerializer(user).data,
            'next_step': 'select_mode',
            'user_status': {
                'is_google_verified': user.is_google_verified,
                'is_email_verified': user.is_email_verified,
                'profile_completed': user.profile_completed,
                'selected_mode': user.selected_mode,
                'mode_selection_completed': user.mode_selection_completed,
                'registration_completed': user.registration_completed,
            }
        })
    print(f"❌ Serializer errors: {serializer.errors}")
    return Response(serializer.errors, status=400)

@extend_schema(tags=['Admin: Profile'], request=ModeSelectionSerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['POST'])
@permission_classes([AllowAny])
def select_mode(request: Any) -> Response:
    """Step 4: Select operation mode (online/offline)"""
    print(f"🔍 Mode selection called")
    print(f"📨 Request data: {request.data}")
    
    serializer = ModeSelectionSerializer(data=request.data)
    if not serializer.is_valid():
        print(f"❌ Serializer errors: {serializer.errors}")
        return Response(serializer.errors, status=400)
    
    validated_data: Dict[str, Any] = cast(Dict[str, Any], serializer.validated_data)
    email: str = validated_data['email']
    selected_mode: str = validated_data['selected_mode']
    
    try:
        user = User.objects.get(email=email, is_email_verified=True, profile_completed=True)
    except User.DoesNotExist:
        return Response({
            'error': 'User not found or profile not completed yet. Please complete profile first.'
        }, status=404)
    
    # Check if mode already selected
    if user.mode_selection_completed:
        print("⚠️ Mode already selected for this user")
        # Generate JWT tokens even if mode is already selected
        refresh = RefreshToken.for_user(user)
        return Response({
            'success': True,
            'message': f'Mode already selected: {user.selected_mode}. Proceeding to next step.',
            'mode_selection_completed': True,
            'selected_mode': user.selected_mode,
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'next_step': 'restaurant_setup' if user.selected_mode == 'online' else 'dashboard',
            'user_status': {
                'is_google_verified': user.is_google_verified,
                'is_email_verified': user.is_email_verified,
                'profile_completed': user.profile_completed,
                'selected_mode': user.selected_mode,
                'mode_selection_completed': user.mode_selection_completed,
                'registration_completed': user.registration_completed,
            }
        })
    
    # Save selected mode
    user.selected_mode = selected_mode
    user.mode_selection_completed = True
    
    # For offline users, registration is complete after mode selection
    if selected_mode == 'offline':
        user.registration_completed = True
        print(f"✅ Mode selected for user {user.email}: {selected_mode} (registration complete)")
    else:
        print(f"✅ Mode selected for user {user.email}: {selected_mode} (needs restaurant setup)")
    
    user.save()
    
    # Generate JWT tokens
    refresh = RefreshToken.for_user(user)
    
    return Response({
        'success': True,
        'message': f'Mode selected: {selected_mode}',
        'selected_mode': selected_mode,
        'access': str(refresh.access_token),
        'refresh': str(refresh),
        'next_step': 'create_restaurant' if selected_mode == 'online' else 'dashboard',
        'user_status': {
            'is_google_verified': user.is_google_verified,
            'is_email_verified': user.is_email_verified,
            'profile_completed': user.profile_completed,
            'selected_mode': user.selected_mode,
            'mode_selection_completed': user.mode_selection_completed,
            'registration_completed': user.registration_completed,
        }
    })

@extend_schema(tags=['Admin API'], responses={200: OpenApiTypes.OBJECT})
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def admin_status(request: Any) -> Response:
    """Check admin registration progress and provide next steps"""
    user: User = cast(User, request.user)
    
    # Determine registration stage and next steps
    if not user.is_email_verified:
        next_step = 'verify_email'
        next_step_description = 'Please verify your email'
    elif not user.profile_completed:
        next_step = 'complete_profile'
        next_step_description = 'Please complete your profile'
    elif not user.mode_selection_completed:
        next_step = 'select_mode'
        next_step_description = 'Please select your operation mode'
    elif user.selected_mode == 'online':
        try:
            if not hasattr(user, 'owned_restaurant') or user.owned_restaurant is None:
                next_step = 'create_restaurant'
                next_step_description = 'Please create your restaurant'
            else:
                next_step = 'dashboard'
                next_step_description = 'Registration complete! Ready for dashboard'
        except AttributeError:
            next_step = 'create_restaurant'
            next_step_description = 'Please create your restaurant'
    elif user.registration_completed:
        next_step = 'dashboard'
        next_step_description = 'Registration complete! Ready for dashboard'
    else:
        next_step = 'incomplete'
        next_step_description = 'Registration incomplete. Please contact support.'
    
    return Response({
        'is_admin': getattr(user, 'role', None) == 'admin',
        'is_google_verified': user.is_google_verified,
        'is_email_verified': user.is_email_verified,
        'profile_completed': user.profile_completed,
        'mode_selection_completed': user.mode_selection_completed,
        'selected_mode': user.selected_mode,
        'restaurant_created': hasattr(user, 'owned_restaurant') and user.owned_restaurant is not None,
        'registration_completed': user.registration_completed,
        'next_step': next_step,
        'next_step_description': next_step_description,
        'ready_for_dashboard': user.registration_completed,
        'user_status': {
            'is_google_verified': user.is_google_verified,
            'is_email_verified': user.is_email_verified,
            'profile_completed': user.profile_completed,
            'selected_mode': user.selected_mode,
            'mode_selection_completed': user.mode_selection_completed,
            'registration_completed': user.registration_completed,
        }
    })

@extend_schema(tags=['Admin API'], responses={200: OpenApiTypes.OBJECT})
@api_view(['GET'])
@permission_classes([IsFullyVerified])
def test_user(request: Any) -> Response:
    """Test endpoint to get current user info"""
    user: User = cast(User, request.user)
    restaurant_name = None
    try:
        if hasattr(user, 'owned_restaurant') and user.owned_restaurant:
            restaurant_name = user.owned_restaurant.name
    except AttributeError:
        pass
    
    return Response({
        'id': user.id,  # type: ignore[attr-defined]
        'username': user.username,
        'email': user.email,
        'role': user.role,
        'phone': user.phone,
        'profile_completed': user.profile_completed,
        'restaurant': restaurant_name
    })


# ============================================================================
# STAFF GOOGLE LOGIN & LOGOUT ENDPOINTS
# ============================================================================

@extend_schema(tags=['Admin: Auth'], request=GoogleLoginSerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['POST'])
@permission_classes([AllowAny])
def google_login(request: Any) -> Response:
    """
    Staff Google login (for kitchen/waiter daily login)
    POST /api/core/google-login/
    Body: {google_id: "123...", email: "staff@example.com"}
    Returns: {user, tokens: {access, refresh}}
    
    This is a simplified login for staff who have already been onboarded.
    They just need to provide their Google ID to log in instantly.
    """
    google_id = request.data.get('google_id')
    email = request.data.get('email')
    
    if not google_id:
        return Response({
            'error': 'google_id is required'
        }, status=400)
    
    if not email:
        return Response({
            'error': 'email is required'
        }, status=400)
    
    # Find user by Google ID
    try:
        user = User.objects.get(google_id=google_id, email=email)
    except User.DoesNotExist:
        return Response({
            'error': 'User not found. Please scan your invitation QR code first.'
        }, status=404)
    
    # Ensure user is staff (kitchen or waiter)
    if user.role not in ['kitchen', 'waiter']:
        return Response({
            'error': 'This login is only for staff members (kitchen/waiter).'
        }, status=403)
    
    # Ensure user has a restaurant assigned
    if not user.restaurant:
        return Response({
            'error': 'You are not assigned to any restaurant. Please contact your admin.'
        }, status=403)
    
    # Check if user is active (admin can deactivate staff)
    if not user.is_active:
        return Response({
            'error': 'Your account has been deactivated. Please contact your restaurant admin.'
        }, status=403)
    
    # Generate JWT tokens
    refresh = RefreshToken.for_user(user)
    
    return Response({
        'success': True,
        'message': f'Welcome back to {user.restaurant.name}!',
        'user': {
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'role': user.role,
            'role_display': user.get_role_display(),
            'restaurant_name': user.restaurant.name,
            'restaurant_id': str(user.restaurant.id)
        },
        'tokens': {
            'access': str(refresh.access_token),
            'refresh': str(refresh)
        }
    })


@extend_schema(tags=['Admin: Auth'], request=LogoutSerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout(request: Any) -> Response:
    """
    Logout endpoint with JWT token blacklisting
    POST /api/core/logout/
    Body: {refresh: "refresh_token"}
    
    Blacklists the refresh token so it can't be used again.
    If the token is already blacklisted, considers it a successful logout.
    """
    try:
        refresh_token = request.data.get('refresh')
        
        if not refresh_token:
            return Response({
                'error': 'Refresh token is required'
            }, status=400)
        
        # Try to blacklist the refresh token
        try:
            token = RefreshToken(refresh_token)
            token.blacklist()
            print(f"✅ Successfully blacklisted refresh token")
        except TokenError as e:
            # If token is already blacklisted, that's actually fine for logout
            if 'blacklisted' in str(e).lower():
                print(f"ℹ️ Refresh token was already blacklisted: {str(e)}")
            else:
                # For other token errors, still return error
                return Response({
                    'error': f'Invalid token: {str(e)}'
                }, status=400)
        
        return Response({
            'success': True,
            'message': 'Successfully logged out'
        })
        
    except Exception as e:
        return Response({
            'error': f'Logout failed: {str(e)}'
        }, status=500)

@extend_schema(tags=['Admin: Profile'], responses={200: GoogleUserSerializer}, methods=['GET'])
@extend_schema(tags=['Admin: Profile'], request=UserUpdateSerializer, responses={200: OpenApiTypes.OBJECT}, methods=['PATCH'])
@api_view(['GET', 'PATCH'])
@permission_classes([IsAuthenticated])
def user_profile(request: Any) -> Response:
    """Get or update current user profile"""
    user: User = cast(User, request.user)
    
    if request.method == 'GET':
        serializer = GoogleUserSerializer(user)
        return Response(serializer.data)
    
    elif request.method == 'PATCH':
        print(f"\n{'='*80}")
        print(f"🔄 PROFILE UPDATE REQUEST")
        print(f"📧 User: {user.email}")
        print(f"📨 Request data: {request.data}")
        print(f"📁 Request FILES: {request.FILES}")
        print(f"🖼️  Current avatar: {user.avatar.name if user.avatar else 'None'}")
        print(f"{'='*80}\n")
        
        serializer = UserUpdateSerializer(user, data=request.data, partial=True)
        if serializer.is_valid():
            print(f"✅ Serializer is valid")
            print(f"📝 Validated data: {serializer.validated_data}")
            serializer.save()
            print(f"💾 Profile updated successfully")
            print(f"🖼️  Avatar after save: {user.avatar.name if user.avatar else 'None'}")
            return Response({
                'success': True,
            })
        print(f"❌ Serializer errors: {serializer.errors}")
        return Response(serializer.errors, status=400)


@extend_schema(tags=['Staff: Profile'], responses={200: StaffProfileSerializer})
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def staff_profile(request: Any) -> Response:
    """
    Get current staff member profile (waiter, kitchen staff, etc.)
    Returns profile information formatted for mobile app
    """
    user: User = cast(User, request.user)
    
    print(f"\n{'='*80}")
    print(f"📱 STAFF PROFILE REQUEST")
    print(f"👤 User ID: {user.id}")
    print(f"📧 Email: {user.email}")
    print(f"👨‍💼 Role: {user.role}")
    print(f"🏢 Restaurant: {user.restaurant.name if user.restaurant else 'None'}")
    print(f"{'='*80}\n")
    
    try:
        serializer = StaffProfileSerializer(user)
        print(f"✅ Staff Profile serialized successfully")
        print(f"📤 Response data: {serializer.data}")
        return Response(serializer.data)
    except Exception as e:
        print(f"❌ Error serializing staff profile: {str(e)}")
        return Response(
            {'error': 'Failed to load profile', 'detail': str(e)},
            status=500
        )


@extend_schema(tags=['Staff: Profile'], request=StaffProfileUpdateSerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def update_staff_profile(request: Any) -> Response:
    """
    Update staff member profile (name, phone, address, avatar)
    Staff can update: username (name), phone, address, avatar
    Email updates require OTP verification (separate endpoint)
    """
    user: User = cast(User, request.user)
    
    print(f"\n{'='*80}")
    print(f"🔄 STAFF PROFILE UPDATE REQUEST")
    print(f"📧 User: {user.email}")
    print(f"📨 Request data: {request.data}")
    print(f"📁 Request FILES: {request.FILES}")
    print(f"🖼️  Current avatar: {user.avatar.name if user.avatar else 'None'}")
    print(f"{'='*80}\n")
    
    serializer = StaffProfileUpdateSerializer(user, data=request.data, partial=True)
    if serializer.is_valid():
        print(f"✅ Serializer is valid")
        print(f"📝 Validated data: {serializer.validated_data}")
        serializer.save()
        print(f"💾 Staff profile updated successfully")
        print(f"🖼️  Avatar after save: {user.avatar.name if user.avatar else 'None'}")
        return Response({
            'success': True,
            'message': 'Profile updated successfully',
            'profile': StaffProfileSerializer(user).data
        })
    print(f"❌ Serializer errors: {serializer.errors}")
    return Response(serializer.errors, status=400)


@extend_schema(tags=['Staff: Profile'], request=EmailUpdateSerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def request_staff_email_update(request: Any) -> Response:
    """
    Request email update for staff - sends OTP to the NEW email.
    The email change will only take effect after OTP verification.
    """
    user = cast(User, request.user)
    serializer = EmailUpdateSerializer(data=request.data, context={'request': request})
    
    if serializer.is_valid():
        new_email = serializer.validated_data['new_email']
        
        print(f"\n{'='*80}")
        print(f"📧 STAFF EMAIL UPDATE REQUEST")
        print(f"👤 User: {user.email}")
        print(f"📨 New email: {new_email}")
        print(f"{'='*80}\n")
        
        # Set pending email and generate OTP
        user.set_email_otp(new_email)
        
        # Send OTP to the NEW email with custom template
        email_sent = send_email_change_otp(
            new_email=new_email,
            old_email=user.email,
            otp_code=user.email_otp,  # type: ignore
            username=user.username
        )
        
        if email_sent:
            print(f"✅ Email change OTP sent to {new_email}")
            return Response({
                'success': True,
                'message': f'Verification code sent to {new_email}. Please check your email.',
                'pending_email': new_email,
                'otp': user.email_otp if settings.DEBUG else None  # Only for debug
            })
        print(f"❌ Failed to send email")
        return Response({
            'error': 'Failed to send verification email. Please try again.'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(tags=['Staff: Profile'], request=EmailVerifyUpdateSerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def verify_staff_email_update(request: Any) -> Response:
    """Verify OTP and update staff member email"""
    user: User = cast(User, request.user)
    serializer = EmailVerifyUpdateSerializer(data=request.data)
    
    if serializer.is_valid():
        otp = serializer.validated_data['otp']
        
        print(f"\n{'='*80}")
        print(f"✓️ STAFF EMAIL VERIFICATION")
        print(f"👤 User: {user.email}")
        print(f"🔐 OTP: {otp}")
        print(f"{'='*80}\n")
        
        success, message = user.verify_email_otp(otp)
        
        if success:
            print(f"✅ Email changed successfully to {user.email}")
            return Response({
                'success': True,
                'message': message,
                'profile': StaffProfileSerializer(user).data
            })
        print(f"❌ Email verification failed: {message}")
        return Response({'error': message}, status=400)
    
    return Response(serializer.errors, status=400)


@extend_schema(tags=['Admin: Profile'], request=inline_serializer('UpdateModeRequest', fields={'mode': serializers.ChoiceField(choices=['online', 'offline'])}), responses={200: OpenApiTypes.OBJECT})
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def update_mode(request: Any) -> Response:
    """Update user's selected mode (online/offline)"""
    user: User = cast(User, request.user)
    mode = request.data.get('mode')
    
    print(f"\n{'='*80}")
    print(f"🔄 MODE UPDATE REQUEST")
    print(f"📧 User: {user.email}")
    print(f"📨 Current mode: {user.selected_mode}")
    print(f"📨 New mode: {mode}")
    print(f"{'='*80}\n")
    
    if mode not in ['online', 'offline']:
        return Response({
            'error': 'Invalid mode. Must be "online" or "offline".'
        }, status=400)
    
    user.selected_mode = mode
    user.save()
    
    print(f"✅ Mode updated to: {mode}")
    
    return Response({
        'success': True,
        'message': f'Mode updated to {mode}',
        'mode': mode
    })

@extend_schema(tags=['Admin: Profile'], request=EmailUpdateSerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def request_email_update(request: Any) -> Response:
    """
    Request email update - sends OTP to the NEW email.
    The email change will only take effect after OTP verification.
    """
    user = cast(User, request.user)
    serializer = EmailUpdateSerializer(data=request.data, context={'request': request})
    
    if serializer.is_valid():
        new_email = serializer.validated_data['new_email']
        
        # Set pending email and generate OTP
        user.set_email_otp(new_email)
        
        # Send OTP to the NEW email with custom template
        email_sent = send_email_change_otp(
            new_email=new_email,
            old_email=user.email,
            otp_code=user.email_otp,  # type: ignore
            username=user.username
        )
        
        if email_sent:
            return Response({
                'success': True,
                'message': f'Verification code sent to {new_email}. Please check your email.',
                'pending_email': new_email,
                'otp': user.email_otp if settings.DEBUG else None  # Only for debug
            })
        return Response({
            'error': 'Failed to send verification email. Please try again.'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(request=EmailVerifyUpdateSerializer, responses={200: OpenApiTypes.OBJECT})
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def verify_email_update(request: Any) -> Response:
    """Verify OTP and update user email"""
    user: User = cast(User, request.user)
    serializer = EmailVerifyUpdateSerializer(data=request.data)
    
    if serializer.is_valid():
        otp = serializer.validated_data['otp']
        success, message = user.verify_email_otp(otp)
        
        if success:
            return Response({
                'success': True,
                'message': message,
                'user': GoogleUserSerializer(user).data
            })
        return Response({'error': message}, status=400)
    
    return Response(serializer.errors, status=400)

@api_view(['GET'])
@permission_classes([AllowAny])
@extend_schema(tags=['Admin API'], responses={200: OpenApiTypes.OBJECT})
def docs_hub(request):
    """
    Beautiful entry point for API documentation with role-based buttons.
    """
    from django.http import HttpResponse
    
    html = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>BhansaGhar API Documentation Hub</title>
        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap" rel="stylesheet">
        <style>
            :root {
                --primary: #FF4B2B;
                --secondary: #FF416C;
                --dark: #1A1A1A;
                --light: #F4F7F6;
                --admin: #4E65FF;
                --kitchen: #F6D365;
                --waiter: #5EE7DF;
                --customer: #92FE9D;
            }
            body {
                font-family: 'Outfit', sans-serif;
                background: var(--dark);
                color: white;
                margin: 0;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                min-height: 100vh;
                text-align: center;
            }
            .container {
                max-width: 900px;
                padding: 40px;
            }
            h1 {
                font-size: 3rem;
                margin-bottom: 10px;
                background: linear-gradient(to right, var(--primary), var(--secondary));
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
            }
            p {
                font-size: 1.2rem;
                color: #AAA;
                margin-bottom: 40px;
            }
            .button-group {
                display: flex;
                gap: 20px;
                justify-content: center;
                flex-wrap: wrap;
            }
            .role-card {
                background: rgba(255, 255, 255, 0.05);
                border: 1px solid rgba(255, 255, 255, 0.1);
                border-radius: 20px;
                padding: 30px;
                width: 180px;
                transition: transform 0.3s ease, background 0.3s ease;
                cursor: pointer;
                text-decoration: none;
                color: white;
                box-shadow: 0 10px 30px rgba(0,0,0,0.5);
            }
            .role-card:hover {
                transform: translateY(-10px);
                background: rgba(255, 255, 255, 0.1);
                box-shadow: 0 15px 40px rgba(0,0,0,0.7);
            }
            .icon {
                font-size: 2.5rem;
                margin-bottom: 15px;
                display: block;
            }
            .role-name {
                font-weight: 600;
                font-size: 1.1rem;
            }
            .btn-admin { border-bottom: 4px solid var(--admin); }
            .btn-kitchen { border-bottom: 4px solid var(--kitchen); }
            .btn-waiter { border-bottom: 4px solid var(--waiter); }
            .btn-customer { border-bottom: 4px solid var(--customer); }
            
            .footer {
                margin-top: 60px;
                font-size: 0.9rem;
                color: #666;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>BhansaGhar API Hub</h1>
            <p>Select a user role to explore the relevant API documentation</p>
            
            <div class="button-group">
                <a href="/api/docs/admin/" class="role-card btn-admin">
                    <span class="icon">🛡️</span>
                    <span class="role-name">Admin API</span>
                </a>
                <a href="/api/docs/kitchen/" class="role-card btn-kitchen">
                    <span class="icon">🍳</span>
                    <span class="role-name">Kitchen API</span>
                </a>
                <a href="/api/docs/waiter/" class="role-card btn-waiter">
                    <span class="icon">🤵</span>
                    <span class="role-name">Waiter API</span>
                </a>
                <a href="/api/docs/customer/" class="role-card btn-customer">
                    <span class="icon">📱</span>
                    <span class="role-name">Customer API</span>
                </a>
            </div>
            
            <div class="footer">
                &copy; 2026 BhansaGhar Restaurant Management System. Built with Django & drf-spectacular.
            </div>
        </div>
    </body>
    </html>
    """
    return HttpResponse(html)

@api_view(['GET', 'POST', 'PUT'])
@permission_classes([IsAuthenticated])
def website_data(request):
    """
    Get or update website data for the authenticated user's restaurant
    """
    try:
        # Get user's restaurant using get_owned_restaurant method
        try:
            restaurant = request.user.get_owned_restaurant()
        except:
            # Fallback: try direct access with exception handling
            restaurant = None
            try:
                restaurant = request.user.owned_restaurant
            except:
                pass
        
        if not restaurant:
            return Response(
                {'error': 'User does not have a restaurant. Please set up your restaurant first.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Get or create website data
        try:
            website_obj = WebsiteData.objects.get(restaurant=restaurant)
        except WebsiteData.DoesNotExist:
            # Create website data with restaurant information
            website_obj = WebsiteData.objects.create(restaurant=restaurant)
            website_obj.populate_from_restaurant()
        
        if request.method == 'GET':
            serializer = WebsiteDataSerializer(website_obj)
            return Response(serializer.data)
        
        elif request.method in ['POST', 'PUT']:
            serializer = WebsiteDataSerializer(website_obj, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data, status=status.HTTP_200_OK)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    except Exception as e:
        import traceback
        traceback.print_exc()
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([AllowAny])
def website_data_public(request, restaurant_slug):
    """
    Get public website data for a restaurant (no auth required)
    """
    try:
        restaurant = Restaurant.objects.get(slug=restaurant_slug)
        website_obj = WebsiteData.objects.get(restaurant=restaurant)
        
        if not website_obj.is_active:
            return Response(
                {'error': 'Website is not available'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        serializer = WebsiteDataSerializer(website_obj)
        return Response(serializer.data)
    
    except Restaurant.DoesNotExist:
        return Response(
            {'error': 'Restaurant not found'},
            status=status.HTTP_404_NOT_FOUND
        )
    except WebsiteData.DoesNotExist:
        return Response(
            {'error': 'Website data not found'},
            status=status.HTTP_404_NOT_FOUND
        )
