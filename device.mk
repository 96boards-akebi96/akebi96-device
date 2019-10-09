
include device/linaro/akebi96/boot_fat.mk

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/copy/Image:Image \
    $(LOCAL_PATH)/copy/uniphier-ld20-akebi96.dtb:uniphier-ld20-akebi96.dtb \
    $(LOCAL_PATH)/copy/extlinux/extlinux.conf:extlinux.conf

# 1.2 rootfs
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/vendor/ueventd.akebi96.rc:$(TARGET_COPY_OUT_VENDOR)/ueventd.rc \
    $(LOCAL_PATH)/vendor/fstab.akebi96:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.akebi96

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/vendor/init.akebi96.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.akebi96.rc \
    $(LOCAL_PATH)/vendor/init.akebi96.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.akebi96.usb.rc

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/config/egl.cfg:$(TARGET_COPY_OUT_VENDOR)/lib/egl/egl.cfg \
    $(LOCAL_PATH)/config/omxregister:$(TARGET_COPY_OUT_VENDOR)/etc/omxregister

# feature declaration
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.app_widgets.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.app_widgets.xml \
    frameworks/native/data/etc/android.hardware.screen.landscape.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.landscape.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.software.print.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.print.xml \
    frameworks/native/data/etc/android.software.webview.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.webview.xml \
    frameworks/native/data/etc/android.hardware.ethernet.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.ethernet.xml


# framework properties
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.heapstartsize=5m \
    dalvik.vm.heapgrowthlimit=96m \
    dalvik.vm.heapsize=256m \
    dalvik.vm.heaptargetutilization=0.75 \
    dalvik.vm.heapminfree=512k \
    dalvik.vm.heapmaxfree=2m \
    ro.sf.lcd_density=160 \
    ro.opengles.version=196609


# start HAL audio >>>>>>>>
## feature declaration
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.output.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.output.xml \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml
## build packages
PRODUCT_PACKAGES += \
    android.hardware.audio@2.0-impl \
    android.hardware.audio@2.0-service \
    android.hardware.audio.effect@4.0-impl \
    android.hardware.soundtrigger@2.0-impl \
    audio.a2dp.default \
    audio.usb.default \
    audio.r_submix.default \
    audio.primary.akebi96
## runtime configs
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/audio/audio_policy.conf:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy.conf


# start HAL drm >>>>>>>>
## build packages
PRODUCT_PACKAGES += \
    android.hardware.drm@1.0-impl
# raw instructions - do I have a better place to go?
$(call inherit-product-if-exists, device/linaro/akebi96/optee/optee-packages.mk)
## service init.rc scripts
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/optee/optee.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/optee.rc


# start HAL graphics >>>>>>>>
## build packages
PRODUCT_PACKAGES += \
    libion \
    android.hardware.graphics.mapper@2.0 \
    android.hardware.graphics.mapper@2.0-impl \
    android.hardware.graphics.allocator@2.0 \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.allocator@2.0-service \
    android.hardware.graphics.composer@2.1 \
    android.hardware.graphics.composer@2.1-impl \
    android.hardware.graphics.composer@2.1-service

# Memtrack
PRODUCT_PACKAGES += memtrack.default \
    android.hardware.memtrack@1.0-service \
    android.hardware.memtrack@1.0-impl

# Property required by Socionext gralloc
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.build.name=akebi96.androidp


# start HAL keymaster >>>>>>>>
## build packages
PRODUCT_PACKAGES += \
    android.hardware.keymaster@3.0-impl \
    android.hardware.keymaster@3.0-service


# start HAL media.codec >>>>>>>>
## runtime configs
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/media/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml \
    $(LOCAL_PATH)/media/media_codecs_performance.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_performance.xml \
    $(LOCAL_PATH)/media/media_profiles_V1_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_video.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_tv.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_tv.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_audio.xml


# start HAL bt >>>>>>>>
## feature declaration
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml
## build packages
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-service \
    android.hardware.bluetooth@1.0-service.rc \
    android.hardware.bluetooth@1.0-impl
## config files
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/bluetooth/rtkbt.conf:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth/rtkbt.conf
## firmwares
## service init.rc scripts
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/bluetooth/bt.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/bt.rc

BOARD_VENDOR_KERNEL_MODULES += \
    device/linaro/akebi96/copy/8822bu.ko \
    device/linaro/akebi96/copy/rtk_btusb.ko \
    device/linaro/akebi96/copy/mali_kbase.ko

# start HAL wifi >>>>>>>>
## feature declaration
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml
## build packages
PRODUCT_PACKAGES += libwpa_client wpa_supplicant hostapd wificond wifilogd wpa_cli
## config files
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/wifi/wpa_supplicant.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant.conf \
    $(LOCAL_PATH)/wifi/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf \
    $(LOCAL_PATH)/wifi/dhcpcd-6.8.2.conf:$(TARGET_COPY_OUT_VEN)/etc/dhcpcd-6.8.2/dhcpcd.conf

## service init.rc scripts
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/wifi/wifi.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/wifi.rc
## feature wifi properties
PRODUCT_PROPERTY_OVERRIDES += \
    wifi.interface=wlan0 \
    wifi.supplicant_scan_interval=15

# Add openssh support for remote debugging and job submission
PRODUCT_PACKAGES += ssh sftp scp sshd ssh-keygen sshd_config start-ssh

PRODUCT_PACKAGES += dhcpcd-6.8.2

# manifest.xml
DEVICE_MANIFEST_FILE := $(LOCAL_PATH)/manifest.xml

# VNDK libraries
PRODUCT_PACKAGES += vndk_package

#
# OpenGL Middlwares
#
PRODUCT_PACKAGES += \
	libGLES_mali \
	egl.cfg \
	gralloc.akebi96

#
# Socionext Middlwares
#
PRODUCT_PACKAGES += \
	display_manager \
	libDisplayManagerClient \
	libOmxDisplayManager \
	libOmxDisplayController \
	hwcomposer.sc1401aj1 \
	libomxil-bellagio \
	libomxprox.sc1401aj1 \
	libvideo-out.sc1401aj1 \
	libsc.sc1401aj1 \
	hvrst

BOARD_VENDOR_KERNEL_MODULES += \
	device/linaro/akebi96/copy/vocdrv-ld20.ko

PRODUCT_VENDOR_KERNEL_HEADERS := device/linaro/akebi96/copy/kernel-headers
