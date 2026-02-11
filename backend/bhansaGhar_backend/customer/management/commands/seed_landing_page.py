from django.core.management.base import BaseCommand
from django.db import transaction
from customer.models import LandingPage
from restaurants.models import Restaurant, RestaurantType, MenuItem, Category
from core.models import User
import uuid


class Command(BaseCommand):
    help = 'Seed the database with sample landing page and restaurant data'

    def add_arguments(self, parser):
        parser.add_argument(
            '--clear',
            action='store_true',
            help='Clear existing data before seeding',
        )

    @transaction.atomic
    def handle(self, *args, **options):
        if options['clear']:
            self.stdout.write('Clearing existing data...')
            LandingPage.objects.all().delete()
            MenuItem.objects.all().delete()
            Category.objects.all().delete()
            Restaurant.objects.all().delete()
            RestaurantType.objects.all().delete()
            self.stdout.write(self.style.SUCCESS('✓ Data cleared'))

        # Create restaurant types
        self.stdout.write('Creating restaurant types...')
        restaurant_types = {
            'indian': RestaurantType.objects.get_or_create(
                name='indian',
                defaults={'display_name': 'Indian', 'is_active': True}
            )[0],
            'italian': RestaurantType.objects.get_or_create(
                name='italian',
                defaults={'display_name': 'Italian', 'is_active': True}
            )[0],
            'chinese': RestaurantType.objects.get_or_create(
                name='chinese',
                defaults={'display_name': 'Chinese', 'is_active': True}
            )[0],
            'continental': RestaurantType.objects.get_or_create(
                name='continental',
                defaults={'display_name': 'Continental', 'is_active': True}
            )[0],
        }

        # Create or get admin user for restaurants
        admin_user, created = User.objects.get_or_create(
            email='restaurant_admin@foodhub.local',
            defaults={
                'first_name': 'Admin',
                'last_name': 'User',
                'is_staff': False,
                'is_superuser': False,
            }
        )
        if created:
            admin_user.set_password('admin123')
            admin_user.save()

        # Create restaurants
        self.stdout.write('Creating sample restaurants...')
        restaurants_data = [
            {
                'name': 'The Taj Kitchen',
                'slug': 'taj-kitchen',
                'type': restaurant_types['indian'],
                'address': '123 Spice Street, Downtown',
                'latitude': 40.7128,
                'longitude': -74.0060,
                'phone': '+1-555-0101',
                'description': 'Authentic Indian cuisine with rich flavors and traditional recipes',
                'about': 'Experience the authentic taste of India with our carefully curated menu featuring North and South Indian delicacies.',
                'tables_capacity': 20,
            },
            {
                'name': 'La Dolce Vita',
                'slug': 'la-dolce-vita',
                'type': restaurant_types['italian'],
                'address': '456 Pasta Lane, Midtown',
                'latitude': 40.7580,
                'longitude': -73.9855,
                'phone': '+1-555-0102',
                'description': 'Traditional Italian dishes made with fresh ingredients',
                'about': 'Step into Italy with our authentic recipes and finest Italian wines.',
                'tables_capacity': 25,
            },
            {
                'name': 'Dragon Palace',
                'slug': 'dragon-palace',
                'type': restaurant_types['chinese'],
                'address': '789 Noodle Road, Uptown',
                'latitude': 40.7489,
                'longitude': -73.9680,
                'phone': '+1-555-0103',
                'description': 'Exquisite Chinese cuisine with a modern twist',
                'about': 'Taste the essence of China with our signature dishes prepared by expert chefs.',
                'tables_capacity': 30,
            },
            {
                'name': 'Continental Delights',
                'slug': 'continental-delights',
                'type': restaurant_types['continental'],
                'address': '321 Gourmet Plaza, Westside',
                'latitude': 40.7614,
                'longitude': -73.9776,
                'phone': '+1-555-0104',
                'description': 'Fine dining continental cuisine with worldwide influences',
                'about': 'Indulge in fine dining with our world-class continental menu.',
                'tables_capacity': 15,
            },
        ]

        restaurants = {}
        for rest_data in restaurants_data:
            restaurant, created = Restaurant.objects.get_or_create(
                slug=rest_data['slug'],
                defaults={
                    **rest_data,
                    'owner': admin_user,
                    'is_active': True,
                }
            )
            restaurants[rest_data['slug']] = restaurant
            if created:
                self.stdout.write(f'  ✓ Created {restaurant.name}')
            else:
                self.stdout.write(f'  → {restaurant.name} already exists')

        # Create categories for restaurants
        self.stdout.write('Creating menu categories...')
        categories_data = {
            'taj-kitchen': ['Appetizers', 'Curries', 'Breads', 'Rice Dishes', 'Desserts'],
            'la-dolce-vita': ['Antipasti', 'Pasta', 'Risotto', 'Meat', 'Desserts'],
            'dragon-palace': ['Starters', 'Noodles', 'Fried Rice', 'Main Course', 'Soup'],
            'continental-delights': ['Appetizers', 'Salads', 'Main Courses', 'Desserts', 'Beverages'],
        }

        categories = {}
        for slug, cat_names in categories_data.items():
            restaurant = restaurants[slug]
            for cat_name in cat_names:
                category, created = Category.objects.get_or_create(
                    restaurant=restaurant,
                    name=cat_name,
                    defaults={'is_active': True, 'position': len(categories.get(slug, []))}
                )
                if slug not in categories:
                    categories[slug] = []
                categories[slug].append(category)

        # Create menu items
        self.stdout.write('Creating menu items...')
        menu_items_data = {
            'taj-kitchen': [
                {'name': 'Samosa', 'category': 'Appetizers', 'price': 4.99, 'description': 'Crispy pastry with spiced potatoes'},
                {'name': 'Butter Chicken', 'category': 'Curries', 'price': 12.99, 'description': 'Tender chicken in creamy tomato sauce'},
                {'name': 'Palak Paneer', 'category': 'Curries', 'price': 10.99, 'description': 'Spinach and cottage cheese curry'},
                {'name': 'Naan', 'category': 'Breads', 'price': 3.99, 'description': 'Traditional Indian bread'},
                {'name': 'Biryani', 'category': 'Rice Dishes', 'price': 13.99, 'description': 'Fragrant rice with meat or vegetables'},
                {'name': 'Gulab Jamun', 'category': 'Desserts', 'price': 5.99, 'description': 'Sweet milk solids in syrup'},
            ],
            'la-dolce-vita': [
                {'name': 'Caprese', 'category': 'Antipasti', 'price': 8.99, 'description': 'Tomato, mozzarella, basil'},
                {'name': 'Fettuccine Alfredo', 'category': 'Pasta', 'price': 11.99, 'description': 'Creamy parmesan sauce'},
                {'name': 'Risotto Primavera', 'category': 'Risotto', 'price': 12.99, 'description': 'Creamy rice with fresh vegetables'},
                {'name': 'Osso Buco', 'category': 'Meat', 'price': 18.99, 'description': 'Braised veal shank'},
                {'name': 'Tiramisu', 'category': 'Desserts', 'price': 6.99, 'description': 'Classic Italian dessert'},
            ],
            'dragon-palace': [
                {'name': 'Spring Rolls', 'category': 'Starters', 'price': 6.99, 'description': 'Crispy vegetable spring rolls'},
                {'name': 'Hakka Noodles', 'category': 'Noodles', 'price': 9.99, 'description': 'Stir-fried noodles with vegetables'},
                {'name': 'Fried Rice', 'category': 'Fried Rice', 'price': 8.99, 'description': 'Egg fried rice with mixed vegetables'},
                {'name': 'Kung Pao Chicken', 'category': 'Main Course', 'price': 11.99, 'description': 'Chicken with peanuts in spicy sauce'},
                {'name': 'Hot & Sour Soup', 'category': 'Soup', 'price': 5.99, 'description': 'Tangy and spicy soup'},
            ],
            'continental-delights': [
                {'name': 'Caesar Salad', 'category': 'Salads', 'price': 9.99, 'description': 'Fresh romaine with parmesan'},
                {'name': 'Grilled Salmon', 'category': 'Main Courses', 'price': 19.99, 'description': 'Atlantic salmon with lemon butter'},
                {'name': 'Beef Steak', 'category': 'Main Courses', 'price': 24.99, 'description': 'Prime cut grilled to perfection'},
                {'name': 'Chocolate Lava Cake', 'category': 'Desserts', 'price': 7.99, 'description': 'Warm chocolate cake with molten center'},
                {'name': 'House Wine', 'category': 'Beverages', 'price': 6.99, 'description': 'Selection of fine wines'},
            ],
        }

        for slug, items in menu_items_data.items():
            restaurant = restaurants[slug]
            for item_data in items:
                category = Category.objects.get(
                    restaurant=restaurant,
                    name=item_data['category']
                )
                MenuItem.objects.get_or_create(
                    restaurant=restaurant,
                    name=item_data['name'],
                    defaults={
                        'category': category,
                        'base_price': item_data['price'],
                        'description': item_data['description'],
                        'is_available': True,
                    }
                )

        # Create or update landing page
        self.stdout.write('Creating/updating landing page...')
        landing_page, created = LandingPage.objects.get_or_create(
            is_active=True,
            defaults={
                'brand_name': 'BhansaGhar',
                'logo': '🍽️',
                'hero_title': 'Discover Amazing Food',
                'hero_subtitle': 'Order from your favorite restaurants with just a few clicks. Fast, fresh, and delicious meals delivered to your table.',
                'stat_2_value': '500+',
                'stat_2_label': 'Menu Items',
                'stat_3_value': '1000+',
                'stat_3_label': 'Happy Customers',
                'stat_4_value': '24/7',
                'stat_4_label': 'Service Available',
                'info_banner_icon': '🎉',
                'info_banner_text': '🎉 Welcome to BhansaGhar - Your favorite food delivery platform! Enjoy seamless ordering and authentic cuisine.',
                'features_subtitle': 'We bring together the finest restaurants and cutting-edge technology to deliver an exceptional dining experience.',
                'feature_1_icon': '⚡',
                'feature_1_title': 'Super Fast Delivery',
                'feature_1_description': 'Get your food delivered quickly to your table or location. Real-time tracking lets you know exactly when your order arrives.',
                'feature_2_icon': '🎯',
                'feature_2_title': 'Quality Assured',
                'feature_2_description': 'Only the best restaurants and freshest ingredients. Every dish is prepared with care and attention to detail.',
                'feature_3_icon': '💎',
                'feature_3_title': 'Easy to Use',
                'feature_3_description': 'Simple and intuitive interface for seamless ordering. Browse menus, customize your meal, and checkout in seconds.',
                'about_title': 'About Our Platform',
                'about_description': 'We\'re revolutionizing the restaurant industry by connecting food lovers with their favorite local restaurants through innovative technology. Our platform makes ordering, managing, and enjoying great food easier than ever before.',
                'about_description_2': 'Whether you\'re a restaurant owner looking to streamline operations or a customer seeking the perfect meal, we provide the tools and support to make it happen seamlessly.',
                'highlight_1': 'Trusted by Top Restaurants',
                'highlight_2': 'Real-time Order Tracking',
                'highlight_3': 'Secure Payments',
                'highlight_4': '24/7 Customer Support',
                'cta_title': 'Ready to Taste Something Amazing?',
                'cta_description': 'Browse through our collection of amazing restaurants and enjoy your favorite meals delivered fresh and hot.',
                'cta_button_text': 'Start Ordering Now',
                'footer_tagline': 'Your one-stop platform for discovering and ordering from the best restaurants in your area.',
                'footer_text': '© 2024 BhansaGhar. All rights reserved.',
            }
        )

        if created:
            self.stdout.write(self.style.SUCCESS('✓ Landing page created'))
        else:
            self.stdout.write(self.style.SUCCESS('✓ Landing page already exists'))

        self.stdout.write(self.style.SUCCESS('\n✅ Seeding completed successfully!'))
        self.stdout.write('\nSummary:')
        self.stdout.write(f'  • Restaurant Types: {len(restaurant_types)}')
        self.stdout.write(f'  • Restaurants: {len(restaurants)}')
        self.stdout.write(f'  • Menu Items: {MenuItem.objects.count()}')
        self.stdout.write(f'  • Landing Pages: {LandingPage.objects.count()}')
        self.stdout.write('\nTo view the landing page, visit: http://localhost:8000/')
        self.stdout.write('To manage content, visit: http://localhost:8000/admin/')
