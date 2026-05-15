#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/liblog.sh"

main() {
  local apn="${1:-}"
  local iface="${2:-}"
  local cfg="/boot/firmware/config.txt"
  local modem=""
  local state=""

  if [[ -z "$apn" ]]; then
    read -r -p "Enter APN (for example: internet): " apn
  fi
  if [[ -z "$apn" ]]; then
    log_error "APN is required"
    exit 1
  fi

  export DEBIAN_FRONTEND=noninteractive
  log_info "Installing modem packages"
  apt update -qq
  apt install -y modemmanager network-manager usb-modeswitch usb-modeswitch-data \
                 isc-dhcp-client net-tools

  if ! grep -q '^usb_max_current_enable=1' "$cfg"; then
    echo 'usb_max_current_enable=1' >> "$cfg"
    log_info "Enabled usb_max_current_enable in firmware config"
  else
    log_ok "usb_max_current_enable already configured"
  fi

  if lsusb | grep -q '12d1:14fe'; then
    log_info "Switching modem from storage mode to NCM mode"
    usb_modeswitch -v 0x12d1 -p 0x14fe -R || true
  fi

  if ! mmcli -L | grep -q Modem; then
    log_error "No modem found by ModemManager"
    exit 1
  fi

  modem="$(mmcli -L | awk -F '/' '/Modem/{print $NF; exit}')"
  state="$(mmcli -m "$modem" | awk '/state:/ {print $3}')"
  if [[ "$state" != "connected" ]]; then
    log_info "Connecting modem ${modem} with APN ${apn}"
    mmcli -m "$modem" --simple-connect="apn=${apn}" || true
  else
    log_ok "Modem ${modem} is already connected"
  fi

  if [[ -z "$iface" ]]; then
    iface="$(ip -brief link | awk '/^wwx/{print $1; exit}')"
  fi
  if [[ -z "$iface" ]]; then
    log_error "Could not detect modem network interface"
    exit 1
  fi

  ip link set "$iface" up
  if ! ip -4 addr show "$iface" | grep -q inet; then
    log_info "Requesting DHCP lease on ${iface}"
    dhclient -v "$iface"
  else
    log_ok "Interface ${iface} already has IPv4 address"
  fi

  if ip route | grep -q "default dev ${iface}"; then
    log_ok "Default route via ${iface} already exists"
  else
    ip route add default dev "$iface" metric 100
    log_info "Added default route via ${iface}"
  fi

  rfkill block wifi || true
  log_ok "Modem ${iface} is up"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi

