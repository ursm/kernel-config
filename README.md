# ursm-kernel

Personal config fragments for the Linux kernel on Gentoo distribution kernels. The scope is intentionally narrow:

- Remove developer-only features that impact runtime performance.
- Apply configuration changes that improve performance without side effects.

Reducing build time is not a goal (it may happen as a byproduct). This repository avoids touching areas that can affect bootability or security; it does not modify Secure Boot, module signing, or lockdown.

This repository targets Gentoo distribution kernels (`sys-kernel/gentoo-kernel`). Instead of editing `/usr/src/linux/.config`, fragments are placed under `/etc/kernel/config.d` and merged by the kernel packaging process.

## Layout

- `overlays/10-disable-devdebug.config`: Disable developer-only instrumentation and heavy debug/testing/profiling features (sanitizers, gcov/kcov, debug/test toggles).
- `overlays/20-perf-optimizations.config`: Opinionated but safe optimizations (Zstd kernel/modules, tickless idle, native CPU, perf-over-size).
- `bin/install`: Install fragments into `/etc/kernel/config.d` (requires root).
- `bin/uninstall`: Remove installed fragments from `/etc/kernel/config.d`.

## Install (Gentoo distribution kernel)

Prerequisites:

- Using `sys-kernel/gentoo-kernel` or another distribution kernel that honors `/etc/kernel/config.d/*.config` via `merge_config.sh`.
- Root privileges to write to `/etc/kernel/config.d`.

Steps:

1. Review overlays: `overlays/10-disable-devdebug.config`, `overlays/20-perf-optimizations.config`.
2. Install fragments: `sudo bin/install`.
3. Rebuild or upgrade the distribution kernel as usual (e.g., `emerge -1 sys-kernel/gentoo-kernel`).
4. If needed, revert: `sudo bin/uninstall` and rebuild.

Notes:

- Files are installed under `/etc/kernel/config.d` with a `50-ursm-*.config` prefix to keep ordering predictable and avoid clobbering other fragments.
- This repository deliberately avoids functional changes that could impact boot or security posture.

## Policy

In scope: disable developer-time instrumentation with significant runtime overhead, and enable safe, broadly beneficial performance features.

- Sanitizers/instrumentation: KASAN, KCSAN, UBSAN, KFENCE, KCOV, GCOV (and KMSAN/KMEMLEAK when available)
- Debug/testing/profiling: SLUB_DEBUG, PAGE_POISONING/OWNER/EXTENSION, SCHEDSTATS/LATENCYTOP, DEBUG_LIST, KGDB/KUNIT, RCU_TRACE, KALLSYMS_ALL, PROFILING, and related DEBUG_* toggles
- Prefer performance over size: `CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y`
- Faster compression where applicable: `CONFIG_KERNEL_ZSTD=y`, `CONFIG_MODULE_COMPRESS=y`, `CONFIG_MODULE_COMPRESS_ZSTD=y`
- Tickless idle: `CONFIG_NO_HZ_IDLE=y`
- Per‑machine x86 tuning: `CONFIG_X86_NATIVE_CPU=y` (note: image becomes machine‑specific)

Out of scope: features with higher risk of side effects.

- Secure Boot, module signing, lockdown
- cgroups, BPF, tracing (e.g., ftrace)
- Preemption model, scheduler policy, HZ, broad MM policy shifts

## Troubleshooting

If a regression appears, list effective changes by inspecting `/etc/kernel/config.d/50-ursm-*.config`. Since this repository only disables heavy debug/instrumentation, unexpected behavioral changes should be rare. Temporarily remove the fragments with `bin/uninstall` to bisect.

## License

See `LICENSE`.
