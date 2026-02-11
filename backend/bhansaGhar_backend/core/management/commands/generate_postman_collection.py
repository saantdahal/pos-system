"""
Django management command to generate Postman collection
Usage: python manage.py generate_postman_collection
"""

from django.core.management.base import BaseCommand, CommandError
from core.services.postman_generator import create_postman_collection


class Command(BaseCommand):
    help = 'Generate Postman API collection for BhansaGhar Backend'

    def add_arguments(self, parser):
        parser.add_argument(
            '--output',
            type=str,
            default='postman_collection.json',
            help='Output file path for the Postman collection',
        )

    def handle(self, *args, **options):
        try:
            collection_path = create_postman_collection()
            self.stdout.write(
                self.style.SUCCESS(
                    f'✓ Postman collection generated successfully!\n'
                    f'  Location: {collection_path}\n'
                    f'  Import this file in Postman to test all API endpoints'
                )
            )
        except Exception as e:
            raise CommandError(
                self.style.ERROR(f'✗ Failed to generate Postman collection: {str(e)}')
            )
