# Dujiao-Next 一键安装项目规划

## 项目定位

为 Dujiao-Next 提供独立的一键安装脚本，不与当前工作区其他项目混用。

## 目录隔离

- 项目目录：`dujiao-next-one-click/`
- 运行目录：`/opt/dujiao-next`

## 已确认的部署方案

- 系统：Ubuntu 22.04+ / Debian 12+
- 最低配置：1C1G
- 建议配置：2C2G
- 磁盘：20GB+
- 域名：至少两个子域名
  - 前台：`shop.example.com`
  - 后台：`admin.example.com`
- API：通过 `/api` 反代到后端，不单独用域名

## 容器规划

- `redis:7-alpine`
- `postgres:16-alpine`
- `dujiaonext/api:v1.0.2`
- `dujiaonext/user:v1.0.2`
- `dujiaonext/admin:v1.0.2`

## 当前脚本能力

- 检测系统是否为 Ubuntu / Debian
- 预检内存、磁盘、关键端口占用
- 检测并安装 Docker
- 检测并安装 Nginx
- 交互输入前后台域名和镜像版本
- 自动生成随机密码和密钥
- 自动写入 `.env` / `config.yml` / `docker-compose.yml`
- 自动启动容器
- 自动写入 Nginx 配置并重载
- 可选启用 Certbot 申请 HTTPS
- 记录安装元信息
- 提供升级、备份、卸载、版本检查、菜单脚本

## 后续可增强项

- 增加 PostgreSQL 逻辑备份
- 增加容器健康等待和失败诊断
- 增加回滚脚本
- 增加防火墙和安全组提示优化
- 增加 GitHub 发布所需 CHANGELOG / LICENSE / Release 文案
