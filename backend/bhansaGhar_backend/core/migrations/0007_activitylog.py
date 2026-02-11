# Generated migration for ActivityLog model

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion
import uuid


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0006_user_restaurant_name'),  # Adjust based on your latest migration
        ('restaurants', '0001_initial'),  # Adjust based on your restaurants app migration
    ]

    operations = [
        migrations.CreateModel(
            name='ActivityLog',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, primary_key=True, serialize=False)),
                ('activity_type', models.CharField(
                    choices=[
                        ('login', 'User Login'),
                        ('logout', 'User Logout'),
                        ('order_created', 'Order Created'),
                        ('order_updated', 'Order Status Updated'),
                        ('order_cancelled', 'Order Cancelled'),
                        ('order_prepared', 'Order Marked as Prepared'),
                        ('order_served', 'Order Marked as Served'),
                        ('bargain_created', 'Bargain Created'),
                        ('bargain_accepted', 'Bargain Accepted'),
                        ('bargain_rejected', 'Bargain Rejected'),
                        ('profile_updated', 'Profile Updated'),
                        ('mode_changed', 'Mode Changed'),
                        ('menu_viewed', 'Menu Viewed'),
                        ('menu_item_added', 'Menu Item Added'),
                        ('menu_item_updated', 'Menu Item Updated'),
                        ('menu_item_deleted', 'Menu Item Deleted'),
                        ('staff_invited', 'Staff Member Invited'),
                        ('staff_added', 'Staff Member Added'),
                        ('staff_removed', 'Staff Member Removed'),
                        ('restaurant_updated', 'Restaurant Settings Updated'),
                        ('restaurant_category_updated', 'Restaurant Category Updated'),
                        ('other', 'Other Activity'),
                    ],
                    max_length=50,
                )),
                ('description', models.TextField(help_text='Human-readable description of the activity')),
                ('related_object_type', models.CharField(
                    blank=True,
                    help_text="Type of related object (e.g., 'order', 'user', 'menu_item')",
                    max_length=50,
                    null=True,
                )),
                ('related_object_id', models.CharField(
                    blank=True,
                    help_text='ID of the related object',
                    max_length=255,
                    null=True,
                )),
                ('metadata', models.JSONField(blank=True, default=dict, help_text='Additional context data for the activity')),
                ('ip_address', models.GenericIPAddressField(blank=True, null=True)),
                ('user_agent', models.TextField(blank=True, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True, db_index=True)),
                ('restaurant', models.ForeignKey(
                    blank=True,
                    null=True,
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='activity_logs',
                    to='restaurants.restaurant',
                )),
                ('user', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='activity_logs',
                    to=settings.AUTH_USER_MODEL,
                )),
            ],
            options={
                'verbose_name': 'Activity Log',
                'verbose_name_plural': 'Activity Logs',
                'ordering': ['-created_at'],
            },
        ),
        migrations.AddIndex(
            model_name='activitylog',
            index=models.Index(fields=['user', 'created_at'], name='core_activi_user_id_created_at_idx'),
        ),
        migrations.AddIndex(
            model_name='activitylog',
            index=models.Index(fields=['user', 'activity_type'], name='core_activi_user_id_activity_type_idx'),
        ),
        migrations.AddIndex(
            model_name='activitylog',
            index=models.Index(fields=['restaurant', 'created_at'], name='core_activi_restaurant_created_at_idx'),
        ),
        migrations.AddIndex(
            model_name='activitylog',
            index=models.Index(fields=['created_at'], name='core_activi_created_at_idx'),
        ),
    ]
