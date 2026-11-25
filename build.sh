#!/bin/sh
# Configure and build qemu-system-pdp64 out of tree (QEMU_BUILD, default ../qemu-build next to this repository) from QEMU_SRC (default ../qemu-src).
# usage: build.sh [-j N]      (a first build takes a long time on two cores: run it in the background)
# QEMU_TARGETS (default pdp64-softmmu, the full system emulation) is the configure target list; add pdp64-linux-user for the
# user-mode emulator (qemu-pdp64) once that target exists.  Changing it needs a fresh QEMU_BUILD directory.
set -e
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
SIB=$(dirname "$here")
Q=${QEMU_SRC:-$SIB/qemu-src}
B=${QEMU_BUILD:-$SIB/qemu-build}
J=2; [ "${1:-}" = "-j" ] && J=$2
T=${QEMU_TARGETS:-pdp64-softmmu}
"$here/install.sh" "$Q"
mkdir -p "$B"
cd "$B"
if [ ! -f build.ninja ]; then
	"$Q/configure" --target-list="$T" --disable-docs --disable-tools --disable-guest-agent \
		--disable-werror --disable-plugins --disable-vnc --disable-gtk --disable-sdl --disable-opengl --disable-curses \
		--disable-slirp --disable-kvm --disable-xen --disable-capstone --disable-libusb --disable-fdt --disable-selinux \
		--disable-attr --disable-linux-aio --disable-linux-io-uring --disable-bzip2 --disable-zstd --disable-snappy \
		--disable-lzo --disable-gnutls --disable-nettle --disable-gcrypt --disable-curl
fi
ninja -j"$J" qemu-system-pdp64
echo "built $B/qemu-system-pdp64"
case " $T " in *pdp64-linux-user*) ninja -j"$J" qemu-pdp64; echo "built $B/qemu-pdp64";; esac
