
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    vendor.wifi_module=rtl8822bu

PRODUCT_PROPERTY_OVERRIDES := \
    wifi.interface=wlan0

PRODUCT_PROPERTY_OVERRIDES += \
    wifi.direct.interface=p2p0

MODLUES_KERNEL_VERSION:=$(shell cat ${BSP_TOP_DIR}/output/images/kernel.release)
BSP_KMOD_DIR:=${BSP_TOP_DIR}/output/target/lib/modules/${MODLUES_KERNEL_VERSION}

PRODUCT_COPY_FILES += \
    $(call add-to-product-copy-files-if-exists,${BSP_KMOD_DIR}/extra/rtl8822bu.ko:$(TARGET_COPY_OUT_VENDOR)/lib/modules/extra/rtl8822bu.ko) \
    $(call add-to-product-copy-files-if-exists,${BSP_KMOD_DIR}/kernel/net/mac80211/mac80211.ko:$(TARGET_COPY_OUT_VENDOR)/lib/modules/kernel/net/mac80211/mac80211.ko) \
    $(call add-to-product-copy-files-if-exists,${BSP_KMOD_DIR}/kernel/net/wireless/cfg80211.ko:$(TARGET_COPY_OUT_VENDOR)/lib/modules/kernel/net/wireless/cfg80211.ko) \
    $(call add-to-product-copy-files-if-exists,${BSP_KMOD_DIR}/kernel/lib/crc-ccitt.ko:$(TARGET_COPY_OUT_VENDOR)/lib/modules/kernel/lib/crc-ccitt.ko) \
    $(call add-to-product-copy-files-if-exists,${BSP_KMOD_DIR}/kernel/crypto/ccm.ko:$(TARGET_COPY_OUT_VENDOR)/lib/modules/kernel/crypto/ccm.ko) \
    $(call add-to-product-copy-files-if-exists,${BSP_KMOD_DIR}/kernel/crypto/ctr.ko:$(TARGET_COPY_OUT_VENDOR)/lib/modules/kernel/crypto/ctr.ko) \
    $(call add-to-product-copy-files-if-exists,${BSP_KMOD_DIR}/extra/rtk_btusb_core.ko:$(TARGET_COPY_OUT_VENDOR)/lib/modules/extra/rtk_btusb_core.ko)

$(call inherit-product-if-exists, $(LOCAL_PATH)/bt/rtkbt/rtkbt.mk)

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/init.rtl8822bu.nl80211.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.rtl8822bu.rc

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/wpa_supplicant.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant.conf \
    $(LOCAL_PATH)/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf \
    $(LOCAL_PATH)/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf

PRODUCT_PACKAGES += \
    libwpa_client \
    wpa_supplicant \
    hostapd \
    wificond \
    wifilogd \
    wpa_supplicant.conf \
    hostapd.conf \
    libwifi-hal \
    android.hardware.wifi.supplicant@1.0-service \
    android.hardware.wifi.supplicant@1.1-service \
    android.hardware.wifi@1.0-service \
    android.hardware.wifi@1.0-service-lib \
    android.hardware.wifi.hostapd@1.0-service \
    android.hardware.wifi@1.0 \
    android.hardware.wifi@1.1 \
    android.hardware.wifi@1.2 \
    android.hardware.wifi.offload@1.0 \
    audio.hearing_aid.default
