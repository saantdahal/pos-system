from django.contrib.auth.models import AbstractUser
from django.db import models
from django.db.models.signals import post_delete
from django.dispatch import receiver
from django.utils import timezone
import random
import string
import os
import uuid
from datetime import timedelta
from typing import TYPE_CHECKING, Optional
from .services.storage import OptimizedCloudinaryStorage

if TYPE_CHECKING:
    from restaurants.models import Restaurant

def user_avatar_upload_to(instance, filename):
    """
    Upload avatar to bhansa_ghar/avatars/{restaurant_id}/{user_id}/{filename}
    If user has no restaurant (e.g. initial setup), use 'no_restaurant'
    """
    restaurant_id = instance.restaurant.id if instance.restaurant else 'no_restaurant'
    if restaurant_id == 'no_restaurant' and instance.owned_restaurant:
        restaurant_id = instance.owned_restaurant.id
        
    filename = os.path.basename(filename)
    return f"bhansa_ghar/avatars/{restaurant_id}/{instance.id}/{filename}"

class BaseUserRole(models.TextChoices):
    ADMIN = 'admin', 'Admin (Restaurant Owner)'
    KITCHEN = 'kitchen', 'Kitchen Staff'
    WAITER = 'waiter', 'Waiter Staff'

class User(AbstractUser):
    """
    STAFF ONLY: Admin, Kitchen, Waiter (Google OAuth login required)
    """
    google_id = models.CharField(max_length=255, unique=True, blank=True, null=True)
    username = models.CharField(max_length=150, unique=True)
    phone = models.CharField(max_length=15, blank=True, null=True)
    address = models.TextField(blank=True, null=True)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    restaurant_name = models.CharField(max_length=200, blank=True, null=True) # Temporary field for setup
    is_google_verified = models.BooleanField(default=False)
    profile_completed = models.BooleanField(default=False)
    
    # Avatar field
    avatar = models.ImageField(
        upload_to=user_avatar_upload_to,
        storage=OptimizedCloudinaryStorage(),
        blank=True,
        null=True,
        max_length=500
    )
    
    # Mode selection (online/offline)
    selected_mode = models.CharField(
        max_length=10,
        choices=[
            ('online', 'Online Mode'),
            ('offline', 'Offline Mode'),
        ],
        blank=True, null=True
    )
    mode_selection_completed = models.BooleanField(default=False)
    
    # Registration completion status
    registration_completed = models.BooleanField(default=False)
    
    # Email verification fields
    email_verification_code = models.CharField(max_length=6, blank=True, null=True)
    email_verification_expires_at = models.DateTimeField(blank=True, null=True)
    last_code_sent_at = models.DateTimeField(blank=True, null=True)
    is_email_verified = models.BooleanField(default=False)
    
    # New fields for email update flow
    pending_email = models.EmailField(blank=True, null=True)
    email_otp = models.CharField(max_length=6, blank=True, null=True)
    email_otp_expires_at = models.DateTimeField(blank=True, null=True)
    
    role = models.CharField(
        max_length=20, 
        choices=BaseUserRole.choices,
        blank=True, null=True
    )
    
    # Note: For owners, use owned_restaurant (via OneToOneField from Restaurant model)
    # For staff, use this field to link to their assigned restaurant
    restaurant = models.ForeignKey(
        'restaurants.Restaurant', 
        on_delete=models.SET_NULL, 
        null=True, blank=True,
        related_name='staff'
    )
    
    groups = models.ManyToManyField(
        'auth.Group',
        related_name='core_users_groups',
        blank=True,
    )
    user_permissions = models.ManyToManyField(
        'auth.Permission',
        related_name='core_users_permissions',
        blank=True,
    )
    
    # Type hint for reverse relation from Restaurant.owner OneToOneField
    owned_restaurant: Optional['Restaurant']
    
    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['email']
    
    def get_owned_restaurant(self) -> Optional['Restaurant']:
        """Safely get the user's owned restaurant, handling the reverse relationship."""
        return getattr(self, 'owned_restaurant', None)
    
    def generate_verification_code(self):
        """Generate a 6-digit verification code"""
        return ''.join(random.choices(string.digits, k=6))
    
    def set_verification_code(self):
        """Set verification code and expiry time"""
        self.email_verification_code = self.generate_verification_code()
        self.email_verification_expires_at = timezone.now() + timedelta(minutes=10)
        self.last_code_sent_at = timezone.now()
        self.save()
    
    def set_email_otp(self, new_email):
        """Set email update OTP and expiry time"""
        self.pending_email = new_email
        self.email_otp = self.generate_verification_code()
        self.email_otp_expires_at = timezone.now() + timedelta(minutes=10)
        self.save()

    def verify_email_otp(self, otp):
        """Verify the email update OTP and perform the update"""
        if not self.email_otp or not self.email_otp_expires_at:
            return False, "No OTP requested"
        
        if timezone.now() > self.email_otp_expires_at:
            return False, "OTP expired"
        
        if self.email_otp != otp:
            return False, "Invalid OTP"
        
        self.email = self.pending_email
        self.pending_email = None
        self.email_otp = None
        self.email_otp_expires_at = None
        self.save()
        return True, "Email updated successfully"

    def can_resend_code(self):
        """Check if 2 minutes have passed since last code sent"""
        if not self.last_code_sent_at:
            return True
        return timezone.now() >= self.last_code_sent_at + timedelta(minutes=2)
    
    def verify_code(self, code):
        """Verify the email verification code"""
        if not self.email_verification_code or not self.email_verification_expires_at:
            return {'valid': False, 'reason': 'no_code'}
        
        if timezone.now() > self.email_verification_expires_at:
            return {'valid': False, 'reason': 'expired'}
        
        if self.email_verification_code != code:
            return {'valid': False, 'reason': 'invalid'}
        
        self.is_email_verified = True
        self.is_active = True
        self.email_verification_code = None
        self.email_verification_expires_at = None
        self.save()
        return {'valid': True, 'reason': 'valid'}
    
    def save(self, *args, **kwargs):
        # Handle avatar deletion on update
        if self.pk:
            try:
                old_instance = User.objects.get(pk=self.pk)
                if old_instance.avatar and old_instance.avatar != self.avatar:
                    old_instance.avatar.delete(save=False)
            except User.DoesNotExist:
                pass
        super().save(*args, **kwargs)

    def __str__(self):
        if self.is_superuser:
            return f"Super Admin - {self.username}"
        
        role_choices = {
            'admin': 'Admin (Restaurant Owner)',
            'kitchen': 'Kitchen Staff',
            'waiter': 'Waiter Staff',
        }
        role_display = role_choices.get(self.role or '', 'No Role')
        return f"{role_display} - {self.username}"
    
    class Meta:
        verbose_name = "Staff User"
        verbose_name_plural = "Staff Users"

