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
}

# 备份数据
backup_data() {
    # 创建备份目录
    BACKUP_DIR="../backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p $BACKUP_DIR
    
    info "开始备份数据到: $BACKUP_DIR"
    
    # 检查后端容器是否运行
    if ! docker-compose ps | grep -q "spug-backend.*Up"; then
        error "后端容器未正常运行，无法备份数据"
    fi
    
    # 备份数据库
    info "备份数据库..."
    docker-compose exec -T backend sqlite3 db.sqlite3 .dump > $BACKUP_DIR/db_backup.sql
    
    # 备份上传的文件
    info "备份上传的文件..."
    docker cp $(docker-compose ps -q backend):/app/storage $BACKUP_DIR/
    
    # 备份配置文件
    info "备份配置文件..."
    cp .env $BACKUP_DIR/
    cp docker-compose.yml $BACKUP_DIR/
    
    # 压缩备份文件
    info "压缩备份文件..."
    tar -czf $BACKUP_DIR.tar.gz -C $(dirname $BACKUP_DIR) $(basename $BACKUP_DIR)
    
    # 删除原始备份目录
    rm -rf $BACKUP_DIR
    
    info "备份完成，文件保存在: $BACKUP_DIR.tar.gz"
}

# 显示备份信息
show_backup_info() {
    echo ""
    info "备份操作完成！"
    echo ""
    info "备份文件位置:"
    echo "  $(readlink -f $BACKUP_DIR.tar.gz)"
    echo ""
    info "恢复备份的步骤:"
    echo "  1. 解压备份文件: tar -xzf $BACKUP_DIR.tar.gz"
    echo "  2. 停止当前容器: docker-compose down"
    echo "  3. 复制数据库文件: docker cp $(basename $BACKUP_DIR)/db_backup.sql spug-backend:/app/"
    echo "  4. 恢复数据库: docker-compose exec backend sqlite3 db.sqlite3 < /app/db_backup.sql"
    echo "  5. 复制上传文件: docker cp $(basename $BACKUP_DIR)/storage spug-backend:/app/"
    echo "  6. 重启容器: docker-compose up -d"
    echo ""
}

# 主函数
main() {
    # 切换到 docker 目录
    cd "$(dirname "$0")/.."
    
    info "开始备份 SPUG 应用数据..."
    
    check_docker
    backup_data
    show_backup_info
}

# 执行主函数
main
