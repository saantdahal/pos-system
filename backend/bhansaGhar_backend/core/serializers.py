from rest_framework import serializers
from drf_spectacular.utils import extend_schema_field
from .models import User, WebsiteData
from datetime import datetime

#  Google Auth Serializer:
class GoogleAuthSerializer(serializers.Serializer):
    id_token = serializers.CharField(help_text="Google ID Token")

#  Google Login Serializer:
class GoogleUserSerializer(serializers.ModelSerializer):
    restaurant = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'google_id', 'is_google_verified', 
                 'is_email_verified', 'profile_completed', 'role', 'restaurant', 'avatar',
                 'phone', 'address', 'latitude', 'longitude']
    
    @extend_schema_field(serializers.JSONField())
    def get_restaurant(self, obj):
        if obj.restaurant:
            return {
                'id': str(obj.restaurant.id),
                'name': obj.restaurant.name,
                'type': {
                    'name': obj.restaurant.type.name,
                    'display_name': obj.restaurant.type.display_name,
                } if obj.restaurant.type else None,
            }
        else:
            # For restaurant owners, return their owned restaurant
            owned_rest = getattr(obj, 'owned_restaurant', None)
            if owned_rest:
                return {
                    'id': str(owned_rest.id),
                    'name': owned_rest.name,
                    'type': {
                        'name': owned_rest.type.name,
                        'display_name': owned_rest.type.display_name,
                    } if owned_rest.type else None,
                }
        return None

# Staff Profile Serializer (for waiter/kitchen staff)
class StaffProfileSerializer(serializers.ModelSerializer):
    """Serializer for staff member profile (waiter, kitchen staff, etc.)"""
    first_name = serializers.CharField(source='username', read_only=True)
    last_name = serializers.CharField(default='', required=False)
    role = serializers.SerializerMethodField()
    location = serializers.SerializerMethodField()
    profile_image = serializers.ImageField(source='avatar', required=False, allow_null=True)
    is_verified = serializers.SerializerMethodField()
    orders_served_today = serializers.SerializerMethodField()
    email = serializers.EmailField()
    
    class Meta:
        model = User
        fields = [
            'id',
            'first_name', 
            'last_name',
            'email',
            'role',
            'location',
            'profile_image',
            'is_verified',
            'orders_served_today',
            'phone',
            'address',
        ]
        read_only_fields = ['id', 'email']
    
    def get_role(self, obj):
        """Return user role in uppercase"""
        return obj.role.upper() if obj.role else 'STAFF'
    
    def get_location(self, obj):
        """Return restaurant location or address"""
        if obj.restaurant:
            return obj.restaurant.name or 'Unknown Location'
        return obj.address or 'Unknown Location'
    
    def get_is_verified(self, obj):
        """Return if user is verified"""
        return obj.is_google_verified or obj.is_email_verified
    
    def get_orders_served_today(self, obj):
        """Calculate orders served today (can be enhanced with actual DB queries)"""
        # TODO: Query OrderItem or Order model for today's orders by this user
        # For now, returning 0 as placeholder
        return 0

class StaffProfileUpdateSerializer(serializers.ModelSerializer):
    """Serializer for updating staff member profile"""
    avatar = serializers.ImageField(required=False, allow_null=True)

    class Meta:
        model = User
        fields = ['username', 'phone', 'address', 'avatar']
        read_only_fields = ['email']
    
    def validate_username(self, value):
        """Check if username is unique (excluding current user)"""
        if not value or not value.strip():
            raise serializers.ValidationError("Username cannot be empty")
        
        value = value.strip()
        
        # Check if username is taken by another user
        if self.instance:
            if User.objects.exclude(pk=self.instance.pk).filter(username=value).exists():
                raise serializers.ValidationError("This username is already taken")
        
        return value
    
    def validate_phone(self, value):
        """Phone is optional but should be clean if provided"""
        if value:
            return value.strip()
        return value
    
    def validate_address(self, value):
        """Address validation (optional but should be clean if provided)"""
        if value:
            return value.strip()
        return value
    
    def update(self, instance, validated_data):
        """Custom update to handle avatar field properly - only update if explicitly provided"""
        # If avatar is not in validated_data or is empty string, don't update it
        if 'avatar' in validated_data:
            avatar_value = validated_data.get('avatar')
            # Only update avatar if a new file is provided
            if avatar_value is None or avatar_value == '':
                # Remove avatar from validated_data to keep existing avatar
                validated_data.pop('avatar')
                print("🔍 Avatar field is empty/None - keeping existing avatar")
        
        return super().update(instance, validated_data)