@receiver(post_delete, sender=User)
def delete_user_avatar(sender, instance, **kwargs):
    """Delete avatar from Cloudinary when user is deleted"""
    if instance.avatar:
        try:
            instance.avatar.delete(save=False)
        except Exception:
            pass

class WebsiteData(models.Model):
    """
    Website configuration and content management for restaurant websites
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    restaurant = models.OneToOneField(
        'restaurants.Restaurant',
        on_delete=models.CASCADE,
        related_name='website_data'
    )
    
    # Website Configuration
    website_title = models.CharField(max_length=200, blank=True, help_text="Website title for SEO")
    website_description = models.TextField(blank=True, help_text="Website meta description")
    website_keywords = models.CharField(max_length=500, blank=True, help_text="SEO keywords separated by commas")
    
    # Branding
    logo = models.ImageField(
        upload_to='bhansa_ghar/website/logos/',
        storage=OptimizedCloudinaryStorage(),
        blank=True, null=True, max_length=500
    )
    favicon = models.ImageField(
        upload_to='bhansa_ghar/website/favicons/',
        storage=OptimizedCloudinaryStorage(),
        blank=True, null=True, max_length=500
    )
    primary_color = models.CharField(max_length=7, default='#FF6B6B', help_text="Primary brand color (hex)")
    secondary_color = models.CharField(max_length=7, default='#4ECDC4', help_text="Secondary brand color (hex)")
    
    # Social Media
    facebook_url = models.URLField(blank=True, null=True)
    instagram_url = models.URLField(blank=True, null=True)
    twitter_url = models.URLField(blank=True, null=True)
    whatsapp_number = models.CharField(max_length=20, blank=True, null=True)
    
    # Contact Information
    contact_email = models.EmailField(blank=True, null=True)
    contact_phone = models.CharField(max_length=20, blank=True, null=True)
    contact_whatsapp = models.CharField(max_length=20, blank=True, null=True)
    
    # Homepage Hero Section
    hero_title = models.CharField(max_length=200, blank=True)
    hero_subtitle = models.CharField(max_length=200, blank=True)
    hero_cta_button_text = models.CharField(max_length=50, blank=True, default="Order Now")
    hero_cta_button_link = models.URLField(blank=True, null=True)
    
    # About Section
    about_title = models.CharField(max_length=200, blank=True, default="About Us")
    about_content = models.TextField(blank=True)
    about_image = models.ImageField(
        upload_to='bhansa_ghar/website/about/',
        storage=OptimizedCloudinaryStorage(),
        blank=True, null=True, max_length=500
    )
    
    # Features/Highlights
    feature_1_title = models.CharField(max_length=100, blank=True)
    feature_1_description = models.TextField(blank=True)
    feature_1_icon = models.CharField(max_length=50, blank=True, help_text="Icon class or emoji")
    
    feature_2_title = models.CharField(max_length=100, blank=True)
    feature_2_description = models.TextField(blank=True)
    feature_2_icon = models.CharField(max_length=50, blank=True)
    
    feature_3_title = models.CharField(max_length=100, blank=True)
    feature_3_description = models.TextField(blank=True)
    feature_3_icon = models.CharField(max_length=50, blank=True)
    
    # Newsletter/Contact
    enable_newsletter = models.BooleanField(default=True)
    enable_contact_form = models.BooleanField(default=True)
    
    # Footer
    footer_text = models.TextField(blank=True, help_text="Footer copyright or additional text")
    
    # Settings
    is_active = models.BooleanField(default=True)
    show_menu_online = models.BooleanField(default=True)
    show_reservations_online = models.BooleanField(default=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Website Data - {self.restaurant.name}"
    
    def populate_from_restaurant(self):
        """
        Populate website data fields with restaurant information if they are empty
        """
        restaurant = self.restaurant
        
        if not self.website_title:
            self.website_title = restaurant.name
            
        if not self.website_description:
            self.website_description = restaurant.description or f"Welcome to {restaurant.name}"
            
        if not self.contact_phone:
            self.contact_phone = restaurant.phone
            
        if not self.contact_email:
            self.contact_email = restaurant.owner.email if restaurant.owner.email else None
            
        if not self.hero_title:
            self.hero_title = f"Welcome to {restaurant.name}"
            
        if not self.hero_subtitle:
            self.hero_subtitle = restaurant.description or "Delicious food served fresh"
            
        if not self.about_title:
            self.about_title = "About Us"
            
        if not self.about_content:
            self.about_content = restaurant.about or f"Welcome to {restaurant.name}. We serve delicious food with passion and dedication."
            
        if not self.footer_text:
            self.footer_text = f"© {restaurant.name}. All rights reserved."
            
        # Add default features if empty
        if not self.feature_1_title:
            self.feature_1_title = "Fresh Ingredients"
            self.feature_1_description = "We use only the freshest ingredients in all our dishes"
            self.feature_1_icon = "🥬"
            
        if not self.feature_2_title:
            self.feature_2_title = "Quick Service"
            self.feature_2_description = "Fast and efficient service to keep you satisfied"
            self.feature_2_icon = "⚡"
            
        if not self.feature_3_title:
            self.feature_3_title = "Quality Assurance"
            self.feature_3_description = "Every dish is prepared with care and attention to detail"
            self.feature_3_icon = "⭐"
            
        self.save()
    
    class Meta:
        verbose_name = "Website Data"
        verbose_name_plural = "Website Data"


