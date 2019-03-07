
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.heapstartsize=8m \
    dalvik.vm.heapgrowthlimit=128m \
    dalvik.vm.heapsize=174m

$(call inherit-product-if-exists, frameworks/native/build/tablet-10in-xhdpi-2048-dalvik-heap.mk)

PRODUCT_COPY_FILES += \
    $(call add-to-product-copy-files-if-exists,frameworks/native/data/etc/android.software.backup.xml:system/etc/permissions/android.software.backup.xml) \
    $(call add-to-product-copy-files-if-exists,frameworks/native/data/etc/android.software.cts.xml:system/etc/permissions/android.software.cts.xml)
    # $(call add-to-product-copy-files-if-exists,frameworks/native/data/etc/android.software.verified_boot.xml:system/etc/permissions/android.software.verified_boot.xml)

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH_DEVICE)/$(USE_CONFIG_DIR_NAME)/init.sc1401aj1.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.sc1401aj1.rc \
    $(LOCAL_FSTAB_PATH)/$(USE_CONFIG_DIR_NAME)/fstab.sc1401aj1:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.sc1401aj1 \
    $(call add-to-product-copy-files-if-exists,$(LOCAL_FSTAB_PATH)/$(USE_CONFIG_DIR_NAME)/fstab_boot.sc1401aj1:$(TARGET_COPY_OUT_VENDOR)/etc/fstab_boot.sc1401aj1)

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH_DEVICE)/ueventd.sc1401aj1.rc:$(TARGET_COPY_OUT_VENDOR)/ueventd.rc \
    $(call add-to-product-copy-files-if-exists,$(LOCAL_PATH_DEVICE)/mixer_paths.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_paths.xml)

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.faketouch.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.faketouch.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml  \
    $(call add-to-product-copy-files-if-exists,$(LOCAL_PATH_DEVICE)/media_profiles.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles.xml) \
    $(call add-to-product-copy-files-if-exists,frameworks/native/data/etc/android.hardware.ethernet.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.ethernet.xml) \
    $(call add-to-product-copy-files-if-exists,$(LOCAL_PATH_DEVICE)/permissions/android.hardware.screen.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.xml) \
    $(call add-to-product-copy-files-if-exists,$(LOCAL_PATH_DEVICE)/permissions/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml) \
    $(call add-to-product-copy-files-if-exists,$(LOCAL_PATH_DEVICE)/permissions/android.software.voice_recognizers.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.voice_recognizers.xml) \
    $(call add-to-product-copy-files-if-exists,frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml) \

# Need AppWidget permission to prevent from Launcher's crash.
PRODUCT_COPY_FILES += \
    $(call add-to-product-copy-files-if-exists,frameworks/native/data/etc/android.software.app_widgets.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.app_widgets.xml)

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml \
    $(LOCAL_PATH)/media_codecs_performance.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_performance.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_tv.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_tv.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_video.xml \
    $(LOCAL_PATH)/media_profiles_V1_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/mediacodec.policy:vendor/etc/seccomp_policy/mediacodec.policy

# Vendor Interface Manifest
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/manifest.xml:$(TARGET_COPY_OUT_VENDOR)/manifest.xml

PRODUCT_PACKAGES += \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.allocator@2.0-service \
    android.hardware.graphics.mapper@2.0-impl

PRODUCT_PACKAGES += \
    android.hardware.audio@2.0-impl \
    android.hardware.audio@2.0-service \
    android.hardware.audio.effect@4.0-impl \
    android.hardware.broadcastradio@1.0-impl \
    android.hardware.soundtrigger@2.0-impl \
    audio.r_submix.default \
    audio.usb.default

PRODUCT_PACKAGES += \
    libpuresoftkeymasterdevice \
    android.hardware.keymaster@3.0-impl \
    android.hardware.keymaster@3.0-service

PRODUCT_PACKAGES += \
    android.hardware.graphics.composer@2.1-impl \
    android.hardware.graphics.composer@2.1-service

PRODUCT_PACKAGES += \
    libminijail \
    libhwminijail \
    libavservices_minijail \
    libavservices_minijail_vendor \
    android.hardware.media.omx@1.0-service

# Library used for VTS profiling (only for userdebug and eng builds)
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
PRODUCT_PACKAGES += \
    libvts_profiling \
    libvts_multidevice_proto
# Test HAL for FMQ performance benchmark.
PRODUCT_PACKAGES += \
    android.hardware.tests.msgq@1.0-impl
endif

# Audio configuration
USE_XML_AUDIO_POLICY_CONF := 1
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    $(call add-to-product-copy-files-if-exists,frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml) \
    $(call add-to-product-copy-files-if-exists,frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml) \
    $(call add-to-product-copy-files-if-exists,frameworks/av/media/libeffects/data/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml) \
    $(call add-to-product-copy-files-if-exists,frameworks/av/services/audiopolicy/config/a2dp_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_audio_policy_configuration.xml) \
    $(call add-to-product-copy-files-if-exists,frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml) \
    $(call add-to-product-copy-files-if-exists,frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml) \
    $(call add-to-product-copy-files-if-exists,frameworks/av/services/audiopolicy/config/hearing_aid_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/hearing_aid_audio_policy_configuration.xml)

# handled device configuration
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.xml

# for hvdiag
PRODUCT_COPY_FILES += \
    $(call add-to-product-copy-files-if-exists,vendor/socionext/akebi96/middle/hvsdk/init.hvdiag.recovery.rc:recovery/root/vendor/etc/init/init.hvdiag.recovery.rc)