# Profile Complete Serializer (Step 3: Basic profile completion)
class ProfileCompleteSerializer(serializers.Serializer):
    """Serializer for step 3: Complete basic profile information"""
    email = serializers.EmailField()  # To identify user
    username = serializers.CharField(max_length=150)
    phone = serializers.CharField(max_length=15)  # Mandatory
    address = serializers.CharField(required=False, allow_blank=True)
    latitude = serializers.FloatField(required=False)
    longitude = serializers.FloatField(required=False)
    restaurant_name = serializers.CharField(max_length=200, required=False, allow_blank=True)

class UserUpdateSerializer(serializers.ModelSerializer):
    """Enhanced serializer for updating user profile"""
    avatar = serializers.ImageField(required=False, allow_null=True)

    class Meta:
        model = User
        fields = ['username', 'phone', 'address', 'avatar']
        read_only_fields = ['email']
    
    def validate_username(self, value):
        """Check if username is unique (excluding current user)"""
        if not value or not value.strip():
            raise serializers.ValidationError("Username cannot be empty")
        
        value = value.strip()
        
        # Check if username is taken by another user
        if self.instance:
            if User.objects.exclude(pk=self.instance.pk).filter(username=value).exists():
                raise serializers.ValidationError("This username is already taken")
        
        return value
    
    def validate_phone(self, value):
        """Phone is required"""
        if not value or not value.strip():
            raise serializers.ValidationError("Phone number is required")
        return value.strip()
    
    def validate_address(self, value):
        """Address validation (optional but should be clean if provided)"""
        if value:
            return value.strip()
        return value
    
    def update(self, instance, validated_data):
        """Custom update to handle avatar field properly - only update if explicitly provided"""
        # If avatar is not in validated_data or is empty string, don't update it
        if 'avatar' in validated_data:
            avatar_value = validated_data.get('avatar')
            # Only update avatar if a new file is provided
            if avatar_value is None or avatar_value == '':
                # Remove avatar from validated_data to keep existing avatar
                validated_data.pop('avatar')
                print("🔍 Avatar field is empty/None - keeping existing avatar")
        
        return super().update(instance, validated_data)


class EmailUpdateSerializer(serializers.Serializer):
    """Enhanced serializer for requesting email update"""
    new_email = serializers.EmailField()

    def validate_new_email(self, value):
        """Validate new email address"""
        # Normalize email
        value = value.lower().strip()
        
        # Check if email already exists in the system
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError(
                "This email is already in use. Please use a different email address."
            )
        
        # Check if it's the same as current email (if context has request)
        request = self.context.get('request')
        if request and hasattr(request, 'user') and request.user.is_authenticated:
            if request.user.email == value:
                raise serializers.ValidationError(
                    "New email must be different from your current email"
                )
        
        return value


class EmailVerifyUpdateSerializer(serializers.Serializer):
    """Serializer for verifying email update OTP"""
    otp = serializers.CharField(max_length=6)

# Email verification serializers
class SendVerificationCodeSerializer(serializers.Serializer):
    email = serializers.EmailField()

class VerifyCodeSerializer(serializers.Serializer):
    email = serializers.EmailField()
    code = serializers.CharField(max_length=6)

class ResendCodeSerializer(serializers.Serializer):
    email = serializers.EmailField()

class RestaurantCreateSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=200)
    type = serializers.ChoiceField(choices=[
        ('cafe', 'Café'), ('restaurant', 'Restaurant'), 
        ('hotel', 'Hotel'), ('fastfood', 'Fast Food')
    ])
    phone = serializers.CharField(max_length=15, required=False)

class ModeSelectionSerializer(serializers.Serializer):
    """Serializer for step 4: Mode selection (online/offline)"""
    email = serializers.EmailField()
    selected_mode = serializers.ChoiceField(choices=[
        ('online', 'Online Mode'),
        ('offline', 'Offline Mode'),
    ])

class GoogleLoginSerializer(serializers.Serializer):
    google_id = serializers.CharField()
    email = serializers.EmailField()

class LogoutSerializer(serializers.Serializer):
    refresh = serializers.CharField()

class WebsiteDataSerializer(serializers.ModelSerializer):
    """Serializer for website data management"""
    class Meta:
        model = WebsiteData
        fields = [
            'id', 'website_title', 'website_description', 'website_keywords',
            'logo', 'favicon', 'primary_color', 'secondary_color',
            'facebook_url', 'instagram_url', 'twitter_url', 'whatsapp_number',
            'contact_email', 'contact_phone', 'contact_whatsapp',
            'hero_title', 'hero_subtitle', 'hero_cta_button_text', 'hero_cta_button_link',
            'about_title', 'about_content', 'about_image',
            'feature_1_title', 'feature_1_description', 'feature_1_icon',
            'feature_2_title', 'feature_2_description', 'feature_2_icon',
            'feature_3_title', 'feature_3_description', 'feature_3_icon',
            'enable_newsletter', 'enable_contact_form', 'footer_text',
            'is_active', 'show_menu_online', 'show_reservations_online',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
