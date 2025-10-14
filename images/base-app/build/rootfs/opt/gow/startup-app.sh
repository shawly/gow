#!/command/with-contenv bash
# shellcheck shell=bash
set -e

s6-setuidgid retro \
  s6-env HOME=/home/retro \
  /opt/gow/bash-lib/launch-comp.sh kitty
