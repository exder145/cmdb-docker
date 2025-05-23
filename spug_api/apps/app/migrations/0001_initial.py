# Generated by Django 2.2.28 on 2025-04-08 17:03

from django.db import migrations, models
import django.db.models.deletion
import libs.mixins
import libs.utils


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('account', '0001_initial'),
        ('config', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='App',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=50)),
                ('key', models.CharField(max_length=50, unique=True)),
                ('desc', models.CharField(max_length=255, null=True)),
                ('rel_apps', models.TextField(null=True)),
                ('rel_services', models.TextField(null=True)),
                ('sort_id', models.IntegerField(db_index=True, default=0)),
                ('created_at', models.CharField(default=libs.utils.human_datetime, max_length=20)),
                ('created_by', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='account.User')),
            ],
            options={
                'db_table': 'apps',
                'ordering': ('-sort_id',),
            },
            bases=(models.Model, libs.mixins.ModelMixin),
        ),
        migrations.CreateModel(
            name='Deploy',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('host_ids', models.TextField()),
                ('extend', models.CharField(choices=[('1', '常规发布'), ('2', '自定义发布')], max_length=2)),
                ('is_audit', models.BooleanField()),
                ('is_parallel', models.BooleanField(default=True)),
                ('rst_notify', models.CharField(max_length=255, null=True)),
                ('created_at', models.CharField(default=libs.utils.human_datetime, max_length=20)),
                ('updated_at', models.CharField(max_length=20, null=True)),
                ('app', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='app.App')),
                ('created_by', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='+', to='account.User')),
                ('env', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='config.Environment')),
                ('updated_by', models.ForeignKey(null=True, on_delete=django.db.models.deletion.PROTECT, related_name='+', to='account.User')),
            ],
            options={
                'db_table': 'deploys',
                'ordering': ('-id',),
            },
            bases=(models.Model, libs.mixins.ModelMixin),
        ),
        migrations.CreateModel(
            name='DeployExtend1',
            fields=[
                ('deploy', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, primary_key=True, serialize=False, to='app.Deploy')),
                ('git_repo', models.CharField(max_length=255)),
                ('dst_dir', models.CharField(max_length=255)),
                ('dst_repo', models.CharField(max_length=255)),
                ('versions', models.IntegerField()),
                ('filter_rule', models.TextField()),
                ('hook_pre_server', models.TextField(null=True)),
                ('hook_post_server', models.TextField(null=True)),
                ('hook_pre_host', models.TextField(null=True)),
                ('hook_post_host', models.TextField(null=True)),
            ],
            options={
                'db_table': 'deploy_extend1',
            },
            bases=(models.Model, libs.mixins.ModelMixin),
        ),
        migrations.CreateModel(
            name='DeployExtend2',
            fields=[
                ('deploy', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, primary_key=True, serialize=False, to='app.Deploy')),
                ('server_actions', models.TextField()),
                ('host_actions', models.TextField()),
                ('require_upload', models.BooleanField(default=False)),
            ],
            options={
                'db_table': 'deploy_extend2',
            },
            bases=(models.Model, libs.mixins.ModelMixin),
        ),
    ]
