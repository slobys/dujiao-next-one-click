# Release Notes

## v0.1.0

这是 `dujiao-next-one-click` 的首个可交付版本。

### 包含内容

- Dujiao-Next 一键安装脚本
- Docker / Docker Compose 自动安装
- Nginx 自动安装与反代配置
- `.env`、`config.yml`、`docker-compose.yml` 自动生成
- 容器启动与基础部署
- 可选 HTTPS 证书申请
- 系统资源与端口预检
- 升级、备份、卸载、版本检查、菜单脚本

### 当前定位

这版重点是先把项目做成：

- 结构清晰
- 能直接跑
- 能继续维护
- 能公开发布

### 后续方向

- PostgreSQL 逻辑备份
- 更稳的健康检查等待
- 失败诊断和回滚能力
- 更完善的 GitHub Actions / 发布流程
