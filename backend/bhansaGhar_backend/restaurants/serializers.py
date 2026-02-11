from rest_framework import serializers
from .models import Restaurant, RestaurantType, Category, MenuItem, Table, StaffInvite, BaseTableStatus
from core.models import User
from drf_spectacular.utils import extend_schema_field
import logging

logger = logging.getLogger(__name__)

class RestaurantTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = RestaurantType
        fields = ['id', 'name', 'display_name']

class RestaurantSerializer(serializers.ModelSerializer):
    type = RestaurantTypeSerializer(read_only=True)

    class Meta:
        model = Restaurant
        fields = ['id', 'name', 'type', 'address', 'latitude', 'longitude', 'phone', 'description', 'tables_capacity', 'operating_hours', 'is_active', 'created_at']
        read_only_fields = ['id', 'created_at']


class RestaurantUpdateSerializer(serializers.ModelSerializer):
    """Serializer for updating restaurant details (admin only)"""
    type = serializers.PrimaryKeyRelatedField(queryset=RestaurantType.objects.all(), required=False)
    
    class Meta:
        model = Restaurant
        fields = ['name', 'type', 'address', 'latitude', 'longitude', 'phone', 'description', 'operating_hours']
        
    def validate_name(self, value):
        """Ensure restaurant name is not empty"""
        if not value or not value.strip():
            raise serializers.ValidationError("Restaurant name cannot be empty")
        return value.strip()
    
    def validate_address(self, value):
        """Address is required for restaurant"""
        if not value or not value.strip():
            raise serializers.ValidationError("Restaurant address is required")
        return value.strip()
    
    def validate_phone(self, value):
        """Phone is required for restaurant"""
        if not value or not value.strip():
            raise serializers.ValidationError("Restaurant phone number is required")
        return value.strip()
    
    def validate_operating_hours(self, value):
        """Validate operating hours JSON structure"""
        if value is None:
            return value
        
        if not isinstance(value, dict):
            raise serializers.ValidationError("Operating hours must be a JSON object")
        
        # Validate regularHours structure
        if 'regularHours' in value:
            regular_hours = value['regularHours']
            if not isinstance(regular_hours, dict):
                raise serializers.ValidationError("regularHours must be an object")
            
            valid_days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
            for day, schedule in regular_hours.items():
                if day not in valid_days:
                    raise serializers.ValidationError(f"Invalid day: {day}")
                
                if schedule is not None:
                    if not isinstance(schedule, dict):
                        raise serializers.ValidationError(f"Schedule for {day} must be an object")
                    
                    if 'isClosed' not in schedule:
                        raise serializers.ValidationError(f"Schedule for {day} must have isClosed field")
                    
                    if not schedule.get('isClosed'):
                        if not schedule.get('openTime') or not schedule.get('closeTime'):
                            raise serializers.ValidationError(
                                f"Schedule for {day} must have openTime and closeTime when not closed"
                            )
        
        # Validate specialClosures structure
        if 'specialClosures' in value:
            special_closures = value['specialClosures']
            if not isinstance(special_closures, list):
                raise serializers.ValidationError("specialClosures must be an array")
            
            for closure in special_closures:
                if not isinstance(closure, dict):
                    raise serializers.ValidationError("Each special closure must be an object")
                
                required_fields = ['startDate', 'endDate', 'note']
                for field in required_fields:
                    if field not in closure:
                        raise serializers.ValidationError(f"Special closure must have {field} field")
        
        return value
    
    def validate(self, data):
        """Ensure latitude and longitude are both provided or both None"""
        latitude = data.get('latitude')
        longitude = data.get('longitude')
        
        # If updating, get existing values
        if self.instance:
            if latitude is None:
                latitude = self.instance.latitude
            if longitude is None:
                longitude = self.instance.longitude
        
        # Both should be provided for restaurant location
        if (latitude is None) != (longitude is None):
            raise serializers.ValidationError(
                "Both latitude and longitude must be provided for restaurant location"
            )
        
        return data


