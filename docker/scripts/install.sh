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

# 检查操作系统
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
    info "检测到操作系统: $OS $VERSION"
else
    error "无法检测操作系统类型"
fi

# 安装 Docker
install_docker() {
    info "开始安装 Docker..."
    
    if command -v docker &> /dev/null; then
        warn "Docker 已安装，跳过安装步骤"
    else
        case $OS in
            ubuntu|debian)
                apt-get update
                apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
                curl -fsSL https://download.docker.com/linux/$OS/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$OS $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
                apt-get update
                apt-get install -y docker-ce docker-ce-cli containerd.io
                ;;
            centos|rhel|fedora)
                yum install -y yum-utils
                yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                yum install -y docker-ce docker-ce-cli containerd.io
                ;;
            *)
                error "不支持的操作系统: $OS"
                ;;
        esac
        
        # 启动 Docker
        systemctl enable docker
        systemctl start docker
        info "Docker 安装完成"
    fi
}

# 安装 Docker Compose
install_docker_compose() {
    info "开始安装 Docker Compose..."
    
    if command -v docker-compose &> /dev/null; then
        warn "Docker Compose 已安装，跳过安装步骤"
    else
        COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
        curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
        info "Docker Compose 安装完成"
    fi
}

# 安装依赖工具
install_dependencies() {
    info "安装依赖工具..."
    
    case $OS in
        ubuntu|debian)
            apt-get update
            apt-get install -y curl wget git
            ;;
        centos|rhel|fedora)
            yum install -y curl wget git
            ;;
        *)
            error "不支持的操作系统: $OS"
            ;;
    esac
    
    info "依赖工具安装完成"
}

# 主函数
main() {
    info "开始安装 SPUG 部署环境..."
    
    install_dependencies
    install_docker
    install_docker_compose
    
    # 验证安装
    docker --version
    docker-compose --version
    
    info "SPUG 部署环境安装完成！"
    info "请运行 './deploy.sh' 开始部署应用"
}

# 执行主函数
main
