#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/liblog.sh"

main() {
  local repo_file="/etc/apt/sources.list.d/hailo.list"
  local repo_line="deb [arch=arm64 signed-by=/usr/share/keyrings/hailo-archive-keyring.gpg] https://hailo.ai/developer-zone/apt/ stable main"
  local keyring="/usr/share/keyrings/hailo-archive-keyring.gpg"
  local cfg="/boot/firmware/config.txt"

  if [[ -f "$repo_file" ]] && grep -Fqx "$repo_line" "$repo_file"; then
    log_ok "Hailo repository already configured"
  else
    log_info "Configuring Hailo repository"
    curl -fsSL https://hailo.ai/developer-zone/apt/public.key | gpg --dearmor -o "$keyring"
    printf '%s\n' "$repo_line" > "$repo_file"
  fi

  if dpkg -s hailort >/dev/null 2>&1 && dpkg -s hailort-examples >/dev/null 2>&1; then
    log_ok "Hailo packages already installed"
  else
    log_info "Installing Hailo runtime and examples"
    apt update
    apt install -y hailort hailort-examples
  fi

  if grep -q '^dtoverlay=pci' "$cfg"; then
    log_ok "PCIe overlay is already configured"
  else
    log_info "Enabling PCIe overlay"
    echo 'dtoverlay=pci' >> "$cfg"
  fi

  log_ok "AI HAT setup completed"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
