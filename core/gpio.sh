#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/liblog.sh"

main() {
	local target_user="${SUDO_USER:-${USER}}"
	local rule_file="/etc/udev/rules.d/88-gpio.rules"

	log_info "Ensuring GPIO packages are installed"
	apt install -y gpiod python3-lgpio

	log_info "Writing GPIO udev rule"
	cat <<'EOF' > "$rule_file"
SUBSYSTEM=="gpio", KERNEL=="gpiochip[0-9]*", GROUP="gpio", MODE="0660"
EOF

	groupadd -f gpio
	if id "$target_user" >/dev/null 2>&1; then
		if id -nG "$target_user" | grep -qw gpio; then
			log_ok "User ${target_user} is already in gpio group"
		else
			log_info "Adding ${target_user} to gpio group"
			usermod -aG gpio "$target_user"
		fi
	fi

	udevadm control --reload-rules
	udevadm trigger
	log_ok "GPIO setup completed"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	main "$@"
fi
