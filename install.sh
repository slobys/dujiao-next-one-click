#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_NAME="dujiao-next"
PROJECT_SLUG="dujiao-next-one-click"
INSTALL_DIR="/opt/dujiao-next"
BACKUP_DIR="/opt/dujiao-next-backups"
COMPOSE_FILE="${INSTALL_DIR}/docker-compose.yml"
ENV_FILE="${INSTALL_DIR}/.env"
CONFIG_FILE="${INSTALL_DIR}/config/config.yml"
NGINX_CONF="/etc/nginx/conf.d/dujiao-next.conf"
DEFAULT_TAG="v1.0.2"
TZ_VALUE="Asia/Shanghai"
API_PORT="8080"
USER_PORT="8081"
ADMIN_PORT="8082"
MIN_MEM_MB=900
MIN_DISK_MB=5120

red(){ printf '\033[31m%s\033[0m\n' "$*"; }
green(){ printf '\033[32m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }
blue(){ printf '\033[36m%s\033[0m\n' "$*"; }
section(){ printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }

on_error() {
  local exit_code=$?
  red "安装过程中出错，退出码: ${exit_code}"
  red "如果已经写入了部分文件，可检查 ${INSTALL_DIR} 和 ${NGINX_CONF}"
  exit "$exit_code"
}
trap on_error ERR

require_root() {
  if [[ ${EUID} -ne 0 ]]; then
    red "请用 root 运行此脚本"
    exit 1
  fi
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    red "缺少命令: $1"
    exit 1
  }
}

prompt_value() {
  local var_name="$1"
  local prompt_text="$2"
  local default_value="${3:-}"
  local input=""
  if [[ -n "$default_value" ]]; then
    read -r -p "$prompt_text [$default_value]: " input
    input="${input:-$default_value}"
  else
    while [[ -z "$input" ]]; do
      read -r -p "$prompt_text: " input
    done
  fi
  printf -v "$var_name" '%s' "$input"
}

confirm_action() {
  local prompt_text="$1"
  local default_value="${2:-N}"
  local input=""
  read -r -p "$prompt_text [$default_value]: " input
  input="${input:-$default_value}"
  input="$(printf '%s' "$input" | tr '[:upper:]' '[:lower:]')"
  [[ "$input" == "y" || "$input" == "yes" ]]
}

check_os() {
  section "系统检测"
  if [[ ! -f /etc/os-release ]]; then
    red "无法识别系统版本"
    exit 1
  fi
  # shellcheck disable=SC1091
  source /etc/os-release
  case "${ID:-}" in
    ubuntu|debian)
      green "检测到系统: ${PRETTY_NAME:-$ID}"
      ;;
    *)
      red "当前仅支持 Ubuntu / Debian，检测到: ${PRETTY_NAME:-$ID}"
      exit 1
      ;;
  esac
}

check_resources() {
  local mem_mb disk_mb arch
  mem_mb=$(awk '/MemTotal/ {printf "%d", $2/1024}' /proc/meminfo)
  disk_mb=$(df -Pm / | awk 'NR==2 {print $4}')
  arch=$(uname -m)

  blue "系统架构: ${arch}"
  blue "可用内存: ${mem_mb} MB"
  blue "根分区可用空间: ${disk_mb} MB"

  if (( mem_mb < MIN_MEM_MB )); then
    yellow "内存低于建议值 ${MIN_MEM_MB} MB，1G 机器可以跑，但稳定性可能一般"
  fi
  if (( disk_mb < MIN_DISK_MB )); then
    red "磁盘可用空间不足，至少建议 ${MIN_DISK_MB} MB"
    exit 1
  fi
}

check_ports() {
  section "端口检测"
  local ports=(80 443 "$API_PORT" "$USER_PORT" "$ADMIN_PORT")
  local busy=0
  for port in "${ports[@]}"; do
    if ss -lnt 2>/dev/null | awk '{print $4}' | grep -Eq "(^|:)${port}$"; then
      yellow "端口已被占用: ${port}"
      busy=1
    fi
  done
  if (( busy == 1 )); then
    if ! confirm_action "检测到端口占用，仍然继续吗？" "N"; then
      red "已取消安装，请先释放冲突端口"
      exit 1
    fi
  else
    green "关键端口检测通过"
  fi
}

validate_domain() {
  local domain="$1"
  [[ "$domain" =~ ^[A-Za-z0-9.-]+$ ]]
}