class CategorySerializer(serializers.ModelSerializer):
    restaurant = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = Category
        fields = ['id', 'restaurant', 'name', 'position', 'created_at']
        read_only_fields = ['id', 'created_at', 'position']  # Make position read-only

    def validate_name(self, value):
        """
        Validate category name:
        1. Name is required (not empty)
        2. No duplicate names (case-insensitive) within the same restaurant
        """
        if not value or not value.strip():
            raise serializers.ValidationError("Category name is required.")

        name = value.strip()
        restaurant = self.context['request'].user.get_owned_restaurant()

        if restaurant:
            # Check for case-insensitive duplicates
            existing_category = Category.objects.filter(
                restaurant=restaurant,
                name__iexact=name
            )

            # If updating, exclude current instance
            if self.instance:
                existing_category = existing_category.exclude(pk=self.instance.pk)

            if existing_category.exists():
                raise serializers.ValidationError(
                    f"A category with the name '{name}' already exists for this restaurant."
                )

        return name

    def create(self, validated_data):
        """Auto-assign position and restaurant when creating a new category"""
        restaurant = self.context['request'].user.get_owned_restaurant()
        if restaurant:
            validated_data['restaurant'] = restaurant
            next_position = Category.objects.filter(restaurant=restaurant).count() + 1
            validated_data['position'] = next_position
            # Ensure name is stripped of whitespace
            validated_data['name'] = validated_data['name'].strip()
        return super().create(validated_data)

class RestaurantCreateRequestSerializer(serializers.Serializer):
    """Serializer for Step 5: Creating restaurant (online users only)"""
    email = serializers.EmailField()
    name = serializers.CharField(max_length=200)
    type = serializers.PrimaryKeyRelatedField(queryset=RestaurantType.objects.all())
    address = serializers.CharField(required=False, allow_blank=True)
    latitude = serializers.FloatField(required=False)
    longitude = serializers.FloatField(required=False)
    phone = serializers.CharField(max_length=15, required=False, allow_blank=True)
    description = serializers.CharField(required=False, allow_blank=True)
    tables_capacity = serializers.IntegerField(required=False, default=0)
    operating_hours = serializers.JSONField(required=False)

