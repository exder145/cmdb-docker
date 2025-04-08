# SPUG Docker 一键部署

本项目提供了 SPUG 的 Docker 一键部署方案，让您可以轻松地在任何支持 Docker 的环境中部署 SPUG。

## 系统要求

- 操作系统：任何支持 Docker 的 Linux 系统（推荐 Ubuntu 20.04+ 或 CentOS 7+）
- 内存：至少 2GB RAM
- 磁盘空间：至少 10GB 可用空间
- 网络：能够访问互联网（用于下载 Docker 镜像）

## 快速开始

### 一键部署

只需运行以下命令即可完成部署：

```bash
# 克隆代码仓库（如果使用 Git）
git clone https://your-repository-url.git
cd your-repository-name

# 或者，如果您已经下载了代码
cd path/to/your/code

# 运行一键部署脚本
sudo bash deploy.sh
```

### 手动部署

如果您想手动控制部署过程，可以按照以下步骤操作：

1. 安装 Docker 和 Docker Compose：
   ```bash
   sudo bash docker/scripts/install.sh
   ```

2. 部署应用：
   ```bash
   cd docker
   sudo bash scripts/deploy.sh
   ```

## 使用说明

### 访问应用

部署完成后，您可以通过以下地址访问应用：

- 前端：http://服务器IP:80
- 后端 API：http://服务器IP:8000

### 默认账号

- 用户名：admin
- 密码：部署脚本输出的随机密码（请查看部署日志）

### 查看日志

```bash
cd docker
docker-compose logs -f
```

### 更新应用

当代码更新后，运行以下命令更新应用：

```bash
cd docker
sudo bash scripts/update.sh
```

### 备份数据

运行以下命令备份数据库和上传的文件：

```bash
cd docker
sudo bash scripts/backup.sh
```

### 恢复数据

运行以下命令从备份文件恢复数据：

```bash
cd docker
sudo bash scripts/restore.sh /path/to/backup/file.tar.gz
```

## 目录结构

```
./
├── deploy.sh              # 一键部署脚本
├── docker/                # Docker 配置目录
│   ├── docker-compose.yml # Docker Compose 配置文件
│   ├── frontend.Dockerfile # 前端 Dockerfile
│   ├── backend.Dockerfile # 后端 Dockerfile
│   ├── nginx.conf         # Nginx 配置文件
│   ├── .env               # 环境变量配置
│   ├── scripts/           # 部署脚本
│   │   ├── install.sh     # 安装 Docker 和 Docker Compose
│   │   ├── deploy.sh      # 部署应用
│   │   ├── update.sh      # 更新应用
│   │   ├── backup.sh      # 备份数据
│   │   └── restore.sh     # 恢复数据
│   └── README.md          # Docker 部署说明
├── spug_api/              # 后端代码
└── spug_web/              # 前端代码
```

## 自定义配置

### 修改端口

编辑 `docker/.env` 文件，修改以下配置：

```
FRONTEND_PORT=80    # 前端端口
BACKEND_PORT=8000   # 后端端口
```

### 修改 Redis 密码

编辑 `docker/.env` 文件，修改以下配置：

```
REDIS_PASSWORD=your_redis_password
```

### 使用外部 Redis

如果您想使用外部 Redis 服务，编辑 `docker/docker-compose.yml` 文件，注释掉 Redis 服务部分，并修改后端服务的环境变量：

```yaml
backend:
  environment:
    - REDIS_HOST=your_redis_host
    - REDIS_PORT=your_redis_port
    - REDIS_PASSWORD=your_redis_password
```

## 常见问题

### 端口被占用

如果 80 或 8000 端口已被占用，您可以修改 `docker/.env` 文件中的端口配置。

### 容器启动失败

检查日志以获取详细错误信息：

```bash
cd docker
docker-compose logs
```

### 数据持久化

所有数据都存储在 Docker 卷中，即使容器删除也不会丢失。卷名称为：

- spug-db：数据库文件
- spug-storage：上传的文件
- spug-logs：日志文件
- spug-repos：代码仓库

## 安全建议

1. 修改默认管理员密码
2. 使用 HTTPS 保护前端和 API 通信
3. 限制服务器防火墙，只开放必要端口
4. 定期备份数据

## 支持与反馈

如有问题或建议，请提交 Issue 或联系项目维护者。
