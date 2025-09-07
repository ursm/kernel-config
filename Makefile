KCONFIG_SRC ?= /proc/config.gz
# Auto-detect reader: use zcat for *.gz, otherwise cat (not user-overridable)
override KCONFIG_READ := $(if $(filter %.gz,$(notdir $(KCONFIG_SRC))),zcat,cat)
GENERATED := 00-net-vendors-off.config 00-wlan-vendors-off.config 00-usbnet-off.config 00-drm-off.config 00-fs-off.config
# A curated set of DRM device drivers to disable by default.
# This avoids turning off DRM core helpers (KMS, TTM, helpers, etc.).
# Major desktop/virtual GPU drivers and common vendor stacks are included.
DRM_DRIVER_RE := AMDGPU|RADEON|I915|XE|NOUVEAU|VMWGFX|GMA500|UDL|AST|MGAG200|QXL|VIRTIO_GPU|BOCHS|CIRRUS_QEMU|VKMS|VGEM|GUD|HYPERV|VBOXVIDEO|XEN_FRONTEND
FS_BLOCK_RE := EXT[234]|XFS|BTRFS|F2FS|NILFS2|REISERFS|JFS|HFSPLUS|HFS|MINIX|UFS|BFS|BEFS|EROFS|EXFAT|NTFS3|FAT|MSDOS|VFAT|ISO9660|UDF|OCFS2|GFS2|BCACHEFS

all: $(GENERATED)

00-net-vendors-off.config: $(KCONFIG_SRC) FORCE
	$(KCONFIG_READ) $(KCONFIG_SRC) \
	  | awk -F= '/^CONFIG_NET_VENDOR_/ {print "# "$$1" is not set"}' \
	  | sort -u > $@

00-wlan-vendors-off.config: $(KCONFIG_SRC) FORCE
	$(KCONFIG_READ) $(KCONFIG_SRC) \
	  | awk -F= '/^CONFIG_WLAN_VENDOR_/ {print "# "$$1" is not set"}' \
	  | sort -u > $@

00-usbnet-off.config: $(KCONFIG_SRC) FORCE
	$(KCONFIG_READ) $(KCONFIG_SRC) \
	  | awk -F= '/^CONFIG_USB_NET_/ {print "# "$$1" is not set"}' \
	  | sort -u > $@

00-drm-off.config: $(KCONFIG_SRC) FORCE
	$(KCONFIG_READ) $(KCONFIG_SRC) \
	  | grep -E "^CONFIG_DRM_($(DRM_DRIVER_RE))=(y|m)" \
	  | awk -F= '{print "# "$$1" is not set"}' \
	  | sort -u > $@

00-fs-off.config: $(KCONFIG_SRC) FORCE
	$(KCONFIG_READ) $(KCONFIG_SRC) \
	  | grep -E "^CONFIG_($(FS_BLOCK_RE))_FS=(y|m)" \
	  | awk -F= '{print "# "$$1" is not set"}' \
	  | sort -u > $@

clean:
	rm -f $(GENERATED)

install: all
	mkdir -p /etc/kernel/config.d
	sh -c 'set -e; arch=$$(uname -m); for f in *.config; do case "$$f" in 10-x86.config) case "$$arch" in x86_64|i?86) cp "$$f" /etc/kernel/config.d/ ;; esac ;; *) cp "$$f" /etc/kernel/config.d/ ;; esac; done'

check:
	@echo "KCONFIG_SRC: $(KCONFIG_SRC)"
	@if [ -r "$(KCONFIG_SRC)" ]; then echo "Readable: yes"; else echo "Readable: no"; exit 1; fi
	@echo "Matches (enabled=y/m):"
	@printf "  NET_VENDOR:    "; $(KCONFIG_READ) $(KCONFIG_SRC) | awk -F= '/^CONFIG_NET_VENDOR_/ && $$2 ~ /^(y|m)/ {c++} END {print c+0}'
	@printf "  WLAN_VENDOR:   "; $(KCONFIG_READ) $(KCONFIG_SRC) | awk -F= '/^CONFIG_WLAN_VENDOR_/ && $$2 ~ /^(y|m)/ {c++} END {print c+0}'
	@printf "  USB_NET:       "; $(KCONFIG_READ) $(KCONFIG_SRC) | awk -F= '/^CONFIG_USB_NET_/ && $$2 ~ /^(y|m)/ {c++} END {print c+0}'
	@printf "  DRM drivers:   "; $(KCONFIG_READ) $(KCONFIG_SRC) | grep -Ec '^CONFIG_DRM_($(DRM_DRIVER_RE))=(y|m)' || true
	@printf "  Filesystems:   "; $(KCONFIG_READ) $(KCONFIG_SRC) | grep -Ec "^CONFIG_($(FS_BLOCK_RE))_FS=(y|m)" || true

.PHONY: all clean install check FORCE

FORCE:
