#!/bin/bash
set -e

PREFIX="${PREFIX:-$(pwd)/build-output}"
BUILD_TMP="${BUILD_TMP:-$(pwd)/build-tmp}"

if [ ! -f upstream/meson.build ]; then
    echo "Error: upstream libdrm checkout not found (git submodule update --init)" >&2
    exit 1
fi

mkdir -p "$PREFIX"
rm -rf "$BUILD_TMP"

# NeoOS has no DRM/KMS subsystem at all -- this port exists purely to
# satisfy Mesa's EGL/DRI2 frontend build-time requirement (see
# neoos-mesa sub-project 2). Every hardware-specific backend is
# disabled; only the generic core (xf86drm.c's device-enumeration and
# ioctl-wrapper functions) is built. At runtime, device enumeration
# just finds no /dev/dri and returns zero devices -- correct real
# behavior, not emulation, since NeoOS genuinely has no DRM devices.
meson setup "$BUILD_TMP" upstream \
    --cross-file="$(pwd)/cross-file.txt" \
    --prefix="$PREFIX" \
    --default-library=static \
    -Dintel=disabled \
    -Dradeon=disabled \
    -Damdgpu=disabled \
    -Dnouveau=disabled \
    -Dvmwgfx=disabled \
    -Dfreedreno=disabled \
    -Dvc4=disabled \
    -Detnaviv=disabled \
    -Domap=disabled \
    -Dexynos=disabled \
    -Dtegra=disabled \
    -Dcairo-tests=disabled \
    -Dman-pages=disabled \
    -Dvalgrind=disabled \
    -Dudev=false \
    -Dtests=false \
    -Dinstall-test-programs=false

echo "OK: Meson configure succeeded -- see build-tmp/meson-logs/meson-log.txt"

ninja -C "$BUILD_TMP"
ninja -C "$BUILD_TMP" install

if [ -f "$PREFIX/lib/libdrm.a" ]; then
    echo "OK: libdrm.a built at $PREFIX/lib/libdrm.a"
else
    echo "ERROR: build finished but libdrm.a not found" >&2
    exit 1
fi
