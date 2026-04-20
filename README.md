# dujiao-next-one-click

面向 **Ubuntu 22.04+ / Debian 12+** 的 **Dujiao-Next 一键安装脚本**。

用一个脚本完成 Docker、Compose、Nginx、容器部署，以及后续升级、备份、卸载。

## 快速开始

```bash
git clone https://github.com/slobys/dujiao-next-one-click.git
cd dujiao-next-one-click
chmod +x install.sh update.sh uninstall.sh backup.sh check-updates.sh menu.sh
sudo ./install.sh
```

如需菜单模式：

```bash
sudo ./menu.sh
```

## 项目特性

- 一键安装 Docker / Docker Compose / Nginx
- 自动生成 `.env`、`config/config.yml`、`docker-compose.yml`
- 自动启动 `redis`、`postgres`、`api`、`user`、`admin`
- 自动写入 Nginx 反向代理配置
- 支持可选 HTTPS
- 自动处理常见防火墙放行逻辑（ufw / firewalld）
- 提供升级、备份、卸载、版本检查、菜单脚本

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

## 常用命令

### 安装

```bash
sudo ./install.sh
```

### 升级

```bash
sudo ./update.sh
sudo ./update.sh v1.0.3
```

### 备份

```bash
sudo ./backup.sh
```

### 卸载

```bash
sudo ./uninstall.sh
```

### 查看版本提示

```bash
./check-updates.sh
```

## 安装说明

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

## 后续可增强

- PostgreSQL 逻辑备份
- 健康检查等待与失败诊断
- 回滚脚本
- GitHub Actions 或自动发布流程
