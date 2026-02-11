# Empty migration - database schema is already aligned
from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0008_align_orderbargain_with_db'),
    ]

    operations = [
    ]
