from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import timedelta
from restaurants.models import StaffInvite
import logging

logger = logging.getLogger(__name__)

class Command(BaseCommand):
    help = 'Expires overdue pending invites and deletes old finalized invites.'

    def handle(self, *args, **options):
        self.stdout.write("🧹 Starting staff invite cleanup...")
        
        now = timezone.now()
        
        # 1. Expire pending invites that are past their expiration time
        expired_count = 0
        overdue_invites = StaffInvite.objects.filter(
            status='pending',
            expires_at__lt=now
        )
        
        for invite in overdue_invites:
            invite.status = 'expired'
            invite.save(update_fields=['status'])
            invite.delete_qr_image() # Clean up the image
            expired_count += 1
            
        if expired_count > 0:
            self.stdout.write(self.style.SUCCESS(f"✅ Marked {expired_count} overdue invites as expired"))
            
        # 2. Delete invites that are 'claimed' or 'expired' and older than 30 days
        cutoff_date = now - timedelta(days=30)
        
        # We check created_at for age, but ensure status is final
        old_invites = StaffInvite.objects.filter(
            status__in=['claimed', 'expired'],
            created_at__lt=cutoff_date
        )
        
        deleted_count = 0
        for invite in old_invites:
            # delete_qr_image is called by post_delete signal, but calling explicitly is safe too
            # calling delete() triggers the signal
            invite.delete()
            deleted_count += 1
            
        if deleted_count > 0:
            self.stdout.write(self.style.SUCCESS(f"🗑️ Deleted {deleted_count} old invites (older than 30 days)"))
            
        self.stdout.write(self.style.SUCCESS("✨ Cleanup completed successfully"))
