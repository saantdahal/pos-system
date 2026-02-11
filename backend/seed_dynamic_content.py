#!/usr/bin/env python3
"""
Seed script for dynamic landing page content.
Creates Footer Links, Social Media Links, and Content Pages.
"""

import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'bhansaGhar_backend.settings')
django.setup()

from customer.models import FooterLink, SocialMediaLink, ContentPage, LandingPage

def seed_footer_links():
    """Seed all footer section links"""
    print("🔗 Seeding Footer Links...")
    
    # Quick Links
    quick_links = [
        {'title': 'Home', 'url': '#home'},
        {'title': 'About Us', 'url': '#about'},
        {'title': 'Restaurants', 'url': '#restaurants'},
        {'title': 'Download Apps', 'url': '#apps'},
    ]
    
    for i, link_data in enumerate(quick_links):
        FooterLink.objects.get_or_create(
            section='quick_links',
            title=link_data['title'],
            defaults={
                'url': link_data['url'],
                'order': i,
                'is_active': True,
            }
        )
    print(f"✅ Created {len(quick_links)} Quick Links")
    
    # For Restaurants
    for_restaurants = [
        {'title': 'Partner With Us', 'url': '#partner'},
        {'title': 'Admin App', 'url': '#admin-app'},
        {'title': 'Kitchen App', 'url': '#kitchen-app'},
        {'title': 'Pricing', 'url': 'pricing'},
    ]
    
    for i, link_data in enumerate(for_restaurants):
        FooterLink.objects.get_or_create(
            section='for_restaurants',
            title=link_data['title'],
            defaults={
                'url': link_data['url'],
                'order': i,
                'is_active': True,
            }
        )
    print(f"✅ Created {len(for_restaurants)} For Restaurants Links")
    
    # Support
    support_links = [
        {'title': 'Privacy Policy', 'url': 'privacy'},
        {'title': 'Terms of Service', 'url': 'terms'},
        {'title': 'Contact Us', 'url': 'contact'},
        {'title': 'FAQ', 'url': 'faq'},
    ]
    
    for i, link_data in enumerate(support_links):
        FooterLink.objects.get_or_create(
            section='support',
            title=link_data['title'],
            defaults={
                'url': link_data['url'],
                'order': i,
                'is_active': True,
            }
        )
    print(f"✅ Created {len(support_links)} Support Links")
    
    # Company
    company_links = [
        {'title': 'About Us', 'url': 'about'},
        {'title': 'Blog', 'url': 'https://blog.example.com'},
        {'title': 'Careers', 'url': 'https://careers.example.com'},
    ]
    
    for i, link_data in enumerate(company_links):
        FooterLink.objects.get_or_create(
            section='company',
            title=link_data['title'],
            defaults={
                'url': link_data['url'],
                'order': i,
                'is_active': True,
            }
        )
    print(f"✅ Created {len(company_links)} Company Links")
    
    # Legal
    legal_links = [
        {'title': 'Terms of Service', 'url': 'terms'},
        {'title': 'Privacy Policy', 'url': 'privacy'},
        {'title': 'Cookie Policy', 'url': 'cookies'},
    ]
    
    for i, link_data in enumerate(legal_links):
        FooterLink.objects.get_or_create(
            section='legal',
            title=link_data['title'],
            defaults={
                'url': link_data['url'],
                'order': i,
                'is_active': True,
            }
        )
    print(f"✅ Created {len(legal_links)} Legal Links")


def seed_social_media_links():
    """Seed social media links"""
    print("\n📱 Seeding Social Media Links...")
    
    socials = [
        {'platform': 'facebook', 'icon': '📘', 'url': 'https://facebook.com/bhansaghar'},
        {'platform': 'instagram', 'icon': '📷', 'url': 'https://instagram.com/bhansaghar'},
        {'platform': 'twitter', 'icon': '🐦', 'url': 'https://twitter.com/bhansaghar'},
        {'platform': 'linkedin', 'icon': '💼', 'url': 'https://linkedin.com/company/bhansaghar'},
        {'platform': 'whatsapp', 'icon': '💬', 'url': 'https://wa.me/919876543210'},
        {'platform': 'telegram', 'icon': '✈️', 'url': 'https://t.me/bhansaghar'},
    ]
    
    for i, social_data in enumerate(socials):
        SocialMediaLink.objects.get_or_create(
            platform=social_data['platform'],
            defaults={
                'icon': social_data['icon'],
                'url': social_data['url'],
                'order': i,
                'is_active': True,
            }
        )
    print(f"✅ Created {len(socials)} Social Media Links")


