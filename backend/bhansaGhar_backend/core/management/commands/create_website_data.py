from django.core.management.base import BaseCommand
from restaurants.models import Restaurant
from core.models import WebsiteData

class Command(BaseCommand):
    help = 'Create WebsiteData objects for all restaurants that don\'t have one'

    def handle(self, *args, **options):
        restaurants = Restaurant.objects.all()
        created_count = 0
        existing_count = 0

        for restaurant in restaurants:
            website_data, created = WebsiteData.objects.get_or_create(
                restaurant=restaurant,
                defaults={
                    'website_title': restaurant.name,
                    'website_description': restaurant.description or f'Welcome to {restaurant.name}',
                    'contact_phone': restaurant.phone,
                    'contact_email': restaurant.owner.email if restaurant.owner else None,
                    'hero_title': f'Welcome to {restaurant.name}',
                    'hero_subtitle': restaurant.description or 'Delicious food served fresh',
                    'about_title': 'About Us',
                    'about_content': restaurant.about or f'Welcome to {restaurant.name}. We serve delicious food with passion and dedication.',
                    'footer_text': f'© {restaurant.name}. All rights reserved.',
                }
            )

            if created:
                created_count += 1
                self.stdout.write(f'✓ Created WebsiteData for: {restaurant.name}')
            else:
                existing_count += 1
                self.stdout.write(f'ℹ️ WebsiteData already exists for: {restaurant.name}')

        total = WebsiteData.objects.count()
        self.stdout.write(
            self.style.SUCCESS(
                f'\n📊 Summary:\n'
                f'  Created: {created_count}\n'
                f'  Existing: {existing_count}\n'
                f'  Total WebsiteData objects: {total}'
            )
        )
