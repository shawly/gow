#!/command/with-contenv bash
# shellcheck shell=bash

set -euo pipefail

source /opt/gow/bash-lib/utils.sh

PUID="${PUID:-1000}"
PGID="${PGID:-1000}"
UMASK="${UMASK:-000}"
XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$PUID}"

gow_log "**** Configure default user ****"

if [[ "$(id -u)" != "0" ]]; then
    gow_log "${TPUT_YELLOW:-}You are running the container as a non-root user which is not supported. The s6 init system requires privilege to work correctly.${TPUT_RESET:-}"
    gow_log "${TPUT_YELLOW:-}Please use the UNAME, PUID and PGID environment variables to set your intended user.${TPUT_RESET:-}"
    gow_log_error "Container must not be run as non-root user!"
    exit 1
fi

if [[ "${UNAME}" != "root" ]] && [[ "${PUID}" -gt 0 ]]; then
    gow_log "Setting default user uid=${PUID}(${UNAME}) gid=${PGID}(${UNAME})"
    if id -u "${PUID}" &>/dev/null; then
        # need to delete the old user $PUID then change $UNAME's UID
        # default ubuntu image comes with user `ubuntu` and UID 1000
        oldname=$(id -nu "${PUID}")
        userdel -r "${oldname}"
    fi

    groupadd -f -g "${PGID}" "${UNAME}"
    useradd -m -u "${PUID}" -g "${PGID}" -s /bin/bash "${UNAME}"
    if [[ -n "${USERHOME:-}" ]]; then
        usermod -d "${USERHOME}" "${UNAME}"
    fi

    gow_log "Setting umask to ${UMASK}"
    umask "${UMASK}"

    gow_log "Ensure retro home directory is writable"
    USERHOME=$(grep "${UNAME}" /etc/passwd | cut -d ":" -f6)
    chown "${PUID}:${PGID}" "${USERHOME}"

    if [[ -d "${XDG_RUNTIME_DIR}" ]]; then
        gow_log "Ensure XDG_RUNTIME_DIR is writable"
        chown -R "${PUID}:${PGID}" "${XDG_RUNTIME_DIR}"
    fi
else
    gow_log "Container running as root. Nothing to do."
fi

gow_log_done
