# 使用华为云镜像源的 Python 镜像
FROM swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/python:3.8-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TZ=Asia/Shanghai

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    git \
    sshpass \
    default-libmysqlclient-dev \
    libldap2-dev \
    libsasl2-dev \
    libssl-dev \
    build-essential \
    python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装 Python 依赖
COPY ../spug_api/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple \
    && pip install --no-cache-dir gunicorn -i https://pypi.tuna.tsinghua.edu.cn/simple \
    && pip install --no-cache-dir "urllib3<2.0.0" -i https://pypi.tuna.tsinghua.edu.cn/simple

# 复制项目文件
COPY ../spug_api/ .

# 创建必要的目录
RUN mkdir -p logs storage repos

# 修改配置文件中的路径为相对路径
RUN sed -i 's|/var/log/spug|logs|g' spug/production.py

# 初始化数据库
RUN python manage.py updatedb

# 暴露端口
EXPOSE 8000

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s CMD curl --fail http://localhost:8000/account/login/ || exit 1

# 启动命令
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "--timeout", "300", "spug.wsgi:application"]
