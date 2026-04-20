# GitHub 发布素材

## 仓库名称

```text
dujiao-next-one-click
```

## 仓库简介（短描述）

```text
Dujiao-Next 一键安装脚本，支持 Docker、Nginx、HTTPS、升级、备份和卸载，适用于 Ubuntu / Debian。
```

## 仓库简介（英文短描述，可选）

```text
One-click installer for Dujiao-Next with Docker, Nginx, HTTPS, update, backup, and uninstall support for Ubuntu and Debian.
```

## Topics 建议

```text
dujiao-next
shell
bash
docker
docker-compose
nginx
installer
one-click
ubuntu
debian
vps
self-hosted
```

## GitHub About 页可放链接

- 项目主页: 暂空
- 文档入口: `README.md`
- 首发版本: `v0.1.0`

## 首发 Release 标题

```text
v0.1.0 · Initial release of dujiao-next-one-click
```

## 首发 Release 文案（中文）

```markdown
## dujiao-next-one-click v0.1.0

这是项目的首个可交付版本，目标是把 Dujiao-Next 的部署流程整理成一套更适合长期维护和公开分享的一键安装脚本。

### 本版已支持

- 一键安装 Docker / Docker Compose
- 一键安装并启用 Nginx
- 自动创建 `/opt/dujiao-next` 目录结构
- 自动生成 `.env`、`config/config.yml`、`docker-compose.yml`
- 自动启动 `redis`、`postgres`、`api`、`user`、`admin`
- 自动写入 Nginx 反向代理配置
- 可选申请 HTTPS 证书
- 系统、内存、磁盘、端口预检
- 提供升级、备份、卸载、版本检查、菜单脚本

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

欢迎试用和反馈。
```

## 首发 Release 文案（英文，可选）

```markdown
## dujiao-next-one-click v0.1.0

This is the first deliverable release of the project. The goal is to turn the Dujiao-Next deployment process into a cleaner, maintainable, and shareable one-click installer.

### Included in this release

- One-click Docker and Docker Compose installation
- One-click Nginx installation and enablement
- Automatic generation of `.env`, `config/config.yml`, and `docker-compose.yml`
- Automatic startup of `redis`, `postgres`, `api`, `user`, and `admin`
- Automatic Nginx reverse proxy configuration
- Optional HTTPS setup with Certbot
- System, memory, disk, and port pre-checks
- Update, backup, uninstall, version check, and menu scripts

### Target environment

- Ubuntu 22.04+
- Debian 12+
- Recommended 2C2G
- At least two subdomains

### Quick start

```bash
chmod +x install.sh update.sh uninstall.sh backup.sh check-updates.sh menu.sh
sudo ./install.sh
```

### Planned improvements

- PostgreSQL logical backup
- Better health waiting and failure diagnostics
- Rollback script
- Automated release workflow
```
