from rest_framework import serializers
from restaurants.models import Restaurant, MenuItem, Category
from .models import LandingPage, AppCard


class RestaurantContentSerializer(serializers.ModelSerializer):
    """Serializer for admin to update public restaurant content"""
    
    class Meta:
        model = Restaurant
        fields = ['id', 'name', 'slug', 'description', 'about', 'hero_image', 'phone', 'address']
        read_only_fields = ['id', 'slug']


class MenuItemSerializer(serializers.ModelSerializer):
    """Serializer for menu items"""
    
    class Meta:
        model = MenuItem
        fields = ['id', 'name', 'description', 'base_price', 'category', 'image']
        read_only_fields = ['id']


class CategorySerializer(serializers.ModelSerializer):
    """Serializer for menu categories"""
    items = MenuItemSerializer(source='items', many=True, read_only=True)
    
    class Meta:
        model = Category
        fields = ['id', 'name', 'position', 'items']
        read_only_fields = ['id']


class RestaurantPublicSerializer(serializers.ModelSerializer):
    """Public serializer for restaurant data (for browsing)"""
    categories = CategorySerializer(many=True, read_only=True)
    
    class Meta:
        model = Restaurant
        fields = ['id', 'name', 'slug', 'description', 'about', 'hero_image', 'phone', 'address', 'categories']
        read_only_fields = '__all__'


# ============================================================================
# Landing Page Serializers
# ============================================================================

class LandingPageSerializer(serializers.ModelSerializer):
    """Serializer for super admin to manage landing page content"""
    
    class Meta:
        model = LandingPage
        fields = [
            'id',
            'brand_name',
            'logo',
            'navbar_logo_image',
            'hero_title',
            'hero_subtitle',
            'hero_image',
            'stat_2_value',
            'stat_2_label',
            'stat_3_value',
            'stat_3_label',
            'stat_4_value',
            'stat_4_label',
            'info_banner_icon',
            'info_banner_image',
            'info_banner_text',
            'features_title',
            'features_subtitle',
            'feature_1_icon',
            'feature_1_icon_image',
            'feature_1_title',
            'feature_1_description',
            'feature_2_icon',
            'feature_2_icon_image',
            'feature_2_title',
            'feature_2_description',
            'feature_3_icon',
            'feature_3_icon_image',
            'feature_3_title',
            'feature_3_description',
            'restaurants_section_title',
            'restaurants_section_subtitle',
            'restaurants_section_tag',
            'about_title',
            'about_description',
            'about_description_2',
            'about_image',
            'app_section_title',
            'app_section_description',
            'highlight_1',
            'highlight_2',
            'highlight_3',
            'highlight_4',
            'cta_title',
            'cta_description',
            'cta_button_text',
            'footer_tagline',
            'footer_text',
            'footer_section_company_title',
            'footer_section_for_restaurants_title',
            'footer_section_legal_title',
            'footer_section_quick_links_title',
            'footer_section_support_title',
            'is_active',
            'updated_at',
            'created_at',
        ]
        read_only_fields = ['id', 'updated_at', 'created_at']


class AppCardSerializer(serializers.ModelSerializer):
    """Serializer for app card management"""
    
    class Meta:
        model = AppCard
        fields = [
            'id',
            'icon',
            'icon_svg',
            'icon_image',
            'title',
            'description',
            'ios_link',
            'android_link',
            'is_active',
            'order',
            'updated_at',
            'created_at',
        ]
        read_only_fields = ['id', 'updated_at', 'created_at']


# For public API (display landing page content)
class LandingPagePublicSerializer(serializers.ModelSerializer):
    """Public serializer for reading landing page content (no image upload fields needed)"""
    
    class Meta:
        model = LandingPage
        fields = [
            'id',
            'brand_name',
            'logo',
            'navbar_logo_image',
            'hero_title',
            'hero_subtitle',
            'hero_image',
            'stat_2_value',
            'stat_2_label',
            'stat_3_value',
            'stat_3_label',
            'stat_4_value',
            'stat_4_label',
            'info_banner_icon',
            'info_banner_image',
            'info_banner_text',
            'features_title',
            'features_subtitle',
            'feature_1_icon',
            'feature_1_icon_image',
            'feature_1_title',
            'feature_1_description',
            'feature_2_icon',
            'feature_2_icon_image',
            'feature_2_title',
            'feature_2_description',
            'feature_3_icon',
            'feature_3_icon_image',
            'feature_3_title',
            'feature_3_description',
            'restaurants_section_title',
            'restaurants_section_subtitle',
            'restaurants_section_tag',
            'about_title',
            'about_description',
            'about_description_2',
            'about_image',
            'app_section_title',
            'app_section_description',
            'highlight_1',
            'highlight_2',
            'highlight_3',
            'highlight_4',
            'cta_title',
            'cta_description',
            'cta_button_text',
            'footer_tagline',
            'footer_text',
            'footer_section_company_title',
            'footer_section_for_restaurants_title',
            'footer_section_legal_title',
            'footer_section_quick_links_title',
            'footer_section_support_title',
        ]
        read_only_fields = '__all__'


class AppCardPublicSerializer(serializers.ModelSerializer):
    """Public serializer for reading app card content"""
    
    class Meta:
        model = AppCard
        fields = [
            'id',
            'icon',
            'icon_svg',
            'icon_image',
            'title',
            'description',
            'ios_link',
            'android_link',
            'order',
        ]
        read_only_fields = '__all__'
