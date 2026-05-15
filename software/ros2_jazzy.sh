#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/liblog.sh"

main() {
    local keyring="/usr/share/keyrings/ros-archive-keyring.gpg"
    local repo_file="/etc/apt/sources.list.d/ros2.list"
    local distro
    local repo_line

    distro="$(lsb_release -cs)"
    repo_line="deb [arch=arm64 signed-by=${keyring}] http://packages.ros.org/ros2/ubuntu ${distro} main"

    log_info "Installing ROS repository prerequisites"
    apt install -y software-properties-common curl gnupg lsb-release

    log_info "Refreshing ROS GPG key"
    curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | gpg --dearmor -o "$keyring"

    if [[ -f "$repo_file" ]] && grep -Fqx "$repo_line" "$repo_file"; then
        log_ok "ROS 2 repository already configured"
    else
        printf '%s\n' "$repo_line" > "$repo_file"
        log_info "Configured ROS 2 repository"
    fi

    if dpkg -s ros-jazzy-ros-base >/dev/null 2>&1; then
        log_ok "ROS 2 Jazzy base already installed"
    else
        apt update
        apt install -y ros-jazzy-ros-base
        log_ok "Installed ROS 2 Jazzy base"
    fi

    cat <<'EOF' > /etc/profile.d/ros2.sh
source /opt/ros/jazzy/setup.bash
EOF

    log_ok "ROS 2 Jazzy setup completed"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi

