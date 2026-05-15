
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/liblog.sh"

main() {
    local target_user="${SUDO_USER:-${USER}}"
    local image_name="inspekcja:humble-pi5-v1"
    local container_name="ros2_humble"
    local build_context="${ROOT_DIR}/docker"

    if ! command -v docker >/dev/null 2>&1; then
        log_info "Installing Docker using the official install script"
        curl -fsSL https://get.docker.com | sh
    else
        log_ok "Docker is already installed"
    fi

    if id "$target_user" >/dev/null 2>&1; then
        if id -nG "$target_user" | grep -qw docker; then
            log_ok "User ${target_user} is already in docker group"
        else
            log_info "Adding ${target_user} to docker group"
            usermod -aG docker "$target_user"
        fi
    else
        log_warn "User ${target_user} not found, skip docker group update"
    fi

    if [[ -d "$build_context" ]]; then
        if docker image inspect "$image_name" >/dev/null 2>&1; then
            log_ok "Docker image ${image_name} already exists"
        else
            log_info "Building Docker image ${image_name}"
            docker build -t "$image_name" "$build_context"
        fi

        if docker ps -a --format '{{.Names}}' | grep -qx "$container_name"; then
            if docker ps --format '{{.Names}}' | grep -qx "$container_name"; then
                log_ok "Container ${container_name} is already running"
            else
                log_info "Starting existing container ${container_name}"
                docker start "$container_name" >/dev/null
                log_ok "Container ${container_name} started"
            fi
        else
            log_info "Creating container ${container_name}"
            docker run -dit --name "$container_name" --net=host --privileged \
                -v /dev:/dev "$image_name" bash >/dev/null
            log_ok "Container ${container_name} created"
        fi
    else
        log_warn "Build context ${build_context} not found, skip image/container setup"
    fi

    log_ok "Docker setup completed"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
