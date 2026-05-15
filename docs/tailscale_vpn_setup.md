# Tailscale VPN Setup on Raspberry Pi 5

This guide shows how to configure Tailscale on Raspberry Pi 5 for secure remote access over your tailnet.

## Install

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo systemctl enable --now tailscaled
```

## Sign in and enable SSH

```bash
sudo tailscale up --ssh
```

The command prints a login URL. Open it, authenticate, and approve the device.

## Check status

```bash
tailscale status
tailscale ip -4
```

To connect over SSH from another machine:

```bash
ssh <user>@<tailscale-ip>
```

## Use with 4G modem

- Complete modem setup first: [docs/modem_setup.md](docs/modem_setup.md)
- For LTE-only testing:

```bash
sudo nmcli radio wifi off
```

Enable Wi-Fi again:

```bash
sudo nmcli radio wifi on
```

## Useful commands

- Check peers and route state: tailscale status
- Show tailnet IP: tailscale ip
- Diagnose NAT/relay path: tailscale netcheck
- Log out this node: tailscale logout

## Common issues

- tailscale status shows offline:
  - Verify Internet uplink (LTE or Wi-Fi)
  - Verify tailscaled service is running
- SSH access fails:
  - Check ACL policy in Tailscale admin
  - Confirm user exists on Raspberry Pi

