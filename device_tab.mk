PRODUCT_PROPERTY_OVERRIDES += \
    ro.sf.lcd_density=320

PRODUCT_PROPERTY_OVERRIDES += \
    vendor.mode=tablet

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    vendor.mode=tablet

PRODUCT_CHARACTERISTICS := nosdcard,tablet

PRODUCT_PACKAGES += Launcher3

DEVICE_PACKAGE_OVERLAYS += device/socionext/akebi96/$(USE_CONFIG_DIR_NAME)/overlay
