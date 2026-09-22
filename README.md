# neoos-libdrm

A NeoOS cross-build of libdrm's core (device enumeration + ioctl
wrappers only -- every hardware-specific backend disabled), pinned to
upstream tag `libdrm-2.4.120`.

Exists purely to satisfy Mesa's EGL/DRI2 frontend, which hard-requires
libdrm at configure time whenever `-Degl=enabled` (see neoos-mesa's
Gallium3D sub-project 2). NeoOS has no DRM/KMS subsystem: at runtime,
libdrm's device enumeration finds no `/dev/dri` and reports zero
devices, which is correct real behavior on a system with no DRM
devices exposed -- not emulation.

Build: `./build.sh` (needs the `x86_64-neoos-linux-musl` hosted
toolchain on PATH, and Meson/Ninja on the host). Produces a static
`libdrm.a` + `libdrm.pc` under `build-output/`.
