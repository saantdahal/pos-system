"""
Auto-generated migration for notifications app.
Initial creation of all models.
"""

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion
import uuid


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Notification',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('category', models.CharField(choices=[('order', 'Order Update'), ('staff', 'Staff Activity'), ('revenue', 'Revenue'), ('stock', 'Stock Alert'), ('bargain', 'Bargain'), ('table', 'Table Status')], max_length=20)),
                ('title', models.CharField(max_length=200)),
                ('message', models.TextField()),
                ('data', models.JSONField(default=dict, help_text='Additional data: order_id, table_number, etc.')),
                ('priority', models.IntegerField(choices=[(1, 'Low'), (2, 'Medium'), (3, 'High'), (5, 'Urgent')], default=2)),
                ('timestamp', models.DateTimeField(auto_now_add=True, db_index=True)),
                ('is_read', models.BooleanField(db_index=True, default=False)),
                ('read_at', models.DateTimeField(blank=True, null=True)),
                ('fcm_sent', models.BooleanField(default=False)),
                ('fcm_sent_at', models.DateTimeField(blank=True, null=True)),
                ('fcm_failed', models.BooleanField(default=False)),
                ('fcm_error', models.TextField(blank=True, null=True)),
                ('ws_sent', models.BooleanField(default=False)),
                ('ws_sent_at', models.DateTimeField(blank=True, null=True)),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='notifications', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'verbose_name_plural': 'Notifications',
                'ordering': ['-timestamp'],
            },
        ),
        migrations.CreateModel(
            name='NotificationPreference',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('order_notifications', models.BooleanField(default=True)),
                ('bargain_notifications', models.BooleanField(default=True)),
                ('table_notifications', models.BooleanField(default=True)),
                ('staff_notifications', models.BooleanField(default=True)),
                ('stock_notifications', models.BooleanField(default=True)),
                ('revenue_notifications', models.BooleanField(default=True)),
                ('fcm_enabled', models.BooleanField(default=True)),
                ('websocket_enabled', models.BooleanField(default=True)),
                ('dnd_enabled', models.BooleanField(default=False)),
                ('dnd_start_time', models.TimeField(blank=True, null=True)),
                ('dnd_end_time', models.TimeField(blank=True, null=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('user', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='notification_preferences', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'verbose_name_plural': 'Notification Preferences',
            },
        ),
        migrations.CreateModel(
            name='NotificationLog',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('delivery_type', models.CharField(choices=[('websocket', 'WebSocket'), ('fcm', 'Firebase Cloud Messaging')], max_length=20)),
                ('status', models.CharField(choices=[('pending', 'Pending'), ('sent', 'Sent'), ('failed', 'Failed'), ('delivered', 'Delivered')], max_length=20)),
                ('error_message', models.TextField(blank=True, null=True)),
                ('timestamp', models.DateTimeField(auto_now_add=True)),
                ('notification', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='delivery_logs', to='notifications.notification')),
            ],
            options={
                'verbose_name_plural': 'Notification Logs',
                'ordering': ['-timestamp'],
            },
        ),
        migrations.CreateModel(
            name='FCMDevice',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('token', models.TextField(help_text='Firebase Cloud Messaging device token')),
                ('platform', models.CharField(choices=[('android', 'Android'), ('ios', 'iOS'), ('web', 'Web')], default='android', max_length=10)),
                ('active', models.BooleanField(default=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('user', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='fcm_device', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'verbose_name_plural': 'FCM Devices',
            },
        ),
        migrations.AddIndex(
            model_name='notification',
            index=models.Index(fields=['user', '-timestamp'], name='notifications_user_id_timestamp_idx'),
        ),
        migrations.AddIndex(
            model_name='notification',
            index=models.Index(fields=['user', 'is_read', '-timestamp'], name='notifications_user_id_read_timestamp_idx'),
        ),
        migrations.AddIndex(
            model_name='notification',
            index=models.Index(fields=['user', 'category', '-timestamp'], name='notifications_user_id_category_timestamp_idx'),
        ),
    ]
