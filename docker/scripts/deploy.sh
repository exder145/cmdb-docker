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

# 检查 Docker 是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        error "Docker 未安装，请先运行 './install.sh' 安装 Docker"
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

    # 检查 Docker 是否运行
    if ! docker info &> /dev/null; then
        warn "Docker 未运行，正在启动..."
        systemctl start docker
        sleep 3
        if ! docker info &> /dev/null; then
            error "Docker 启动失败，请检查 Docker 服务"
        fi
    fi
}

# 创建随机密码
generate_password() {
    < /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-12}
}

# 配置环境变量
setup_env() {
    info "配置环境变量..."

    # 检查 .env 文件是否存在
    if [ ! -f .env ]; then
        info "创建 .env 文件..."
        cp .env.example .env 2>/dev/null || touch .env

        # 生成随机 Redis 密码
        REDIS_PASSWORD=$(generate_password)
        echo "REDIS_PASSWORD=$REDIS_PASSWORD" >> .env

        # 设置默认端口
        echo "FRONTEND_PORT=80" >> .env
        echo "BACKEND_PORT=8000" >> .env

        # 设置时区
        echo "TZ=Asia/Shanghai" >> .env
    else
        warn ".env 文件已存在，跳过创建"
    fi
}

# 构建并启动容器
start_containers() {
    info "构建并启动容器..."

    # 拉取最新镜像
    $DOCKER_COMPOSE pull

    # 构建并启动容器
    $DOCKER_COMPOSE up -d --build

    # 等待容器启动
    info "等待容器启动..."
    sleep 10
}

# 初始化数据库
init_database() {
    info "初始化数据库..."

    # 检查后端容器是否运行
    if ! $DOCKER_COMPOSE ps | grep -q "spug-backend.*Up"; then
        error "后端容器未正常运行，请检查日志"
    fi

    # 运行数据库迁移
    $DOCKER_COMPOSE exec -T backend python manage.py updatedb

    # 检查是否需要创建管理员用户
    if $DOCKER_COMPOSE exec -T backend python -c "from apps.account.models import User; exit(0 if User.objects.filter(is_supper=True).exists() else 1)" 2>/dev/null; then
        warn "管理员用户已存在，跳过创建"
    else
        info "创建管理员用户..."
        ADMIN_PASSWORD=$(generate_password)
        $DOCKER_COMPOSE exec -T backend python manage.py user add -u admin -p $ADMIN_PASSWORD -n 管理员 -s
        info "管理员用户创建成功"
        info "用户名: admin"
        info "密码: $ADMIN_PASSWORD"
        info "请登录后立即修改密码！"
    fi
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

# 显示部署信息
show_info() {
    FRONTEND_PORT=$(grep FRONTEND_PORT .env | cut -d= -f2 || echo 80)
    BACKEND_PORT=$(grep BACKEND_PORT .env | cut -d= -f2 || echo 8000)

    echo ""
    info "SPUG 部署完成！"
    echo ""
    info "访问地址:"
    echo "  前端: http://$(hostname -I | awk '{print $1}'):$FRONTEND_PORT"
    echo "  后端 API: http://$(hostname -I | awk '{print $1}'):$BACKEND_PORT"
    echo ""
    info "管理员账号:"
    echo "  用户名: admin"
    echo "  密码: 请查看上方输出或使用默认密码 spug.cc"
    echo ""
    info "如需查看日志，请运行:"
    echo "  $DOCKER_COMPOSE logs -f"
    echo ""
    info "如需更新应用，请运行:"
    echo "  ./update.sh"
    echo ""
    info "如需备份数据，请运行:"
    echo "  ./backup.sh"
    echo ""
}

# 主函数
main() {
    # 切换到 docker 目录
    cd "$(dirname "$0")/.."

    info "开始部署 SPUG 应用..."

    check_docker
    setup_env
    start_containers
    init_database
    check_services
    show_info
}

# 执行主函数
main
