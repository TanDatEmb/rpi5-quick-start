# Complete Setup Guide

This document maps every setup script in the repository to its purpose, prerequisites, and typical usage.

## Prerequisites

- Ubuntu 24.04 on Raspberry Pi 5
- Sudo access
- Internet connection for package installation
- Reboot access (some hardware changes require reboot)

## Script inventory

### Core scripts

1. core/utils.sh
- Purpose: install common tools (neovim, zsh, htop, neofetch) and set zsh as default shell.
- Run:

```bash
sudo ./core/utils.sh
```

2. core/docker.sh
- Purpose: install Docker, configure docker group, and manage ROS container artifacts if docker context exists.
- Run:

```bash
sudo ./core/docker.sh
```

3. core/remote_connection.sh
- Purpose: set up Raspberry Pi Connect repository/key and install rpi-connect.
- Run:

```bash
sudo ./core/remote_connection.sh
```

4. core/gpio.sh
- Purpose: install GPIO packages, configure gpio udev rules, and add user to gpio group.
- Run:

```bash
sudo ./core/gpio.sh
```

### Hardware scripts

5. hardware/ai_hat.sh
- Purpose: configure Hailo repository/key, install Hailo runtime packages, and enable PCIe overlay.
- Run:

```bash
sudo ./hardware/ai_hat.sh
```

6. hardware/camera_imx477.sh
- Purpose: install camera build dependencies, build/install camera stack when needed, and apply IMX477 overlays.
- Run:

```bash
sudo ./hardware/camera_imx477.sh
```

7. hardware/uart_fc.sh
- Purpose: configure UART overlays, install MAVROS packages, and create/enable bridge systemd service.
- Run:

```bash
sudo ./hardware/uart_fc.sh
```

### Modem scripts

8. hardware/modem/setup.sh
- Purpose: full modem setup (packages, APN connection, DHCP, route preference).
- Arguments:
  - APN (optional if you want interactive prompt)
  - Interface name (optional)
- Run:

```bash
sudo ./hardware/modem/setup.sh <APN> [INTERFACE]
```

9. hardware/modem/start.sh
- Purpose: quick modem reconnect/start after reboot or network interruption.
- Arguments:
  - APN (optional, default: internet)
- Run:

```bash
sudo ./hardware/modem/start.sh [APN]
```

### Software scripts

10. software/ros2_jazzy.sh
- Purpose: configure ROS repository/key and install ROS 2 Jazzy base packages.
- Run:

```bash
sudo ./software/ros2_jazzy.sh
```

## Interactive launcher

main.sh runs all setup scripts in a guided order and asks for confirmation at each step.

```bash
sudo ./main.sh
```

The launcher reports:
- Completed steps
- Skipped steps
- Missing script files

## Recommended order

1. core/utils.sh
2. core/docker.sh
3. core/remote_connection.sh
4. core/gpio.sh
5. hardware/ai_hat.sh
6. hardware/camera_imx477.sh
7. hardware/modem/setup.sh
8. hardware/modem/start.sh
9. software/ros2_jazzy.sh
10. hardware/uart_fc.sh

## Related documents

- Modem details: docs/modem_setup.md
- Tailscale VPN: docs/tailscale_vpn_setup.md
- Legacy PPP notes: docs/legacy_modem_notes.md