def seed_content_pages():
    """Seed content pages"""
    print("\n📄 Seeding Content Pages...")
    
    content_pages = [
        {
            'content_type': 'privacy',
            'title': 'Privacy Policy',
            'slug': 'privacy',
            'description': 'Our privacy policy explains how we collect and use your data',
            'content': """
<h3>Privacy Policy</h3>
<p>At BhansaGhar, we are committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and otherwise process personal information in connection with our website and services.</p>

<h4>Information We Collect</h4>
<p>We collect information you provide directly to us, such as:</p>
<ul>
<li>Account information (name, email, phone number)</li>
<li>Payment information (credit card, billing address)</li>
<li>Order history and preferences</li>
<li>Location information</li>
<li>Communication preferences</li>
</ul>

<h4>How We Use Your Information</h4>
<p>We use your information to:</p>
<ul>
<li>Process your orders and payments</li>
<li>Provide customer support</li>
<li>Send promotional emails (with your consent)</li>
<li>Improve our services</li>
<li>Comply with legal obligations</li>
</ul>

<h4>Data Protection</h4>
<p>We implement appropriate security measures to protect your personal information. However, no method of transmission over the Internet is completely secure.</p>

<h4>Contact Us</h4>
<p>If you have any questions about our Privacy Policy, please contact us at privacy@bhansaghar.com</p>
            """,
        },
        {
            'content_type': 'terms',
            'title': 'Terms of Service',
            'slug': 'terms',
            'description': 'Please read our terms of service carefully before using our platform',
            'content': """
<h3>Terms of Service</h3>
<p>By accessing and using BhansaGhar's website and services, you accept and agree to be bound by the terms and provision of this agreement.</p>

<h4>Use License</h4>
<p>Permission is granted to temporarily download one copy of the materials (information or software) on BhansaGhar's website for personal, non-commercial transitory viewing only.</p>

<h4>Disclaimer</h4>
<p>The materials on BhansaGhar's website are provided "as is". BhansaGhar makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.</p>

<h4>Limitations</h4>
<p>In no event shall BhansaGhar or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on BhansaGhar's website.</p>

<h4>Accuracy of Materials</h4>
<p>The materials appearing on BhansaGhar's website could include technical, typographical, or photographic errors. BhansaGhar does not warrant that any of the materials on its website are accurate, complete, or current.</p>

<h4>Contact Us</h4>
<p>If you have any questions about our Terms of Service, please contact us at legal@bhansaghar.com</p>
            """,
        },
        {
            'content_type': 'pricing',
            'title': 'Pricing & Subscription Models',
            'slug': 'pricing',
            'description': 'Learn about our subscription plans for restaurants and customers',
            'content': """
<h3>Pricing & Subscription Models</h3>

<h4>For Customers</h4>
<p>BhansaGhar's platform is completely <strong>FREE</strong> for customers to use:</p>
<ul>
<li>Browse unlimited restaurants</li>
<li>View detailed menus and prices</li>
<li>Place orders online</li>
<li>Track your orders in real-time</li>
<li>No hidden charges or subscription fees</li>
</ul>

<h4>For Restaurants</h4>
<p>We offer flexible subscription plans for restaurant partners:</p>

<h5>🥉 Basic Plan - ₹2,999/month</h5>
<ul>
<li>Listed on BhansaGhar platform</li>
<li>Online menu management</li>
<li>Basic order management</li>
<li>Email support</li>
<li>Up to 10 tables</li>
</ul>

<h5>🥈 Professional Plan - ₹5,999/month</h5>
<ul>
<li>Everything in Basic +</li>
<li>Advanced analytics dashboard</li>
<li>Kitchen display system</li>
<li>Staff management</li>
<li>Priority support</li>
<li>Up to 50 tables</li>
<li>SMS notifications</li>
</ul>

<h5>🥇 Enterprise Plan - Custom pricing</h5>
<ul>
<li>Everything in Professional +</li>
<li>Custom integrations</li>
<li>Dedicated account manager</li>
<li>24/7 phone support</li>
<li>Unlimited tables</li>
<li>Multi-location support</li>
<li>API access</li>
</ul>

<h4>Special Offers</h4>
<p>We regularly offer discounts for annual commitments and special promotions for new restaurants. Contact our sales team for more information.</p>

<h4>Questions?</h4>
<p>Contact our sales team: sales@bhansaghar.com | +91-9876543210</p>
            """,
        },
        {
            'content_type': 'faq',
            'title': 'Frequently Asked Questions',
            'slug': 'faq',
            'description': 'Common questions and answers about BhansaGhar',
            'content': """
<h3>Frequently Asked Questions</h3>

<h4>For Customers</h4>

<h5>Q: Is BhansaGhar app available on iOS and Android?</h5>
<p>A: Yes! Download our app from the App Store and Google Play Store for the best experience.</p>

<h5>Q: What payment methods do you accept?</h5>
<p>A: We accept credit/debit cards, UPI, net banking, and digital wallets like Google Pay and Apple Pay.</p>

<h5>Q: How long does delivery take?</h5>
<p>A: Delivery times vary by restaurant. You can see the estimated time before confirming your order.</p>

<h5>Q: Can I cancel my order?</h5>
<p>A: Yes, you can cancel orders before they're confirmed by the restaurant through the app.</p>

<h4>For Restaurants</h4>

<h5>Q: How do I get started with BhansaGhar?</h5>
<p>A: Contact our partnership team at partnerships@bhansaghar.com or call +91-9876543210.</p>

<h5>Q: What's the commission rate?</h5>
<p>A: Our commission structure is competitive and negotiable based on your business volume.</p>

<h5>Q: Can I manage my menu?</h5>
<p>A: Yes, you have full control over your menu items, prices, and availability.</p>

<h5>Q: What support do you provide?</h5>
<p>A: We provide email support for Basic, and phone support for Professional and Enterprise plans.</p>

<h4>General</h4>

<h5>Q: Is my data secure?</h5>
<p>A: Yes! We use industry-standard encryption and security measures to protect your information.</p>

<h5>Q: How can I contact support?</h5>
<p>A: Email us at support@bhansaghar.com or call our hotline. Response time is usually within 2 hours.</p>
            """,
        },
        {
            'content_type': 'contact',
            'title': 'Contact Us',
            'slug': 'contact',
            'description': 'Get in touch with our support team',
            'content': """
<h3>Contact Us</h3>
<p>We'd love to hear from you! Reach out to us through any of the following channels:</p>

<h4>📧 Email</h4>
<p><strong>General Inquiries:</strong> hello@bhansaghar.com<br>
<strong>Support:</strong> support@bhansaghar.com<br>
<strong>Sales/Partnerships:</strong> sales@bhansaghar.com<br>
<strong>Privacy/Legal:</strong> legal@bhansaghar.com</p>

<h4>📞 Phone</h4>
<p><strong>Customer Support:</strong> +91-9876543210<br>
<strong>Business Hours:</strong> Monday - Saturday, 10 AM - 8 PM IST</p>

<h4>📍 Address</h4>
<p>BhansaGhar Headquarters<br>
Mumbai, Maharashtra, India</p>

<h4>💬 Live Chat</h4>
<p>Available on our website during business hours (10 AM - 8 PM IST)</p>

<h4>🐦 Social Media</h4>
<p>Follow us on Facebook, Instagram, Twitter, and LinkedIn for updates and promotions.</p>

<h4>Response Times</h4>
<p>We aim to respond to all inquiries within 24 hours. For urgent matters, please call our hotline.</p>
            """,
        },
        {
            'content_type': 'about',
            'title': 'About BhansaGhar',
            'slug': 'about',
            'description': 'Learn more about BhansaGhar and our mission',
            'content': """
<h3>About BhansaGhar</h3>

<h4>Our Mission</h4>
<p>To revolutionize the restaurant industry by connecting food lovers with amazing local restaurants through innovative technology that simplifies ordering and enhances the dining experience.</p>

<h4>Our Vision</h4>
<p>To become the leading food ordering platform in South Asia, empowering restaurants to grow their business and customers to discover exceptional culinary experiences.</p>

<h4>Who We Are</h4>
<p>BhansaGhar is a team of passionate food enthusiasts, tech innovators, and business leaders dedicated to transforming how people discover and order food.</p>

<h4>What We Do</h4>
<p>We provide an all-in-one platform that:</p>
<ul>
<li>Helps customers discover and order from their favorite restaurants</li>
<li>Provides restaurants with digital tools to manage orders efficiently</li>
<li>Offers real-time tracking and seamless payment processing</li>
<li>Builds a community of food lovers and culinary entrepreneurs</li>
</ul>

<h4>Our Values</h4>
<ul>
<li><strong>Innovation:</strong> We constantly innovate to provide better solutions</li>
<li><strong>Integrity:</strong> We operate with transparency and honesty</li>
<li><strong>Customer Focus:</strong> Your satisfaction is our priority</li>
<li><strong>Excellence:</strong> We strive for excellence in everything we do</li>
<li><strong>Sustainability:</strong> We care about our impact on society and environment</li>
</ul>

<h4>Our Journey</h4>
<p>Starting from a small idea to revolutionize food ordering, BhansaGhar has grown into a trusted platform serving thousands of customers and hundreds of restaurants. We continue to innovate and expand our services to better serve our community.</p>
            """,
        },
    ]
    
    for page_data in content_pages:
        ContentPage.objects.get_or_create(
            content_type=page_data['content_type'],
            defaults={
                'title': page_data['title'],
                'slug': page_data['slug'],
                'description': page_data['description'],
                'content': page_data['content'],
                'is_active': True,
            }
        )
    print(f"✅ Created {len(content_pages)} Content Pages")


