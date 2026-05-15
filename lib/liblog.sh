
#!/usr/bin/env bash
set -euo pipefail

_log_with_level() {
    local level="$1"
    local colour="$2"
    shift 2
    printf "%b[%(%F %T)T] [%s] %s%b\n" "$colour" -1 "$level" "$*" "\e[0m"
}

log_info() {
    _log_with_level "INFO" "\e[34m" "$@"
}

log_ok() {
    _log_with_level "OK" "\e[32m" "$@"
}

log_warn() {
    _log_with_level "WARN" "\e[33m" "$@"
}

log_error() {
    _log_with_level "ERROR" "\e[31m" "$@"
}
