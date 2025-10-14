ARG BASE_IMAGE=ghcr.io/games-on-whales/base:edge

#################################
FROM ubuntu:25.04 AS base-app-builder

ARG DEBIAN_FRONTEND=noninteractive

RUN <<_INSTALL_BUILD_DEPENDENCIES
    set -e

    apt-get update -y
    echo "**** Install general build dependencies ****"
    apt install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      curl \
      cmake \
      git 

    echo "**** Install sdl-jstest dependencies ****"
    apt-get install -y --no-install-recommends \
      libsdl2-dev \
      libncurses5-dev
    
    echo "**** Install gamescope dependencies ****"
    apt-get install -y --no-install-recommends \
        glslang-tools \
        hwdata \
        libavif-dev \
        libbenchmark-dev \
        libcap-dev \
        libdisplay-info-dev \
        libdrm-dev \
        libeis-dev \
        libglm-dev \
        libinput-dev \
        libliftoff-dev \
        libluajit-5.1-dev \
        libpipewire-0.3-dev \
        libpixman-1-dev \
        libsdl2-dev \
        libseat-dev \
        libstb-dev \
        libvulkan-dev \
        libwayland-dev \
        libwlroots-0.18-dev \
        libx11-dev \
        libx11-xcb-dev \
        libxcb-composite0-dev \
        libxcb-composite0-dev \
        libxcb-dri3-dev \
        libxcb-errors-dev \
        libxcb-ewmh-dev \
        libxcb-icccm4-dev \
        libxcb-image0-dev \
        libxcb-present-dev \
        libxcb-render-util0-dev \
        libxcb-render-util0-dev \
        libxcb-render0-dev \
        libxcb-res0-dev \
        libxcb-shm0-dev \
        libxcb-xfixes0-dev \
        libxcb-xinput-dev \
        libxcb1-dev \
        libxcomposite-dev \
        libxdamage-dev \
        libxext-dev \
        libxfixes-dev \
        libxkbcommon-dev \
        libxmu-dev \
        libxrender-dev \
        libxres-dev \
        libxtst-dev \
        libxxf86vm-dev \
        meson \
        pkgconf \
        spirv-headers \
        vkroots-headers \
        wayland-protocols \
        xwayland

    apt-get clean
    rm -rf /var/lib/apt/lists/*
_INSTALL_BUILD_DEPENDENCIES

#################################
FROM base-app-builder AS sdl-jstest-builder

ARG SDL_JS_TEST_REF=8a84a47209f96eb3994cf9f906ae072e828886bb
ARG SDL_JS_TEST_REPO="https://github.com/games-on-whales/sdl-jstest.git"

WORKDIR /usr/src/sdl-jstest

RUN <<_CLONE_SDL_JSTEST
    set -e 
    git init
    git remote add origin "${SDL_JS_TEST_REPO}"
    git fetch --depth 1 origin "${SDL_JS_TEST_REF}"
    git checkout FETCH_HEAD
    git submodule update --init --recursive --depth 1 --recommend-shallow
_CLONE_SDL_JSTEST

RUN <<_BUILD_SDL_JSTEST
    set -e
    mkdir build
    cd build
    export CMAKE_INSTALL_PREFIX=/usr/local
    cmake .. -DBUILD_SDL_JSTEST=OFF -DBUILD_SDL2_JSTEST=ON
    make -j$(nproc)
_BUILD_SDL_JSTEST

RUN <<_INSTALL_SDL_JSTEST
    set -e 
    export DESTDIR=/gowinstall
    cd build
    make install
_INSTALL_SDL_JSTEST

#################################
FROM base-app-builder AS gamescope-builder

ARG GAMESCOPE_REF="3.16.17"
ARG GAMESCOPE_REPO="https://github.com/ValveSoftware/gamescope.git"

WORKDIR /usr/src/gamescope

RUN <<_CLONE_GAMESCOPE
    set -e 
    git init
    git remote add origin "${GAMESCOPE_REPO}"
    git fetch --depth 1 origin "${GAMESCOPE_REF}"
    git checkout FETCH_HEAD
    git submodule update --init --recursive --depth 1 --recommend-shallow
_CLONE_GAMESCOPE

RUN <<_BUILD_GAMESCOPE
    set -e 
    meson setup build/
    ninja -C build/
_BUILD_GAMESCOPE

RUN <<_INSTALL_GAMESCOPE
    set -e 
    export DESTDIR=/gowinstall
    export MESON_INSTALL_PREFIX=/usr/local
    meson install -C build/ --skip-subprojects
_INSTALL_GAMESCOPE

#################################
FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

# x11-utils: contains xdpyinfo, which we use to know whether Xorg has started yet
# pulseaudio-utils: some apps can't play sound unless this package is installed
ARG REQUIRED_PACKAGES="\
    x11-utils \
    pulseaudio-utils \
    mesa-vulkan-drivers libgbm1 libgles2 libegl1 libgl1-mesa-dri \
    libnvidia-egl-wayland1 libnvidia-egl-gbm1 \
    libsdl2-2.0-0 libncurses6 \
    fonts-noto-cjk \
    locales \
    xwayland kitty nano \
    waybar fonts-font-awesome xdg-desktop-portal xdg-desktop-portal-gtk psmisc \
    libaom3 libavif16 libdav1d7 libeis1 libgav1-1 libluajit-5.1-2 libluajit-5.1-common librav1e0.7 libsvtav1enc2 libwlroots-0.18 libxcb-errors0 libxres1 libyuv0 seatd \
    "

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    $REQUIRED_PACKAGES && \
    rm -rf /var/lib/apt/lists/*

# Some games with native Linux ports require en_US.UTF-8
# to be generated regardless of user locale settings
# see: https://github.com/games-on-whales/gow/pull/185
RUN locale-gen en_US.UTF-8

COPY --from=sdl-jstest-builder /gowinstall/ /
COPY --from=gamescope-builder /gowinstall/ /

#################################
# Install Sway
#################################
# We had lots of issues with Sway 1.10.1
# So we are manually reverting back to 1.9 from Ubuntu 24.04
RUN <<_INSTALL_SWAY
#!/bin/bash
set -e
curl -L -o sway.deb https://launchpad.net/ubuntu/+source/sway/1.9-1build2/+build/28013086/+files/sway_1.9-1build2_amd64.deb
apt update
apt install -y --no-install-recommends ./sway.deb
rm -rf /var/lib/apt/lists/* ./sway.deb
_INSTALL_SWAY

#################################
# Install MangoHuD
#################################
RUN <<_INSTALL_MANGO
#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

github_download "flightlessmango/MangoHud" ".assets[]|select(.name|endswith(\".tar.gz\")).browser_download_url" "MangoHud.tar.gz"
tar xf MangoHud.tar.gz
cd MangoHud
tar xf MangoHud-package.tar
chmod +x ./mangohud-setup.sh && ./mangohud-setup.sh install
rm -rf /MangoHud*
_INSTALL_MANGO

# Copy rootfs
COPY rootfs/ /

# Configure the default directory to be /root
WORKDIR /root
