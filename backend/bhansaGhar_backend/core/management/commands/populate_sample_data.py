from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from django.utils import timezone
from decimal import Decimal
import random
from datetime import timedelta

from restaurants.models import Restaurant, MenuItem, RestaurantType, Category
from orders.models import Order
from core.models import User

User = get_user_model()

class Command(BaseCommand):
    help = 'Populate database with sample data for testing'

    def handle(self, *args, **options):
        self.stdout.write('Creating sample data...')

        # Create superuser if not exists
        if not User.objects.filter(username='admin').exists():
            User.objects.create_superuser('admin', 'admin@example.com', 'admin123')

        # Create sample users
        users = []
        for i in range(5):
            user, created = User.objects.get_or_create(
                username=f'user{i+1}',
                defaults={
                    'email': f'user{i+1}@example.com',
                    'first_name': f'User{i+1}',
                    'last_name': 'Test',
                    'is_active': True
                }
            )
            users.append(user)

        # Create restaurant types
        restaurant_types = []
        type_data = [
            {'name': 'fine_dining', 'display_name': 'Fine Dining'},
            {'name': 'casual', 'display_name': 'Casual Dining'},
            {'name': 'fast_food', 'display_name': 'Fast Food'},
            {'name': 'cafe', 'display_name': 'Cafe'}
        ]
        for data in type_data:
            rtype, created = RestaurantType.objects.get_or_create(
                name=data['name'],
                defaults={
                    'display_name': data['display_name'],
                    'is_active': True
                }
            )
            restaurant_types.append(rtype)

        # Create restaurants
        restaurants = []
        restaurant_names = ['Spice Garden', 'Ocean View', 'Mountain Grill', 'Urban Cafe', 'Royal Palace']
        for i, name in enumerate(restaurant_names):
            restaurant, created = Restaurant.objects.get_or_create(
                name=name,
                defaults={
                    'owner': users[i % len(users)],
                    'type': restaurant_types[i % len(restaurant_types)],
                    'address': f'123 {name} Street',
                    'latitude': 27.7172 + random.uniform(-0.1, 0.1),
                    'longitude': 85.3240 + random.uniform(-0.1, 0.1),
                    'phone': f'+977{i}23456789',
                    'description': f'Authentic cuisine at {name}',
                    'tables_capacity': random.randint(10, 30),
                    'is_active': True
                }
            )
            restaurants.append(restaurant)

        # Create menu items - simplified
        menu_items = []
        for restaurant in restaurants:
            # Create a simple category
            category, created = Category.objects.get_or_create(
                name='Main Course',
                restaurant=restaurant,
                defaults={'position': 1}
            )
            item, created = MenuItem.objects.get_or_create(
                name='Sample Dish',
                restaurant=restaurant,
                defaults={
                    'category': category,
                    'description': 'Sample menu item',
                    'base_price': Decimal('100.00'),
                    'stock_quantity': 100
                }
            )
            menu_items.append(item)

        # Create orders
        statuses = ['pending', 'preparing', 'ready', 'served', 'cancelled']
        for i in range(50):
            restaurant = random.choice(restaurants)
            order = Order.objects.create(
                restaurant=restaurant,
                table_number=random.randint(1, restaurant.tables_capacity),
                session_id=f'session_{i}',
                status=random.choice(statuses),
                items=[
                    {
                        'item_id': str(random.choice(menu_items).id),
                        'qty': random.randint(1, 3),
                        'price': float(Decimal(str(random.uniform(10, 50))))
                    } for _ in range(random.randint(1, 4))
                ],
                subtotal=Decimal(str(random.uniform(50, 200))),
                customer_notes='Sample order',
                created_at=timezone.now() - timedelta(days=random.randint(0, 30))
            )

        self.stdout.write(self.style.SUCCESS('Sample data created successfully!'))
        self.stdout.write(f'Created {len(restaurants)} restaurants, {len(menu_items)} menu items, and 50 orders.')
