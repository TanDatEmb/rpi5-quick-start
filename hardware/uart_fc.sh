#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/liblog.sh"

main() {
  local cfg="/boot/firmware/config.txt"
  local svc="/etc/systemd/system/px4_bridge.service"

  if ! grep -q '^enable_uart=1' "$cfg"; then
    echo 'enable_uart=1' >> "$cfg"
    log_info "Enabled UART in firmware config"
  else
    log_ok "UART is already enabled"
  fi

  if ! grep -q '^dtoverlay=disable-bt' "$cfg"; then
    echo 'dtoverlay=disable-bt' >> "$cfg"
    log_info "Disabled Bluetooth overlay for primary UART"
  else
    log_ok "Bluetooth disable overlay already configured"
  fi

  log_info "Installing MAVROS packages"
  apt install -y ros-jazzy-mavros ros-jazzy-mavros-extras screen

  cat <<'EOF' > "$svc"
[Unit]
Description=PX4 ROS2 micro DDS bridge
After=network-online.target docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/docker exec ros2_jazzy /opt/ros/jazzy/bin/microdds_agent -t Serial -d /dev/serial0 -b 921600
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable px4_bridge.service >/dev/null
  log_ok "UART and bridge service setup completed"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi

