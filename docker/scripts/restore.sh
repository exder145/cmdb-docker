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

# 检查参数
if [ $# -ne 1 ]; then
    error "用法: $0 <备份文件路径>"
fi

BACKUP_FILE=$1

# 检查备份文件是否存在
if [ ! -f "$BACKUP_FILE" ]; then
    error "备份文件不存在: $BACKUP_FILE"
fi

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
}

# 解压备份文件
extract_backup() {
    info "解压备份文件..."
    
    # 创建临时目录
    TEMP_DIR=$(mktemp -d)
    
    # 解压备份文件
    tar -xzf $BACKUP_FILE -C $TEMP_DIR
    
    # 获取备份目录名
    BACKUP_DIR=$(find $TEMP_DIR -type d -name "20*" | head -1)
    
    if [ -z "$BACKUP_DIR" ]; then
        rm -rf $TEMP_DIR
        error "无法找到有效的备份目录"
    fi
    
    info "备份文件解压到: $BACKUP_DIR"
}

# 停止容器
stop_containers() {
    info "停止当前容器..."
    docker-compose down
}

# 恢复数据
restore_data() {
    info "恢复数据..."
    
    # 启动后端容器
    docker-compose up -d backend
    
    # 等待容器启动
    info "等待容器启动..."
    sleep 10
    
    # 检查后端容器是否运行
    if ! docker-compose ps | grep -q "spug-backend.*Up"; then
        error "后端容器未正常运行，无法恢复数据"
    fi
    
    # 恢复数据库
    info "恢复数据库..."
    docker cp $BACKUP_DIR/db_backup.sql $(docker-compose ps -q backend):/app/
    docker-compose exec -T backend bash -c "sqlite3 db.sqlite3 < /app/db_backup.sql"
    
    # 恢复上传的文件
    info "恢复上传的文件..."
    docker-compose exec -T backend rm -rf /app/storage
    docker cp $BACKUP_DIR/storage $(docker-compose ps -q backend):/app/
    
    # 恢复配置文件（可选）
    if [ -f "$BACKUP_DIR/.env" ]; then
        info "恢复配置文件..."
        cp $BACKUP_DIR/.env .env
    fi
}

# 启动所有容器
start_containers() {
    info "启动所有容器..."
    docker-compose up -d
    
    # 等待容器启动
    info "等待容器启动..."
    sleep 10
}

# 清理临时文件
cleanup() {
    info "清理临时文件..."
    rm -rf $TEMP_DIR
}

# 显示恢复信息
show_restore_info() {
    FRONTEND_PORT=$(grep FRONTEND_PORT .env | cut -d= -f2 || echo 80)
    
    echo ""
    info "SPUG 数据恢复完成！"
    echo ""
    info "访问地址:"
    echo "  http://$(hostname -I | awk '{print $1}'):$FRONTEND_PORT"
    echo ""
    info "如需查看日志，请运行:"
    echo "  docker-compose logs -f"
    echo ""
}

# 主函数
main() {
    # 切换到 docker 目录
    cd "$(dirname "$0")/.."
    
    info "开始恢复 SPUG 应用数据..."
    
    check_docker
    extract_backup
    stop_containers
    restore_data
    start_containers
    cleanup
    show_restore_info
}

# 执行主函数
main
