#!/usr/bin/env bash
set -Eeuo pipefail

INSTALL_DIR="/opt/dujiao-next"
ENV_FILE="${INSTALL_DIR}/.env"
NGINX_CONF="/etc/nginx/conf.d/dujiao-next.conf"

red(){ printf '\033[31m%s\033[0m\n' "$*"; }
green(){ printf '\033[32m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }

[[ ${EUID} -eq 0 ]] || { red "请用 root 运行"; exit 1; }
[[ -d "$INSTALL_DIR" ]] || { red "未找到安装目录 ${INSTALL_DIR}"; exit 1; }

read -r -p "是否停止并卸载 Dujiao-Next？这会删除容器和安装目录 [y/N]: " CONFIRM
CONFIRM="$(printf '%s' "$CONFIRM" | tr '[:upper:]' '[:lower:]')"
[[ "$CONFIRM" == "y" || "$CONFIRM" == "yes" ]] || { yellow "已取消"; exit 0; }

if [[ -f "$ENV_FILE" ]]; then
  cd "$INSTALL_DIR"
  docker compose --env-file "$ENV_FILE" down -v || true
fi

rm -rf "$INSTALL_DIR"
rm -f "$NGINX_CONF"
nginx -t && systemctl reload nginx || true

green "卸载完成"
yellow "如果你还申请过 HTTPS 证书，Certbot 证书文件不会自动删除，需要你自己按需清理"
