from django.core.management.base import BaseCommand
from django.utils import timezone
from restaurants.models import StaffInvite
import logging

logger = logging.getLogger(__name__)


class Command(BaseCommand):
    help = 'Delete expired staff invitations and their QR code images from Cloudinary'

    def add_arguments(self, parser):
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Show what would be deleted without actually deleting',
        )

    def handle(self, *args, **options):
        dry_run = options['dry_run']
        
        # Find all expired invitations
        expired_invites = StaffInvite.objects.filter(
            expires_at__lt=timezone.now(),
            status__in=['pending', 'expired']
        )
        
        count = expired_invites.count()
        
        if count == 0:
            self.stdout.write(self.style.SUCCESS('✅ No expired invitations to delete'))
            return
        
        self.stdout.write(f'Found {count} expired invitation(s)')
        
        if dry_run:
            self.stdout.write(self.style.WARNING('🔍 DRY RUN - No deletions will be performed'))
            for invite in expired_invites:
                self.stdout.write(f'  Would delete: {invite.email} ({invite.role}) - Expired: {invite.expires_at}')
            return
        
        # Delete expired invitations (signal will handle QR image deletion)
        deleted_count = 0
        for invite in expired_invites:
            try:
                email = invite.email
                role = invite.role
                expires_at = invite.expires_at
                
                # Delete will trigger post_delete signal which deletes QR image
                invite.delete()
                
                deleted_count += 1
                self.stdout.write(f'  ✅ Deleted: {email} ({role}) - Expired: {expires_at}')
                logger.info(f'Deleted expired invitation: {email} ({role})')
                
            except Exception as e:
                self.stdout.write(self.style.ERROR(f'  ❌ Error deleting {invite.email}: {e}'))
                logger.error(f'Error deleting expired invitation {invite.id}: {e}')
        
        self.stdout.write(self.style.SUCCESS(f'\n✅ Successfully deleted {deleted_count} expired invitation(s)'))
        self.stdout.write('💡 Tip: Set up a cron job to run this command daily: python manage.py cleanup_expired_invites')
