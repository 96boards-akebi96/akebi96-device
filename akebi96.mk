
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

PRODUCT_NAME := akebi96
PRODUCT_DEVICE := akebi96
PRODUCT_BRAND := akebi96
PRODUCT_MODEL := akebi96
PRODUCT_MANUFACTURER := socionext

DEVICE_PACKAGE_OVERLAYS := device/linaro/akebi96/overlay

# automatically called
$(call inherit-product, device/linaro/akebi96/device.mk)

