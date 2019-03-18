ifneq (,$(findstring $(TARGET_DEVICE),akebi96))

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_CFLAGS :=
LOCAL_C_INCLUDES += bootable/recovery
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := librecovery_updater_sc1401aj1
LOCAL_SRC_FILES := recovery_updater.cpp

include $(BUILD_STATIC_LIBRARY)

endif
