#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/lib/liblog.sh"

declare -a COMPLETED_STEPS=()
declare -a SKIPPED_STEPS=()
declare -a MISSING_STEPS=()

ask_and_run() {
    local script_path="$1"
    local description="$2"
    local choice=""

    if [[ ! -f "$script_path" ]]; then
        log_error "Missing script: ${script_path}"
        MISSING_STEPS+=("${description} (${script_path})")
        return 0
    fi

    read -r -p "Do you want to install/configure: ${description}? (y/N): " choice
    case "$choice" in
        y|Y)
            log_info "Running ${script_path}"
            bash "$script_path"
            log_ok "Completed ${description}"
            COMPLETED_STEPS+=("${description}")
            ;;
        *)
            log_info "Skipped ${description}"
            SKIPPED_STEPS+=("${description}")
            ;;
    esac
}

print_summary() {
    local item=""

    log_info "=== Setup Summary ==="

    if [[ ${#COMPLETED_STEPS[@]} -gt 0 ]]; then
        log_ok "Completed steps:"
        for item in "${COMPLETED_STEPS[@]}"; do
            printf "  - %s\n" "$item"
        done
    fi

    if [[ ${#SKIPPED_STEPS[@]} -gt 0 ]]; then
        log_warn "Skipped steps:"
        for item in "${SKIPPED_STEPS[@]}"; do
            printf "  - %s\n" "$item"
        done
    fi

    if [[ ${#MISSING_STEPS[@]} -gt 0 ]]; then
        log_error "Missing script files:"
        for item in "${MISSING_STEPS[@]}"; do
            printf "  - %s\n" "$item"
        done
    fi
}

main() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Please run with sudo: sudo ./main.sh"
        exit 1
    fi

    log_info "=== RPI5 QUICK START INTERACTIVE SETUP ==="

    ask_and_run "${SCRIPT_DIR}/core/utils.sh" "System tools (htop, vim, swap...)"
    ask_and_run "${SCRIPT_DIR}/core/docker.sh" "Docker and Docker Compose"
    ask_and_run "${SCRIPT_DIR}/core/remote_connection.sh" "Remote Connection (SSH/VNC)"
    ask_and_run "${SCRIPT_DIR}/core/gpio.sh" "GPIO configuration"
    ask_and_run "${SCRIPT_DIR}/hardware/ai_hat.sh" "AI Hat (Hailo-8L/NPU)"
    ask_and_run "${SCRIPT_DIR}/hardware/camera_imx477.sh" "Camera IMX477"
    ask_and_run "${SCRIPT_DIR}/hardware/modem/setup.sh" "4G modem configuration"
    ask_and_run "${SCRIPT_DIR}/hardware/modem/start.sh" "4G modem quick start (reconnect)"
    ask_and_run "${SCRIPT_DIR}/software/ros2_jazzy.sh" "ROS 2 Jazzy"
    ask_and_run "${SCRIPT_DIR}/hardware/uart_fc.sh" "UART connection with Flight Controller"

    print_summary
    log_ok "All selected setup tasks have been processed"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi