#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/liblog.sh"

main() {
  local cfg="/boot/firmware/config.txt"
  local src_dir="${ROOT_DIR}/.build/camera"

  mkdir -p "$src_dir"

  log_info "Installing camera build prerequisites"
  apt install -y clang meson ninja-build pkg-config libyaml-dev \
    libdw-dev libunwind-dev libudev-dev libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev libpython3-dev pybind11-dev \
    libevent-dev libtiff-dev qt6-base-dev qt6-tools-dev-tools

  if command -v rpicam-hello >/dev/null 2>&1; then
    log_ok "rpicam-apps already available, skip source build"
  else
    if [[ ! -d "${src_dir}/libcamera/.git" ]]; then
      log_info "Cloning libcamera"
      git clone --depth=1 https://github.com/raspberrypi/libcamera.git "${src_dir}/libcamera"
    else
      log_ok "libcamera source already present"
    fi

    log_info "Building libcamera"
    meson setup "${src_dir}/libcamera/build" --buildtype=release -Dv4l2=true -Dgstreamer=enabled --reconfigure
    ninja -C "${src_dir}/libcamera/build" install

    if [[ ! -d "${src_dir}/rpicam-apps/.git" ]]; then
      log_info "Cloning rpicam-apps"
      git clone --depth=1 https://github.com/raspberrypi/rpicam-apps.git "${src_dir}/rpicam-apps"
    else
      log_ok "rpicam-apps source already present"
    fi

    log_info "Building rpicam-apps"
    meson setup "${src_dir}/rpicam-apps/build" -Denable_libav=enabled -Denable_egl=enabled --reconfigure
    meson compile -C "${src_dir}/rpicam-apps/build"
    meson install -C "${src_dir}/rpicam-apps/build"
  fi

  if ! grep -q '^camera_auto_detect=0' "$cfg"; then
    echo 'camera_auto_detect=0' >> "$cfg"
  fi
  if ! grep -q '^dtoverlay=imx477,cam0' "$cfg"; then
    echo 'dtoverlay=imx477,cam0' >> "$cfg"
  fi

  log_ok "Camera IMX477 setup completed"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi

