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

# 检查操作系统和架构
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID

    # 检测架构
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)
            ARCH="amd64"
            ;;
        aarch64)
            ARCH="arm64"
            ;;
        armv7l)
            ARCH="armv7"
            ;;
        *)
            warn "未知架构: $ARCH，将尝试使用 amd64"
            ARCH="amd64"
            ;;
    esac

    info "检测到操作系统: $OS $VERSION ($ARCH)"

    # 对 Ubuntu 系统进行特殊处理
    if [ "$OS" = "ubuntu" ]; then
        info "检测到 Ubuntu 系统，将使用 Ubuntu 专用配置"
    fi
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
            ubuntu)
                apt-get update
                apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
                # 使用清华源安装Docker
                curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/$OS/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/$OS $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
                apt-get update
                apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
                ;;
            debian)
                apt-get update
                apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
                # 使用清华源安装Docker
                curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/$OS/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/$OS $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
                apt-get update
                apt-get install -y docker-ce docker-ce-cli containerd.io
                ;;
            centos|rhel|fedora)
                yum install -y yum-utils
                # 使用清华源安装Docker
                yum-config-manager --add-repo https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/docker-ce.repo
                sed -i 's+download.docker.com+mirrors.tuna.tsinghua.edu.cn/docker-ce+' /etc/yum.repos.d/docker-ce.repo
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

# 安装 Docker Compose 插件
install_docker_compose() {
<<<<<<< HEAD
    info "开始安装 Docker Compose 插件..."

    if docker compose version &> /dev/null; then
        warn "Docker Compose 插件已安装，跳过安装步骤"
=======
    info "开始安装 Docker Compose..."

    if command -v docker-compose &> /dev/null; then
        warn "Docker Compose 已安装，跳过安装步骤"
>>>>>>> 6bcbe8bf843ed564402aa8b772bede61b4d951fe
    else
        case $OS in
            ubuntu|debian)
                info "使用 apt 安装 Docker Compose 插件"
                apt-get update
                apt-get install -y docker-compose-plugin
                ;;
            centos|rhel|fedora)
                info "使用 yum 安装 Docker Compose 插件"
                yum install -y docker-compose-plugin
                ;;
            *)
                warn "不支持的操作系统: $OS，尝试使用 pip 安装"
                if ! command -v pip3 &> /dev/null; then
                    case $OS in
                        ubuntu|debian)
                            apt-get update
                            apt-get install -y python3-pip
                            ;;
                        centos|rhel|fedora)
                            yum install -y python3-pip
                            ;;
                    esac
                fi
                pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple docker-compose
                ;;
        esac
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
<<<<<<< HEAD
    docker compose version || docker-compose --version
=======
    docker-compose --version
>>>>>>> 6bcbe8bf843ed564402aa8b772bede61b4d951fe

    info "SPUG 部署环境安装完成！"
    info "请运行 './deploy.sh' 开始部署应用"
}

# 执行主函数
main