class MenuItemSerializer(serializers.ModelSerializer):
    category = serializers.PrimaryKeyRelatedField(queryset=Category.objects.all())
    restaurant = serializers.PrimaryKeyRelatedField(read_only=True)
    current_price = serializers.SerializerMethodField()
    has_offer = serializers.SerializerMethodField()
    is_available = serializers.SerializerMethodField()
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = MenuItem
        fields = ['id', 'restaurant', 'category', 'name', 'description', 'image', 'image_url', 'base_price', 'discount_percentage', 'current_price', 'has_offer', 'stock_quantity', 'is_available', 'position', 'created_at']
        read_only_fields = ['id', 'restaurant', 'current_price', 'has_offer', 'is_available', 'position', 'created_at', 'image_url']

    @extend_schema_field(serializers.FloatField())
    def get_current_price(self, obj) -> float:
        return obj.current_price

    @extend_schema_field(serializers.BooleanField())
    def get_has_offer(self, obj) -> bool:
        return obj.has_offer

    @extend_schema_field(serializers.BooleanField())
    def get_is_available(self, obj) -> bool:
        return obj.is_available

    @extend_schema_field(serializers.CharField())
    def get_image_url(self, obj) -> Optional[str]:
        """Return the full Cloudinary URL for the image"""
        print(f"🔍 get_image_url called for item: {obj.id}")
        print(f"🔍 Image field value: {obj.image}")
        print(f"🔍 Image field name: {obj.image.name if obj.image else 'None'}")
        
        if obj.image and str(obj.image).strip():
            try:
                url = obj.image.url
                print(f"✅ Image URL generated: {url}")
                
                # Try to verify image exists in storage
                if hasattr(obj.image, 'storage'):
                    try:
                        if obj.image.storage.exists(obj.image.name):
                            print(f"✅ Image verified in storage")
                        else:
                            print(f"⚠️ Image not found in storage: {obj.image.name}")
                            # Return None if image doesn't exist in storage
                            return None
                    except Exception as e:
                        print(f"⚠️ Could not verify image storage: {e}")
                
                return url
            except Exception as e:
                print(f"❌ Error generating image URL: {e}")
                return None
        else:
            print(f"⚠️ Image is None/empty")
            return None

    def validate_category(self, value):
        """Ensure category belongs to the user's restaurant"""
        restaurant = self.context['request'].user.get_owned_restaurant()
        if restaurant and value.restaurant != restaurant:
            raise serializers.ValidationError("Category does not belong to your restaurant.")
        return value

    def validate_name(self, value):
        """
        Validate menu item name:
        1. Name is required (not empty)
        2. No duplicate names (case-insensitive) within the same restaurant
        """
        if not value or not value.strip():
            raise serializers.ValidationError("Menu item name is required.")

        name = value.strip()
        restaurant = self.context['request'].user.get_owned_restaurant()

        if restaurant:
            # Check for case-insensitive duplicates
            existing_item = MenuItem.objects.filter(
                restaurant=restaurant,
                name__iexact=name
            )

            # If updating, exclude current instance
            if self.instance:
                existing_item = existing_item.exclude(pk=self.instance.pk)

            if existing_item.exists():
                raise serializers.ValidationError(
                    f"A menu item with the name '{name}' already exists for this restaurant."
                )

        return name

    def validate_discount_percentage(self, value):
        """Validate discount percentage is between 0 and 100"""
        if value is not None and (value < 0 or value > 100):
            raise serializers.ValidationError("Discount percentage must be between 0 and 100.")
        return value

    def validate_stock_quantity(self, value):
        """Validate stock quantity: null (unlimited), 0 (out of stock), or positive integer"""
        if value is not None and value < 0:
            raise serializers.ValidationError("Stock quantity must be null (unlimited), 0 (out of stock), or a positive number.")
        return value

    def validate(self, data):
        """Validate entire request"""
        print(f"🔍 MenuItemSerializer.validate() called")
        print(f"📨 Validated data keys: {data.keys()}")
        print(f"📨 Image field value: {data.get('image')}")
        print(f"📨 Image type: {type(data.get('image'))}")
        
        if 'image' in data and data['image'] is not None:
            image = data['image']
            print(f"✅ Image object: {image}")
            print(f"✅ Image name: {image.name if hasattr(image, 'name') else 'N/A'}")
            print(f"✅ Image size: {image.size if hasattr(image, 'size') else 'N/A'} bytes")
        else:
            print(f"⚠️ No image provided in request")
        
        return data

    def create(self, validated_data):
        """Auto-assign restaurant and position when creating menu item"""
        print(f"\n{'='*80}")
        print(f"🎯 MenuItemSerializer.create() called")
        print(f"📋 Validated data: {validated_data}")
        print(f"📷 Image field in validated_data: {validated_data.get('image')}")
        
        restaurant = self.context['request'].user.get_owned_restaurant()
        if restaurant:
            validated_data['restaurant'] = restaurant
            next_position = MenuItem.objects.filter(restaurant=restaurant).count() + 1
            validated_data['position'] = next_position
            print(f"✅ Restaurant assigned: {restaurant.name}")
            print(f"✅ Position assigned: {next_position}")
        
        print(f"📋 Final validated_data before save: {validated_data}")
        instance = super().create(validated_data)
        
        print(f"✅ Menu item created successfully!")
        print(f"✅ Item ID: {instance.id}")
        print(f"✅ Item image field: {instance.image}")
        print(f"✅ Item image URL: {instance.image.url if instance.image else 'No image'}")
        print(f"{'='*80}\n")
        
        return instance

    def update(self, instance, validated_data):
        """Update menu item"""
        print(f"\n{'='*80}")
        print(f"🔄 MenuItemSerializer.update() called")
        print(f"📷 Image in validated_data: {validated_data.get('image')}")
        print(f"📷 Current instance image: {instance.image}")
        
        result = super().update(instance, validated_data)
        
        # Refresh image from database to ensure it's properly saved
        result.refresh_image()
        
        print(f"✅ Menu item updated!")
        print(f"✅ Updated image: {result.image}")
        print(f"✅ Updated image URL: {result.image.url if result.image else 'No image'}")
        print(f"{'='*80}\n")
        
        return result

