PRODUCT_FULL_TREBLE_OVERRIDE := true
#PRODUCT_TREBLE_LINKER_NAMESPACES := true
BOARD_VNDK_VERSION := current
#BOARD_VNDK_RUNTIME_DISABLE := true
TARGET_COPY_OUT_VENDOR := vendor
BOARD_PLAT_PRIVATE_SEPOLICY_DIR := device/socionext/akebi96/p/sepolicy/private

#TARGET_NO_RECOVERY := true
BOARD_USES_FULL_RECOVERY_IMAGE := true
#BOARD_USES_RECOVERY_AS_BOOT := true
BOARD_BUILD_SYSTEM_ROOT_IMAGE := true

# Android-P always use 64bit binder
TARGET_USES_64_BIT_BINDER := true

TARGET_USES_MKE2FS := true

TARGET_ENABLE_BYPASS_DECODE := false

TARGET_USES_DEV_CERTIFICATE_DIR ?=

ifneq ($(TARGET_USES_DEV_CERTIFICATE_DIR),)
PRODUCT_DEFAULT_DEV_CERTIFICATE := $(TARGET_USES_DEV_CERTIFICATE_DIR)/releasekey
PRODUCT_OTA_PUBLIC_KEYS := $(TARGET_USES_DEV_CERTIFICATE_DIR)/releasekey.x509.pem
endif

-include build/target/product/product_launched_with_p.mk

DEVICE_MATRIX_FILE := device/socionext/akebi96/p/compatibility_matrix.xml

-include vendor/socionext/akebi96/middle/hvrst/BoardConfig.mk
