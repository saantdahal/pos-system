from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from restaurants.models import Restaurant, RestaurantType, Category, MenuItem, Table
from orders.models import Order, OrderItem
import uuid

User = get_user_model()

class Command(BaseCommand):
    help = 'Create sample data for testing the customer interface'

    def handle(self, *args, **options):
        self.stdout.write('Creating sample data...')

        # Create restaurant type
        restaurant_type, created = RestaurantType.objects.get_or_create(
            name='cafe',
            defaults={'display_name': 'Café'}
        )

        # Create user (restaurant owner)
        user, created = User.objects.get_or_create(
            username='testowner',
            defaults={
                'email': 'owner@test.com',
                'first_name': 'Test',
                'last_name': 'Owner',
                'restaurant_name': 'Sperium Lounge'
            }
        )

        # Create restaurant
        restaurant, created = Restaurant.objects.get_or_create(
            owner=user,
            defaults={
                'name': 'Sperium Lounge',
                'type': restaurant_type,
                'address': '123 Test Street, Test City',
                'latitude': 27.7172,
                'longitude': 85.3240,
                'phone': '+977-1234567890',
                'description': 'A cozy café serving delicious food and beverages',
                'tables_capacity': 20,
                'is_active': True
            }
        )

        # Create categories
        categories_data = [
            {'name': 'Coffee', 'position': 1},
            {'name': 'Tea', 'position': 2},
            {'name': 'Food', 'position': 3},
            {'name': 'Desserts', 'position': 4},
        ]

        categories = {}
        for cat_data in categories_data:
            category, created = Category.objects.get_or_create(
                restaurant=restaurant,
                name=cat_data['name'],
                defaults={'position': cat_data['position']}
            )
            categories[cat_data['name']] = category

        # Create menu items
        menu_items_data = [
            {'name': 'Espresso', 'category': 'Coffee', 'price': 150.00, 'description': 'Strong and bold espresso shot'},
            {'name': 'Cappuccino', 'category': 'Coffee', 'price': 200.00, 'description': 'Creamy cappuccino with latte art'},
            {'name': 'Green Tea', 'category': 'Tea', 'price': 120.00, 'description': 'Fresh green tea leaves infusion'},
            {'name': 'Black Tea', 'category': 'Tea', 'price': 100.00, 'description': 'Classic black tea'},
            {'name': 'Club Sandwich', 'category': 'Food', 'price': 350.00, 'description': 'Triple layer sandwich with fries'},
            {'name': 'Caesar Salad', 'category': 'Food', 'price': 280.00, 'description': 'Fresh salad with caesar dressing'},
            {'name': 'Chocolate Cake', 'category': 'Desserts', 'price': 250.00, 'description': 'Rich chocolate cake'},
            {'name': 'Ice Cream', 'category': 'Desserts', 'price': 180.00, 'description': 'Vanilla ice cream scoop'},
        ]

        for item_data in menu_items_data:
            MenuItem.objects.get_or_create(
                restaurant=restaurant,
                category=categories[item_data['category']],
                name=item_data['name'],
                defaults={
                    'description': item_data['description'],
                    'base_price': item_data['price'],
                    'stock_quantity': None,  # Unlimited
                    'position': 0
                }
            )

        # Create tables (commented out due to QR code generation issue)
        # for i in range(1, 6):  # Tables 1-5
        #     table, created = Table.objects.get_or_create(
        #         restaurant=restaurant,
        #         number=i,
        #         defaults={
        #             'capacity': 4,
        #             'status': 'available',
        #             'is_active': True
        #         }
        #     )

        self.stdout.write(self.style.SUCCESS('Sample data created successfully!'))
        self.stdout.write(f'Restaurant: {restaurant.name}')
        # self.stdout.write(f'Tables: {restaurant.tables.count()}')
        self.stdout.write(f'Categories: {restaurant.categories.count()}')
        self.stdout.write(f'Menu Items: {restaurant.menu_items.count()}')
