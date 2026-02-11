from django.db import models
from django.core.validators import FileExtensionValidator
import os
from core.services.storage import OptimizedCloudinaryStorage


def landing_page_hero_image_upload_to(instance, filename):
    """Upload hero image to bhansa_ghar/landing_page/hero/{filename}"""
    ext = os.path.splitext(filename)[1]
    filename = f"hero_image{ext}"
    return f"bhansa_ghar/landing_page/hero/{filename}"


def landing_page_navbar_logo_upload_to(instance, filename):
    """Upload navbar logo to bhansa_ghar/landing_page/navbar_logo/{filename}"""
    ext = os.path.splitext(filename)[1]
    filename = f"navbar_logo{ext}"
    return f"bhansa_ghar/landing_page/navbar_logo/{filename}"


def landing_page_info_banner_upload_to(instance, filename):
    """Upload info banner image to bhansa_ghar/landing_page/info_banner/{filename}"""
    ext = os.path.splitext(filename)[1]
    filename = f"info_banner_image{ext}"
    return f"bhansa_ghar/landing_page/info_banner/{filename}"


def landing_page_feature_1_icon_upload_to(instance, filename):
    """Upload feature 1 icon to bhansa_ghar/landing_page/feature_icons/{filename}"""
    ext = os.path.splitext(filename)[1]
    filename = f"feature_1_icon{ext}"
    return f"bhansa_ghar/landing_page/feature_icons/{filename}"


def landing_page_feature_2_icon_upload_to(instance, filename):
    """Upload feature 2 icon to bhansa_ghar/landing_page/feature_icons/{filename}"""
    ext = os.path.splitext(filename)[1]
    filename = f"feature_2_icon{ext}"
    return f"bhansa_ghar/landing_page/feature_icons/{filename}"


def landing_page_feature_3_icon_upload_to(instance, filename):
    """Upload feature 3 icon to bhansa_ghar/landing_page/feature_icons/{filename}"""
    ext = os.path.splitext(filename)[1]
    filename = f"feature_3_icon{ext}"
    return f"bhansa_ghar/landing_page/feature_icons/{filename}"
    filename = f"feature_{feature_num}_icon{ext}"
    return f"bhansa_ghar/landing_page/feature_icons/{filename}"


