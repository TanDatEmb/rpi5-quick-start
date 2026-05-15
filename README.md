# RPi5 Quick Start

Quick setup scripts for Raspberry Pi 5, including:

- Core system setup
- Hardware configuration (AI Hat, Camera, UART, 4G Modem)
- ROS 2 Jazzy installation
- Interactive flow to choose each step

## What this repository covers

All setup scripts currently in this repository are listed below:

- Core: utils, docker, remote connection, GPIO
- Hardware: AI Hat, Camera IMX477, UART for flight controller
- Modem: full setup and quick reconnect/start flow
- Software: ROS 2 Jazzy

No setup script is intentionally hidden from the interactive launcher.

## Folder structure

```text
rpi5-quick-start/
├── main.sh
├── lib/
│   └── liblog.sh
├── core/
│   ├── docker.sh
│   ├── remote_connection.sh
│   ├── utils.sh
│   └── gpio.sh
├── hardware/
│   ├── ai_hat.sh
│   ├── camera_imx477.sh
│   ├── uart_fc.sh
│   └── modem/
│       ├── setup.sh
│       └── start.sh
├── software/
│   └── ros2_jazzy.sh
├── docs/
│   ├── modem_setup.md
│   ├── tailscale_vpn_setup.md
│   └── legacy_modem_notes.md
```

## Quick start

Run the interactive menu:

```bash
cd /path/to/rpi5-quick-start
sudo ./main.sh
```

The script asks whether you want to run each setup step (y/N).
It also prints a final summary: completed, skipped, and missing script files.

## Run individual modules

```bash
sudo ./core/utils.sh
sudo ./core/docker.sh
sudo ./core/remote_connection.sh
sudo ./core/gpio.sh
sudo ./hardware/ai_hat.sh
sudo ./hardware/camera_imx477.sh
sudo ./hardware/modem/setup.sh internet
sudo ./hardware/modem/start.sh internet
sudo ./software/ros2_jazzy.sh
sudo ./hardware/uart_fc.sh
```

## Complete setup order (recommended)

1. sudo ./core/utils.sh
2. sudo ./core/docker.sh
3. sudo ./core/remote_connection.sh
4. sudo ./core/gpio.sh
5. sudo ./hardware/ai_hat.sh
6. sudo ./hardware/camera_imx477.sh
7. sudo ./hardware/modem/setup.sh <APN>
8. sudo ./hardware/modem/start.sh <APN>
9. sudo ./software/ros2_jazzy.sh
10. sudo ./hardware/uart_fc.sh

## Documentation

- Modem 4G: [docs/modem_setup.md](docs/modem_setup.md)
- VPN Tailscale: [docs/tailscale_vpn_setup.md](docs/tailscale_vpn_setup.md)
- Legacy modem notes: [docs/legacy_modem_notes.md](docs/legacy_modem_notes.md)
- Complete script-by-script guide: [docs/setup_guide.md](docs/setup_guide.md)

## Notes

- Use sudo to grant the scripts enough system privileges.
- Several changes require reboot to take effect (GPIO/UART/overlays).
- Scripts are written with basic idempotent checks so they can be re-run safely.
