from django.db import models
from django.db.models.signals import post_delete
from django.dispatch import receiver
from core.models import User
from core.services.storage import OptimizedCloudinaryStorage
from django.utils import timezone
from django.utils.text import slugify
from datetime import timedelta
import uuid
import os
import logging
import qrcode
from io import BytesIO
from django.core.files.base import ContentFile

logger = logging.getLogger(__name__)

def menu_image_upload_to(instance, filename):
    # Ensure filename is just the name, not a path
    filename = os.path.basename(filename)
    upload_path = f"bhansa_ghar/menu/{instance.restaurant.id}/{filename}"
    print(f"📁 [menu_image_upload_to] Uploading to: {upload_path}")
    return upload_path

def qr_code_upload_to(instance, filename):
    """
    Organize QR codes by restaurant (admin) to prevent data mismatch
    Path: bhansa_ghar/qr_codes/{restaurant_id}/table_{table_number}.png
    """
    filename = os.path.basename(filename)
    upload_path = f"bhansa_ghar/qr_codes/{instance.restaurant.id}/table_{instance.number}.png"
    print(f"📁 [qr_code_upload_to] Uploading to: {upload_path}")
    return upload_path

def staff_invite_qr_upload_to(instance, filename):
    """
    Organize staff invite QR codes by restaurant
    Path: bhansa_ghar/staff_invites/{restaurant_id}/invite_{uuid}.png
    """
    filename = os.path.basename(filename)
    upload_path = f"bhansa_ghar/staff_invites/{instance.restaurant.id}/invite_{instance.id}.png"
    print(f"📁 [staff_invite_qr_upload_to] Uploading to: {upload_path}")
    return upload_path

class RestaurantType(models.Model):
    name = models.CharField(max_length=20, unique=True)
    display_name = models.CharField(max_length=50)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.display_name

class Restaurant(models.Model):
    """
    One restaurant per Admin (owner)
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    owner = models.OneToOneField(User, on_delete=models.CASCADE, related_name='owned_restaurant')
    name = models.CharField(max_length=200)
    slug = models.SlugField(max_length=200, db_index=True)
    type = models.ForeignKey(RestaurantType, on_delete=models.CASCADE)
    address = models.TextField()
    latitude = models.FloatField()
    longitude = models.FloatField()
    phone = models.CharField(max_length=15, blank=True)
    description = models.TextField(blank=True)
    about = models.TextField(blank=True, help_text="About the restaurant for public website")
    hero_image = models.ImageField(upload_to='bhansa_ghar/hero/', storage=OptimizedCloudinaryStorage(), blank=True, null=True, max_length=500)
    tables_capacity = models.PositiveIntegerField(default=0)
    operating_hours = models.JSONField(blank=True, null=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)
    
    def __str__(self):
        return self.name


class RestaurantGallery(models.Model):
    """
    Gallery images for restaurant - allows admins to showcase their restaurant
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    restaurant = models.ForeignKey(Restaurant, on_delete=models.CASCADE, related_name='gallery_images')
    image = models.ImageField(upload_to='bhansa_ghar/gallery/', storage=OptimizedCloudinaryStorage(), max_length=500)
    title = models.CharField(max_length=200, blank=True)
    description = models.TextField(blank=True)
    position = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['position']
    
    def __str__(self):
        return f"{self.restaurant.name} - {self.title or 'Image'}"


class BaseStaffInviteRole(models.TextChoices):
    KITCHEN = 'kitchen', 'Kitchen Staff'
    WAITER = 'waiter', 'Waiter Staff'

class BaseStaffInviteStatus(models.TextChoices):
    PENDING = 'pending', 'Pending'
    CLAIMED = 'claimed', 'Claimed'
    EXPIRED = 'expired', 'Expired'

