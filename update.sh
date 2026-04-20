#!/usr/bin/env bash
set -Eeuo pipefail

INSTALL_DIR="/opt/dujiao-next"
ENV_FILE="${INSTALL_DIR}/.env"
META_FILE="${INSTALL_DIR}/install-meta.env"
DEFAULT_TAG="v1.0.2"

red(){ printf '\033[31m%s\033[0m\n' "$*"; }
green(){ printf '\033[32m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }
blue(){ printf '\033[36m%s\033[0m\n' "$*"; }

validate_tag() {
  local tag="$1"
  [[ "$tag" =~ ^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$ ]]
}

detect_latest_tag() {
  local latest_tag=""
  latest_tag="$(curl -fsSL https://api.github.com/repos/dujiao-next/dujiao-next/releases/latest 2>/dev/null | jq -r '.tag_name // empty' 2>/dev/null || true)"
  if [[ -n "$latest_tag" ]] && validate_tag "$latest_tag"; then
    DETECTED_TAG="$latest_tag"
    green "已获取官方最新版本: ${DETECTED_TAG}"
  else
    DETECTED_TAG="$DEFAULT_TAG"
    yellow "获取官方最新版本失败，回退到默认版本: ${DETECTED_TAG}"
  fi
}

[[ ${EUID} -eq 0 ]] || { red "请用 root 运行"; exit 1; }
[[ -f "$ENV_FILE" ]] || { red "未找到 ${ENV_FILE}，请先安装"; exit 1; }

command -v curl >/dev/null 2>&1 || { red "缺少命令: curl"; exit 1; }
command -v jq >/dev/null 2>&1 || { red "缺少命令: jq"; exit 1; }
command -v docker >/dev/null 2>&1 || { red "缺少命令: docker"; exit 1; }

if [[ -f "$META_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$META_FILE"
fi

CURRENT_TAG=$(grep '^TAG=' "$ENV_FILE" | cut -d= -f2-)
detect_latest_tag
TARGET_TAG="${1:-}"

if [[ -z "$TARGET_TAG" ]]; then
  read -r -p "请输入要升级到的 TAG [默认 ${DETECTED_TAG}，当前 ${CURRENT_TAG}]: " TARGET_TAG
  TARGET_TAG="${TARGET_TAG:-$DETECTED_TAG}"
fi

validate_tag "$TARGET_TAG" || { red "TAG 格式不合法，例如 v1.0.2 或 latest"; exit 1; }

blue "升级配置确认:"
echo "  当前版本: ${CURRENT_TAG}"
echo "  目标版本: ${TARGET_TAG}"
read -r -p "确认继续升级？ [Y]: " CONFIRM
CONFIRM="${CONFIRM:-Y}"
CONFIRM="$(printf '%s' "$CONFIRM" | tr '[:upper:]' '[:lower:]')"
[[ "$CONFIRM" == "y" || "$CONFIRM" == "yes" ]] || { yellow "已取消升级"; exit 0; }

sed -i "s/^TAG=.*/TAG=${TARGET_TAG}/" "$ENV_FILE"
cd "$INSTALL_DIR"
docker compose --env-file "$ENV_FILE" pull
docker compose --env-file "$ENV_FILE" up -d
docker compose --env-file "$ENV_FILE" ps

green "升级完成: ${CURRENT_TAG} -> ${TARGET_TAG}"
