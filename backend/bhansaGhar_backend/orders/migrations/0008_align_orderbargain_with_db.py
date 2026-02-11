# Migration to align OrderBargain model state with actual database schema

from django.db import migrations, models
import django.db.models.deletion
import uuid


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0007_align_order_model_with_db'),
    ]

    operations = [
        # This is a state-only migration to update the ORM representation
        # The database already has these fields from previous migrations
    ]
