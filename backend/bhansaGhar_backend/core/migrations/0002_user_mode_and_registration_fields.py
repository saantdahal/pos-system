# Generated migration for User model updates

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0001_initial'),  # Update this to the latest migration
    ]

    operations = [
        migrations.AddField(
            model_name='user',
            name='selected_mode',
            field=models.CharField(
                blank=True,
                choices=[('online', 'Online Mode'), ('offline', 'Offline Mode')],
                max_length=10,
                null=True
            ),
        ),
        migrations.AddField(
            model_name='user',
            name='mode_selection_completed',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='user',
            name='registration_completed',
            field=models.BooleanField(default=False),
        ),
    ]
