# Generated by Django 2.2.28 on 2025-04-08 17:03

from django.db import migrations, models
import django.db.models.deletion
import libs.mixins
import libs.utils


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='History',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('username', models.CharField(max_length=100, null=True)),
                ('type', models.CharField(default='default', max_length=20)),
                ('ip', models.CharField(max_length=50)),
                ('agent', models.CharField(max_length=255, null=True)),
                ('message', models.CharField(max_length=255, null=True)),
                ('is_success', models.BooleanField(default=True)),
                ('created_at', models.CharField(default=libs.utils.human_datetime, max_length=20)),
            ],
            options={
                'db_table': 'login_histories',
                'ordering': ('-id',),
            },
            bases=(models.Model, libs.mixins.ModelMixin),
        ),
        migrations.CreateModel(
            name='Role',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=50)),
                ('desc', models.CharField(max_length=255, null=True)),
                ('page_perms', models.TextField(null=True)),
                ('deploy_perms', models.TextField(null=True)),
                ('group_perms', models.TextField(null=True)),
                ('created_at', models.CharField(default=libs.utils.human_datetime, max_length=20)),
            ],
            options={
                'db_table': 'roles',
                'ordering': ('-id',),
            },
            bases=(models.Model, libs.mixins.ModelMixin),
        ),
        migrations.CreateModel(
            name='User',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('username', models.CharField(max_length=100)),
                ('nickname', models.CharField(max_length=100)),
                ('password_hash', models.CharField(max_length=100)),
                ('type', models.CharField(default='default', max_length=20)),
                ('is_supper', models.BooleanField(default=False)),
                ('is_active', models.BooleanField(default=True)),
                ('access_token', models.CharField(max_length=32)),
                ('token_expired', models.IntegerField(null=True)),
                ('last_login', models.CharField(max_length=20)),
                ('last_ip', models.CharField(max_length=50)),
                ('wx_token', models.CharField(max_length=50, null=True)),
                ('created_at', models.CharField(default=libs.utils.human_datetime, max_length=20)),
                ('deleted_at', models.CharField(max_length=20, null=True)),
                ('created_by', models.ForeignKey(null=True, on_delete=django.db.models.deletion.PROTECT, related_name='+', to='account.User')),
                ('deleted_by', models.ForeignKey(null=True, on_delete=django.db.models.deletion.PROTECT, related_name='+', to='account.User')),
                ('roles', models.ManyToManyField(db_table='user_role_rel', to='account.Role')),
            ],
            options={
                'db_table': 'users',
                'ordering': ('-id',),
            },
            bases=(models.Model, libs.mixins.ModelMixin),
        ),
        migrations.AddField(
            model_name='role',
            name='created_by',
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='+', to='account.User'),
        ),
    ]
