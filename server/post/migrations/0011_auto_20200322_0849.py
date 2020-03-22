# Generated by Django 3.0.3 on 2020-03-22 08:49

from django.db import migrations, models
import uuid


class Migration(migrations.Migration):

    dependencies = [
        ('post', '0010_auto_20200322_0847'),
    ]

    operations = [
        migrations.AlterField(
            model_name='post',
            name='id',
            field=models.UUIDField(default=uuid.UUID('b4db16bf-4e1e-4dc6-a969-bbe8ed37a408'), primary_key=True, serialize=False, unique=True),
        ),
        migrations.AlterField(
            model_name='tag',
            name='id',
            field=models.UUIDField(default=uuid.UUID('ff989aca-b5f4-4d2d-af74-1d20ad594c42'), primary_key=True, serialize=False, unique=True),
        ),
    ]
