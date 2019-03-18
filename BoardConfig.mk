# config.mk
#
# Product-specific compile-time definitions.
#

# The generic product target doesn't have any hardware-specific pieces.
TARGET_NO_BOOTLOADER := true
TARGET_NO_KERNEL := false
# BOARD_ADD_VENDOR_BOOT_IMAGE_FILE := boot_b.img boot_u.img boot_st.img bin_k.img bin_r.img bin_u.img recovery.img

TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_VARIANT := generic
TARGET_CPU_ABI := arm64-v8a

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv7-a-neon
TARGET_2ND_CPU_VARIANT := cortex-a15
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi

TARGET_USES_64_BIT_BINDER := true

TARGET_BOARD_PLATFORM = sc1401aj1
TARGET_BOOTLOADER_BOARD_NAME := sc1401aj1

BOARD_KERNEL_BASE := 0
BOARD_KERNEL_OFFSET := 0xb7080000
BOARD_RAMDISK_OFFSET := 0xe8800000
BOARD_MKBOOTIMG_ARGS := --base $(BOARD_KERNEL_BASE) --kernel_offset $(BOARD_KERNEL_OFFSET) --ramdisk_offset $(BOARD_RAMDISK_OFFSET)

BOARD_USES_ALSA_AUDIO := true

USE_CAMERA_STUB := true

USE_OPENGL_RENDERER := true
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3
TARGET_DISABLE_TRIPLE_BUFFERING := true
VSYNC_EVENT_PHASE_OFFSET_NS := 0

# PDK does not use ext4 image, but it is added here to prevent build break.
BOARD_BOOTIMAGE_PARTITION_SIZE := $(shell device/socionext/akebi96/partinfo.sh boot size)
BOARD_RECOVERYIMAGE_PARTITION_SIZE := $(shell device/socionext/akebi96/partinfo.sh recovery size)
TARGET_USERIMAGES_USE_EXT4 := true
BOARD_SYSTEMIMAGE_PARTITION_SIZE := $(shell device/socionext/akebi96/partinfo.sh system size)
BOARD_VENDORIMAGE_PARTITION_SIZE := $(shell device/socionext/akebi96/partinfo.sh vendor size)
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_PARTITION_SIZE := $(shell device/socionext/akebi96/partinfo.sh userdata size)
BOARD_CACHEIMAGE_PARTITION_SIZE := $(shell device/socionext/akebi96/partinfo.sh cache size)
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_FLASH_BLOCK_SIZE := 512

BOARD_SEPOLICY_DIRS += \
       device/socionext/akebi96/${USE_CONFIG_DIR_NAME}/sepolicy/vendor

# for depend on wifi module
-include device/socionext/akebi96/$(BOARD_WLAN_DEVICE)/BoardConfig.mk

-include device/socionext/akebi96/$(USE_CONFIG_DIR_NAME)/BoardConfig.mk

# Recovery setting
TARGET_RECOVERY_FSTAB := device/socionext/akebi96/$(USE_CONFIG_DIR_NAME)/fstab.sc1401aj1
TARGET_RECOVERY_PIXEL_FORMAT := "BGRA_8888"
TARGET_RECOVERY_ENABLE_COLOR_CONVERTER := yes
TARGET_RECOVERY_FORCE_SINGLE_BUFFER := yes

TARGET_RELEASETOOLS_EXTENSIONS := device/socionext/akebi96/$(USE_CONFIG_DIR_NAME)
TARGET_RECOVERY_UPDATER_LIBS := librecovery_updater_sc1401aj1

# for libsuspend
TARGET_USE_SUSPEND_MODE := freeze

BOARD_EGL_CFG := device/socionext/akebi96/egl.cfg
