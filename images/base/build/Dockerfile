# syntax=docker/dockerfile:1.4
FROM ubuntu:25.04

ARG TARGETARCH TARGETVARIANT

ARG DEBIAN_FRONTEND=noninteractive

# Set vars for s6 overlay
ARG S6_OVERLAY_VERSION="v3.2.1.0"
ARG S6_OVERLAY_BASE_URL="https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}"
ARG S6_OVERLAY_NOARCH="${S6_OVERLAY_BASE_URL}/s6-overlay-noarch.tar.xz"

# Configure default user and set env
# The users UID and GID will be set on container startup
ENV \
    PUID=1000 \
    PGID=1000 \
    UMASK=000 \
    UNAME="retro" \
    TZ="Etc/UTC" \
    NEEDRESTART_SUSPEND=1

RUN <<_INSTALL_PACKAGES
set -e
echo "**** Update apt database ****"
apt-get update

echo "**** Install certificates ****"
apt-get install -y --reinstall --no-install-recommends \
    ca-certificates

echo "**** Install base packages ****"
apt-get install -y --no-install-recommends \
    fuse \
    libnss3 \
    wget \
    curl \
    jq \
    xz-utils

echo "**** Install s6-overlay ****"
case "${TARGETARCH}" in \
    amd64) S6_ARCH="x86_64" ;;
    arm64) S6_ARCH="aarch64" ;;
    *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;;
esac

curl -L "${S6_OVERLAY_NOARCH}" | tar -C / -Jxpf -
curl -L "${S6_OVERLAY_BASE_URL}/s6-overlay-${S6_ARCH}.tar.xz" | tar -C / -Jxpf -

# backwards compatibility for things that depend on gosu
ln -sf /package/admin/s6/command/s6-setuidgid /usr/local/sbin/gosu

echo "**** Section cleanup ****"
rm -rf \
    /var/lib/apt/lists/*

echo
_INSTALL_PACKAGES

# Import overlay
COPY rootfs/ /
COPY rootfs/etc/skel/* /root/

# Start s6
ENTRYPOINT ["/init"]

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
