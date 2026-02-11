"""
Seed command to populate the database with comprehensive test data
for visualizing the Super Admin Dashboard
"""
from datetime import datetime, timedelta
from decimal import Decimal
import random
from django.core.management.base import BaseCommand
from django.utils import timezone
from django.contrib.auth import get_user_model
from restaurants.models import Restaurant, RestaurantType, MenuItem, Table, Category
from orders.models import Order, OrderBargain
from invoices.models import Invoice

User = get_user_model()


class Command(BaseCommand):
    help = 'Seed database with comprehensive test data for dashboard visualization'

    def add_arguments(self, parser):
        parser.add_argument(
            '--clear',
            action='store_true',
            help='Clear existing data before seeding',
        )

    def handle(self, *args, **options):
        self.stdout.write(self.style.WARNING('🌱 Starting database seeding...'))
        
        if options['clear']:
            self.clear_data()
        
        # Create restaurant type first
        restaurant_type = self.create_restaurant_type()
        
        # Create restaurants
        restaurants = self.create_restaurants(restaurant_type)
        
        # Create categories
        categories = self.create_categories(restaurants)
        
        # Create menu items
        menu_items = self.create_menu_items(restaurants, categories)
        
        # Create tables
        tables = self.create_tables(restaurants)
        
        # Create staff users
        staff = self.create_staff(restaurants)
        
        # Create orders with various statuses
        orders = self.create_orders(restaurants, menu_items, tables, staff)
        
        # Create bargains
        self.create_bargains(orders)
        
        # Create invoices
        self.create_invoices(orders, restaurants)
        
        self.stdout.write(self.style.SUCCESS('✅ Database seeding completed successfully!'))
        self.print_summary(restaurants)

    def clear_data(self):
        self.stdout.write('🗑️  Clearing existing data...')
        OrderBargain.objects.all().delete()
        Invoice.objects.all().delete()
        Order.objects.all().delete()
        MenuItem.objects.all().delete()
        Category.objects.all().delete()
        Table.objects.all().delete()
        User.objects.filter(is_superuser=False).delete()
        Restaurant.objects.all().delete()
        self.stdout.write(self.style.SUCCESS('   Data cleared!'))

    def create_restaurant_type(self):
        self.stdout.write('🏷️  Creating restaurant type...')
        restaurant_type, created = RestaurantType.objects.get_or_create(
            name='fine_dining',
            defaults={
                'display_name': 'Fine Dining',
                'is_active': True,
            }
        )
        if created:
            self.stdout.write(f'   ✓ Created restaurant type: {restaurant_type.display_name}')
        else:
            self.stdout.write(f'   ✓ Using existing restaurant type: {restaurant_type.display_name}')
        return restaurant_type

    def create_restaurants(self, restaurant_type):
        import random
        self.stdout.write('🏪 Creating restaurants...')
        
        restaurants_data = [
            {
                'name': 'Sperium Downtown',
                'address': '123 Main Street, Kathmandu',
                'phone': '+977-1-4567890',
                'tables_capacity': 25,
                'latitude': 27.7172,
                'longitude': 85.3240,
                'description': 'Premium fine dining in the heart of Kathmandu',
            },
            {
                'name': 'Sperium Lakeside',
                'address': '456 Lakeside Road, Pokhara',
                'phone': '+977-61-456789',
                'tables_capacity': 20,
                'latitude': 28.2096,
                'longitude': 83.9856,
                'description': 'Beautiful lakeside dining experience',
            },
        ]
        
        restaurants = []
        for i, data in enumerate(restaurants_data):
            # Create owner for each restaurant
            owner, owner_created = User.objects.get_or_create(
                email=f'owner{i+1}@sperium.com',
                defaults={
                    'username': f'owner_{i+1}',
                    'first_name': f'Owner{i+1}',
                    'last_name': 'Manager',
                    'role': 'admin',
                    'is_staff': True,
                    'is_active': True,
                }
            )
            if owner_created:
                owner.set_password('password123')
                owner.save()
            
            # Check if restaurant already exists for this owner
            try:
                restaurant = Restaurant.objects.get(owner=owner)
                self.stdout.write(f'   ✓ Using existing: {restaurant.name}')
            except Restaurant.DoesNotExist:
                restaurant = Restaurant.objects.create(
                    name=data['name'],
                    address=data['address'],
                    phone=data['phone'],
                    tables_capacity=data['tables_capacity'],
                    owner=owner,
                    type=restaurant_type,
                    latitude=data['latitude'],
                    longitude=data['longitude'],
                    description=data['description'],
                    is_active=True,
                )
                self.stdout.write(f'   ✓ Created: {restaurant.name}')
            
            restaurants.append(restaurant)
        
        return restaurants

    def create_categories(self, restaurants):
        self.stdout.write('📁 Creating categories...')
        
        category_names = [
            ('Appetizers', '🥗'),
            ('Main Course', '🍛'),
            ('Nepali Specials', '🇳🇵'),
            ('Chinese', '🥡'),
            ('Indian', '🍛'),
            ('Beverages', '🥤'),
            ('Desserts', '🍰'),
            ('Fast Food', '🍔'),
        ]
        
        categories = {}
        for restaurant in restaurants:
            categories[restaurant.id] = []
            for position, (name, emoji) in enumerate(category_names):
                category, created = Category.objects.get_or_create(
                    name=f'{emoji} {name}',
                    restaurant=restaurant,
                    defaults={
                        'position': position,
                    }
                )
                categories[restaurant.id].append(category)
        
        self.stdout.write(f'   ✓ Created {len(category_names)} categories per restaurant')
        return categories

    def create_menu_items(self, restaurants, categories):
        self.stdout.write('🍽️  Creating menu items...')
        
        menu_data = {
            'Appetizers': [
                ('Momo (Veg)', 180, 'Steamed vegetable dumplings'),
                ('Momo (Chicken)', 220, 'Steamed chicken dumplings'),
                ('Spring Rolls', 150, 'Crispy vegetable spring rolls'),
                ('Samosa', 80, 'Spiced potato triangles'),
                ('Chicken Wings', 350, 'Spicy grilled wings'),
            ],
            'Main Course': [
                ('Butter Chicken', 450, 'Creamy tomato chicken curry'),
                ('Paneer Tikka Masala', 380, 'Cottage cheese in spiced gravy'),
                ('Grilled Fish', 550, 'Fresh fish with herbs'),
                ('Mutton Curry', 520, 'Traditional mutton curry'),
                ('Mixed Grill Platter', 850, 'Assorted grilled meats'),
            ],
            'Nepali Specials': [
                ('Dal Bhat Set', 350, 'Traditional Nepali meal'),
                ('Thukpa', 200, 'Nepali noodle soup'),
                ('Sekuwa', 400, 'Grilled meat skewers'),
                ('Choila', 320, 'Spiced grilled meat'),
                ('Sel Roti', 120, 'Nepali rice donut'),
            ],
            'Chinese': [
                ('Chow Mein', 180, 'Stir-fried noodles'),
                ('Fried Rice', 200, 'Wok-fried rice'),
                ('Manchurian', 250, 'Spicy vegetable balls'),
                ('Hot & Sour Soup', 150, 'Tangy soup'),
                ('Kung Pao Chicken', 380, 'Spicy peanut chicken'),
            ],
            'Beverages': [
                ('Fresh Lime Soda', 80, 'Refreshing lime drink'),
                ('Mango Lassi', 120, 'Sweet mango yogurt'),
                ('Masala Tea', 50, 'Spiced milk tea'),
                ('Cold Coffee', 150, 'Iced coffee'),
                ('Fresh Juice', 100, 'Seasonal fruit juice'),
            ],
            'Desserts': [
                ('Gulab Jamun', 120, 'Sweet milk balls'),
                ('Kheer', 100, 'Rice pudding'),
                ('Ice Cream', 150, 'Assorted flavors'),
                ('Jalebi', 80, 'Sweet spiral'),
                ('Rasgulla', 100, 'Sweet cheese balls'),
            ],
        }
        
        all_items = {}
        for restaurant in restaurants:
            all_items[restaurant.id] = []
            for cat in categories[restaurant.id]:
                cat_name = cat.name.split(' ', 1)[1] if ' ' in cat.name else cat.name
                if cat_name in menu_data:
                    for position, (item_name, price, desc) in enumerate(menu_data[cat_name]):
                        item, created = MenuItem.objects.get_or_create(
                            name=item_name,
                            restaurant=restaurant,
                            category=cat,
                            defaults={
                                'description': desc,
                                'base_price': Decimal(str(price)),
                                'position': position,
                            }
                        )
                        all_items[restaurant.id].append(item)
        
        total_items = sum(len(items) for items in all_items.values())
        self.stdout.write(f'   ✓ Created {total_items} menu items')
        return all_items

    def create_tables(self, restaurants):
        self.stdout.write('🪑 Creating tables...')
        
        tables = {}
        for restaurant in restaurants:
            tables[restaurant.id] = []
            for i in range(restaurant.tables_capacity):
                # Check if table already exists
                table, created = Table.objects.get_or_create(
                    restaurant=restaurant,
                    number=i+1,
                    defaults={
                        'capacity': random.choice([2, 4, 4, 6, 8]),
                        'status': random.choice(['available', 'occupied', 'available', 'available']),
                    }
                )
                tables[restaurant.id].append(table)
        
        total_tables = sum(len(t) for t in tables.values())
        self.stdout.write(f'   ✓ Created {total_tables} tables')
        return tables

    def create_staff(self, restaurants):
        self.stdout.write('👥 Creating staff members...')
        
        staff_roles = [
            ('waiter', 4),
            ('kitchen', 3),
        ]
        
        staff = {}
        for idx, restaurant in enumerate(restaurants):
            staff[restaurant.id] = {'waiters': [], 'kitchen': []}
            for role, count in staff_roles:
                for i in range(count):
                    username = f'{role}{i+1}_r{idx+1}'
                    user, created = User.objects.get_or_create(
                        email=f'{username}@sperium.com',
                        defaults={
                            'username': username,
                            'first_name': f'{role.capitalize()}{i+1}',
                            'last_name': restaurant.name.split()[1] if len(restaurant.name.split()) > 1 else 'Staff',
                            'role': role,
                            'restaurant': restaurant,
                            'is_active': True,
                        }
                    )
                    if created:
                        user.set_password('password123')
                        user.save()
                    
                    if role == 'waiter':
                        staff[restaurant.id]['waiters'].append(user)
                    elif role == 'kitchen':
                        staff[restaurant.id]['kitchen'].append(user)
        
        total_staff = sum(len(s['waiters']) + len(s['kitchen']) for s in staff.values())
        self.stdout.write(f'   ✓ Created {total_staff} staff members')
        return staff

    def create_orders(self, restaurants, menu_items, tables, staff):
        self.stdout.write('📋 Creating orders...')
        
        statuses = ['pending', 'preparing', 'ready', 'served', 'served', 'served', 'cancelled']
        orders = {}
        
        for restaurant in restaurants:
            orders[restaurant.id] = []
            r_items = menu_items[restaurant.id]
            r_tables = tables[restaurant.id]
            r_staff = staff[restaurant.id]
            
            # Create orders for last 30 days
            for days_ago in range(30):
                date = timezone.now() - timedelta(days=days_ago)
                
                # More orders on weekends, fewer on weekdays
                if date.weekday() >= 5:  # Weekend
                    num_orders = random.randint(15, 30)
                else:
                    num_orders = random.randint(8, 20)
                
                # Even more orders today
                if days_ago == 0:
                    num_orders = random.randint(20, 35)
                
                for order_num in range(num_orders):
                    # Random time during the day (10 AM - 10 PM)
                    hour = random.randint(10, 22)
                    minute = random.randint(0, 59)
                    order_time = date.replace(hour=hour, minute=minute, second=0, microsecond=0)
                    
                    # Select random items
                    num_items = random.randint(1, 5)
                    selected_items = random.sample(r_items, min(num_items, len(r_items)))
                    
                    items_data = []
                    subtotal = Decimal('0')
                    for item in selected_items:
                        qty = random.randint(1, 3)
                        items_data.append({
                            'item_id': str(item.id),
                            'name': item.name,
                            'price': float(item.base_price),
                            'qty': qty,
                        })
                        subtotal += item.base_price * qty
                    
                    # Determine status based on time
                    if days_ago == 0 and hour >= 18:
                        status = random.choice(['pending', 'preparing', 'ready', 'bargain'])
                    elif days_ago == 0:
                        status = random.choice(['pending', 'preparing', 'ready', 'served', 'served'])
                    else:
                        status = random.choice(statuses)
                    
                    table = random.choice(r_tables)
                    waiter = random.choice(r_staff['waiters']) if r_staff['waiters'] else None
                    kitchen_staff_list = random.sample(r_staff['kitchen'], min(2, len(r_staff['kitchen']))) if r_staff['kitchen'] else []
                    
                    order = Order.objects.create(
                        restaurant=restaurant,
                        table_number=table.number,
                        session_id=f'session_{restaurant.id}_{days_ago}_{order_num}',
                        items=items_data,
                        subtotal=subtotal,
                        status=status,
                        assigned_waiter=waiter,
                        customer_notes=random.choice(['', '', '', 'Extra spicy please', 'No onions', 'Less salt']),
                    )
                    
                    # Add kitchen staff (ManyToMany)
                    if kitchen_staff_list:
                        order.assigned_kitchen_staff.set(kitchen_staff_list)
                    
                    # Update created_at to match the intended date
                    Order.objects.filter(id=order.id).update(created_at=order_time)
                    order.refresh_from_db()
                    
                    orders[restaurant.id].append(order)
        
        total_orders = sum(len(o) for o in orders.values())
        self.stdout.write(f'   ✓ Created {total_orders} orders')
        return orders

    def create_bargains(self, orders):
        self.stdout.write('🤝 Creating bargain requests...')
        
        count = 0
        for restaurant_id, restaurant_orders in orders.items():
            for order in restaurant_orders:
                # 15% of orders have bargain requests
                if random.random() < 0.15 and order.items:
                    status = random.choice(['pending', 'accepted', 'accepted', 'rejected'])
                    
                    # Get first item from the order
                    first_item = order.items[0]
                    
                    OrderBargain.objects.create(
                        order=order,
                        item_id=1,  # Placeholder item ID
                        customer_qty=random.randint(2, 5),
                        kitchen_qty=random.randint(1, 3),
                        kitchen_message=random.choice([
                            'Only this quantity available',
                            'Limited stock today',
                            'This is what we have',
                        ]),
                        status=status,
                        customer_response=random.choice([
                            'OK, I accept',
                            'That works for me',
                            '',
                        ]) if status == 'accepted' else '',
                    )
                    count += 1
        
        self.stdout.write(f'   ✓ Created {count} bargain requests')

    def create_invoices(self, orders, restaurants):
        self.stdout.write('💰 Creating invoices...')
        
        count = 0
        for restaurant in restaurants:
            for order in orders[restaurant.id]:
                if order.status == 'served':
                    # 80% of served orders have invoices
                    if random.random() < 0.8:
                        tax = order.subtotal * Decimal('0.13')
                        total = order.subtotal + tax
                        
                        Invoice.objects.create(
                            restaurant=restaurant,
                            table_number=order.table_number,
                            items=[{
                                'order_id': str(order.id),
                                'items': order.items,
                                'price': float(order.subtotal),
                            }],
                            subtotal=order.subtotal,
                            tax=tax,
                            total=total,
                            status='paid',
                            paid_at=order.created_at + timedelta(hours=1),
                        )
                        count += 1
        
        self.stdout.write(f'   ✓ Created {count} invoices')

    def print_summary(self, restaurants):
        self.stdout.write('\n' + '='*50)
        self.stdout.write(self.style.SUCCESS('📊 SEEDING SUMMARY'))
        self.stdout.write('='*50)
        
        for restaurant in restaurants:
            self.stdout.write(f'\n🏪 {restaurant.name}:')
            self.stdout.write(f'   • Tables: {Table.objects.filter(restaurant=restaurant).count()}')
            self.stdout.write(f'   • Menu Items: {MenuItem.objects.filter(restaurant=restaurant).count()}')
            self.stdout.write(f'   • Staff: {User.objects.filter(restaurant=restaurant).count()}')
            self.stdout.write(f'   • Orders: {Order.objects.filter(restaurant=restaurant).count()}')
            self.stdout.write(f'   • Invoices: {Invoice.objects.filter(restaurant=restaurant).count()}')
        
        self.stdout.write(f'\n📈 Total Statistics:')
        self.stdout.write(f'   • Restaurants: {Restaurant.objects.count()}')
        self.stdout.write(f'   • Total Orders: {Order.objects.count()}')
        self.stdout.write(f'   • Bargain Requests: {OrderBargain.objects.count()}')
        self.stdout.write(f'   • Active Orders: {Order.objects.filter(status__in=["pending", "preparing", "ready"]).count()}')
        
        self.stdout.write('\n' + '='*50)
        self.stdout.write(self.style.SUCCESS('🎉 Ready to test the dashboard!'))
        self.stdout.write('   Visit: http://localhost:8000/admin/')
        self.stdout.write('='*50 + '\n')
