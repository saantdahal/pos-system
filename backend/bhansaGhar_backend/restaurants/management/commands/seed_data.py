"""
Management command to seed fake test data for the restaurant application
Usage: python manage.py seed_data
"""

from django.core.management.base import BaseCommand
from django.utils.text import slugify
from restaurants.models import Restaurant, Category, MenuItem, Table, RestaurantType
from core.models import User
from django.db import transaction


class Command(BaseCommand):
    help = 'Seed the database with fake test data for restaurants, menus, and tables'

    def add_arguments(self, parser):
        parser.add_argument(
            '--flush',
            action='store_true',
            help='Delete existing data before seeding',
        )

    @transaction.atomic
    def handle(self, *args, **options):
        if options['flush']:
            self.stdout.write(self.style.WARNING('Deleting existing data...'))
            Restaurant.objects.all().delete()
            User.objects.filter(email__contains='@test.com').delete()
            self.stdout.write(self.style.SUCCESS('✓ Data cleared'))

        self.stdout.write(self.style.SUCCESS('🌱 Seeding test data...'))

        # Get or create default restaurant type
        rest_type, _ = RestaurantType.objects.get_or_create(
            name='Restaurant',
            defaults={'is_active': True}
        )

        # Create test users (restaurant owners)
        owner_emails = [
            'bhol-owner@test.com',
            'bca-owner@test.com',
            'chaiwala-owner@test.com',
        ]
        
        owners = {}
        for email in owner_emails:
            user, _ = User.objects.get_or_create(
                email=email,
                defaults={
                    'username': email.split('@')[0],
                    'is_staff': True,
                    'is_active': True,
                }
            )
            owners[email] = user

        # Create 3 test restaurants with coordinates for Kathmandu
        restaurants_data = [
            {
                'name': 'Bhol Momo House',
                'owner_email': 'bhol-owner@test.com',
                'description': 'Authentic Nepali momos and dumplings',
                'about': 'We serve the best steamed and fried momos made with traditional recipes passed down through generations. Our ingredients are fresh and sourced locally.',
                'address': 'Thamel, Kathmandu',
                'phone': '9841234567',
                'latitude': 27.7172,
                'longitude': 85.3240,
                'is_active': True,
            },
            {
                'name': 'BCA Chaya Wala',
                'owner_email': 'bca-owner@test.com',
                'description': 'Premium tea and local snacks',
                'about': 'Experience the finest tea selection from around the world. Enjoy our traditional Nepali tea (chiya) and fresh snacks in a cozy atmosphere.',
                'address': 'Patan Dhoka, Kathmandu',
                'phone': '9842345678',
                'latitude': 27.6761,
                'longitude': 85.3128,
                'operating_hours': {
                    'Monday': '7:00 AM - 8:00 PM',
                    'Tuesday': '7:00 AM - 8:00 PM',
                    'Wednesday': '7:00 AM - 8:00 PM',
                    'Thursday': '7:00 AM - 8:00 PM',
                    'Friday': '7:00 AM - 9:00 PM',
                    'Saturday': '8:00 AM - 9:00 PM',
                    'Sunday': '9:00 AM - 7:00 PM'
                },
                'is_active': True,
            },
            {
                'name': 'Chaiwala Express',
                'owner_email': 'chaiwala-owner@test.com',
                'description': 'Quick bites and hot beverages',
                'about': 'Fast and friendly service with delicious coffee, tea, and light snacks perfect for your busy day.',
                'address': 'Baneshwor, Kathmandu',
                'phone': '9843456789',
                'latitude': 27.7245,
                'longitude': 85.3505,
                'is_active': True,
            },
        ]

        restaurants = {}
        for rest_data in restaurants_data:
            owner = owners[rest_data['owner_email']]
            rest, created = Restaurant.objects.get_or_create(
                slug=slugify(rest_data['name']),
                defaults={
                    'name': rest_data['name'],
                    'owner': owner,
                    'type': rest_type,
                    'description': rest_data['description'],
                    'about': rest_data['about'],
                    'address': rest_data['address'],
                    'phone': rest_data['phone'],
                    'latitude': rest_data['latitude'],
                    'longitude': rest_data['longitude'],
                    'operating_hours': rest_data.get('operating_hours'),
                    'is_active': rest_data['is_active'],
                }
            )
            restaurants[rest_data['name']] = rest
            status = '✓ Created' if created else '✓ Exists'
            self.stdout.write(f"  {status}: {rest.name}")

        # Create menus for each restaurant
        menus = {
            'Bhol Momo House': {
                'Momos': [
                    {'name': 'Vegetable Momo', 'description': 'Fresh mixed vegetables', 'price': 150},
                    {'name': 'Chicken Momo', 'description': 'Tender chicken filling', 'price': 200},
                    {'name': 'Meat Momo', 'description': 'Spiced ground meat', 'price': 250},
                    {'name': 'Paneer Momo', 'description': 'Soft cottage cheese', 'price': 180},
                ],
                'Beverages': [
                    {'name': 'Nepali Tea', 'description': 'Traditional masala tea', 'price': 80},
                    {'name': 'Fresh Juice', 'description': 'Seasonal fresh juice', 'price': 120},
                    {'name': 'Soft Drink', 'description': 'Cold beverages', 'price': 100},
                ],
            },
            'BCA Chaya Wala': {
                'Tea': [
                    {'name': 'Black Tea', 'description': 'Premium black tea', 'price': 100},
                    {'name': 'Green Tea', 'description': 'Organic green tea', 'price': 120},
                    {'name': 'Herbal Tea', 'description': 'Mixed herbal blend', 'price': 130},
                    {'name': 'Masala Tea', 'description': 'Spiced Indian tea', 'price': 90},
                ],
                'Snacks': [
                    {'name': 'Samosa', 'description': 'Crispy potato pastry', 'price': 60},
                    {'name': 'Pakora', 'description': 'Fried vegetable bites', 'price': 80},
                    {'name': 'Biscuit', 'description': 'Assorted biscuits', 'price': 50},
                ],
                'Coffee': [
                    {'name': 'Espresso', 'description': 'Strong espresso shot', 'price': 150},
                    {'name': 'Cappuccino', 'description': 'Creamy cappuccino', 'price': 180},
                    {'name': 'Latte', 'description': 'Smooth milk latte', 'price': 170},
                ],
            },
            'Chaiwala Express': {
                'Hot Beverages': [
                    {'name': 'Coffee', 'description': 'Fresh brewed coffee', 'price': 120},
                    {'name': 'Tea', 'description': 'Hot tea', 'price': 80},
                    {'name': 'Hot Chocolate', 'description': 'Rich hot chocolate', 'price': 140},
                ],
                'Quick Bites': [
                    {'name': 'Toast', 'description': 'Buttered bread toast', 'price': 70},
                    {'name': 'Sandwich', 'description': 'Vegetable or cheese sandwich', 'price': 150},
                    {'name': 'Egg Fried Rice', 'description': 'Quick fried rice', 'price': 200},
                    {'name': 'Noodles', 'description': 'Stir-fried noodles', 'price': 180},
                ],
                'Cold Drinks': [
                    {'name': 'Cold Coffee', 'description': 'Iced coffee beverage', 'price': 140},
                    {'name': 'Iced Tea', 'description': 'Chilled tea', 'price': 100},
                    {'name': 'Smoothie', 'description': 'Fresh fruit smoothie', 'price': 160},
                ],
            },
        }

        # Create categories and menu items
        for restaurant_name, categories_data in menus.items():
            restaurant = restaurants[restaurant_name]
            for category_name, items_data in categories_data.items():
                category, created = Category.objects.get_or_create(
                    restaurant=restaurant,
                    name=category_name,
                    defaults={'position': 0}
                )
                
                for item_data in items_data:
                    menu_item, created = MenuItem.objects.get_or_create(
                        restaurant=restaurant,
                        category=category,
                        name=item_data['name'],
                        defaults={
                            'description': item_data['description'],
                            'base_price': item_data['price'],
                        }
                    )
                    if created:
                        self.stdout.write(f"    ✓ Added: {menu_item.name}")

        # Create tables for each restaurant
        tables_per_restaurant = {
            'Bhol Momo House': 12,
            'BCA Chaya Wala': 8,
            'Chaiwala Express': 6,
        }

        for restaurant_name, table_count in tables_per_restaurant.items():
            restaurant = restaurants[restaurant_name]
            for table_num in range(1, table_count + 1):
                table, created = Table.objects.get_or_create(
                    restaurant=restaurant,
                    number=table_num,
                    defaults={
                        'capacity': 4 if table_num <= 8 else 6,
                        'status': 'available',
                        'is_active': True,
                    }
                )
                if created:
                    self.stdout.write(f"    ✓ Table {table_num} created")

        # Summary
        self.stdout.write(self.style.SUCCESS('\n✅ Database seeding complete!\n'))
        
        total_restaurants = Restaurant.objects.filter(is_active=True).count()
        total_categories = Category.objects.count()
        total_items = MenuItem.objects.count()
        total_tables = Table.objects.count()
        
        self.stdout.write(self.style.SUCCESS(f"""
📊 Data Summary:
   🏢 Restaurants: {total_restaurants}
   📂 Categories: {total_categories}
   🍽️  Menu Items: {total_items}
   🪑 Tables: {total_tables}
        
🌐 Access the application:
   Homepage: http://localhost:8000/
   Restaurants: http://localhost:8000/restaurants/
        """))
