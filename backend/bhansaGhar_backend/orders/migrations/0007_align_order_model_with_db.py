# Migration to align Django ORM model state with actual database schema
# The database already has the current fields, this just updates the model state

from django.db import migrations, models
import django.db.models.deletion
import uuid


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0006_align_with_database_schema'),
        ('restaurants', '0018_restaurantgallery'),
    ]

    operations = [
        # This is a state-only operation to reflect the actual database schema
        # The database already has these fields from previous migrations
        migrations.AlterField(
            model_name='order',
            name='subtotal',
            field=models.DecimalField(decimal_places=2, default=0, max_digits=10),
        ),
    ]
