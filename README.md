# kernel-config

Small, reproducible collection of Linux kernel config fragments for Gentoo's distribution kernel (`sys-kernel/gentoo-kernel`). It generates minimal defaults and installs them under Gentoo's fragment directory `/etc/kernel/config.d`.

## Overview

This repository helps you maintain kernel configuration as small, focused fragments:

- Generate `00-*.config` files from the running kernel (`/proc/config.gz`) that disable broad option families (NET vendor, WLAN vendor, USB NET, DRM).
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

- Clean generated files (`00-*.config` only):

  make clean

- Generate a single file (example):

  make 00-net-vendors-off.config

- Check source and match counts:

  make check

## How It Works

The Makefile reads `/proc/config.gz` and produces the following files by matching option families and emitting "is not set" lines, sorted and unique:

- `00-net-vendors-off.config`: disables all `CONFIG_NET_VENDOR_*` options.
- `00-wlan-vendors-off.config`: disables all `CONFIG_WLAN_VENDOR_*` options.
- `00-usbnet-off.config`: disables all `CONFIG_USB_NET_*` options.
- `00-drm-off.config`: disables non-core DRM options detected as enabled (y/m) while keeping DRM core helpers (KMS, TTM, GEM helpers, DP helpers, display helpers) intact.

These generated files complement `10-base.config`, which prioritizes a minimal, fast kernel by turning off extensive debug/tracing/testing options and choosing modern defaults like Zstd compression.

Use `99-local.config` to selectively re-enable hardware or features required for your machine or workload. Start by copying the example:

cp -n 99-local.config.example 99-local.config

Then edit `99-local.config` to match your needs (e.g., specific GPU, WLAN vendors, higher CPU count, security modules, etc.).

## Notes

- On Gentoo, files placed in `/etc/kernel/config.d` are picked up by `sys-kernel/gentoo-kernel` on the next build/upgrade, influencing the final `.config`.
- The generated files reflect the option families present in the currently running kernel. If you change kernels, re-run `make` to refresh.
- `install` depends on `all`, so `make install` will always generate before copying.
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