class StaffInvite(models.Model):
    """
    Staff invitation model for QR-based staff onboarding
    Admin creates invite → Staff scans QR → Claims with Google Auth → Auto-assigned
    """
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    restaurant = models.ForeignKey(Restaurant, on_delete=models.CASCADE, related_name='staff_invites')
    email = models.EmailField()
    role = models.CharField(max_length=20, choices=BaseStaffInviteRole.choices)
    qr_code_image = models.ImageField(
        upload_to=staff_invite_qr_upload_to, 
        storage=OptimizedCloudinaryStorage(), 
        blank=True, 
        null=True,
        max_length=500
    )
    qr_url = models.URLField(blank=True, null=True, max_length=500)
    status = models.CharField(max_length=20, choices=BaseStaffInviteStatus.choices, default=BaseStaffInviteStatus.PENDING)
    is_claimed = models.BooleanField(default=False)
    claimed_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='claimed_invites')
    claimed_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    
    class Meta:
        ordering = ['-created_at']
        unique_together = ('restaurant', 'email', 'role')
    
    def __str__(self):
        return f"{self.get_role_display()} invite for {self.email} at {self.restaurant.name}"
    
    def save(self, *args, **kwargs):
        # Set expiry date if not already set (24 hours from creation)
        if not self.expires_at:
            self.expires_at = timezone.now() + timedelta(hours=24)
        
        # Check if this is a new object by looking at force_insert kwarg
        is_new = kwargs.get('force_insert', False) or (self.pk is None)
        
        super().save(*args, **kwargs)
        
        if is_new and not self.qr_code_image:
            self.generate_qr_code()
            # Force refresh from DB to get the updated qr_url
            self.refresh_from_db()
    
    def generate_qr_code(self):
        """Generate QR code for staff invitation"""
        from django.conf import settings
        
        try:
            # Create claim URL (this will be the URL staff scan)
            # Format: https://yourdomain.com/claim-invite/{uuid}
            claim_url = f"{settings.FRONTEND_URL}/claim-invite/{self.id}"
            
            # Generate QR code
            qr = qrcode.QRCode(version=1, box_size=10, border=5)
            qr.add_data(claim_url)
            qr.make(fit=True)
            
            img = qr.make_image(fill_color="black", back_color="white")
            
            # Save to BytesIO
            buffer = BytesIO()
            img.save(buffer, format='PNG')
            buffer.seek(0)
            
            # Save to ImageField
            filename = f"invite_{self.id}.png"
            self.qr_code_image.save(filename, ContentFile(buffer.read()), save=False)
            
            # Store the Cloudinary URL
            if self.qr_code_image:
                self.qr_url = self.qr_code_image.url
            
            super().save(update_fields=['qr_code_image', 'qr_url'])
            logger.info(f"✅ QR code generated for staff invite {self.id}: {self.qr_url}")
        except Exception as e:
            logger.error(f"❌ Error generating QR code for invite {self.id}: {e}")
            raise
    
    def is_valid(self):
        """Check if invite is still valid (not expired, not claimed)"""
        if self.is_claimed:
            return False
        if timezone.now() > self.expires_at:
            self.status = 'expired'
            self.save(update_fields=['status'])
            # Delete QR image from Cloudinary when expired
            self.delete_qr_image()
            return False
        return True
    
    def delete_qr_image(self):
        """Delete QR code image from Cloudinary"""
        if self.qr_code_image:
            try:
                logger.info(f"🗑️ Deleting QR image for invite {self.id}")
                self.qr_code_image.delete(save=False)
                self.qr_url = None
                self.save(update_fields=['qr_url'])
                logger.info(f"✅ QR image deleted for invite {self.id}")
            except Exception as e:
                logger.error(f"❌ Error deleting QR image for invite {self.id}: {e}")
    
    def claim(self, user):
        """Claim the invite by a user"""
        if not self.is_valid():
            return False
        
        self.is_claimed = True
        self.claimed_by = user
        self.claimed_at = timezone.now()
        self.status = 'claimed'
        
        # Assign user to restaurant and role
        user.restaurant = self.restaurant
        user.role = self.role
        user.is_google_verified = True
        user.is_email_verified = True
        user.profile_completed = True
        user.registration_completed = True
        user.save()
        
        self.save()
        
        # Delete QR image to save space
        self.delete_qr_image()
        
        logger.info(f"✅ Invite {self.id} claimed by {user.email}")
        return True


class BaseTableStatus(models.TextChoices):
    AVAILABLE = 'available', '🟢 Available'
    OCCUPIED = 'occupied', '🟡 Occupied'
    READY = 'ready', '🔵 Ready'
    SERVING = 'serving', '🟠 Serving'
    DIRTY = 'dirty', '🔴 Dirty'

