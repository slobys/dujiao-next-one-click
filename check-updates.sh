#!/usr/bin/env bash
set -Eeuo pipefail

INSTALL_DIR="/opt/dujiao-next"
ENV_FILE="${INSTALL_DIR}/.env"

red(){ printf '\033[31m%s\033[0m\n' "$*"; }
green(){ printf '\033[32m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }

[[ -f "$ENV_FILE" ]] || { red "未找到 ${ENV_FILE}，请先安装"; exit 1; }
CURRENT_TAG=$(grep '^TAG=' "$ENV_FILE" | cut -d= -f2-)

echo "当前安装版本: ${CURRENT_TAG}"
echo "上游版本请查看: https://github.com/dujiao-next/dujiao-next/releases"
yellow "如果你确认新版本可用，可执行: sudo ./update.sh <TAG>"
