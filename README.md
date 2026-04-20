# dujiao-next-one-click

一个面向 **Ubuntu 22.04+ / Debian 12+** 的 **Dujiao-Next 一键安装项目**。

目标不是只给一串能跑的命令，而是把 Dujiao-Next 的部署整理成一套更适合长期维护、后续升级、公开分享的脚本项目。

## 一句话说明

用一个脚本完成 Dujiao-Next 的基础部署，自动处理 Docker、Compose、Nginx、配置文件、容器启动，以及后续的升级、备份、卸载。

## 项目亮点

- 单脚本安装，尽量减少手工操作
- 自动生成部署配置，避免手写出错
- 自动配置 Nginx 反向代理
- 自动处理常见防火墙放行逻辑（ufw / firewalld）
- 支持可选 HTTPS
- 自带升级、备份、卸载、菜单脚本
- 适合整理后直接发布到 GitHub

## 已完成能力

- 一键安装 Docker / Docker Compose
- 一键安装并启用 Nginx
- 自动创建 `/opt/dujiao-next` 目录结构
- 自动生成 `.env`、`config/config.yml`、`docker-compose.yml`
- 自动启动 `redis`、`postgres`、`api`、`user`、`admin`
- 自动写入 Nginx 反向代理配置
- 自动处理常见防火墙放行规则
- 可选一键申请 HTTPS
- 增加系统预检（系统、内存、磁盘、端口）
- 提供升级、备份、卸载、菜单脚本

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

## 适用环境

- Ubuntu 22.04+
- Debian 12+
- 建议 root 运行
- 最低 1C1G，建议 2C2G
- 磁盘建议 20GB+
- 至少两个子域名

推荐域名规划：

- 前台商城: `shop.example.com`
- 后台管理: `admin.example.com`
- API: 通过 `/api` 反代，不单独使用子域名

## 端口与安全组建议

对当前脚本的默认部署方式，公网通常只需要放行：

- `22/tcp`
- `80/tcp`
- `443/tcp`

## 快速开始

如果你只是想先跑起来，直接执行：

```bash
git clone https://github.com/slobys/dujiao-next-one-click.git
cd dujiao-next-one-click
chmod +x install.sh update.sh uninstall.sh backup.sh check-updates.sh menu.sh
sudo ./install.sh
```

或者使用菜单：

```bash
git clone https://github.com/slobys/dujiao-next-one-click.git
cd dujiao-next-one-click
chmod +x install.sh update.sh uninstall.sh backup.sh check-updates.sh menu.sh
sudo ./menu.sh
```

## 脚本说明

### 0. 先获取项目文件

如果你的服务器上还没有这个项目目录，先执行：

```bash
git clone https://github.com/slobys/dujiao-next-one-click.git
cd dujiao-next-one-click
```

然后再执行安装、升级、备份、卸载等脚本。


### 1. 安装

```bash
sudo ./install.sh
```

安装时会提示输入：

- 前台域名
- 后台域名
- 镜像版本 TAG，默认 `v1.0.2`
- 是否立即申请 HTTPS

其中镜像版本 TAG 应填写版本号，例如：

- `v1.0.2`
- `latest`

不要把域名填到 TAG 位置。

脚本还会额外处理：

- 如果检测到 `ufw`，自动放行 `22/tcp`、`80/tcp`、`443/tcp`
- 如果检测到 `firewalld`，自动放行 `ssh`、`http`、`https`
- 如果检测到 `nftables` 或 `iptables`，会给出手动放行提示，不会粗暴改现有规则
- 不会直接关闭防火墙
- 仍然需要你自己确认云厂商安全组 / 云防火墙已放行 `80` 和 `443`

### 2. 升级

```bash
sudo ./update.sh
```

也可以直接指定版本：

```bash
sudo ./update.sh v1.0.3
```

### 3. 备份

```bash
sudo ./backup.sh
```

默认会把当前 `/opt/dujiao-next` 完整复制到：

- `/opt/dujiao-next-backups/时间戳/`
- `/opt/dujiao-next-backups/dujiao-next-backup-时间戳.tar.gz`

### 4. 卸载

```bash
sudo ./uninstall.sh
```

会执行：

- 停止并删除容器
- 删除安装目录 `/opt/dujiao-next`
- 删除 Nginx 配置 `/etc/nginx/conf.d/dujiao-next.conf`

### 5. 查看版本提示

```bash
./check-updates.sh
```

## 仓库发布建议

建议仓库名：

```text
dujiao-next-one-click
```

建议首版标签：

```text
v0.1.0
```

GitHub 发布可直接参考：

- `RELEASE.md`
- `docs/github-release-assets.md`

## 当前版本打磨内容

相比最初草案，这一版已经补上：

- 系统兼容性判断
- 内存 / 磁盘预检
- 端口占用检测
- 防火墙规则预处理
- 自定义镜像版本输入
- 更完整的错误提示
- 安装后元信息记录
- 升级 / 备份 / 卸载配套脚本

## 还可以继续增强的点

下一轮我建议再补：

- PostgreSQL 逻辑备份
- 健康检查等待与失败诊断
- 回滚脚本
- GitHub Actions 或自动发布流程
