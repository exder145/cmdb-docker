#!/bin/bash
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 打印带颜色的信息
info() {
    echo -e "${GREEN}[INFO] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARN] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

# 检查是否为 root 用户
if [ "$(id -u)" != "0" ]; then
    error "此脚本需要以 root 权限运行，请使用 sudo 或切换到 root 用户"
fi

# 设置脚本权限
chmod +x docker/scripts/*.sh

# 安装 Docker 和 Docker Compose
info "安装 Docker 和 Docker Compose..."
bash docker/scripts/install.sh

# 部署应用
info "部署应用..."
cd docker
bash scripts/deploy.sh

info "一键部署完成！请按照上面的说明访问应用。"
