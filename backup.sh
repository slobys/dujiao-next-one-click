#!/usr/bin/env bash
set -Eeuo pipefail

INSTALL_DIR="/opt/dujiao-next"
ENV_FILE="${INSTALL_DIR}/.env"
BACKUP_ROOT="/opt/dujiao-next-backups"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"

red(){ printf '\033[31m%s\033[0m\n' "$*"; }
green(){ printf '\033[32m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }

[[ ${EUID} -eq 0 ]] || { red "请用 root 运行"; exit 1; }
[[ -d "$INSTALL_DIR" ]] || { red "未找到安装目录 ${INSTALL_DIR}"; exit 1; }

mkdir -p "$BACKUP_DIR"
cp -a "$INSTALL_DIR/." "$BACKUP_DIR/"

if [[ -f "$ENV_FILE" ]]; then
  cd "$INSTALL_DIR"
  docker compose --env-file "$ENV_FILE" ps > "${BACKUP_DIR}/docker-compose.ps.txt" || true
fi

tar -czf "${BACKUP_ROOT}/dujiao-next-backup-${TIMESTAMP}.tar.gz" -C "$BACKUP_ROOT" "$TIMESTAMP"

green "备份完成"
echo "目录备份: ${BACKUP_DIR}"
echo "压缩包: ${BACKUP_ROOT}/dujiao-next-backup-${TIMESTAMP}.tar.gz"
yellow "注意: 这是文件级备份，适合快速回滚；如果后续要更稳，可以再加 PostgreSQL 逻辑备份"
