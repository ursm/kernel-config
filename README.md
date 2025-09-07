# kernel-config

Small, reproducible collection of Linux kernel config fragments for Gentoo's distribution kernel (`sys-kernel/gentoo-kernel`). It generates minimal defaults and installs them under Gentoo's fragment directory `/etc/kernel/config.d`.

## Overview

This repository helps you maintain kernel configuration as small, focused fragments:

- Generate `00-*.config` files from the running kernel (`/proc/config.gz`) that disable broad option families (NET vendor, WLAN vendor, USB NET, DRM, filesystems, partitions, media, SCSI LLD, IIO, NetFS).
- Keep opinionated base settings in `10-base.config` for a lightweight kernel.
- Keep machine/user specific overrides in `99-local.config` (with an example provided).
- Install all `*.config` files to `/etc/kernel/config.d` in one command.

## Requirements

- Gentoo with `sys-kernel/gentoo-kernel` (uses `/etc/kernel/config.d/*.config`).

## Repository Layout

- `Makefile`: build rules for generating, cleaning, and installing the fragments.
- `10-base.config`: opinionated baseline focused on a lean kernel (debug/tracing/test features off; Zstd compression, etc.).
- `10-x86.config`: x86-specific tuning (e.g., `CONFIG_X86_NATIVE_CPU=y`). Installed only on x86 hosts.
- `00-*.config`: generated files that turn off large groups of options detected from the running kernel.
- `99-local.config`: local overrides; kept out of VCS design by default (see example).
- `99-local.config.example`: template to create your own `99-local.config`.

## Usage

- Generate fragments (writes `00-*.config` to repo root):

  make

- Install all `*.config` to `/etc/kernel/config.d` (runs generation first):

  sudo make install

- Uninstall all files installed by this repo (safe; uses manifest):

  sudo make uninstall

- Clean generated files (`00-*.config` only):

  make clean

- Generate a single file (example):

  make 00-net-vendors-off.config

- Check source and match counts:

  make check

## How It Works

The Makefile reads `/proc/config.gz` (or a provided source) and, for each option family, normalizes entries whether enabled, modular, or already disabled, and emits canonical "# CONFIG_… is not set" lines (sorted and unique):

- `00-net-vendors-off.config`: disables all `CONFIG_NET_VENDOR_*` options.
- `00-wlan-vendors-off.config`: disables all `CONFIG_WLAN_VENDOR_*` options.
- `00-usbnet-off.config`: disables all `CONFIG_USB_NET_*` options.
- `00-drm-off.config`: disables non-core DRM options while keeping DRM core helpers (KMS, TTM, GEM helpers, DP helpers, display helpers) intact. Also drops small embedded panels/displays (MIPI DBI, SSD130x, ST77xx, GM12U320, selected PANEL_*), while keeping laptop‑relevant parts.
- `00-fs-off.config`: disables common on-disk filesystems — e.g., ext4/xfs/btrfs/f2fs/bcachefs/ntfs/exfat — without touching pseudo filesystems like proc/sysfs/tmpfs.
- `00-part-off.config`: disables partition table parsers — e.g., GPT/EFI, MBR/MSDOS, and legacy labels (Amiga/Mac/BSD/etc.).
- `00-media-off.config`: disables Media (V4L2/DVB/RC) options. Minimal webcam support (UVC) is re-enabled in `10-base.config`.
- `00-iio-off.config`: disables Industrial I/O (IIO) core and drivers (sensors/ADC/DAC).
- `00-netfs-off.config`: disables network filesystems — CIFS/SMB, NFS, 9P, AFS, Ceph.
- `00-pata-off.config`: disables legacy Parallel ATA (PATA) support and related host drivers.
- `00-sata-off.config`: disables all `CONFIG_SATA_*` host/controller drivers; AHCI is re-enabled in `10-base.config`.
- `00-alsa-pci-legacy-off.config`: disables legacy PCI ALSA drivers (non-HDA) such as EMU10K1, FM801, AC'97-era chipsets.
- `00-joy-legacy-off.config`: disables legacy gameport-era joystick drivers (keeps USB-based xpad/iforce_usb, etc.).
- `00-scsi-off.config`: disables SCSI low-level drivers (HBA-specific) while keeping SCSI core intact.
- `00-nfc-off.config`: disables NFC core and NFC device drivers.
- `00-staging-off.config`: disables staging drivers subtree (and staging media when present).
- `00-9p-rxrpc-off.config`: disables 9P network filesystem and RxRPC stack (and RXKAD/RXGK auth).
- `00-ceph-lib-off.config`: disables Ceph client library (useful only with CephFS/RBD userspace).
- `00-intel-smartconnect-off.config`: disables deprecated Intel Smart Connect feature.

These generated files complement `10-base.config`, which prioritizes a minimal, fast kernel by turning off extensive debug/tracing/testing options and choosing modern defaults like Zstd compression.

Use `99-local.config` to selectively re-enable hardware or features required for your machine or workload. Start by copying the example:

cp -n 99-local.config.example 99-local.config

Then edit `99-local.config` to match your needs (e.g., specific GPU, WLAN vendors, higher CPU count, security modules, etc.).

## Notes

- On Gentoo, files placed in `/etc/kernel/config.d` are picked up by `sys-kernel/gentoo-kernel` on the next build/upgrade, influencing the final `.config`.
- The generated files reflect the option families present in the selected source `.config` (enabled, modular, or already disabled are all normalized). If you change kernels, re-run `make` to refresh.
- `install` depends on `all`, so `make install` will always generate before copying.
- `install` writes a manifest to `/etc/kernel/config.d/.kernel-config.manifest` and removes files from previous installs that no longer exist in the repo (safe cleanup; it does not touch files it did not install).
- `uninstall` reads the manifest and removes only the files previously installed by this repository, then deletes the manifest. It leaves `/etc/kernel/config.d` intact.
- `clean` removes only the generated `00-*.config` files, preserving your curated files.
- `10-x86.config` is copied only when `uname -m` is `x86_64` or `i?86`.

### Selecting the source `.config`

- Default source: `/proc/config.gz`.
- Use a plain-text file:

  make KCONFIG_SRC=/path/to/.config

- Use a compressed file (`.gz` is handled automatically):

  make KCONFIG_SRC=/path/to/config.gz

## License

MIT — see `LICENSE`.
