KCONFIG_SRC ?= /proc/config.gz
# Auto-detect reader: use zcat for *.gz, otherwise cat (not user-overridable)
override KCONFIG_READ := $(if $(filter %.gz,$(notdir $(KCONFIG_SRC))),zcat,cat)
GENERATED := 00-net-vendors-off.config 00-wlan-vendors-off.config 00-usbnet-off.config 00-drm-off.config 00-fs-off.config 00-part-off.config 00-media-off.config 00-scsi-off.config 00-iio-off.config 00-netfs-off.config
# A curated set of DRM device drivers to disable by default.
# This avoids turning off DRM core helpers (KMS, TTM, helpers, etc.).
# Major desktop/virtual GPU drivers and common vendor stacks are included.
DRM_DRIVER_RE := AMDGPU|RADEON|I915|XE|NOUVEAU|VMWGFX|GMA500|UDL|AST|MGAG200|QXL|VIRTIO_GPU|BOCHS|CIRRUS_QEMU|VKMS|VGEM|GUD|HYPERV|VBOXVIDEO|XEN_FRONTEND
FS_BLOCK_RE := EXT[234]|XFS|BTRFS|F2FS|NILFS2|REISERFS|JFS|HFSPLUS|HFS|MINIX|UFS|BFS|BEFS|EROFS|EXFAT|NTFS3|FAT|MSDOS|VFAT|ISO9660|UDF|OCFS2|GFS2|BCACHEFS
PART_RE := EFI|MSDOS|AMIGA|OSF|SGI|SUN|MAC|ATARI|IBM|LDM|KARMA|ULTRIX|SYSV68|MINIX_SUB|SOLARIS_X86
MEDIA_RE := MEDIA_.*|VIDEO_.*|V4L2_.*|DVB_.*|RC_.*|IR_.*
SCSI_KEEP_RE := SCSI$$|SCSI_COMMON|SCSI_PROC_FS|SCSI_SCAN_.*|SCSI_LOWLEVEL|SCSI_LOGGING|SCSI_CONSTANTS|SCSI_NETLINK|SCSI_DMA|SCSI_.*ATTRS|SCSI_.*TRANSPORT
NETFS_RE := NFS_FS|CIFS|SMB_SERVER|9P_FS|AFS_FS|CEPH_FS

all: $(GENERATED)

00-net-vendors-off.config: $(KCONFIG_SRC) FORCE
	$(KCONFIG_READ) $(KCONFIG_SRC) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^CONFIG_NET_VENDOR_' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-wlan-vendors-off.config: $(KCONFIG_SRC) FORCE
	$(KCONFIG_READ) $(KCONFIG_SRC) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^CONFIG_WLAN_VENDOR_' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-usbnet-off.config: $(KCONFIG_SRC) FORCE
	$(KCONFIG_READ) $(KCONFIG_SRC) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^CONFIG_USB_NET_' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-drm-off.config: $(KCONFIG_SRC) FORCE
	$(KCONFIG_READ) $(KCONFIG_SRC) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E "^CONFIG_DRM_($(DRM_DRIVER_RE))$$" \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-fs-off.config: $(KCONFIG_SRC) FORCE
	$(KCONFIG_READ) $(KCONFIG_SRC) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E "^CONFIG_($(FS_BLOCK_RE))_FS$$" \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-media-off.config: $(KCONFIG_SRC) FORCE
	$(KCONFIG_READ) $(KCONFIG_SRC) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^CONFIG_($(MEDIA_RE))$$' \
	  | grep -Ev '^CONFIG_(MEDIA_SUPPORT|MEDIA_USB_SUPPORT|MEDIA_CAMERA_SUPPORT|MEDIA_CONTROLLER|VIDEO_DEV)$$' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-iio-off.config: $(KCONFIG_SRC) FORCE
	$(KCONFIG_READ) $(KCONFIG_SRC) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^CONFIG_IIO($$|_)' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-netfs-off.config: $(KCONFIG_SRC) FORCE
	$(KCONFIG_READ) $(KCONFIG_SRC) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^CONFIG_($(NETFS_RE))$$' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-scsi-off.config: $(KCONFIG_SRC) FORCE
	$(KCONFIG_READ) $(KCONFIG_SRC) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^CONFIG_SCSI_.*$$' \
	  | grep -Ev '^CONFIG_($(SCSI_KEEP_RE))$$' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-part-off.config: $(KCONFIG_SRC) FORCE
	$(KCONFIG_READ) $(KCONFIG_SRC) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^(CONFIG_($(PART_RE))_PARTITION|CONFIG_(BSD_DISKLABEL|UNIXWARE_DISKLABEL))$$' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

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
	@printf "  Partitions:    "; $(KCONFIG_READ) $(KCONFIG_SRC) | grep -Ec '^(CONFIG_($(PART_RE))_PARTITION|CONFIG_(BSD_DISKLABEL|UNIXWARE_DISKLABEL))=(y|m)' || true
	@printf "  Media:         "; $(KCONFIG_READ) $(KCONFIG_SRC) | grep -Ec '^CONFIG_($(MEDIA_RE))=(y|m)' || true
	@printf "  IIO:           "; $(KCONFIG_READ) $(KCONFIG_SRC) | grep -Ec '^CONFIG_IIO(=|_).*=(y|m)' || true
	@printf "  NetFS:         "; $(KCONFIG_READ) $(KCONFIG_SRC) | grep -Ec '^CONFIG_($(NETFS_RE))=(y|m)' || true
	@printf "  SCSI LLD:      "; $(KCONFIG_READ) $(KCONFIG_SRC) | grep -E '^CONFIG_SCSI_.*=(y|m)' | grep -Ev '^CONFIG_($(SCSI_KEEP_RE))=' | wc -l

.PHONY: all clean install check FORCE

FORCE:
