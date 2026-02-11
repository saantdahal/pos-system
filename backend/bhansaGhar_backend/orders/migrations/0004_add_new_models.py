# Second migration: Add new models now that OrderBargain.id is UUID

import django.db.models.deletion
import uuid
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0003_fix_orderbargain_uuid'),
        ('restaurants', '0016_table_last_served_table_notes_alter_table_status'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        # Migrate OrderBargain model definition to reflect UUID primary key
        # (Database was already changed in migration 0003, now update Django model state)
        migrations.RunSQL(
            sql="SELECT 1;",  # No-op SQL, just update state
            reverse_sql="SELECT 1;",
            state_operations=[
                migrations.AlterField(
                    model_name='orderbargain',
                    name='id',
                    field=models.UUIDField(primary_key=True, default=uuid.uuid4, serialize=False),
                ),
            ]
        ),

        # Add fields to Order
        migrations.AddField(
            model_name='order',
            name='assigned_kitchen_staff',
            field=models.ManyToManyField(blank=True, related_name='assigned_kitchen_orders', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='order',
            name='assigned_waiter',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='assigned_waiter_orders', to=settings.AUTH_USER_MODEL),
        ),

        # Add indexes
        migrations.AddIndex(
            model_name='order',
            index=models.Index(fields=['restaurant', 'status'], name='orders_orde_restaur_17016b_idx'),
        ),
        migrations.AddIndex(
            model_name='order',
            index=models.Index(fields=['assigned_waiter', 'status'], name='orders_orde_assigne_aefa0c_idx'),
        ),

        # Create BargainMessage
        migrations.CreateModel(
            name='BargainMessage',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('sender_type', models.CharField(choices=[('kitchen', 'Kitchen Staff'), ('customer', 'Customer'), ('admin', 'Admin')], max_length=20)),
                ('message', models.TextField()),
                ('status', models.CharField(choices=[('sent', 'Sent'), ('delivered', 'Delivered'), ('read', 'Read')], default='sent', max_length=20)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('read_at', models.DateTimeField(blank=True, null=True)),
                ('bargain', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='messages', to='orders.orderbargain')),
                ('sender', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'ordering': ['created_at'],
            },
        ),

        # Create OrderAssignment
        migrations.CreateModel(
            name='OrderAssignment',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('task_type', models.CharField(choices=[('prep', 'Preparation'), ('serve', 'Service')], max_length=20)),
                ('status', models.CharField(choices=[('pending', 'Pending Assignment'), ('accepted', 'Accepted'), ('in_progress', 'In Progress'), ('completed', 'Completed'), ('cancelled', 'Cancelled')], default='pending', max_length=20)),
                ('assigned_at', models.DateTimeField(auto_now_add=True)),
                ('accepted_at', models.DateTimeField(blank=True, null=True)),
                ('started_at', models.DateTimeField(blank=True, null=True)),
                ('completed_at', models.DateTimeField(blank=True, null=True)),
                ('notes', models.TextField(blank=True)),
                ('assigned_user', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL)),
                ('order', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='assignments', to='orders.order')),
            ],
            options={
                'ordering': ['assigned_at'],
            },
        ),

        # Create OrderTimeline
        migrations.CreateModel(
            name='OrderTimeline',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('status_old', models.CharField(blank=True, max_length=20, null=True)),
                ('status_new', models.CharField(max_length=20)),
                ('reason', models.TextField(blank=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('changed_by', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL)),
                ('order', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='timeline', to='orders.order')),
            ],
            options={
                'ordering': ['created_at'],
            },
        ),

        # Create WaiterSession
        migrations.CreateModel(
            name='WaiterSession',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('status', models.CharField(choices=[('idle', 'Idle - Available'), ('busy', 'Busy - Active Orders'), ('on_break', 'On Break'), ('offline', 'Offline')], default='offline', max_length=20)),
                ('active_orders_count', models.IntegerField(default=0)),
                ('last_heartbeat', models.DateTimeField(auto_now=True)),
                ('session_started_at', models.DateTimeField(auto_now_add=True)),
                ('session_ended_at', models.DateTimeField(blank=True, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('restaurant', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='waiter_sessions', to='restaurants.restaurant')),
                ('user', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='waiter_session', to=settings.AUTH_USER_MODEL)),
            ],
        ),

        # Add indexes
        migrations.AddIndex(
            model_name='bargainmessage',
            index=models.Index(fields=['bargain', 'created_at'], name='orders_barg_bargain_19b0a5_idx'),
        ),
        migrations.AddIndex(
            model_name='orderassignment',
            index=models.Index(fields=['order', 'task_type'], name='orders_orde_order_i_990049_idx'),
        ),
        migrations.AddIndex(
            model_name='orderassignment',
            index=models.Index(fields=['assigned_user', 'status'], name='orders_orde_assigne_357aa1_idx'),
        ),
        migrations.AddIndex(
            model_name='ordertimeline',
            index=models.Index(fields=['order', 'created_at'], name='orders_orde_order_i_a5a9a4_idx'),
        ),
        migrations.AddIndex(
            model_name='waitersession',
            index=models.Index(fields=['restaurant', 'status'], name='orders_wait_restaur_9ddce9_idx'),
        ),
        migrations.AddIndex(
            model_name='waitersession',
            index=models.Index(fields=['last_heartbeat'], name='orders_wait_last_he_dfc5cc_idx'),
        ),

        # Unique constraint
        migrations.AlterUniqueTogether(
            name='waitersession',
            unique_together={('user', 'restaurant')},
        ),
    ]
