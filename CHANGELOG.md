# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2026-04-20

### Added
- 初始化独立项目 `dujiao-next-one-click`
- 新增 `install.sh`，支持 Dujiao-Next 一键部署
- 支持自动安装 Docker / Docker Compose / Nginx
- 支持生成 `.env`、`config/config.yml`、`docker-compose.yml`
- 支持自动启动 `redis`、`postgres`、`api`、`user`、`admin`
- 支持自动写入 Nginx 反向代理配置
- 支持可选申请 HTTPS 证书
- 增加系统预检，包括系统、内存、磁盘、端口占用检测
- 新增 `update.sh` 用于镜像版本升级
- 新增 `backup.sh` 用于文件级备份
- 新增 `uninstall.sh` 用于卸载部署
- 新增 `check-updates.sh` 用于查看版本更新提示
- 新增 `menu.sh` 作为统一入口菜单
- 补充 README 和项目规划文档

### Notes
- 当前版本适合 Ubuntu 22.04+ / Debian 12+
- 当前备份为文件级备份，后续可继续增强 PostgreSQL 逻辑备份
