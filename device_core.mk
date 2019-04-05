
USE_CONFIG_DIR_NAME := p

LOCAL_PATH_DEVICE := device/socionext/akebi96
LOCAL_FSTAB_PATH ?= device/socionext/akebi96

# Set vendor kernel path
PRODUCT_VENDOR_KERNEL_HEADERS := ${BSP_TOP_DIR}/output/images/kernel-headers

# # Select WiFi module
BOARD_WLAN_DEVICE ?= rtl8822bu

PRODUCT_PROPERTY_OVERRIDES += \
    ro.opengles.version=196610

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    persist.sys.usb.config=adb \
    ro.boot.hardware=sc1401aj1

# for depend on android version
$(call inherit-product-if-exists, $(LOCAL_PATH_DEVICE)/$(USE_CONFIG_DIR_NAME)/device.mk)

# for depend on wifi module
$(call inherit-product-if-exists, $(LOCAL_PATH_DEVICE)/$(BOARD_WLAN_DEVICE)/device.mk)

TARGET_PREBUILT_KERNEL := ${BSP_TOP_DIR}/output/images/Image.gz
TARGET_PREBUILT_DTB := ${BSP_TOP_DIR}/output/images/for_android.dtb

PRODUCT_COPY_FILES += \
    $(TARGET_PREBUILT_KERNEL):kernel \
    $(TARGET_PREBUILT_DTB):for_android.dtb

LOCAL_BOOT2nd   := ${BSP_TOP_DIR}/output/images/unph_bl.bin
LOCAL_BOOTUboot := ${BSP_TOP_DIR}/output/images/fip.bin
LOCAL_KERNEL    := ${BSP_TOP_DIR}/output/images/Image.gz
LOCAL_KERNEL_DTB:= ${BSP_TOP_DIR}/output/images/for_android.dtb
LOCAL_ROOTFS    := ${BSP_TOP_DIR}/output/images/rootfs.cpio.uboot

PRODUCT_COPY_FILES += \
    $(LOCAL_BOOT2nd):boot_b.img \
    $(LOCAL_BOOTUboot):boot_u.img \
    $(LOCAL_KERNEL):bin_k.img \
    $(LOCAL_ROOTFS):bin_r.img \
    $(LOCAL_KERNEL_DTB):bin_u.img

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH_DEVICE)/omxregister:$(TARGET_COPY_OUT_VENDOR)/etc/omxregister

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH_DEVICE)/socionext.xml:system/etc/sysconfig/socionext.xml

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH_DEVICE)/$(USE_CONFIG_DIR_NAME)/audio_policy.conf:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy.conf

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH_DEVICE)/ueventd.sc1401aj1.rc:recovery/root/vendor/ueventd.rc \
    $(LOCAL_PATH_DEVICE)/$(USE_CONFIG_DIR_NAME)/init.recovery.sc1401aj1.rc:recovery/root/vendor/etc/init/init.recovery.sc1401aj1.rc

#
# Additional OpenSource Section
#
#
# Socionext Section
#
PRODUCT_PACKAGES_VSOC_MIDDLE := \
    display_manager \
    libDisplayManagerClient \
    libOmxDisplayManager \
    libOmxDisplayController \
    display_init \
    hwcomposer.sc1401aj1 \
    audio.primary.sc1401aj1 \

PRODUCT_PACKAGES_VSOC_OPENMAX := \
    libomxil-bellagio \
    libomxprox.sc1401aj1

PRODUCT_PACKAGES_VSOC_COMPONENTS := \
    libvideo-out \
    libsc.sc1401aj1

PRODUCT_PACKAGES_KMOD := \
    snd-hwdep.ko \
    snd-usb-audio.ko \
    snd-usbmidi-lib.ko \
    dwc3.ko \
    dwc3-uniphier.ko \
    ave.ko \
    ion-uniphier.ko \
    snd-soc-uniphier-aio2013.ko \
    uniphier-spdif_tx.ko \
    vocdrv-ld20.ko

PRODUCT_PACKAGES_HVSDK := \
    hvrst

PRODUCT_PACKAGES_OPENGL := \
    libGLES_mali \
    egl.cfg \
    gralloc.sc1401aj1 \
    mali_kbase.ko

#
# Config PRODUCT_PACKAGES
#
PRODUCT_PACKAGES += $(PRODUCT_PACKAGES_VSOC_MIDDLE)
PRODUCT_PACKAGES += $(PRODUCT_PACKAGES_VSOC_OPENMAX)
PRODUCT_PACKAGES += $(PRODUCT_PACKAGES_VSOC_COMPONENTS)
PRODUCT_PACKAGES += $(PRODUCT_PACKAGES_KMOD)
PRODUCT_PACKAGES += $(PRODUCT_PACKAGES_HVSDK)
PRODUCT_PACKAGES += $(PRODUCT_PACKAGES_OPENGL)

# for Dummy Provisioning
PRODUCT_PACKAGES += Provision

DEVICE_PACKAGE_OVERLAYS += device/socionext/akebi96/$(USE_CONFIG_DIR_NAME)/overlay

# for CTS
# https://code.google.com/p/android/issues/detail?id=63796
PRODUCT_AAPT_CONFIG += large
