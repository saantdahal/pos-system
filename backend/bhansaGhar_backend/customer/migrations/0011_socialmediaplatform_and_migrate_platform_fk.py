# Generated migration for Social Media Platform system

from django.db import migrations, models
import django.db.models.deletion


def create_default_platforms(apps, schema_editor):
    """Create default social media platforms with branding info"""
    SocialMediaPlatform = apps.get_model('customer', 'SocialMediaPlatform')
    
    platforms = [
        {
            'name': 'Facebook',
            'platform_key': 'facebook',
            'icon': '👍',
            'color': '#1877F2',
            'url_placeholder': 'https://facebook.com/yourpage',
            'position': 1,
        },
        {
            'name': 'Instagram',
            'platform_key': 'instagram',
            'icon': '📷',
            'color': '#E4405F',
            'url_placeholder': 'https://instagram.com/yourprofile',
            'position': 2,
        },
        {
            'name': 'Twitter',
            'platform_key': 'twitter',
            'icon': '𝕏',
            'color': '#000000',
            'url_placeholder': 'https://twitter.com/yourhandle',
            'position': 3,
        },
        {
            'name': 'LinkedIn',
            'platform_key': 'linkedin',
            'icon': '🔗',
            'color': '#0A66C2',
            'url_placeholder': 'https://linkedin.com/in/yourprofile',
            'position': 4,
        },
        {
            'name': 'YouTube',
            'platform_key': 'youtube',
            'icon': '📺',
            'color': '#FF0000',
            'url_placeholder': 'https://youtube.com/@yourchannel',
            'position': 5,
        },
        {
            'name': 'TikTok',
            'platform_key': 'tiktok',
            'icon': '🎵',
            'color': '#000000',
            'url_placeholder': 'https://tiktok.com/@yourprofile',
            'position': 6,
        },
        {
            'name': 'WhatsApp',
            'platform_key': 'whatsapp',
            'icon': '💬',
            'color': '#25D366',
            'url_placeholder': '+1234567890',
            'position': 7,
        },
        {
            'name': 'Telegram',
            'platform_key': 'telegram',
            'icon': '✈️',
            'color': '#0088cc',
            'url_placeholder': 'https://t.me/yourhandle',
            'position': 8,
        },
    ]
    
    for platform_data in platforms:
        SocialMediaPlatform.objects.get_or_create(
            platform_key=platform_data['platform_key'],
            defaults=platform_data
        )


def migrate_platform_data(apps, schema_editor):
    """Migrate platform string values to ForeignKey references and remove duplicates"""
    SocialMediaLink = apps.get_model('customer', 'SocialMediaLink')
    SocialMediaPlatform = apps.get_model('customer', 'SocialMediaPlatform')
    
    # Map of old platform strings to new platform keys
    platform_mapping = {
        'facebook': 'facebook',
        'instagram': 'instagram',
        'twitter': 'twitter',
        'linkedin': 'linkedin',
        'youtube': 'youtube',
        'tiktok': 'tiktok',
        'whatsapp': 'whatsapp',
        'telegram': 'telegram',
        'custom': 'facebook',  # Default custom to facebook
    }
    
    # Update all social media links with their new platform FK
    for link in SocialMediaLink.objects.all():
        # Get the platform key from mapping
        platform_key = platform_mapping.get(link.platform_temp, 'facebook')
        
        try:
            platform = SocialMediaPlatform.objects.get(platform_key=platform_key)
            link.platform_fk = platform
            link.save(update_fields=['platform_fk'])
        except SocialMediaPlatform.DoesNotExist:
            # If platform not found, use Facebook as default
            platform = SocialMediaPlatform.objects.get(platform_key='facebook')
            link.platform_fk = platform
            link.save(update_fields=['platform_fk'])
    
    # Remove duplicate links before applying unique constraints
    # Using raw SQL to delete duplicates efficiently
    from django.db import connection
    with connection.cursor() as cursor:
        # Delete duplicates for (restaurant_id, platform_fk_id) pairs
        cursor.execute("""
            DELETE FROM customer_socialmedialink
            WHERE restaurant_id IS NOT NULL
            AND id NOT IN (
                SELECT DISTINCT ON (restaurant_id, platform_fk_id) id
                FROM customer_socialmedialink
                WHERE restaurant_id IS NOT NULL
                ORDER BY restaurant_id, platform_fk_id, id
            )
        """)
        
        # Delete duplicates for (landing_page_id, platform_fk_id) pairs
        cursor.execute("""
            DELETE FROM customer_socialmedialink
            WHERE landing_page_id IS NOT NULL
            AND id NOT IN (
                SELECT DISTINCT ON (landing_page_id, platform_fk_id) id
                FROM customer_socialmedialink
                WHERE landing_page_id IS NOT NULL
                ORDER BY landing_page_id, platform_fk_id, id
            )
        """)