class Table(models.Model):
    """
    Represents a physical table in a restaurant with its own unique QR code.
    Each table has a unique QR code that users can scan to access the menu and place orders.
    """
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    restaurant = models.ForeignKey(Restaurant, on_delete=models.CASCADE, related_name='tables')
    number = models.PositiveIntegerField()  # Table 1, 2, 3...
    capacity = models.PositiveIntegerField(default=4)
    status = models.CharField(max_length=20, choices=BaseTableStatus.choices, default=BaseTableStatus.AVAILABLE)
    qr_code_image = models.ImageField(upload_to=qr_code_upload_to, storage=OptimizedCloudinaryStorage(), blank=True, null=True, max_length=500)  # Cloudinary!
    qr_url = models.URLField(blank=True, max_length=500)  # https://res.cloudinary.com/.../table5.jpg
    notes = models.TextField(blank=True)
    last_served = models.DateTimeField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ('restaurant', 'number')
        ordering = ['number']
    
    def __str__(self):
        return f"Table {self.number} - {self.status}"
    
    def generate_qr_code(self):
        """Generate QR code image for the table"""
        from .services import QRGenerator
        generator = QRGenerator()
        qr_url = generator.generate_table_qr(self.restaurant, self.number)
        self.qr_url = qr_url
    
    def regenerate_qr_code(self):
        """Regenerate QR code by deleting the old one and creating a new one"""
        print(f"🔄 Regenerating QR code for table {self.id} (Table {self.number})")
        if self.qr_code_image:
            print(f"🗑️ Deleting old QR code image: {self.qr_code_image}")
            self.qr_code_image.delete(save=False)  # Delete old image from Cloudinary
            print(f"✅ Old QR code deleted")
        else:
            print(f"⚠️ No existing QR code image to delete")
        
        print(f"🎯 Calling generate_qr_code...")
        self.generate_qr_code()
        print(f"✅ QR code regeneration completed. New qr_url: {self.qr_url}, qr_code_image: {self.qr_code_image}")
    
    @property
    def qr_code_url(self):
        """Get the URL of the QR code image"""
        if self.qr_code_image:
            return self.qr_code_image.url
        return None
    
    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)

class Category(models.Model):
    restaurant = models.ForeignKey(Restaurant, on_delete=models.CASCADE, related_name='categories')
    name = models.CharField(max_length=100)
    position = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['position']
    
    def __str__(self):
        return f"{self.restaurant.name} - {self.name}"

