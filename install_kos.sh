#!/usr/bin/env bash
###############################################################################
# KOS VM Script
###############################################################################
# This script represents a machine where KOS is built.

set -e

export DC_ROOT=~/Tools/dreamcast
export DC_TOOLCHAIN_ROOT=$DC_ROOT/KallistiOS/utils/dc-chain

function pkg_install() {
    sudo -E DEBIAN_FRONTEND=noninteractive apt-get install $@
}


function install_gcc_prerequisites() {
    sudo apt-get update
    # Thanks to kenws on #dreamcastdev for providing this list.
    pkg_install gcc make bison flex   \
         libelf-dev texinfo latex2html git wget sed lyx
}

function download_kos_source() {
    mkdir -p $DC_ROOT
    pushd $DC_ROOT
    git clone git://cadcdev.git.sourceforge.net/gitroot/cadcdev/KallistiOS
    git clone --recursive git://cadcdev.git.sourceforge.net/gitroot/cadcdev/kos-ports kos-ports
    popd
}

function prepare_gcc_source() {
    pushd $DC_TOOLCHAIN_ROOT
    # This downloads the GCC source code.
    ./download.sh
    # Unzips it.
    ./unpack.sh
    pushd gcc-4.7.0
    # This next script downloads the current versions of mp, mpfr, and mpc.
    # If it fails, an alternative is to instal them via the package manager.
    ./contrib/download_prerequisites
    popd
    # There are numerous problems where the build process will not have access
    # to various directories. This preemptively creates those directories and
    # chowns them so we have access.
    sudo mkdir -p /opt/toolchains/dc
    sudo chown $USER /opt/toolchains/dc
    mkdir -p /opt/toolchains/dc/sh-elf/sh-elf/include
    mkdir -p /opt/toolchains/dc/sh-elf/share

    # The last step uses the KOS provided make file to patch GCC to
    # work with the Dreamcast processors.
    make patch
    popd
}

function build_sh4_tools() {
    pushd $DC_TOOLCHAIN_ROOT
    make build-sh4-binutils
    make build-sh4-gcc-pass1
    make build-sh4-newlib-only
    make fixup-sh4-newlib
    make build-sh4-gcc-pass2
    popd
}

function build_arm_tools() {
    pushd $DC_TOOLCHAIN_ROOT
    make build-arm-binutils
    make build-arm-gcc
    popd
}

function create_environ_sh_script() {
    echo "
# KallistiOS environment variable settings
export KOS_ARCH='dreamcast'

export KOS_SUBARCH='pristine'

export KOS_BASE='$DC_ROOT/KallistiOS'
" >  $DC_ROOT/environ.sh
    echo '
# Make utility
export KOS_MAKE="make"

# Load utility
export KOS_LOADER="dc-tool -x"              # dcload, preconfigured

# Genromfs utility
export KOS_GENROMFS="${KOS_BASE}/utils/genromfs/genromfs"

# Compiler prefixes
export KOS_CC_BASE="/opt/toolchains/dc/sh-elf"      # DC
export KOS_CC_PREFIX="sh-elf"

export DC_ARM_BASE="/opt/toolchains/dc/arm-eabi"
export DC_ARM_PREFIX="arm-eabi"

export PATH="${PATH}:${KOS_CC_BASE}/bin:/usr/local/dc/bin"

export KOS_INC_PATHS="-I${KOS_BASE}/../kos-ports/include"

export KOS_CFLAGS=""
export KOS_CPPFLAGS=""
export KOS_LDFLAGS=""
export KOS_AFLAGS=""

export KOS_CFLAGS="-O2 -fomit-frame-pointer"

. ${KOS_BASE}/environ_base.sh
    ' >> $DC_ROOT/environ.sh
}

function build_kos() {
    pushd $DC_ROOT/KallistiOS
    make
    popd
}

function build_kos_ports() {
    pushd $DC_ROOT/kos-ports
    make
    popd
}

function cmd_install() {
    install_gcc_prerequisites
    download_kos_source
    prepare_gcc_source
    build_sh4_tools
    build_arm_tools
    create_environ_sh_script
    source $DC_ROOT/environ.sh
    build_kos
    build_kos_ports
}

cmd_install
