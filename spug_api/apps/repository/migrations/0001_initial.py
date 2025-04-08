# Generated by Django 2.2.28 on 2025-04-08 17:03

from django.db import migrations, models
import django.db.models.deletion
import libs.mixins


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('app', '0001_initial'),
        ('config', '0001_initial'),
        ('account', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Repository',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('version', models.CharField(max_length=100)),
                ('spug_version', models.CharField(max_length=50)),
                ('remarks', models.CharField(max_length=255, null=True)),
                ('extra', models.TextField()),
                ('status', models.CharField(choices=[('0', '未开始'), ('1', '构建中'), ('2', '失败'), ('5', '成功')], default='0', max_length=2)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('app', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='app.App')),
                ('created_by', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='account.User')),
                ('deploy', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='app.Deploy')),
                ('env', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='config.Environment')),
            ],
            options={
                'db_table': 'repositories',
                'ordering': ('-id',),
            },
            bases=(models.Model, libs.mixins.ModelMixin),
        ),
    ]