collect_inputs() {
  section "收集部署信息"
  prompt_value SHOP_DOMAIN "请输入前台域名" "shop.example.com"
  prompt_value ADMIN_DOMAIN "请输入后台域名" "admin.example.com"
  prompt_value INPUT_TAG "请输入镜像版本 TAG" "$DEFAULT_TAG"
  prompt_value ENABLE_HTTPS "是否立即申请 HTTPS? (y/N)" "N"
  ENABLE_HTTPS="$(printf '%s' "$ENABLE_HTTPS" | tr '[:upper:]' '[:lower:]')"

  validate_domain "$SHOP_DOMAIN" || { red "前台域名格式不合法"; exit 1; }
  validate_domain "$ADMIN_DOMAIN" || { red "后台域名格式不合法"; exit 1; }
  [[ "$SHOP_DOMAIN" != "$ADMIN_DOMAIN" ]] || { red "前后台域名不能相同"; exit 1; }
  TAG="$INPUT_TAG"
}

install_base_packages() {
  section "安装基础依赖"
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y curl openssl ca-certificates gnupg lsb-release wget jq
}

install_docker_if_needed() {
  section "检查 Docker"
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    green "Docker 和 Docker Compose 已安装，跳过"
    systemctl enable --now docker
    return
  fi
  yellow "开始安装 Docker 和 Docker Compose"
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sh /tmp/get-docker.sh
  systemctl enable --now docker
}

install_nginx_if_needed() {
  section "检查 Nginx"
  if ! dpkg -s nginx >/dev/null 2>&1; then
    yellow "安装 Nginx"
    apt-get install -y nginx
  fi
  systemctl enable --now nginx
}

configure_firewall() {
  section "配置防火墙规则"

  if command -v ufw >/dev/null 2>&1; then
    ufw allow 22/tcp >/dev/null 2>&1 || true
    ufw allow 80/tcp >/dev/null 2>&1 || true
    ufw allow 443/tcp >/dev/null 2>&1 || true

    if ufw status 2>/dev/null | grep -q "Status: active"; then
      ufw reload >/dev/null 2>&1 || true
      green "已为活动中的 ufw 放行 22、80、443 端口"
    else
      green "已写入 ufw 规则 22、80、443（当前 ufw 未启用，若后续启用会自动生效）"
    fi

    yellow "请同时确认云厂商安全组 / 云防火墙已放行 80 和 443，通常公网只需要放行 22、80、443"
    return
  fi

  if command -v firewall-cmd >/dev/null 2>&1; then
    firewall-cmd --permanent --add-service=ssh >/dev/null 2>&1 || true
    firewall-cmd --permanent --add-service=http >/dev/null 2>&1 || true
    firewall-cmd --permanent --add-service=https >/dev/null 2>&1 || true

    if systemctl is-active --quiet firewalld; then
      firewall-cmd --reload >/dev/null 2>&1 || true
      green "已为活动中的 firewalld 放行 ssh、http、https"
    else
      green "已写入 firewalld 永久规则 ssh、http、https（当前 firewalld 未运行）"
    fi

    yellow "请同时确认云厂商安全组 / 云防火墙已放行 80 和 443，通常公网只需要放行 22、80、443"
    return
  fi

  if command -v nft >/dev/null 2>&1 && systemctl is-active --quiet nftables; then
    yellow "检测到 nftables 在运行，脚本暂不自动改 nft 规则，请手动放行 22、80、443"
    yellow "示例: nft add rule inet filter input tcp dport {22,80,443} accept"
    yellow "同时请确认云厂商安全组 / 云防火墙已放行 80 和 443，通常公网只需要放行 22、80、443"
    yellow "不建议暴露 6379、5432，8080、8081、8082 默认仅供本机 Nginx 使用"
    return
  fi

  if command -v iptables >/dev/null 2>&1; then
    yellow "检测到 iptables 环境，脚本暂不直接改现有 iptables 规则，以免误伤已有策略"
    yellow "请手动放行 22、80、443，并确认云厂商安全组 / 云防火墙已放行 80 和 443"
    yellow "不建议暴露 6379、5432，8080、8081、8082 默认仅供本机 Nginx 使用"
    return
  fi

  yellow "未检测到受支持的主机防火墙工具，请自行确认本机和云防火墙已放行 22、80、443，不建议暴露 6379、5432"
}

create_dirs() {
  section "创建目录"
  mkdir -p "${INSTALL_DIR}/config" "${INSTALL_DIR}/data/uploads" "${INSTALL_DIR}/data/logs" "${INSTALL_DIR}/data/redis" "${INSTALL_DIR}/data/postgres"
  chmod -R 0777 "${INSTALL_DIR}/data/logs" "${INSTALL_DIR}/data/uploads" "${INSTALL_DIR}/data/redis" "${INSTALL_DIR}/data/postgres"
}

