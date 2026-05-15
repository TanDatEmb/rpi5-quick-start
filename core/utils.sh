#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/liblog.sh"

main() {
	local target_user="${SUDO_USER:-${USER}}"
	local packages=(neovim zsh htop neofetch)
	local missing=()
	local pkg=""

	for pkg in "${packages[@]}"; do
		if ! dpkg -s "$pkg" >/dev/null 2>&1; then
			missing+=("$pkg")
		fi
	done

	if [[ ${#missing[@]} -gt 0 ]]; then
		log_info "Installing CLI tools: ${missing[*]}"
		apt update
		apt install -y "${missing[@]}"
	else
		log_ok "CLI tools already installed"
	fi

	if id "$target_user" >/dev/null 2>&1; then
		local current_shell
		current_shell="$(getent passwd "$target_user" | cut -d: -f7)"
		if [[ "$current_shell" != "/usr/bin/zsh" ]]; then
			log_info "Setting /usr/bin/zsh as default shell for ${target_user}"
			chsh -s /usr/bin/zsh "$target_user"
		else
			log_ok "Default shell for ${target_user} is already /usr/bin/zsh"
		fi
	else
		log_warn "User ${target_user} not found, skip default shell update"
	fi

	log_ok "System tools setup completed"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	main "$@"
fi
