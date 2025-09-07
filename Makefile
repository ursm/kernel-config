KCONFIG_SRC ?= /proc/config.gz
# Auto-detect reader: use zcat for *.gz, otherwise cat (not user-overridable)
override KCONFIG_READ := $(if $(filter %.gz,$(notdir $(KCONFIG_SRC))),zcat,cat)
KCFG_READ_CMD := $(KCONFIG_READ) $(KCONFIG_SRC)
GENERATED := 00-net-vendors-off.config 00-wlan-vendors-off.config 00-drm-off.config 00-fs-off.config 00-part-off.config 00-media-off.config 00-scsi-off.config 00-iio-off.config 00-netfs-off.config 00-pata-off.config 00-sata-off.config 00-alsa-pci-legacy-off.config 00-joy-legacy-off.config 00-9p-rxrpc-off.config
# A curated set of DRM device drivers to disable by default.
# This avoids turning off DRM core helpers (KMS, TTM, helpers, etc.).
# Major desktop/virtual GPU drivers and common vendor stacks are included.
DRM_DRIVER_RE := AMDGPU|RADEON|I915|XE|NOUVEAU|VMWGFX|GMA500|UDL|AST|MGAG200|QXL|VIRTIO_GPU|BOCHS|CIRRUS_QEMU|VKMS|VGEM|GUD|HYPERV|VBOXVIDEO|XEN_FRONTEND
# Small/embedded panels and tiny displays to disable (keep laptop-relevant bits)
DRM_SMALL_RE := MIPI_DBI|GM12U320|ST7571_I2C|ST7586|ST7735R|SSD130X|SSD130X_I2C|SSD130X_SPI|PANEL_MIPI_DBI|PANEL_WIDECHIPS_WS2401
FS_BLOCK_RE := EXT[234]|XFS|BTRFS|F2FS|NILFS2|REISERFS|JFS|HFSPLUS|HFS|MINIX|UFS|BFS|BEFS|EROFS|EXFAT|NTFS3|FAT|MSDOS|VFAT|ISO9660|UDF|OCFS2|GFS2|BCACHEFS|AFFS|ECRYPT|JFFS2|UBIFS|ROMFS|ORANGEFS
PART_RE := EFI|MSDOS|AMIGA|OSF|SGI|SUN|MAC|ATARI|AIX|LDM|KARMA|ULTRIX|SYSV68|SOLARIS_X86
MEDIA_RE := MEDIA_.*|VIDEO_.*|V4L2_.*|DVB_.*|RC_.*|IR_.*
SCSI_KEEP_RE := SCSI$$|SCSI_COMMON|SCSI_PROC_FS|SCSI_SCAN_.*|SCSI_LOWLEVEL|SCSI_LOGGING|SCSI_CONSTANTS|SCSI_NETLINK|SCSI_DMA|SCSI_.*ATTRS|SCSI_.*TRANSPORT
NETFS_RE := NFS_FS|CIFS|SMB_SERVER|9P_FS|AFS_FS|CEPH_FS
JOY_LEGACY_RE := ANALOG|A3D|ADI|COBRA|GF2K|GRIP(_MP)?|GUILLEMOT|INTERACT|SIDEWINDER|TMDC|WARRIOR|MAGELLAN|SPACEORB|SPACEBALL|STINGER|TWIDJOY|ZHENHUA|JOYDUMP|IFORCE_232
SND_PCI_LEGACY_RE := EMU10K1X?|FM801|ENS137[01]|CMIPCI|VIA82XX|ALI5451|ATIIXP|CS4281|CS46XX|TRIDENT|AU88[123]0|ICE17(12|24)|INTEL8X0M?

all: $(GENERATED)

## Convenience aliases
# Generate any fragment by its base name (without leading 00- and .config)
# Example: `make fs-off` -> builds 00-fs-off.config
FRAG_ALIASES := \
	net-vendors-off \
	wlan-vendors-off \
	drm-off \
	fs-off \
	part-off \
	media-off \
	scsi-off \
	iio-off \
	netfs-off \
	pata-off \
	sata-off \
	alsa-pci-legacy-off \
	joy-legacy-off \
	9p-rxrpc-off \
	nfc-off \
	staging-off

$(FRAG_ALIASES): %: 00-%.config

