# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Changed
- `install.sh` 现在会在检测到 `ufw` 时自动放行 `22/tcp`、`80/tcp`、`443/tcp`，避免 HTTPS 申请因本机防火墙拦截而失败
- `install.sh` 现在也会兼容 `firewalld`，自动放行 `ssh`、`http`、`https`
- 对 `nftables` 和 `iptables` 环境改为输出明确提示，避免脚本粗暴修改已有规则
- README 补充防火墙和云安全组说明，明确脚本不会直接关闭防火墙
- README 和安装提示改为更精简的公网端口说明，仅保留默认放行 22、80、443 的必要信息
- `install.sh` 现在会校验镜像 TAG，并在 TAG 看起来像域名时直接阻止继续安装
- 修正 TAG 域名误判逻辑，避免把 `v1.0.2` 这类合法版本号错误识别成域名
- 修正安装完成后的摘要输出，在启用 HTTPS 时直接输出 `https://` 访问地址
- 安装时会优先自动获取 Dujiao-Next 官方最新 release 作为默认 TAG，失败时回退到内置版本
- `update.sh` 现在也会优先自动获取官方最新 release 作为默认升级目标，并在升级前展示确认信息

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