class Migration(migrations.Migration):

    dependencies = [
        ('customer', '0010_socialmedialink_restaurant'),
    ]

    operations = [
        # Create the SocialMediaPlatform model
        migrations.CreateModel(
            name='SocialMediaPlatform',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(help_text="Platform name (e.g., 'Facebook')", max_length=50, unique=True)),
                ('platform_key', models.CharField(help_text="Unique identifier (e.g., 'facebook')", max_length=20, unique=True)),
                ('icon', models.CharField(help_text="Icon (emoji, font-awesome class, or SVG). E.g., '👍' or 'fab fa-facebook-f' or '<svg>...</svg>'", max_length=500)),
                ('color', models.CharField(default='#000000', help_text="Brand color hex code (e.g., '#1877F2' for Facebook)", max_length=7)),
                ('url_placeholder', models.CharField(blank=True, help_text="Placeholder for URL input. E.g., 'https://facebook.com/yourpage' or '+1234567890' for WhatsApp", max_length=255, null=True)),
                ('is_active', models.BooleanField(default=True)),
                ('position', models.PositiveIntegerField(default=0, help_text='Display order')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
            ],
            options={
                'verbose_name': 'Social Media Platform',
                'verbose_name_plural': 'Social Media Platforms',
                'ordering': ['position'],
            },
        ),
        # Add temporary CharField to store old platform strings
        migrations.AddField(
            model_name='socialmedialink',
            name='platform_temp',
            field=models.CharField(default='facebook', help_text='Temporary field for migration', max_length=20),
            preserve_default=False,
        ),
        # Copy existing platform data to temp field
        migrations.RunPython(
            lambda apps, schema_editor: None,  # Forward: no-op (data already there)
            lambda apps, schema_editor: None,  # Reverse: no-op
        ),
        # Create default platforms
        migrations.RunPython(create_default_platforms, migrations.RunPython.noop),
        # Add new ForeignKey field (nullable initially)
        migrations.AddField(
            model_name='socialmedialink',
            name='platform_fk',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, related_name='links', to='customer.socialmediaplatform'),
        ),
        # Migrate data from old CharField to new ForeignKey
        migrations.RunPython(migrate_platform_data, migrations.RunPython.noop),
        # Remove old platform field
        migrations.RemoveField(
            model_name='socialmedialink',
            name='platform',
        ),
        # Remove temp field
        migrations.RemoveField(
            model_name='socialmedialink',
            name='platform_temp',
        ),
        # Rename new ForeignKey to 'platform'
        migrations.RenameField(
            model_name='socialmedialink',
            old_name='platform_fk',
            new_name='platform',
        ),
        # Make platform field non-nullable
        migrations.AlterField(
            model_name='socialmedialink',
            name='platform',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='links', to='customer.socialmediaplatform', help_text='Select a social media platform'),
        ),
        # Update unique constraints
        migrations.AlterUniqueTogether(
            name='socialmedialink',
            unique_together={('restaurant', 'platform'), ('landing_page', 'platform')},
        ),
    ]