00-net-vendors-off.config: $(KCONFIG_SRC) FORCE
	$(KCFG_READ_CMD) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^CONFIG_NET_VENDOR_' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-wlan-vendors-off.config: $(KCONFIG_SRC) FORCE
	$(KCFG_READ_CMD) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^CONFIG_WLAN_VENDOR_' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-drm-off.config: $(KCONFIG_SRC) FORCE
	$(KCFG_READ_CMD) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E "^CONFIG_DRM_($(DRM_DRIVER_RE)|$(DRM_SMALL_RE))$$" \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-fs-off.config: $(KCONFIG_SRC) FORCE
	$(KCFG_READ_CMD) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E "^CONFIG_($(FS_BLOCK_RE))_FS$$" \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-media-off.config: $(KCONFIG_SRC) FORCE
	$(KCFG_READ_CMD) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^CONFIG_($(MEDIA_RE))$$' \
	  | grep -Ev '^CONFIG_(MEDIA_SUPPORT|MEDIA_USB_SUPPORT|MEDIA_CAMERA_SUPPORT|MEDIA_CONTROLLER|VIDEO_DEV)$$' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-iio-off.config: $(KCONFIG_SRC) FORCE
	$(KCFG_READ_CMD) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^CONFIG_IIO($$|_)' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-netfs-off.config: $(KCONFIG_SRC) FORCE
	$(KCFG_READ_CMD) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^CONFIG_($(NETFS_RE))$$' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-scsi-off.config: $(KCONFIG_SRC) FORCE
	$(KCFG_READ_CMD) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^CONFIG_SCSI_.*$$' \
	  | grep -Ev '^CONFIG_($(SCSI_KEEP_RE))$$' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-part-off.config: $(KCONFIG_SRC) FORCE
	$(KCFG_READ_CMD) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^(CONFIG_($(PART_RE))_PARTITION|CONFIG_MINIX_SUBPARTITION|CONFIG_(BSD_DISKLABEL|UNIXWARE_DISKLABEL))$$' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-pata-off.config: $(KCONFIG_SRC) FORCE
	$(KCFG_READ_CMD) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^CONFIG_PATA_' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-sata-off.config: $(KCONFIG_SRC) FORCE
	$(KCFG_READ_CMD) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^CONFIG_SATA_' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-alsa-pci-legacy-off.config: $(KCONFIG_SRC) FORCE
	$(KCFG_READ_CMD) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^CONFIG_SND_($(SND_PCI_LEGACY_RE))$$' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-joy-legacy-off.config: $(KCONFIG_SRC) FORCE
	$(KCFG_READ_CMD) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^CONFIG_JOYSTICK_($(JOY_LEGACY_RE))$$' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-nfc-off.config: $(KCONFIG_SRC) FORCE
	$(KCFG_READ_CMD) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^CONFIG_NFC($$|_)' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-staging-off.config: $(KCONFIG_SRC) FORCE
	$(KCFG_READ_CMD) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^CONFIG_STAGING($$|_)' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

00-9p-rxrpc-off.config: $(KCONFIG_SRC) FORCE
	$(KCFG_READ_CMD) \
	  | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) is not set$$/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/' \
	  | grep -E '^(CONFIG_NET_9P($$|_)|CONFIG_AF_RXRPC($$|_)|CONFIG_RX(KAD|GK)($$|_))$$' \
	  | sort -u \
	  | sed -E 's/^/# /; s/$$/ is not set/' \
	  > $@

clean:
	rm -f $(GENERATED)

install: all
	sh scripts/install.sh

uninstall:
	sh scripts/uninstall.sh

help:
	@echo "Usage: make <target> [KCONFIG_SRC=…]"
	@echo
	@echo "Common targets:"
	@echo "  all             Generate default 00-*.config set"
	@echo "  install         Install *.config to /etc/kernel/config.d (with cleanup)"
	@echo "  uninstall       Remove files previously installed by this repo"
	@echo "  clean           Remove generated 00-*.config"
	@echo "  check           Show source and counts"
	@echo
	@echo "Fragment aliases (generate 00-<name>.config):"
	@printf "  %s\n" $(FRAG_ALIASES)

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
	@printf "  IIO:           "; $(KCONFIG_READ) $(KCONFIG_SRC) | grep -Ec '^CONFIG_IIO=(y|m)|^CONFIG_IIO_.*=(y|m)' || true
	@printf "  NetFS:         "; $(KCONFIG_READ) $(KCONFIG_SRC) | grep -Ec '^CONFIG_($(NETFS_RE))=(y|m)' || true
	@printf "  SCSI LLD:      "; $(KCONFIG_READ) $(KCONFIG_SRC) | grep -E '^CONFIG_SCSI_.*=(y|m)' | grep -Ev '^CONFIG_($(SCSI_KEEP_RE))=' | wc -l
	@printf "  PATA:          "; $(KCONFIG_READ) $(KCONFIG_SRC) | grep -Ec '^CONFIG_PATA_.*=(y|m)' || true
	@printf "  SATA:          "; $(KCONFIG_READ) $(KCONFIG_SRC) | grep -Ec '^CONFIG_SATA_.*=(y|m)' || true
	@printf "  JOY legacy:    "; $(KCONFIG_READ) $(KCONFIG_SRC) | grep -Ec '^CONFIG_JOYSTICK_($(JOY_LEGACY_RE))=(y|m)' || true

.PHONY: all clean install uninstall check help $(FRAG_ALIASES) FORCE

FORCE:
