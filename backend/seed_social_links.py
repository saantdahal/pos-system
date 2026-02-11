#!/usr/bin/env python3
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'bhansaGhar_backend.settings')
django.setup()

from customer.models import SocialMediaLink, SocialMediaPlatform, LandingPage

landing_page = LandingPage.objects.filter(is_active=True).first()
if not landing_page:
    print("❌ No active landing page found!")
else:
    print(f"✅ Found landing page: {landing_page}")
    
    # Create social media links
    socials = [
        {'platform': 'facebook', 'icon': '📘', 'url': 'https://facebook.com/bhansaghar'},
        {'platform': 'instagram', 'icon': '📷', 'url': 'https://instagram.com/bhansaghar'},
        {'platform': 'linkedin', 'icon': '💼', 'url': 'https://linkedin.com/company/bhansaghar'},
        {'platform': 'twitter', 'icon': '𝕏', 'url': 'https://twitter.com/bhansaghar'},
        {'platform': 'whatsapp', 'icon': '📱', 'url': 'https://wa.me/919876543210'},
    ]
    
    for i, social_data in enumerate(socials):
        # Get or create the platform
        platform, created = SocialMediaPlatform.objects.get_or_create(
            platform_key=social_data['platform'],
            defaults={
                'name': social_data['platform'].title(),
                'icon': social_data['icon'],
                'url_placeholder': 'https://example.com'
            }
        )
        
        # Create the social link
        link, created = SocialMediaLink.objects.get_or_create(
            landing_page=landing_page,
            platform=platform,
            defaults={
                'url': social_data['url'],
                'order': i,
                'is_active': True,
            }
        )
        if created:
            print(f"  ✅ Created: {link.platform.name}")
        else:
            print(f"  ℹ️  Already exists: {link.platform.name}")
    
    # Verify
    links = SocialMediaLink.objects.filter(landing_page=landing_page, is_active=True)
    print(f"\n📊 Total social links for landing page: {links.count()}")
    for link in links:
        print(f"  - {link.platform.name}: {link.platform.icon}")
