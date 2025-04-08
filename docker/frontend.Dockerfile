# 构建阶段
FROM node:14-alpine AS build

# 设置工作目录
WORKDIR /app

# 安装依赖
COPY ../spug_web/package*.json ./
RUN npm config set registry https://registry.npmmirror.com && \
    npm install

# 复制源代码
COPY ../spug_web/ ./

# 构建应用
RUN npm run build

# 生产阶段
FROM nginx:alpine

# 复制构建产物
COPY --from=build /app/build /usr/share/nginx/html

# 复制 Nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 80

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# 启动 Nginx
CMD ["nginx", "-g", "daemon off;"]