class MenuItem(models.Model):
    restaurant = models.ForeignKey(Restaurant, on_delete=models.CASCADE, related_name='menu_items')
    category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name='items')
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    base_price = models.DecimalField(max_digits=10, decimal_places=2)
    stock_quantity = models.PositiveIntegerField(default=None, null=True, blank=True)  # null = unlimited, 0 = out of stock
    image = models.ImageField(upload_to=menu_image_upload_to, storage=OptimizedCloudinaryStorage(), blank=True, null=True)
    discount_percentage = models.DecimalField(max_digits=5, decimal_places=2, default=0.00)  # e.g., 20.00 for 20%
    position = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['position']
    
    def __str__(self):
        return f"{self.name} - NPR {self.base_price}"
    
    def save(self, *args, **kwargs):
        print(f"\n{'='*80}")
        print(f"💾 [MenuItem.save()] Saving menu item: {self.name}")
        print(f"💾 Item ID (pk): {self.pk}")
        print(f"💾 Image field: {self.image}")
        print(f"💾 Image type: {type(self.image)}")
        
        if self.image:
            print(f"✅ Image object has value")
            if hasattr(self.image, 'name'):
                print(f"✅ Image name: {self.image.name}")
            if hasattr(self.image, 'size'):
                print(f"✅ Image size: {self.image.size}")
            if hasattr(self.image, 'file'):
                print(f"✅ Image file object exists: {self.image.file}")
        else:
            print(f"⚠️ Image is None/empty")
        
        # Handle image deletion on update BEFORE saving
        if self.pk:
            try:
                old_instance = MenuItem.objects.get(pk=self.pk)
                print(f"📋 Old instance found")
                print(f"📋 Old image: {old_instance.image}")
                
                if old_instance.image and str(old_instance.image) != str(self.image):
                    print(f"🗑️ Deleting old image: {old_instance.image}")
                    try:
                        old_instance.image.delete(save=False)
                        print(f"✅ Old image deleted")
                    except Exception as e:
                        print(f"⚠️ Error deleting old image: {e}")
                elif old_instance.image == self.image:
                    print(f"📋 Image unchanged, skipping deletion")
            except MenuItem.DoesNotExist:
                print(f"📋 No old instance found (new item)")
        
        print(f"💾 Calling super().save()...")
        try:
            super().save(*args, **kwargs)
            print(f"✅ Item saved successfully!")
            print(f"✅ Final image field: {self.image}")
            if self.image:
                print(f"✅ Final image URL: {self.image.url}")
                print(f"✅ Image name after save: {self.image.name}")
                # Check if file actually exists in storage
                if hasattr(self.image, 'storage'):
                    print(f"✅ Storage backend: {self.image.storage.__class__.__name__}")
                    try:
                        if self.image.storage.exists(self.image.name):
                            print(f"✅ Image EXISTS in storage!")
                        else:
                            print(f"❌ Image DOES NOT EXIST in storage!")
                    except Exception as e:
                        print(f"⚠️ Could not verify storage existence: {e}")
            print(f"{'='*80}\n")
        except Exception as e:
            print(f"❌ Error saving item: {e}")
            print(f"❌ Exception type: {type(e).__name__}")
            import traceback
            traceback.print_exc()
            print(f"{'='*80}\n")
            raise
    
    @property
    def is_available(self):
        """Available if stock_quantity is None (unlimited) or > 0"""
        return self.stock_quantity is None or self.stock_quantity > 0
    
    @property
    def current_price(self):
        """Calculate current price after discount"""
        if self.discount_percentage > 0:
            discount_amount = (self.base_price * self.discount_percentage) / 100
            return self.base_price - discount_amount
        return self.base_price
    
    @property
    def has_offer(self):
        """Check if there's an offer (discount > 0)"""
        return self.discount_percentage > 0
    
    def refresh_image(self):
        """Refresh image field from database to ensure it's current"""
        fresh_instance = MenuItem.objects.get(pk=self.pk)
        self.image = fresh_instance.image
        return self.image


@receiver(post_delete, sender=Category)
def reorder_categories_on_delete(sender, instance, **kwargs):
    """
    When a category is deleted, reorder the remaining categories
    to eliminate gaps in position numbering.
    """
    restaurant = instance.restaurant
    categories = Category.objects.filter(restaurant=restaurant).order_by('position')

    # Reassign positions starting from 1
    for index, category in enumerate(categories, start=1):
        if category.position != index:
            category.position = index
            category.save(update_fields=['position'])


@receiver(post_delete, sender=MenuItem)
def delete_menu_image(sender, instance, **kwargs):
    if instance.image:
        instance.image.delete(save=False)


@receiver(post_delete, sender=StaffInvite)
def delete_staff_invite_qr(sender, instance, **kwargs):
    """Delete QR code image from Cloudinary when invitation is deleted"""
    if instance.qr_code_image:
        try:
            logger.info(f"🗑️ Deleting QR image for deleted invite {instance.id}")
            instance.qr_code_image.delete(save=False)
            logger.info(f"✅ QR image deleted for invite {instance.id}")
        except Exception as e:
            logger.error(f"❌ Error deleting QR image for invite {instance.id}: {e}")


@receiver(models.signals.post_save, sender=MenuItem)
def log_menu_item_saved(sender, instance, created, **kwargs):
    """Log menu item save with image details"""
    print(f"\n📤 [post_save signal] MenuItem saved: {instance.name} (ID: {instance.id})")
    if instance.image:
        print(f"📤 Image: {instance.image.name}")
        print(f"📤 Image URL: {instance.image.url}")
        try:
            if instance.image.storage.exists(instance.image.name):
                size = instance.image.storage.size(instance.image.name)
                print(f"✅ Image exists in storage! Size: {size} bytes")
            else:
                print(f"❌ Image does NOT exist in storage!")
        except Exception as e:
            print(f"❌ Error checking image storage: {e}")
    else:
        print(f"⚠️ No image for this item")
