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

# 检查容器状态
check_containers() {
    info "检查容器状态..."
    
    # 检查所有容器是否运行
    if [ $(docker ps -q | wc -l) -lt 6 ]; then
        error "不是所有容器都在运行，请检查日志"
    fi
    
    # 检查后端容器是否健康
    if [ "$(docker inspect --format='{{.State.Health.Status}}' spug-backend 2>/dev/null)" != "healthy" ]; then
        warn "后端容器未处于健康状态，可能需要更多时间启动"
    fi
    
    # 检查前端容器是否健康
    if [ "$(docker inspect --format='{{.State.Health.Status}}' spug-frontend 2>/dev/null)" != "healthy" ]; then
        warn "前端容器未处于健康状态，可能需要更多时间启动"
    fi
    
    info "所有容器都在运行"
}

# 检查端口映射
check_ports() {
    info "检查端口映射..."
    
    # 检查前端端口 (80)
    if ! netstat -tuln | grep -q ":80 "; then
        error "前端端口 (80) 未正确映射"
    fi
    
    # 检查后端端口 (8000)
    if ! netstat -tuln | grep -q ":8000 "; then
        error "后端端口 (8000) 未正确映射"
    fi
    
    info "端口映射正确"
}

# 检查服务可访问性
check_services() {
    info "检查服务可访问性..."
    
    # 获取本机 IP
    IP=$(hostname -I | awk '{print $1}')
    
    # 检查前端服务
    if ! curl -s -o /dev/null -w "%{http_code}" http://$IP:80 | grep -q "200\|301\|302"; then
        warn "前端服务可能不可访问，请手动检查 http://$IP:80"
    else
        info "前端服务可访问"
    fi
    
    # 检查后端服务
    if ! curl -s -o /dev/null -w "%{http_code}" http://$IP:8000/account/login/ | grep -q "200\|301\|302"; then
        warn "后端服务可能不可访问，请手动检查 http://$IP:8000"
    else
        info "后端服务可访问"
    fi
}

# 主函数
main() {
    info "开始测试部署..."
    
    # 检查 Docker 是否安装
    if ! command -v docker &> /dev/null; then
        error "Docker 未安装，请先安装 Docker"
    fi
    
    # 检查 Docker Compose 是否安装
    if ! (docker compose version &> /dev/null || command -v docker-compose &> /dev/null); then
        error "Docker Compose 未安装，请先安装 Docker Compose"
    fi
    
    # 检查容器状态
    check_containers
    
    # 检查端口映射
    check_ports
    
    # 检查服务可访问性
    check_services
    
    info "测试完成，部署看起来正常"
    info "前端地址: http://$IP:80"
    info "后端地址: http://$IP:8000"
}

# 执行主函数
main