class TableSerializer(serializers.ModelSerializer):
    """Serializer for Table CRUD operations"""
    qr_code_url = serializers.SerializerMethodField()
    restaurant = serializers.PrimaryKeyRelatedField(read_only=True)
    
    class Meta:
        model = Table
        fields = ['id', 'restaurant', 'number', 'capacity', 'status', 'qr_code_image', 'qr_url', 'qr_code_url', 'is_active', 'created_at', 'updated_at']
        read_only_fields = ['id', 'restaurant', 'qr_code_image', 'qr_url', 'qr_code_url', 'created_at', 'updated_at']
    
    @extend_schema_field(serializers.CharField())
    def get_qr_code_url(self, obj) -> Optional[str]:
        """Return the QR code URL - prefer qr_url (Cloudinary) over qr_code_image"""
        if obj.qr_url and str(obj.qr_url).strip():
            print(f"✅ Using qr_url: {obj.qr_url}")
            return obj.qr_url
        elif obj.qr_code_image and str(obj.qr_code_image).strip():
            try:
                url = obj.qr_code_image.url
                print(f"✅ Using qr_code_image.url: {url}")
                return url
            except Exception as e:
                logger.warning(f"Error generating QR code URL for table {obj.id}: {e}")
                return None
        return None
    
    def create(self, validated_data):
        """Auto-assign restaurant and table number when creating table"""
        restaurant = self.context['request'].user.get_owned_restaurant()
        if restaurant:
            # Find the next available table number (lowest missing number)
            existing_numbers = set(Table.objects.filter(restaurant=restaurant).values_list('number', flat=True))
            table_number = 1
            while table_number in existing_numbers:
                table_number += 1
            validated_data['restaurant'] = restaurant
            validated_data['number'] = table_number
        return super().create(validated_data)


class TableListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for listing tables"""
    qr_code_url = serializers.SerializerMethodField()
    
    class Meta:
        model = Table
        fields = ['id', 'number', 'capacity', 'status', 'qr_code_url', 'is_active', 'created_at']
        read_only_fields = ['id', 'qr_code_url', 'created_at']
    
    @extend_schema_field(serializers.CharField())
    def get_qr_code_url(self, obj) -> Optional[str]:
        """Return the full URL for the QR code image"""
        if obj.qr_code_image and str(obj.qr_code_image).strip():
            try:
                return obj.qr_code_image.url
            except Exception as e:
                logger.warning(f"Error generating QR code URL for table {obj.id}: {e}")
                return None
        return None


class QRCodeScanSerializer(serializers.Serializer):
    """Serializer for QR code scan endpoint"""
    qr_code_data = serializers.CharField(max_length=500)


class TableDetailWithMenuSerializer(serializers.Serializer):
    """Serializer for returning table info with menu after QR scan"""
    table = TableSerializer()
    restaurant = RestaurantSerializer()
    categories = serializers.SerializerMethodField()
    
    def get_categories(self, obj):
        """Return categories with their menu items"""
        categories = obj['restaurant'].categories.all().order_by('position')
        return CategoryWithItemsSerializer(categories, many=True).data


class CategoryWithItemsSerializer(serializers.ModelSerializer):
    """Serializer for category with all its menu items"""
    items = MenuItemSerializer(source='items', many=True, read_only=True)
    
    class Meta:
        model = Category
        fields = ['id', 'name', 'position', 'items']


# ============================================================================
# STAFF INVITATION SERIALIZERS
# ============================================================================

class StaffInviteCreateSerializer(serializers.ModelSerializer):
    """Serializer for Admin creating staff invitations"""
    class Meta:
        model = StaffInvite
        fields = ['email', 'role']
    
    def validate_email(self, value):
        """Validate email format and check for duplicates"""
        if not value or '@' not in value:
            raise serializers.ValidationError("Valid email is required.")
        return value.lower().strip()
    
    def validate_role(self, value):
        """Ensure role is either kitchen or waiter"""
        valid_roles = ['kitchen', 'waiter']
        if value not in valid_roles:
            raise serializers.ValidationError(f"Role must be one of: {', '.join(valid_roles)}")
        return value
    
    def validate(self, data):
        """Validate email and role, check if user is already staff"""
        request = self.context.get('request')
        if request and request.user:
            restaurant = request.user.get_owned_restaurant()
            if restaurant:
                # Check if user is already staff in this restaurant
                existing_staff = User.objects.filter(
                    email=data['email'],
                    restaurant=restaurant,
                    role=data['role']
                ).first()
                
                if existing_staff:
                    raise serializers.ValidationError(
                        f"{data['email']} is already working as {data['role']} at your restaurant."
                    )
        
        return data

    def create(self, validated_data):
        """Create staff invitation, deleting expired ones if needed"""
        request = self.context.get('request')
        restaurant = request.user.get_owned_restaurant()
        
        # Delete any expired/claimed invitations for this email+role combination
        StaffInvite.objects.filter(
            restaurant=restaurant,
            email=validated_data['email'],
            role=validated_data['role']
        ).delete()
        
        # Create new invitation
        return StaffInvite.objects.create(
            restaurant=restaurant,
            email=validated_data['email'],
            role=validated_data['role']
        )


class StaffInviteSerializer(serializers.ModelSerializer):
    """Serializer for listing staff invitations"""
    qr_code_url = serializers.SerializerMethodField()
    role_display = serializers.CharField(source='get_role_display', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    claimed_by_email = serializers.EmailField(source='claimed_by.email', read_only=True)
    
    class Meta:
        model = StaffInvite
        fields = [
            'id', 'email', 'role', 'role_display', 'status', 'status_display',
            'qr_code_url', 'is_claimed', 'claimed_by_email', 'claimed_at',
            'created_at', 'expires_at'
        ]
        read_only_fields = fields
    
    @extend_schema_field(serializers.CharField())
    def get_qr_code_url(self, obj) -> Optional[str]:
        """Return QR code URL"""
        if obj.qr_url:
            return obj.qr_url
        elif obj.qr_code_image:
            try:
                return obj.qr_code_image.url
            except Exception as e:
                logger.warning(f"Error generating QR URL for invite {obj.id}: {e}")
                return None
        return None


class ClaimInviteSerializer(serializers.Serializer):
    """Serializer for staff claiming an invitation via QR code scan
    
    Secure QR Code Invitation Workflow:
    - Admin creates invitation for specific email: sakarchaulagain1@gmail.com
    - Staff scans QR code (shows who it's for)
    - Staff must sign in with THAT EXACT EMAIL
    - Backend validates: UUID exists, valid, not expired, not claimed, AND email matches
    - Once claimed, QR is invalidated (cannot be reused)
    - User is linked to restaurant and can login with their Google account
    
    This ensures:
    1. Only the intended staff member can claim each invitation
    2. QR codes cannot be shared/reused
    3. Admin has control over who gets access
    """
    google_id = serializers.CharField(max_length=255)
    email = serializers.EmailField()
    google_token = serializers.CharField(max_length=2048, required=False)
    
    def validate_email(self, value):
        """Normalize email"""
        return value.lower().strip()
    
    def validate(self, data):
        """Validate QR invitation exists, is valid, and email matches
        
        Security checks:
        1. UUID must exist in database
        2. Invitation must not be expired
        3. Invitation must not be already claimed
        4. Email MUST match the invitation email (security measure)
        """
        invite_id = self.context.get('invite_id')
        
        if not invite_id:
            raise serializers.ValidationError("Invitation ID is required.")
        
        try:
            invite = StaffInvite.objects.get(id=invite_id)
        except StaffInvite.DoesNotExist:
            raise serializers.ValidationError("Invalid invitation.")
        
        # Check if invite is valid (not expired, not already claimed)
        if not invite.is_valid():
            if invite.is_claimed:
                raise serializers.ValidationError("This invitation has already been claimed.")
            else:
                raise serializers.ValidationError("This invitation has expired.")
        
        # CRITICAL: Validate email matches - only the invited person can claim it
        # This is a security measure to prevent unauthorized access
        if data['email'] != invite.email:
            raise serializers.ValidationError(
                f"This invitation is for {invite.email}. "
                f"Please sign in with that email to claim this invitation."
            )
        
        # Store invite in validated data for later use
        data['invite'] = invite
        
        return data


class StaffUserSerializer(serializers.ModelSerializer):
    """Serializer for listing staff members"""
    role_display = serializers.CharField(source='get_role_display', read_only=True)
    restaurant_name = serializers.CharField(source='restaurant.name', read_only=True)
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'role', 'role_display',
            'restaurant_name', 'is_active', 'date_joined', 'last_login'
        ]
        read_only_fields = fields

class UpdateStockSerializer(serializers.Serializer):
    stock_quantity = serializers.IntegerField(required=False, allow_null=True)

class BulkTableCreateSerializer(serializers.Serializer):
    count = serializers.IntegerField(min_value=1, max_value=100)

class UpdateTableStatusSerializer(serializers.Serializer):
    status = serializers.ChoiceField(choices=BaseTableStatus.choices)

class ToggleStaffStatusSerializer(serializers.Serializer):
    is_active = serializers.BooleanField()