generate_secrets() {
  section "生成随机密钥"
  REDIS_PASSWORD="$(openssl rand -hex 16)"
  POSTGRES_PASSWORD="$(openssl rand -hex 16)"
  ADMIN_PASS="Admin@$(openssl rand -hex 8)"
  APP_SECRET="$(openssl rand -hex 16)"
  JWT_SECRET="$(openssl rand -hex 32)"
  USER_JWT_SECRET="$(openssl rand -hex 32)"
}

write_env() {
  cat > "$ENV_FILE" <<EOF
TAG=${TAG}
TZ=${TZ_VALUE}

API_PORT=${API_PORT}
USER_PORT=${USER_PORT}
ADMIN_PORT=${ADMIN_PORT}

DJ_DEFAULT_ADMIN_USERNAME=admin
DJ_DEFAULT_ADMIN_PASSWORD=${ADMIN_PASS}

REDIS_PASSWORD=${REDIS_PASSWORD}

POSTGRES_DB=dujiao_next
POSTGRES_USER=dujiao
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
EOF
}

write_config() {
  cat > "$CONFIG_FILE" <<EOF
app:
  secret_key: "${APP_SECRET}"

server:
  host: 0.0.0.0
  port: 8080
  mode: release

log:
  dir: /app/logs
  filename: app.log
  max_size_mb: 100
  max_backups: 14
  max_age_days: 30
  compress: true

database:
  driver: postgres
  dsn: host=postgres user=dujiao password=${POSTGRES_PASSWORD} dbname=dujiao_next port=5432 sslmode=disable TimeZone=Asia/Shanghai
  pool:
    max_open_conns: 20
    max_idle_conns: 5
    conn_max_lifetime_seconds: 1200
    conn_max_idle_time_seconds: 300

jwt:
  secret: "${JWT_SECRET}"
  expire_hours: 24

user_jwt:
  secret: "${USER_JWT_SECRET}"
  expire_hours: 24
  remember_me_expire_hours: 168

bootstrap:
  default_admin_username: admin
  default_admin_password: "${ADMIN_PASS}"

redis:
  enabled: true
  host: redis
  port: 6379
  password: "${REDIS_PASSWORD}"
  db: 0
  prefix: "dj"

queue:
  enabled: true
  host: redis
  port: 6379
  password: "${REDIS_PASSWORD}"
  db: 1
  concurrency: 10
  queues:
    default: 10
    critical: 5

upload:
  max_size: 10485760
  allowed_types:
    - image/jpeg
    - image/png
    - image/gif
    - image/webp
    - image/svg+xml
  allowed_extensions:
    - .jpg
    - .jpeg
    - .png
    - .gif
    - .webp
    - .svg
  max_width: 4096
  max_height: 4096

cors:
  allowed_origins:
    - "https://${SHOP_DOMAIN}"
    - "https://${ADMIN_DOMAIN}"
    - "http://${SHOP_DOMAIN}"
    - "http://${ADMIN_DOMAIN}"
  allowed_methods:
    - GET
    - POST
    - PUT
    - PATCH
    - DELETE
    - OPTIONS
  allowed_headers:
    - Content-Type
    - Content-Length
    - Accept-Encoding
    - Authorization
    - Cache-Control
    - X-Requested-With
    - X-CSRF-Token
  allow_credentials: true
  max_age: 600

security:
  login_rate_limit:
    window_seconds: 300
    max_attempts: 5
    block_seconds: 900
  password_policy:
    min_length: 8
    require_upper: true
    require_lower: true
    require_number: true
    require_special: false

email:
  enabled: false
  host: ""
  port: 465
  username: ""
  password: ""
  from: ""
  from_name: ""
  use_tls: false
  use_ssl: true
  verify_code:
    expire_minutes: 10
    send_interval_seconds: 60
    max_attempts: 5
    length: 6

order:
  payment_expire_minutes: 15
  max_refund_days: 30
EOF
}

