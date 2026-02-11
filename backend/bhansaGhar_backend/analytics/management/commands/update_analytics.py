from django.core.management.base import BaseCommand, CommandError
from django.utils import timezone
from restaurants.models import Restaurant
from analytics.services import AnalyticsService
from datetime import timedelta
import logging

logger = logging.getLogger(__name__)


class Command(BaseCommand):
    help = 'Generate or update analytics for restaurants'

    def add_arguments(self, parser):
        parser.add_argument(
            '--days',
            type=int,
            default=1,
            help='Number of days to regenerate analytics for (default: 1)',
        )
        parser.add_argument(
            '--restaurant',
            type=str,
            help='Specific restaurant ID to update (optional)',
        )
        parser.add_argument(
            '--all',
            action='store_true',
            help='Update all restaurants',
        )

    def handle(self, *args, **options):
        days = options['days']
        restaurant_id = options.get('restaurant')
        update_all = options['all']

        try:
            if update_all:
                restaurants = Restaurant.objects.filter(is_active=True)
                self.stdout.write(f"Updating {restaurants.count()} restaurants...")
            elif restaurant_id:
                restaurants = Restaurant.objects.filter(id=restaurant_id)
                if not restaurants.exists():
                    raise CommandError(f"Restaurant with ID {restaurant_id} not found")
            else:
                restaurants = Restaurant.objects.filter(is_active=True)

            end_date = timezone.now().date()
            start_date = end_date - timedelta(days=days-1)

            for restaurant in restaurants:
                self.stdout.write(
                    self.style.SUCCESS(
                        f"\n📊 Processing {restaurant.name}..."
                    )
                )

                current_date = start_date
                while current_date <= end_date:
                    daily_analytics, created = AnalyticsService.save_daily_analytics(
                        restaurant,
                        current_date
                    )

                    action = "✓ Created" if created else "↻ Updated"
                    self.stdout.write(
                        f"  {action}: {current_date} - "
                        f"{daily_analytics.total_orders} orders, "
                        f"${daily_analytics.total_revenue}"
                    )

                    current_date += timedelta(days=1)

            self.stdout.write(
                self.style.SUCCESS(
                    f"\n✅ Analytics updated successfully for {restaurants.count()} restaurants!"
                )
            )

        except Exception as e:
            logger.error(f"Error updating analytics: {str(e)}")
            raise CommandError(f"Error updating analytics: {str(e)}")