def update_landing_page_footer_titles():
    """Update landing page with footer section titles"""
    print("\n🎨 Updating Landing Page Footer Section Titles...")
    
    landing_page = LandingPage.objects.filter(is_active=True).first()
    if landing_page:
        landing_page.footer_section_quick_links_title = "Quick Links"
        landing_page.footer_section_for_restaurants_title = "For Restaurants"
        landing_page.footer_section_support_title = "Support"
        landing_page.footer_section_company_title = "Company"
        landing_page.footer_section_legal_title = "Legal"
        landing_page.save()
        print("✅ Updated Landing Page Footer Titles")
    else:
        print("⚠️ No active landing page found")


def main():
    print("🌍 Seeding Dynamic Landing Page Content...\n")
    
    try:
        seed_footer_links()
        seed_social_media_links()
        seed_content_pages()
        update_landing_page_footer_titles()
        
        print("\n" + "="*50)
        print("✅ All dynamic content seeded successfully!")
        print("="*50)
        print("\n📊 Summary:")
        print(f"   - Footer Links: {FooterLink.objects.filter(is_active=True).count()}")
        print(f"   - Social Media Links: {SocialMediaLink.objects.filter(is_active=True).count()}")
        print(f"   - Content Pages: {ContentPage.objects.filter(is_active=True).count()}")
        print("\n🎯 Now you can:")
        print("   1. Visit http://localhost:8000/admin/ to manage content")
        print("   2. Try clicking footer links to see content modals")
        print("   3. Edit any section through the Django admin")
        print("\n")
        
    except Exception as e:
        print(f"\n❌ Error seeding data: {str(e)}")
        import traceback
        traceback.print_exc()


if __name__ == '__main__':
    main()
