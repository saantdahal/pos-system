"""
Management command to cleanup old notifications.
Usage: python manage.py cleanup_notifications --days 30
"""

import logging
from django.core.management.base import BaseCommand
from notifications.services import NotificationService

logger = logging.getLogger(__name__)


class Command(BaseCommand):
    help = "Clean up old read notifications from the database"

    def add_arguments(self, parser):
        parser.add_argument(
            "--days",
            type=int,
            default=30,
            help="Number of days to keep (default: 30)",
        )

    def handle(self, *args, **options):
        days = options["days"]
        self.stdout.write(f"Cleaning up notifications older than {days} days...")

        try:
            deleted_count = NotificationService.cleanup_old_notifications(days=days)
            self.stdout.write(
                self.style.SUCCESS(
                    f"✓ Successfully deleted {deleted_count} old notifications"
                )
            )
        except Exception as e:
            self.stdout.write(
                self.style.ERROR(f"✗ Error during cleanup: {str(e)}")
            )
            logger.error(f"Cleanup error: {str(e)}", exc_info=True)
