# First migration: Fix OrderBargain UUID type
# This must be applied BEFORE adding models with FK to OrderBargain

import django.db.models.deletion
import uuid
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0002_orderservelog'),
        ('restaurants', '0016_table_last_served_table_notes_alter_table_status'),
    ]

    operations = [
        # Change OrderBargain.id from BIGINT to UUID using raw SQL
        migrations.RunSQL(
            sql="""
            -- Create new UUID column
            ALTER TABLE orders_orderbargain ADD COLUMN id_new uuid DEFAULT gen_random_uuid();
            
            -- Set existing non-null values
            UPDATE orders_orderbargain SET id_new = gen_random_uuid() WHERE id_new IS NULL;
            
            -- Drop primary key
            ALTER TABLE orders_orderbargain DROP CONSTRAINT orders_orderbargain_pkey;
            
            -- Drop old id column
            ALTER TABLE orders_orderbargain DROP COLUMN id;
            
            -- Rename new column to id
            ALTER TABLE orders_orderbargain RENAME COLUMN id_new TO id;
            
            -- Set as primary key
            ALTER TABLE orders_orderbargain ADD PRIMARY KEY (id);
            """,
            reverse_sql="""
            -- Reverse migration not supported for this schema change
            SELECT 1;
            """,
        ),
    ]
