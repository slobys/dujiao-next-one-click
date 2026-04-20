#!/usr/bin/env bash
set -Eeuo pipefail

INSTALL_DIR="/opt/dujiao-next"
ENV_FILE="${INSTALL_DIR}/.env"
META_FILE="${INSTALL_DIR}/install-meta.env"

red(){ printf '\033[31m%s\033[0m\n' "$*"; }
green(){ printf '\033[32m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }

[[ ${EUID} -eq 0 ]] || { red "请用 root 运行"; exit 1; }
[[ -f "$ENV_FILE" ]] || { red "未找到 ${ENV_FILE}，请先安装"; exit 1; }

if [[ -f "$META_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$META_FILE"
fi

CURRENT_TAG=$(grep '^TAG=' "$ENV_FILE" | cut -d= -f2-)
TARGET_TAG="${1:-}"

if [[ -z "$TARGET_TAG" ]]; then
  read -r -p "请输入要升级到的 TAG [当前 ${CURRENT_TAG}]: " TARGET_TAG
  TARGET_TAG="${TARGET_TAG:-$CURRENT_TAG}"
fi

sed -i "s/^TAG=.*/TAG=${TARGET_TAG}/" "$ENV_FILE"
cd "$INSTALL_DIR"
docker compose --env-file "$ENV_FILE" pull
docker compose --env-file "$ENV_FILE" up -d
docker compose --env-file "$ENV_FILE" ps

green "升级完成: ${CURRENT_TAG} -> ${TARGET_TAG}"
