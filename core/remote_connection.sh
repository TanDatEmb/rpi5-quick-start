
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/liblog.sh"

main() {
  local repo_file="/etc/apt/sources.list.d/raspi-connect.list"
  local repo_line="deb http://archive.raspberrypi.com/debian/ bookworm main"
  local keyring="/usr/share/keyrings/raspi.gpg"

  if [[ -f "$repo_file" ]] && grep -Fqx "$repo_line" "$repo_file"; then
    log_ok "Raspberry Pi repository already configured"
  else
    log_info "Configuring Raspberry Pi repository"
    printf '%s\n' "$repo_line" > "$repo_file"
  fi

  log_info "Refreshing Raspberry Pi repository key"
  curl -fsSL https://archive.raspberrypi.com/debian/pubkey.gpg | gpg --dearmor -o "$keyring"

  if dpkg -s rpi-connect >/dev/null 2>&1; then
    log_ok "rpi-connect already installed"
  else
    log_info "Installing rpi-connect"
    apt update
    apt install -y rpi-connect
  fi

  if command -v rpi-connect >/dev/null 2>&1; then
    log_info "Run 'rpi-connect signin' if the device is not linked yet"
  fi

  log_ok "Remote connection setup completed"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
