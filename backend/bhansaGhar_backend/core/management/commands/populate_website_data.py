from django.core.management.base import BaseCommand
from core.models import WebsiteData

class Command(BaseCommand):
    help = 'Populate existing WebsiteData objects with restaurant information'

    def handle(self, *args, **options):
        website_data_objects = WebsiteData.objects.all()
        updated_count = 0

        for website_data in website_data_objects:
            restaurant = website_data.restaurant

            # Only update if fields are empty
            if not website_data.website_title:
                website_data.website_title = restaurant.name
                updated_count += 1

            if not website_data.website_description:
                website_data.website_description = restaurant.description or f"Welcome to {restaurant.name}"
                updated_count += 1

            if not website_data.contact_phone:
                website_data.contact_phone = restaurant.phone
                updated_count += 1

            if not website_data.contact_email:
                website_data.contact_email = restaurant.owner.email if restaurant.owner.email else None
                updated_count += 1

            if not website_data.hero_title:
                website_data.hero_title = f"Welcome to {restaurant.name}"
                updated_count += 1

            if not website_data.hero_subtitle:
                website_data.hero_subtitle = restaurant.description or "Delicious food served fresh"
                updated_count += 1

            if not website_data.about_title:
                website_data.about_title = "About Us"
                updated_count += 1

            if not website_data.about_content:
                website_data.about_content = restaurant.about or f"Welcome to {restaurant.name}. We serve delicious food with passion and dedication."
                updated_count += 1

            if not website_data.footer_text:
                website_data.footer_text = f"© {restaurant.name}. All rights reserved."
                updated_count += 1

            website_data.save()

        self.stdout.write(
            self.style.SUCCESS(f'Successfully updated {updated_count} fields in {website_data_objects.count()} WebsiteData objects')
        )
