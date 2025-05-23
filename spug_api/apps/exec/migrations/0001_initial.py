# Generated by Django 2.2.28 on 2025-04-08 17:03

from django.db import migrations, models
import django.db.models.deletion
import libs.mixins
import libs.utils


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('account', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Transfer',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('digest', models.CharField(db_index=True, max_length=32)),
                ('host_id', models.IntegerField(null=True)),
                ('src_dir', models.CharField(max_length=255)),
                ('dst_dir', models.CharField(max_length=255)),
                ('host_ids', models.TextField()),
                ('updated_at', models.CharField(default=libs.utils.human_datetime, max_length=20)),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='account.User')),
            ],
            options={
                'db_table': 'exec_transfer',
                'ordering': ('-id',),
            },
            bases=(models.Model, libs.mixins.ModelMixin),
        ),
        migrations.CreateModel(
            name='ExecTemplate',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=50)),
                ('type', models.CharField(max_length=50)),
                ('body', models.TextField()),
                ('interpreter', models.CharField(default='sh', max_length=20)),
                ('host_ids', models.TextField(default='[]')),
                ('desc', models.CharField(max_length=255, null=True)),
                ('parameters', models.TextField(default='[]')),
                ('created_at', models.CharField(default=libs.utils.human_datetime, max_length=20)),
                ('updated_at', models.CharField(max_length=20, null=True)),
                ('created_by', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='+', to='account.User')),
                ('updated_by', models.ForeignKey(null=True, on_delete=django.db.models.deletion.PROTECT, related_name='+', to='account.User')),
            ],
            options={
                'db_table': 'exec_templates',
                'ordering': ('-id',),
            },
            bases=(models.Model, libs.mixins.ModelMixin),
        ),
        migrations.CreateModel(
            name='ExecHistory',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('digest', models.CharField(db_index=True, max_length=32)),
                ('interpreter', models.CharField(max_length=20)),
                ('command', models.TextField()),
                ('command_type', models.CharField(default='shell', max_length=20)),
                ('params', models.TextField(default='{}')),
                ('host_ids', models.TextField()),
                ('updated_at', models.CharField(default=libs.utils.human_datetime, max_length=20)),
                ('template', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to='exec.ExecTemplate')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='account.User')),
            ],
            options={
                'db_table': 'exec_histories',
                'ordering': ('-updated_at',),
            },
            bases=(models.Model, libs.mixins.ModelMixin),
        ),
    ]
