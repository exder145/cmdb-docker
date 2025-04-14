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

# 检查 Docker 是否运行
check_docker() {
    if ! docker info &> /dev/null; then
        warn "Docker 未运行，正在启动..."
        systemctl start docker
        sleep 3
        if ! docker info &> /dev/null; then
            error "Docker 启动失败，请检查 Docker 服务"
        fi
    fi

    # 检查 Docker Compose 是否安装（支持插件模式和独立模式）
    if ! (docker compose version &> /dev/null || command -v docker-compose &> /dev/null); then
        error "Docker Compose 未安装，请先运行 './install.sh' 安装 Docker Compose"
    fi

    # 判断使用哪种命令格式
    if docker compose version &> /dev/null; then
        DOCKER_COMPOSE="docker compose"
        info "使用 Docker Compose 插件模式"
    else
        DOCKER_COMPOSE="docker-compose"
        info "使用 Docker Compose 独立模式"
    fi
}

# 备份数据
backup_data() {
    info "备份当前数据..."

    # 创建备份目录
    BACKUP_DIR="../backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p $BACKUP_DIR

    # 备份数据库
    info "备份数据库..."
    $DOCKER_COMPOSE exec -T backend sqlite3 db.sqlite3 .dump > $BACKUP_DIR/db_backup.sql

    # 备份上传的文件
    info "备份上传的文件..."
    docker cp $($DOCKER_COMPOSE ps -q backend):/app/storage $BACKUP_DIR/

    info "备份完成，文件保存在: $BACKUP_DIR"
}

# 更新容器
update_containers() {
    info "更新容器..."

    # 拉取最新代码（如果使用 Git）
    if [ -d ../.git ]; then
        info "检测到 Git 仓库，拉取最新代码..."
        cd ..
        git pull
        cd docker
    fi

    # 停止并移除旧容器
    $DOCKER_COMPOSE down

    # 构建并启动新容器
    $DOCKER_COMPOSE up -d --build

    # 等待容器启动
    info "等待容器启动..."
    sleep 10
}

# 更新数据库
update_database() {
    info "更新数据库..."

    # 检查后端容器是否运行
    if ! $DOCKER_COMPOSE ps | grep -q "spug-backend.*Up"; then
        error "后端容器未正常运行，请检查日志"
    fi

    # 运行数据库迁移
    $DOCKER_COMPOSE exec -T backend python manage.py updatedb
}

# 检查服务状态
check_services() {
    info "检查服务状态..."

    # 获取容器状态
    $DOCKER_COMPOSE ps

    # 检查前端是否可访问
    FRONTEND_PORT=$(grep FRONTEND_PORT .env | cut -d= -f2 || echo 80)
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:$FRONTEND_PORT/ | grep -q "200\|301\|302"; then
        info "前端服务运行正常"
    else
        warn "前端服务可能未正常运行，请检查日志"
    fi

    # 检查后端是否可访问
    BACKEND_PORT=$(grep BACKEND_PORT .env | cut -d= -f2 || echo 8000)
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:$BACKEND_PORT/account/login/ | grep -q "200\|301\|302"; then
        info "后端服务运行正常"
    else
        warn "后端服务可能未正常运行，请检查日志"
    fi
}

# 显示更新信息
show_info() {
    FRONTEND_PORT=$(grep FRONTEND_PORT .env | cut -d= -f2 || echo 80)

    echo ""
    info "SPUG 更新完成！"
    echo ""
    info "访问地址:"
    echo "  http://$(hostname -I | awk '{print $1}'):$FRONTEND_PORT"
    echo ""
    info "如需查看日志，请运行:"
    echo "  $DOCKER_COMPOSE logs -f"
    echo ""
}

# 主函数
main() {
    # 切换到 docker 目录
    cd "$(dirname "$0")/.."

    info "开始更新 SPUG 应用..."

    check_docker
    backup_data
    update_containers
    update_database
    check_services
    show_info
}

# 执行主函数
main