class LandingPage(models.Model):
    """Landing page model for website homepage"""
    brand_name = models.CharField(
        max_length=100,
        default='FoodHub',
        help_text='Brand name displayed in navbar and footer'
    )
    logo = models.CharField(
        max_length=10,
        default='🍽️',
        help_text='Logo/emoji displayed in navbar'
    )
    # New: Logo/Image for navbar
    navbar_logo_image = models.ImageField(
        upload_to=landing_page_navbar_logo_upload_to,
        storage=OptimizedCloudinaryStorage(),
        blank=True,
        null=True,
        max_length=500,
        help_text='Logo image for navbar (optional, displayed before brand name)'
    )
    hero_title = models.CharField(
        max_length=200,
        help_text='Main title for hero section'
    )
    hero_subtitle = models.TextField(help_text='Subtitle/description for hero section')
    # Updated: Hero image now supports file upload
    hero_image = models.ImageField(
        upload_to=landing_page_hero_image_upload_to,
        storage=OptimizedCloudinaryStorage(),
        blank=True,
        null=True,
        max_length=500,
        help_text='Hero section background image'
    )
    hero_cta_text = models.CharField(
        max_length=100,
        default='Browse Restaurants',
        help_text='Text for the hero section CTA button'
    )
    hero_cta_link = models.CharField(
        max_length=500,
        default='#restaurants',
        blank=True,
        help_text='Link for hero CTA button (e.g., #restaurants, /menu, https://example.com)'
    )
    stat_2_value = models.CharField(
        max_length=50,
        default='500+',
        help_text="Value for second stat (e.g., '500+')"
    )
    stat_2_label = models.CharField(
        max_length=100,
        default='Menu Items',
        help_text='Label for second stat'
    )
    stat_3_value = models.CharField(
        max_length=50,
        default='1000+',
        help_text='Value for third stat'
    )
    stat_3_label = models.CharField(
        max_length=100,
        default='Happy Customers',
        help_text='Label for third stat'
    )
    stat_4_value = models.CharField(
        max_length=50,
        default='24/7',
        help_text='Value for fourth stat'
    )
    stat_4_label = models.CharField(
        max_length=100,
        default='Service Available',
        help_text='Label for fourth stat'
    )
    info_banner_icon = models.CharField(
        max_length=10,
        default='ℹ️',
        help_text='Icon/emoji for info banner'
    )
    # New: Info banner image support
    info_banner_image = models.ImageField(
        upload_to=landing_page_info_banner_upload_to,
        storage=OptimizedCloudinaryStorage(),
        blank=True,
        null=True,
        max_length=500,
        help_text='Info banner background image (optional)'
    )
    info_banner_text = models.TextField(help_text='Text content for info banner')
    features_title = models.CharField(
        max_length=200,
        default='Why Choose Us',
        help_text='Title for features section'
    )
    features_subtitle = models.TextField(
        default='We bring together the finest restaurants and cutting-edge technology to deliver an exceptional dining experience',
        help_text='Subtitle for features section'
    )
    feature_1_icon = models.CharField(max_length=10, default='⚡')
    # New: Feature 1 icon image support
    feature_1_icon_image = models.ImageField(
        upload_to=landing_page_feature_1_icon_upload_to,
        storage=OptimizedCloudinaryStorage(),
        blank=True,
        null=True,
        max_length=500,
        help_text='Feature 1 icon image (optional, takes precedence over emoji)'
    )
    feature_1_title = models.CharField(max_length=100)
    feature_1_description = models.TextField()
    feature_2_icon = models.CharField(max_length=10, default='🚀')
    # New: Feature 2 icon image support
    feature_2_icon_image = models.ImageField(
        upload_to=landing_page_feature_2_icon_upload_to,
        storage=OptimizedCloudinaryStorage(),
        blank=True,
        null=True,
        max_length=500,
        help_text='Feature 2 icon image (optional, takes precedence over emoji)'
    )
    feature_2_title = models.CharField(max_length=100)
    feature_2_description = models.TextField()
    feature_3_icon = models.CharField(max_length=10, default='💎')
    # New: Feature 3 icon image support
    feature_3_icon_image = models.ImageField(
        upload_to=landing_page_feature_3_icon_upload_to,
        storage=OptimizedCloudinaryStorage(),
        blank=True,
        null=True,
        max_length=500,
        help_text='Feature 3 icon image (optional, takes precedence over emoji)'
    )
    feature_3_title = models.CharField(max_length=100)
    feature_3_description = models.TextField()
    restaurants_section_title = models.CharField(
        max_length=200,
        default='Partner Restaurants',
        help_text='Title for restaurants section'
    )
    restaurants_section_subtitle = models.TextField(
        default='Discover amazing food from our partner restaurants',
        help_text='Subtitle for restaurants section'
    )
    restaurants_section_tag = models.CharField(
        max_length=100,
        default='Explore',
        help_text='Tag/label for restaurants section'
    )
    about_title = models.CharField(
        max_length=200,
        default='About Our Platform'
    )
    about_description = models.TextField()
    about_description_2 = models.TextField(blank=True)
    about_image = models.TextField(
        blank=True,
        null=True,
        help_text='About section image URL or SVG'
    )
    app_section_title = models.CharField(
        max_length=200,
        default='Download Our Apps',
        help_text='Title for app download section'
    )
    app_section_description = models.TextField(
        default='Get the best experience with our mobile apps',
        help_text='Description for app download section'
    )
    highlight_1 = models.CharField(
        max_length=200,
        default='Trusted by Top Restaurants'
    )
    highlight_2 = models.CharField(
        max_length=200,
        default='Real-time Order Tracking'
    )
    highlight_3 = models.CharField(
        max_length=200,
        default='Secure Payments'
    )
    highlight_4 = models.CharField(
        max_length=200,
        default='24/7 Customer Support'
    )
    cta_title = models.CharField(
        max_length=200,
        help_text='Call-to-action section title'
    )
    cta_description = models.TextField(help_text='CTA section description')
    cta_button_text = models.CharField(
        max_length=100,
        default='Start Ordering Now',
        help_text='Text for CTA button'
    )
    footer_tagline = models.TextField(
        default='Your one-stop platform for discovering and ordering from the best restaurants in town.',
        help_text='Tagline displayed in footer'
    )
    footer_text = models.TextField(
        default='© 2024 FoodHub. All rights reserved.',
        help_text='Copyright text for footer'
    )
    footer_section_company_title = models.CharField(
        max_length=100,
        default='Company',
        help_text='Title for Company section'
    )
    footer_section_for_restaurants_title = models.CharField(
        max_length=100,
        default='For Restaurants',
        help_text='Title for For Restaurants section'
    )
    footer_section_legal_title = models.CharField(
        max_length=100,
        default='Legal',
        help_text='Title for Legal section'
    )
    footer_section_quick_links_title = models.CharField(
        max_length=100,
        default='Quick Links',
        help_text='Title for Quick Links section'
    )
    footer_section_support_title = models.CharField(
        max_length=100,
        default='Support',
        help_text='Title for Support section'
    )
    is_active = models.BooleanField(
        default=True,
        help_text='Whether this landing page is currently active'
    )
    updated_at = models.DateTimeField(auto_now=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Landing Page'
        verbose_name_plural = 'Landing Pages'

    def __str__(self):
        return self.brand_name

    def save(self, *args, **kwargs):
        """Ensure only one LandingPage instance exists"""
        if not self.pk and LandingPage.objects.exists():
            raise ValueError('Only one LandingPage instance is allowed.')
        super().save(*args, **kwargs)


class ContentPage(models.Model):
    """Model for dynamic content pages (policies, about, etc.)"""
    slug = models.SlugField(unique=True, help_text='URL slug for the page')
    title = models.CharField(max_length=200, help_text='Page title')
    content = models.TextField(help_text='Page content (supports HTML)')
    is_active = models.BooleanField(default=True, help_text='Whether this page is published')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Content Page'
        verbose_name_plural = 'Content Pages'
        ordering = ['title']

    def __str__(self):
        return self.title


class FooterLink(models.Model):
    """Model for footer links organized by section"""
    SECTION_CHOICES = [
        ('quick_links', 'Quick Links'),
        ('company', 'Company'),
        ('for_restaurants', 'For Restaurants'),
        ('legal', 'Legal'),
        ('support', 'Support'),
    ]

    section = models.CharField(
        max_length=20,
        choices=SECTION_CHOICES,
        help_text='Footer section this link belongs to'
    )
    title = models.CharField(max_length=100, help_text='Link text/title')
    url = models.CharField(
        max_length=500,
        help_text="URL or content page slug (e.g., '#privacy' or 'https://example.com')"
    )
    is_active = models.BooleanField(default=True)
    order = models.IntegerField(
        default=0,
        help_text='Display order within section'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Footer Link'
        verbose_name_plural = 'Footer Links'
        ordering = ['section', 'order', 'title']

    def __str__(self):
        return f"{self.get_section_display()} - {self.title}"


class SocialMediaPlatform(models.Model):
    """
    Default social media platforms defined by super admin.
    Restaurant owners can select from these and add their links.
    """
    name = models.CharField(
        max_length=50,
        unique=True,
        help_text="Platform name (e.g., 'Facebook')"
    )
    platform_key = models.CharField(
        max_length=20,
        unique=True,
        help_text="Unique identifier (e.g., 'facebook')"
    )
    icon = models.CharField(
        max_length=5000,
        help_text="Icon (emoji, font-awesome class, SVG, or PNG/SVG URL link). E.g., '👍' or 'fab fa-facebook-f' or '<svg>...</svg>' or 'https://example.com/icon.svg'"
    )
    url_placeholder = models.CharField(
        max_length=255,
        blank=True,
        null=True,
        help_text="Placeholder for URL input. E.g., 'https://facebook.com/yourpage' or '+1234567890' for WhatsApp"
    )
    is_active = models.BooleanField(default=True)
    position = models.PositiveIntegerField(
        default=0,
        help_text='Display order'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['position']
        verbose_name = 'Social Media Platform'
        verbose_name_plural = 'Social Media Platforms'

    def __str__(self):
        return f"{self.name} ({self.platform_key})"


class SocialMediaLink(models.Model):
    """
    Model to store social media links that appear in the footer.
    """
    landing_page = models.ForeignKey(
        'LandingPage',
        on_delete=models.CASCADE,
        related_name='social_links',
        null=True,
        blank=True,
        help_text='Associated landing page (leave blank for global)'
    )
    restaurant = models.ForeignKey(
        'restaurants.Restaurant',
        on_delete=models.CASCADE,
        related_name='social_links',
        null=True,
        blank=True,
        help_text='Associated restaurant (leave blank for global or landing page specific)'
    )
    platform = models.ForeignKey(
        'SocialMediaPlatform',
        on_delete=models.CASCADE,
        related_name='links',
        help_text='Select a social media platform'
    )
    url = models.URLField(help_text='Link URL or contact info for this platform')
    is_active = models.BooleanField(default=True)
    order = models.IntegerField(
        default=0,
        help_text='Display order'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Social Media Link'
        verbose_name_plural = 'Social Media Links'
        ordering = ['order', 'platform']
        unique_together = [('restaurant', 'platform'), ('landing_page', 'platform')]

    def __str__(self):
        owner = self.restaurant or self.landing_page or 'Global'
        return f"{self.platform.name} - {owner}"


class AppCard(models.Model):
    """Model for app download cards in landing page"""
    icon = models.CharField(
        max_length=10,
        help_text='Icon/emoji for the app card'
    )
    # New: SVG code support for app card icons
    icon_svg = models.TextField(
        blank=True,
        null=True,
        help_text='SVG code for app icon (takes precedence over emoji icon)'
    )
    # New: Image/Icon file upload
    icon_image = models.ImageField(
        upload_to='bhansa_ghar/landing_page/app_card_icons/',
        storage=OptimizedCloudinaryStorage(),
        blank=True,
        null=True,
        max_length=500,
        help_text='Icon image file (takes precedence over SVG and emoji)'
    )
    title = models.CharField(
        max_length=100,
        help_text='App name/title'
    )
    description = models.TextField(help_text='App description')
    ios_link = models.URLField(
        blank=True,
        help_text='iOS app download link'
    )
    android_link = models.URLField(
        blank=True,
        help_text='Android app download link'
    )
    is_active = models.BooleanField(default=True)
    order = models.IntegerField(
        default=0,
        help_text='Display order'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'App Card'
        verbose_name_plural = 'App Cards'
        ordering = ['order']

    def __str__(self):
        return self.title


class Testimonial(models.Model):
    """Model for customer testimonials"""
    RATING_CHOICES = [
        (1, '1 Star'),
        (2, '2 Stars'),
        (3, '3 Stars'),
        (4, '4 Stars'),
        (5, '5 Stars'),
    ]

    restaurant = models.ForeignKey(
        'restaurants.Restaurant',
        on_delete=models.CASCADE,
        related_name='testimonials',
        help_text='Restaurant this testimonial belongs to'
    )
    author_name = models.CharField(
        max_length=100,
        help_text='Name of the person who gave the testimonial'
    )
    rating = models.IntegerField(
        choices=RATING_CHOICES,
        help_text='Rating out of 5 stars'
    )
    text = models.TextField(help_text='Testimonial content')
    is_active = models.BooleanField(
        default=True,
        help_text='Whether to display this testimonial'
    )
    order = models.IntegerField(
        default=0,
        help_text='Display order'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Testimonial'
        verbose_name_plural = 'Testimonials'
        ordering = ['order', '-created_at']

    def __str__(self):
        return f"{self.author_name} - {self.get_rating_display()}"
