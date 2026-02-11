# Generated migration to align model state with database schema

from django.db import migrations, models
import django.db.models.deletion
import uuid
from django.conf import settings


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0005_alter_order_restaurant'),
        ('restaurants', '0018_restaurantgallery'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        # This is a state-only operation to align the Django ORM with the database
        # The table_id column already exists in the database as a Foreign Key to restaurants_table
        migrations.RunSQL(
            sql="SELECT 1;",  # No-op SQL
            reverse_sql="SELECT 1;",
            state_operations=[
                # Remove the conceptual table_number field
                migrations.RemoveField(
                    model_name='order',
                    name='table_number',
                ),
                # Add the table FK field that already exists in the database
                migrations.AddField(
                    model_name='order',
                    name='table',
                    field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='orders', to='restaurants.table'),
                ),
            ]
        ),
    ]

