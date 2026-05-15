#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/liblog.sh"

main() {
	local apn="${1:-internet}"
	local iface=""

	if ! mmcli -L | grep -q Modem; then
		log_error "No modem detected"
		exit 1
	fi

	log_info "Connecting modem with APN ${apn}"
	mmcli -m 0 --simple-connect="apn=${apn}" || true

	iface="$(ip -brief link | awk '/^wwx/{print $1; exit}')"
	if [[ -z "$iface" ]]; then
		log_error "No wwx interface found"
		exit 1
	fi

	ip link set "$iface" up
	if ! ip -4 addr show "$iface" | grep -q inet; then
		dhclient -v "$iface"
		log_info "Requested DHCP lease for ${iface}"
	else
		log_ok "Interface ${iface} already has IPv4 address"
	fi

	if ip route | grep -q "default dev ${iface}"; then
		log_ok "Default route via ${iface} already set"
	else
		ip route add default dev "$iface" metric 100
		log_info "Added default route via ${iface}"
	fi

	log_ok "Modem start flow completed"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	main "$@"
fi

