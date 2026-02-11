#!/usr/bin/env python3
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'bhansaGhar_backend.settings')
django.setup()

from restaurants.models import Restaurant, Category, MenuItem
from customer.models import Testimonial, SocialMediaLink

def main():
    # Get the restaurant
    r = Restaurant.objects.filter(slug='bca-chaya-wala').first()
    if not r:
        print('Restaurant not found')
        return

    print(f'Found restaurant: {r.name}')

    # Create categories if they don't exist
    categories_data = [
        {'name': 'Tea & Beverages', 'description': 'Hot and cold beverages'},
        {'name': 'Snacks', 'description': 'Light snacks and appetizers'},
        {'name': 'Main Course', 'description': 'Main dishes'},
    ]

    categories = []
    for cat_data in categories_data:
        cat, created = Category.objects.get_or_create(
            restaurant=r,
            name=cat_data['name'],
            defaults={'description': cat_data['description'], 'is_active': True}
        )
        categories.append(cat)
        if created:
            print(f'Created category: {cat.name}')

    # Create menu items
    menu_items_data = [
        {'name': 'Masala Chai', 'description': 'Traditional spiced tea', 'price': 50, 'category': categories[0]},
        {'name': 'Black Tea', 'description': 'Classic black tea', 'price': 40, 'category': categories[0]},
        {'name': 'Green Tea', 'description': 'Healthy green tea', 'price': 45, 'category': categories[0]},
        {'name': 'Samosa', 'description': 'Crispy potato filled pastry', 'price': 30, 'category': categories[1]},
        {'name': 'Pakora', 'description': 'Vegetable fritters', 'price': 35, 'category': categories[1]},
        {'name': 'Chicken Momo', 'description': 'Steamed dumplings with chicken', 'price': 120, 'category': categories[2]},
        {'name': 'Veg Momo', 'description': 'Steamed vegetable dumplings', 'price': 100, 'category': categories[2]},
    ]

    for item_data in menu_items_data:
        item, created = MenuItem.objects.get_or_create(
            restaurant=r,
            name=item_data['name'],
            defaults={
                'description': item_data['description'],
                'base_price': item_data['price'],
                'category': item_data['category'],
                'is_active': True,
                'is_available': True
            }
        )
        if created:
            print(f'Created menu item: {item.name}')

    # Create testimonials
    testimonials_data = [
        {'author': 'Sarah Johnson', 'rating': 5, 'text': 'Amazing tea selection and the atmosphere is perfect for relaxation. The staff is very friendly!'},
        {'author': 'Rajesh Sharma', 'rating': 5, 'text': 'Best chai in Kathmandu! Authentic masala tea and delicious snacks.'},
        {'author': 'Priya Patel', 'rating': 4, 'text': 'Great place for a quick tea break. Clean, comfortable, excellent service.'},
    ]

    for i, test_data in enumerate(testimonials_data):
        testimonial, created = Testimonial.objects.get_or_create(
            restaurant=r,
            author_name=test_data['author'],
            defaults={
                'rating': test_data['rating'],
                'text': test_data['text'],
                'is_active': True,
                'order': i
            }
        )
        if created:
            print(f'Created testimonial: {testimonial.author_name}')

    # Create social media links
    social_data = [
        {'platform': 'facebook', 'icon': '📘', 'url': 'https://facebook.com/bcachayawala'},
        {'platform': 'instagram', 'icon': '📷', 'url': 'https://instagram.com/bcachayawala'},
        {'platform': 'twitter', 'icon': '🐦', 'url': 'https://twitter.com/bcachayawala'},
    ]

    for i, social in enumerate(social_data):
        link, created = SocialMediaLink.objects.get_or_create(
            platform=social['platform'],
            landing_page__isnull=True,
            defaults={
                'icon': social['icon'],
                'url': social['url'],
                'is_active': True,
                'order': i
            }
        )
        if created:
            print(f'Created social link: {link.platform}')

    print('\nData seeding completed!')
    print(f'Categories: {r.categories.count()}')
    print(f'Menu items: {r.menu_items.count()}')
    print(f'Testimonials: {r.testimonials.count()}')
    print(f'Social links: {SocialMediaLink.objects.filter(landing_page__isnull=True, is_active=True).count()}')

if __name__ == '__main__':
    main()
