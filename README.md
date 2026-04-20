# dujiao-next-one-click

![Platform](https://img.shields.io/badge/platform-Ubuntu%2022.04%2B%20%7C%20Debian%2012%2B-0A84FF)
![Shell](https://img.shields.io/badge/script-bash-121011)
![License](https://img.shields.io/badge/license-MIT-green)
![Release](https://img.shields.io/github/v/release/slobys/dujiao-next-one-click)

面向 **Ubuntu 22.04+ / Debian 12+** 的 **Dujiao-Next 一键安装脚本**。

用一个脚本完成 Docker、Compose、Nginx、容器部署，以及后续升级、备份、卸载。

## 快速开始

```bash
git clone https://github.com/slobys/dujiao-next-one-click.git
cd dujiao-next-one-click
chmod +x install.sh update.sh uninstall.sh backup.sh check-updates.sh menu.sh
sudo ./install.sh
```

菜单模式：

```bash
sudo ./menu.sh
```

## 项目特性

- 一键安装 Docker、Docker Compose、Nginx
- 自动生成 `.env`、`config.yml`、`docker-compose.yml`
- 自动部署 `redis`、`postgres`、`api`、`user`、`admin`
- 支持可选 HTTPS 和常见防火墙处理
- 提供升级、备份、卸载、版本检查、菜单脚本

## 适用环境

- Ubuntu 22.04+
- Debian 12+
- 建议 root 运行
- 最低 1C1G，建议 2C2G
- 至少两个子域名

推荐域名规划：

- 前台商城: `shop.example.com`
- 后台管理: `admin.example.com`
- API: 通过 `/api` 反代，不单独使用子域名

## 端口建议

公网通常只需要放行：

- `22/tcp`
- `80/tcp`
- `443/tcp`

## 常用命令

```bash
# 安装
sudo ./install.sh

# 升级
sudo ./update.sh
sudo ./update.sh v1.0.3

# 备份
sudo ./backup.sh

# 卸载
sudo ./uninstall.sh

# 查看版本提示
./check-updates.sh
```

## 安装说明

安装时会提示输入：

- 前台域名
- 后台域名
- 镜像版本 TAG，默认优先自动获取官方最新 release，失败时回退到 `v1.0.2`
- 是否立即申请 HTTPS

TAG 应填写版本号，例如：

- `v1.0.2`
- `latest`

如果你直接回车，脚本会优先使用自动检测到的最新版本。

不要把域名填到 TAG 位置。

脚本还会额外处理：

- `ufw` 环境自动放行 `22/tcp`、`80/tcp`、`443/tcp`
- `firewalld` 环境自动放行 `ssh`、`http`、`https`
- `nftables` / `iptables` 环境给出手动提示
- 不会直接关闭防火墙
- 仍需自行确认云安全组 / 云防火墙已放行 `80` 和 `443`

## 目录结构

```text
dujiao-next-one-click/
├─ install.sh
├─ update.sh
├─ uninstall.sh
├─ backup.sh
├─ check-updates.sh
├─ menu.sh
├─ README.md
├─ CHANGELOG.md
├─ RELEASE.md
├─ LICENSE
├─ .gitignore
└─ docs/
   └─ plan.md
```

## 当前版本内容

- 系统兼容性判断
- 内存 / 磁盘预检
- 端口占用检测
- 防火墙规则预处理
- 自定义镜像版本输入校验
- 安装后元信息记录
- 升级 / 备份 / 卸载配套脚本

## 后续计划

- PostgreSQL 逻辑备份
- 健康检查等待与失败诊断
- 回滚脚本
- GitHub Actions 或自动发布流程
