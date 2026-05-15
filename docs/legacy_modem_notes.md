# Legacy Notes: WvDial PPP Modem Flow

This file preserves an older PPP/WvDial approach. Use it only when troubleshooting legacy modems that do not work well with ModemManager.

## Required packages

```bash
sudo apt-get update
sudo apt-get install -y lsusb ppp usb-modeswitch wvdial sg3-utils
```

## Check USB modem

```bash
lsusb
```

Look for a line with Huawei vendor ID.

## Example /etc/wvdial.conf

```ini
[Dialer Defaults]
Init1 = ATZ
Init2 = ATE1
Init3 = AT+CGDCONT=1,"IP","internet"
Stupid Mode = 1
MessageEndPoint = "0x01"
Modem Type = Analog Modem
ISDN = 0
Phone = *99#
Modem = /dev/ttyUSB0
Username = { }
Password = { }
Baud = 460800
Auto Reconnect = on
```

## /etc/network/interfaces

```text
auto ppp0
iface ppp0 inet wvdial
```

## Notes

- Common APN value: internet (depends on carrier)
- This is a legacy flow. Prefer the modern script:
  - sudo ./hardware/modem/setup.sh <APN>