write_compose() {
  cat > "$COMPOSE_FILE" <<'EOF'
services:
  redis:
    image: redis:7-alpine
    container_name: dujiaonext-redis
    restart: unless-stopped
    command: ["redis-server", "--appendonly", "yes", "--requirepass", "${REDIS_PASSWORD}"]
    volumes:
      - ./data/redis:/data
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 10s
      timeout: 3s
      retries: 10
    networks:
      - dujiao-net

  postgres:
    image: postgres:16-alpine
    container_name: dujiaonext-postgres
    restart: unless-stopped
    environment:
      TZ: ${TZ}
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - ./data/postgres:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 10
    networks:
      - dujiao-net

  api:
    image: dujiaonext/api:${TAG}
    container_name: dujiaonext-api
    restart: unless-stopped
    environment:
      TZ: ${TZ}
      DJ_DEFAULT_ADMIN_USERNAME: ${DJ_DEFAULT_ADMIN_USERNAME}
      DJ_DEFAULT_ADMIN_PASSWORD: ${DJ_DEFAULT_ADMIN_PASSWORD}
    ports:
      - "127.0.0.1:${API_PORT}:8080"
    volumes:
      - ./config/config.yml:/app/config.yml:ro
      - ./data/uploads:/app/uploads
      - ./data/logs:/app/logs
    depends_on:
      redis:
        condition: service_healthy
      postgres:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://127.0.0.1:8080/health"]
      interval: 10s
      timeout: 3s
      retries: 10
    networks:
      - dujiao-net

  user:
    image: dujiaonext/user:${TAG}
    container_name: dujiaonext-user
    restart: unless-stopped
    environment:
      TZ: ${TZ}
    ports:
      - "127.0.0.1:${USER_PORT}:80"
    depends_on:
      api:
        condition: service_healthy
    networks:
      - dujiao-net

  admin:
    image: dujiaonext/admin:${TAG}
    container_name: dujiaonext-admin
    restart: unless-stopped
    environment:
      TZ: ${TZ}
    ports:
      - "127.0.0.1:${ADMIN_PORT}:80"
    depends_on:
      api:
        condition: service_healthy
    networks:
      - dujiao-net

networks:
  dujiao-net:
    driver: bridge
EOF
}

write_nginx_conf() {
  cat > "$NGINX_CONF" <<EOF
server {
  listen 80;
  server_name ${SHOP_DOMAIN};

  client_max_body_size 20m;

  location / {
    proxy_pass http://127.0.0.1:${USER_PORT};
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }

  location /api/ {
    proxy_pass http://127.0.0.1:${API_PORT}/api/;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }

  location /uploads/ {
    proxy_pass http://127.0.0.1:${API_PORT}/uploads/;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}

server {
  listen 80;
  server_name ${ADMIN_DOMAIN};

  client_max_body_size 20m;

  location / {
    proxy_pass http://127.0.0.1:${ADMIN_PORT};
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }

  location /api/ {
    proxy_pass http://127.0.0.1:${API_PORT}/api/;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }

  location /uploads/ {
    proxy_pass http://127.0.0.1:${API_PORT}/uploads/;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}
EOF

  nginx -t
  systemctl reload nginx
}

start_services() {
  section "启动容器"
  cd "$INSTALL_DIR"
  docker compose --env-file "$ENV_FILE" pull || true
  docker compose --env-file "$ENV_FILE" up -d
  docker compose --env-file "$ENV_FILE" ps
}

maybe_enable_https() {
  if [[ "$ENABLE_HTTPS" != "y" && "$ENABLE_HTTPS" != "yes" ]]; then
    yellow "跳过 HTTPS 申请，你之后可以手动执行 certbot"
    return
  fi
  section "申请 HTTPS"
  apt-get install -y certbot python3-certbot-nginx
  certbot --nginx -d "$SHOP_DOMAIN" -d "$ADMIN_DOMAIN"
}

write_metadata() {
  cat > "${INSTALL_DIR}/install-meta.env" <<EOF
PROJECT_NAME=${PROJECT_NAME}
PROJECT_SLUG=${PROJECT_SLUG}
SHOP_DOMAIN=${SHOP_DOMAIN}
ADMIN_DOMAIN=${ADMIN_DOMAIN}
TAG=${TAG}
INSTALLED_AT=$(date '+%F %T %Z')
EOF
}

show_summary() {
  green "Dujiao-Next 部署完成"
  echo
  echo "安装目录: ${INSTALL_DIR}"
  echo "镜像版本: ${TAG}"
  echo "前台地址: http://${SHOP_DOMAIN}"
  echo "后台地址: http://${ADMIN_DOMAIN}"
  echo "默认后台账号: admin"
  echo "默认后台密码: ${ADMIN_PASS}"
  echo
  yellow "首次登录后请立刻修改后台密码"
  yellow "请确认服务器安全组已放行 80 / 443"
  yellow "如已启用 HTTPS，请改用 https 访问"
}

main() {
  require_root
  check_os
  install_base_packages
  require_cmd curl
  require_cmd openssl
  require_cmd ss
  check_resources
  collect_inputs
  check_ports
  install_docker_if_needed
  install_nginx_if_needed
  configure_firewall
  create_dirs
  generate_secrets
  write_env
  write_config
  write_compose
  start_services
  write_nginx_conf
  maybe_enable_https
  write_metadata
  show_summary
}

main "$@"
