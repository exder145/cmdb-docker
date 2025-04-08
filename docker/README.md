# SPUG Docker 部署

本目录包含了 SPUG 项目的 Docker 部署配置文件。

## 目录结构

```
docker/
├── docker-compose.yml     # Docker Compose 配置文件
├── frontend.Dockerfile    # 前端 Dockerfile
├── backend.Dockerfile     # 后端 Dockerfile
├── nginx.conf            # Nginx 配置文件
├── scripts/              # 部署脚本
│   ├── install.sh        # 安装 Docker 和 Docker Compose
│   ├── deploy.sh         # 部署应用
│   ├── update.sh         # 更新应用
│   └── backup.sh         # 备份数据
└── README.md             # 说明文档
```

## 快速开始

1. 安装 Docker 和 Docker Compose：
   ```bash
   bash scripts/install.sh
   ```

2. 部署应用：
   ```bash
   bash scripts/deploy.sh
   ```

3. 访问应用：
   - 前端：http://localhost
   - 后端 API：http://localhost:8000

## 更新应用

当代码更新后，运行以下命令更新应用：

```bash
bash scripts/update.sh
```

## 备份数据

运行以下命令备份数据库和上传的文件：

```bash
bash scripts/backup.sh
```

## 注意事项

- 数据存储在 Docker 卷中，即使容器删除也不会丢失
- 默认使用 SQLite 数据库，如需使用其他数据库，请修改配置
- 日志文件存储在 `logs` 卷中
