#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script is meant to be sourced, not executed directly."
    exit 1
fi

if [[ -t 1 ]]; then
    _tput_colors="$(tput colors)"

    if [[ -n "$_tput_colors" && $_tput_colors -ge 8 ]]; then
        TPUT_RESET="$(tput sgr0)"
        TPUT_BOLD="$(tput bold)"
        TPUT_STANDOUT="$(tput smso)"
        TPUT_UNDERLINE="$(tput smul)"
        TPUT_BLACK="$(tput setaf 0)"
        TPUT_RED="$(tput setaf 1)"
        TPUT_GREEN="$(tput setaf 2)"
        TPUT_YELLOW="$(tput setaf 3)"
        TPUT_BLUE="$(tput setaf 4)"
        TPUT_MAGENTA="$(tput setaf 5)"
        TPUT_CYAN="$(tput setaf 6)"
        TPUT_WHITE="$(tput setaf 7)"
        export TPUT_BOLD TPUT_UNDERLINE TPUT_STANDOUT TPUT_RESET TPUT_BLACK TPUT_RED TPUT_GREEN TPUT_YELLOW TPUT_BLUE TPUT_MAGENTA TPUT_CYAN TPUT_WHITE
    fi
fi

gow_log() {
    echo -e "$(date +"[%Y-%m-%d %H:%M:%S]") $*"
}

gow_log_done() {
    echo -e "$(date +"[%Y-%m-%d %H:%M:%S]") [$(basename $(dirname "$0"))] ${TPUT_GREEN:-}DONE${TPUT_RESET:-}"
}

gow_log_error() {
    echo -e "$(date +"[%Y-%m-%d %H:%M:%S]") [$(basename $(dirname "$0"))] ${TPUT_RED:-}ERROR: $*${TPUT_RESET:-}" >&2
}

join_by() { local IFS="$1"; shift; echo "$*"; }

github_download(){
    curl -H "X-GitHub-Api-Version: "${GITHUB_REST_VERSION:-2022-11-28}"" \
        https://api.github.com/repos/$1/releases/latest | \
        jq $2 | \
        xargs curl -fsLo $3
}
