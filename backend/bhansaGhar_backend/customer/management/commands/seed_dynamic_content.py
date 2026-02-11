from django.core.management.base import BaseCommand
from customer.models import FooterLink, SocialMediaLink, ContentPage, LandingPage, AppCard, SocialMediaPlatform


class Command(BaseCommand):
    help = 'Seed dynamic landing page content (footer links, social media, content pages)'

    def add_arguments(self, parser):
        parser.add_argument(
            '--clear',
            action='store_true',
            help='Clear existing data before seeding',
        )

    def handle(self, *args, **options):
        if options['clear']:
            self.stdout.write('🗑️  Clearing existing data...')
            FooterLink.objects.all().delete()
            SocialMediaLink.objects.all().delete()
            ContentPage.objects.all().delete()
            AppCard.objects.all().delete()

        self.seed_footer_links()
        self.seed_social_media_links()
        self.seed_app_cards()
        self.seed_content_pages()
        self.update_landing_page_footer_titles()

        self.stdout.write(self.style.SUCCESS('\n✅ All dynamic content seeded successfully!'))
        self.stdout.write(f'   - Footer Links: {FooterLink.objects.filter(is_active=True).count()}')
        self.stdout.write(f'   - Social Media Links: {SocialMediaLink.objects.filter(is_active=True).count()}')
        self.stdout.write(f'   - App Cards: {AppCard.objects.filter(is_active=True).count()}')
        self.stdout.write(f'   - Content Pages: {ContentPage.objects.filter(is_active=True).count()}')

    def seed_footer_links(self):
        self.stdout.write('🔗 Seeding Footer Links...')

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
                defaults={'url': link_data['url'], 'order': i, 'is_active': True}
            )
        self.stdout.write(f'  ✅ Created {len(quick_links)} Quick Links')

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
                defaults={'url': link_data['url'], 'order': i, 'is_active': True}
            )
        self.stdout.write(f'  ✅ Created {len(for_restaurants)} For Restaurants Links')

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
                defaults={'url': link_data['url'], 'order': i, 'is_active': True}
            )
        self.stdout.write(f'  ✅ Created {len(support_links)} Support Links')

        company_links = [
            {'title': 'About Us', 'url': 'about'},
            {'title': 'Blog', 'url': 'https://blog.example.com'},
            {'title': 'Careers', 'url': 'https://careers.example.com'},
        ]

        for i, link_data in enumerate(company_links):
            FooterLink.objects.get_or_create(
                section='company',
                title=link_data['title'],
                defaults={'url': link_data['url'], 'order': i, 'is_active': True}
            )
        self.stdout.write(f'  ✅ Created {len(company_links)} Company Links')

        legal_links = [
            {'title': 'Terms of Service', 'url': 'terms'},
            {'title': 'Privacy Policy', 'url': 'privacy'},
            {'title': 'Cookie Policy', 'url': 'cookies'},
        ]

        for i, link_data in enumerate(legal_links):
            FooterLink.objects.get_or_create(
                section='legal',
                title=link_data['title'],
                defaults={'url': link_data['url'], 'order': i, 'is_active': True}
            )
        self.stdout.write(f'  ✅ Created {len(legal_links)} Legal Links')

    def seed_social_media_links(self):
        from customer.models import SocialMediaPlatform
        
        self.stdout.write('\n📱 Seeding Social Media Links...')

        socials = [
            {'platform': 'facebook', 'icon': '📘', 'url': 'https://facebook.com/bhansaghar'},
            {'platform': 'instagram', 'icon': '📷', 'url': 'https://instagram.com/bhansaghar'},
            {'platform': 'twitter', 'icon': '🐦', 'url': 'https://twitter.com/bhansaghar'},
            {'platform': 'linkedin', 'icon': '💼', 'url': 'https://linkedin.com/company/bhansaghar'},
            {'platform': 'whatsapp', 'icon': '💬', 'url': 'https://wa.me/919876543210'},
            {'platform': 'telegram', 'icon': '✈️', 'url': 'https://t.me/bhansaghar'},
        ]

        landing_page = LandingPage.objects.filter(is_active=True).first()
        
        for i, social_data in enumerate(socials):
            # Get or create the platform
            platform, _ = SocialMediaPlatform.objects.get_or_create(
                platform_key=social_data['platform'],
                defaults={
                    'name': social_data['platform'].title(),
                    'icon': social_data['icon'],
                    'url_placeholder': 'https://example.com'
                }
            )
            
            # Create the social link
            SocialMediaLink.objects.get_or_create(
                landing_page=landing_page,
                platform=platform,
                defaults={
                    'url': social_data['url'],
                    'order': i,
                    'is_active': True,
                }
            )
        self.stdout.write(f'  ✅ Created {len(socials)} Social Media Links')

    def seed_app_cards(self):
        self.stdout.write('\n📱 Seeding App Cards...')

        app_cards = [
            {
                'icon': '👨‍💼',
                'title': 'Admin App',
                'description': 'Complete restaurant management at your fingertips. Monitor sales, update menus, manage orders, and control your entire operation from anywhere.',
                'ios_link': 'https://apps.apple.com/app/admin-app',
                'android_link': 'https://play.google.com/store/apps/details?id=admin-app',
            },
            {
                'icon': '👨‍🍳',
                'title': 'Kitchen & Staff App',
                'description': 'Streamline kitchen operations with real-time order notifications, preparation tracking, table management, and seamless communication with your team.',
                'ios_link': 'https://apps.apple.com/app/kitchen-app',
                'android_link': 'https://play.google.com/store/apps/details?id=kitchen-app',
            },
        ]

        for i, app_data in enumerate(app_cards):
            AppCard.objects.get_or_create(
                title=app_data['title'],
                defaults={
                    'icon': app_data['icon'],
                    'description': app_data['description'],
                    'ios_link': app_data['ios_link'],
                    'android_link': app_data['android_link'],
                    'order': i,
                    'is_active': True,
                }
            )
        self.stdout.write(f'  ✅ Created {len(app_cards)} App Cards')

    def seed_content_pages(self):
        self.stdout.write('\n📄 Seeding Content Pages...')

        content_pages = [
            {
                'title': 'Privacy Policy',
                'slug': 'privacy',
                'content': '<h3>Privacy Policy</h3><p>At BhansaGhar, we are committed to protecting your privacy. This privacy policy explains how we collect, use, disclose, and safeguard your information when you visit our website and use our services...</p>',
            },
            {
                'title': 'Terms of Service',
                'slug': 'terms',
                'content': '<h3>Terms of Service</h3><p>By accessing and using BhansaGhar, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service...</p>',
            },
            {
                'title': 'Pricing & Subscription Models',
                'slug': 'pricing',
                'content': '<h3>Pricing</h3><p>We offer flexible pricing for restaurants of all sizes. Our subscription plans are designed to scale with your business...</p>',
            },
            {
                'title': 'Frequently Asked Questions',
                'slug': 'faq',
                'content': '<h3>FAQ</h3><p><strong>Q: How do I place an order?</strong></p><p>A: Browse through our restaurants, select your items, and complete checkout to place an order.</p><p><strong>Q: What are the delivery times?</strong></p><p>A: Delivery times vary by restaurant and location. You can see estimated delivery time during checkout.</p>',
            },
            {
                'title': 'Contact Us',
                'slug': 'contact',
                'content': '<h3>Contact Us</h3><p>We\'d love to hear from you! Contact our support team at:</p><p>Email: support@bhansaghar.com</p><p>Phone: +1 (555) 123-4567</p><p>Hours: 24/7 Customer Support</p>',
            },
            {
                'title': 'About BhansaGhar',
                'slug': 'about',
                'content': '<h3>About Us</h3><p>BhansaGhar is a leading food ordering platform connecting food lovers with their favorite local restaurants. Our mission is to make good food accessible to everyone with just a few clicks.</p>',
            },
        ]

        for page_data in content_pages:
            ContentPage.objects.get_or_create(
                slug=page_data['slug'],
                defaults={
                    'title': page_data['title'],
                    'content': page_data['content'],
                    'is_active': True,
                }
            )
        self.stdout.write(f'  ✅ Created {len(content_pages)} Content Pages')

    def update_landing_page_footer_titles(self):
        self.stdout.write('\n🎨 Updating Landing Page Footer Section Titles...')

        landing_page = LandingPage.objects.filter(is_active=True).first()
        if landing_page:
            landing_page.footer_section_quick_links_title = "Quick Links"
            landing_page.footer_section_for_restaurants_title = "For Restaurants"
            landing_page.footer_section_support_title = "Support"
            landing_page.footer_section_company_title = "Company"
            landing_page.footer_section_legal_title = "Legal"
            landing_page.save()
            self.stdout.write('  ✅ Updated Landing Page Footer Titles')
        else:
            self.stdout.write('  ⚠️ No active landing page found')
