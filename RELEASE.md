# Release Notes

## v0.1.0

这是 `dujiao-next-one-click` 的首个可交付版本，目标是把 Dujiao-Next 的部署流程整理成一套更适合长期维护和公开分享的一键安装脚本。

### 本版已支持

- 一键安装 Docker / Docker Compose
- 一键安装并启用 Nginx
- 自动创建 `/opt/dujiao-next` 目录结构
- 自动生成 `.env`、`config/config.yml`、`docker-compose.yml`
- 自动启动 `redis`、`postgres`、`api`、`user`、`admin`
- 自动写入 Nginx 反向代理配置
- 可选申请 HTTPS 证书
- 系统、内存、磁盘、端口预检
- 升级、备份、卸载、版本检查、菜单脚本

### 适用环境

- Ubuntu 22.04+
- Debian 12+
- 建议 2C2G
- 至少两个子域名

### 快速开始

```bash
chmod +x install.sh update.sh uninstall.sh backup.sh check-updates.sh menu.sh
sudo ./install.sh
```

### 后续计划

- PostgreSQL 逻辑备份
- 健康检查等待与失败诊断
- 回滚脚本
- 自动发布流程
