/**
 * Copyright (c) OpenSpug Organization. https://github.com/openspug/spug
 * Copyright (c) <spug.dev@gmail.com>
 * Released under the AGPL-3.0 License.
 */
const proxy = require('http-proxy-middleware');

module.exports = function (app) {
  // 使用localhost代替硬编码IP，便于部署
  const target = 'http://localhost:8000';

  // 定义所有需要代理的API路径
  const paths = [
    '/account',
    '/host',
    '/exec',
    '/schedule',
    '/monitor',
    '/setting',
    '/config',
    '/app',
    '/deploy',
    '/repository',
    '/home',
    '/notify',
    '/file',
    '/apis',
    '/dashboard'  // 添加dashboard路径
  ];

  // 为每个路径创建代理
  paths.forEach(path => {
    app.use(
      path,
      proxy({
        target: target,
        changeOrigin: true,
        headers: {
          'X-Real-IP': '127.0.0.1',
          'X-Forwarded-For': '127.0.0.1'
        }
      })
    );
  });

  // 添加/api前缀的代理规则，将/api请求重写到相应的后端路径
  app.use(
    '/api',
    proxy({
      target: target,
      pathRewrite: {'^/api': ''},  // 将 /api 前缀重写为空
      changeOrigin: true,
      headers: {
        'X-Real-IP': '127.0.0.1',
        'X-Forwarded-For': '127.0.0.1'
      }
    })
  );

  // 单独处理websocket连接
  app.use(
    '/ws',
    proxy({
      target: target,
      changeOrigin: true,
      ws: true,
      headers: {
        'X-Real-IP': '127.0.0.1',
        'X-Forwarded-For': '127.0.0.1'
      }
    })
  );
};
