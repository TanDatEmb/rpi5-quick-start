#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/liblog.sh"

# Detect the first available modem index from ModemManager (avoids hardcoded -m 0)
_get_modem_index() {
    mmcli -L 2>/dev/null | awk -F '/Modem/' '/Modem/{print $2; exit}'
}

# Detect modem network interface: supports wwx (Huawei NCM),
# wwan0 (generic), usb0 (RNDIS) – covers SIM7600 ECM/NCM/RNDIS modes
_get_modem_iface() {
    ip -brief link | awk '/^(wwx|wwan|usb)[0-9a-f]/{print $1; exit}'
}

main() {
    local apn="${1:-internet}"
    local modem_index=""
    local iface=""
    local max_retries=5
    local attempt=0

    # --- Modem detection ---
    log_info "Waiting for ModemManager to register modem"
    while [[ $attempt -lt $max_retries ]]; do
        modem_index="$(_get_modem_index)"
        if [[ -n "$modem_index" ]]; then
            break
        fi
        attempt=$(( attempt + 1 ))
        log_warn "No modem registered yet (attempt ${attempt}/${max_retries}), retrying in 3s"
        sleep 3
    done

    if [[ -z "$modem_index" ]]; then
        log_error "No modem detected after ${max_retries} attempts"
        exit 1
    fi
    log_ok "Found modem index: ${modem_index}"

    # --- Connect ---
    log_info "Connecting modem ${modem_index} with APN ${apn}"
    mmcli -m "$modem_index" --simple-connect="apn=${apn}" || true

    # --- Interface detection with retry (interface may appear after connect) ---
    attempt=0
    while [[ $attempt -lt $max_retries ]]; do
        iface="$(_get_modem_iface)"
        if [[ -n "$iface" ]]; then
            break
        fi
        attempt=$(( attempt + 1 ))
        log_warn "No modem interface visible yet (attempt ${attempt}/${max_retries}), retrying in 3s"
        sleep 3
    done

    if [[ -z "$iface" ]]; then
        log_error "No modem network interface found after ${max_retries} attempts"
        exit 1
    fi
    log_ok "Using interface: ${iface}"

    # --- Bring up and acquire IP ---
    ip link set "$iface" up
    if ! ip -4 addr show "$iface" | grep -q inet; then
        log_info "Requesting DHCP lease on ${iface} (timeout 30s)"
        timeout 30 dhclient -v "$iface" || log_warn "DHCP timed out, will retry next run"
    else
        log_ok "Interface ${iface} already has an IPv4 address"
    fi

    # --- Set preferred route ---
    if ip route | grep -q "default dev ${iface}"; then
        log_ok "Default route via ${iface} already set"
    else
        ip route add default dev "$iface" metric 100
        log_info "Added default route via ${iface}"
    fi

    log_ok "Modem start flow completed on ${iface}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	main "$@"
fi

