# 4G Modem Setup on Raspberry Pi 5

This guide targets Ubuntu 24.04 on Raspberry Pi 5 with a USB 4G modem (for example Huawei E3276).

## Goals

- Bring up stable Internet access on a wwx... network interface
- Prefer LTE as the default route when needed
- Keep setup re-runnable with minimal side effects

## Quick usage with repository script

```bash
cd /path/to/rpi5-quick-start
sudo ./hardware/modem/setup.sh <APN>
```

Example:

```bash
sudo ./hardware/modem/setup.sh internet
```

If APN is not passed, the script prompts interactively.

## Requirements

- Raspberry Pi 5 with stable power source
- SIM card with LTE data plan
- USB 4G modem
- Temporary Internet access (Wi-Fi/LAN) for initial package installation

## Manual flow (for troubleshooting)

1. Install required packages:

```bash
sudo apt update
sudo apt install -y modemmanager network-manager usb-modeswitch usb-modeswitch-data isc-dhcp-client net-tools
```

2. Check modem detection:

```bash
lsusb | grep 12d1
sudo mmcli -L
```

3. Connect with APN:

```bash
sudo mmcli -m 0 --simple-connect="apn=internet"
```

4. Detect interface and request IP address:

```bash
IF=$(ip -brief link | awk '/^wwx/{print $1; exit}')
sudo ip link set "$IF" up
sudo dhclient -v "$IF"
```

5. Prefer LTE route:

```bash
sudo ip route add default dev "$IF" metric 100
```

## Verification

```bash
ip -4 addr show "$IF"
ip route
curl -4 ifconfig.co
```

## Common issues

- No modem shown by mmcli:
   - Check USB power
   - Replug modem
   - Verify usb-modeswitch is installed and running
- Connected modem but no IP:
   - Re-run dhclient on the wwx interface
- Invalid APN:
   - Confirm APN with your carrier and rerun setup

