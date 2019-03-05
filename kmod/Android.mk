
LOCAL_PATH := $(call my-dir)

MODLUES_KERNEL_VERSION:=$(shell cat ${BSP_TOP_DIR}/output/images/kernel.release)
BSP_KMOD_DIR:=${BSP_TOP_DIR}/output/target/lib/modules/${MODLUES_KERNEL_VERSION}

ifeq ($(TARGET_ARCH),arm)
LOCAL_TARGET_STRIP := ${BSP_TOP_DIR}/output/host/bin/aarch64-linux-gnu-strip
define _kmod_strip
	@echo "Copy: $(PRIVATE_MODULE) ($@)"
	@$(copy-file-to-new-target)
	$(LOCAL_TARGET_STRIP) --strip-unneeded $@
endef
else
define _kmod_strip
	@echo "Copy: $(PRIVATE_MODULE) ($@)"
	@$(copy-file-to-new-target)
	$(TARGET_STRIP) --strip-unneeded $@
endef
endif

include $(CLEAR_VARS)
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/lib/modules
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := snd-hwdep.ko
LOCAL_MODULE_RELATIVE_PATH := kernel/sound/core
include $(BUILD_SYSTEM)/base_rules.mk
$(LOCAL_BUILT_MODULE): $(BSP_KMOD_DIR)/$(LOCAL_MODULE_RELATIVE_PATH)/$(LOCAL_MODULE) | $(ACP)
	$(_kmod_strip)

include $(CLEAR_VARS)
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/lib/modules
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := snd-usb-audio.ko
LOCAL_MODULE_RELATIVE_PATH := kernel/sound/usb
include $(BUILD_SYSTEM)/base_rules.mk
$(LOCAL_BUILT_MODULE): $(BSP_KMOD_DIR)/$(LOCAL_MODULE_RELATIVE_PATH)/$(LOCAL_MODULE) | $(ACP)
	$(_kmod_strip)

include $(CLEAR_VARS)
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/lib/modules
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := snd-usbmidi-lib.ko
LOCAL_MODULE_RELATIVE_PATH := kernel/sound/usb
include $(BUILD_SYSTEM)/base_rules.mk
$(LOCAL_BUILT_MODULE): $(BSP_KMOD_DIR)/$(LOCAL_MODULE_RELATIVE_PATH)/$(LOCAL_MODULE) | $(ACP)
	$(_kmod_strip)

include $(CLEAR_VARS)
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/lib/modules
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := dwc3.ko
LOCAL_MODULE_RELATIVE_PATH := kernel/drivers/usb/dwc3
include $(BUILD_SYSTEM)/base_rules.mk
$(LOCAL_BUILT_MODULE): $(BSP_KMOD_DIR)/$(LOCAL_MODULE_RELATIVE_PATH)/$(LOCAL_MODULE) | $(ACP)
	$(_kmod_strip)

include $(CLEAR_VARS)
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/lib/modules
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := dwc3-uniphier.ko
LOCAL_MODULE_RELATIVE_PATH := kernel/drivers/usb/dwc3
include $(BUILD_SYSTEM)/base_rules.mk
$(LOCAL_BUILT_MODULE): $(BSP_KMOD_DIR)/$(LOCAL_MODULE_RELATIVE_PATH)/$(LOCAL_MODULE) | $(ACP)
	$(_kmod_strip)

include $(CLEAR_VARS)
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/lib/modules
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := ave.ko
LOCAL_MODULE_RELATIVE_PATH := kernel/drivers/net/ethernet/socionext/ave
include $(BUILD_SYSTEM)/base_rules.mk
$(LOCAL_BUILT_MODULE): $(BSP_KMOD_DIR)/$(LOCAL_MODULE_RELATIVE_PATH)/$(LOCAL_MODULE) | $(ACP)
	$(_kmod_strip)

include $(CLEAR_VARS)
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/lib/modules
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := ion-uniphier-pxs2.ko
LOCAL_MODULE_RELATIVE_PATH := extra
include $(BUILD_SYSTEM)/base_rules.mk
$(LOCAL_BUILT_MODULE): $(BSP_KMOD_DIR)/$(LOCAL_MODULE_RELATIVE_PATH)/$(LOCAL_MODULE) | $(ACP)
	$(_kmod_strip)

include $(CLEAR_VARS)
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/lib/modules
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := ion-uniphier.ko
LOCAL_MODULE_RELATIVE_PATH := extra
include $(BUILD_SYSTEM)/base_rules.mk
$(LOCAL_BUILT_MODULE): $(BSP_KMOD_DIR)/$(LOCAL_MODULE_RELATIVE_PATH)/$(LOCAL_MODULE) | $(ACP)
	$(_kmod_strip)

include $(CLEAR_VARS)
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/lib/modules
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := snd-soc-uniphier-aio2013.ko
LOCAL_MODULE_RELATIVE_PATH := extra
include $(BUILD_SYSTEM)/base_rules.mk
$(LOCAL_BUILT_MODULE): $(BSP_KMOD_DIR)/$(LOCAL_MODULE_RELATIVE_PATH)/$(LOCAL_MODULE) | $(ACP)
	$(_kmod_strip)

include $(CLEAR_VARS)
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/lib/modules
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := uniphier-spdif_tx.ko
LOCAL_MODULE_RELATIVE_PATH := extra
include $(BUILD_SYSTEM)/base_rules.mk
$(LOCAL_BUILT_MODULE): $(BSP_KMOD_DIR)/$(LOCAL_MODULE_RELATIVE_PATH)/$(LOCAL_MODULE) | $(ACP)
	$(_kmod_strip)

include $(CLEAR_VARS)
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/lib/modules
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := vocdrv-ld20.ko
LOCAL_MODULE_RELATIVE_PATH := extra
include $(BUILD_SYSTEM)/base_rules.mk
$(LOCAL_BUILT_MODULE): $(BSP_KMOD_DIR)/$(LOCAL_MODULE_RELATIVE_PATH)/$(LOCAL_MODULE) | $(ACP)
	$(_kmod_strip)

