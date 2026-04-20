#!/usr/bin/env bash
set -Eeuo pipefail

while true; do
  clear
  cat <<'EOF'
Dujiao-Next 管理菜单
1. 安装 / 重装
2. 升级版本
3. 备份数据
4. 卸载
5. 查看版本提示
0. 退出
EOF
  read -r -p "请选择操作: " choice
  case "$choice" in
    1) sudo ./install.sh ;;
    2) sudo ./update.sh ;;
    3) sudo ./backup.sh ;;
    4) sudo ./uninstall.sh ;;
    5) ./check-updates.sh ;;
    0) exit 0 ;;
    *) echo "无效选项"; sleep 1 ;;
  esac
done
