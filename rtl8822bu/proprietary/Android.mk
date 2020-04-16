LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MULTILIB      := both
LOCAL_MODULE        := libbt-vendor
LOCAL_SRC_FILES_32  := lib/libbt-vendor.so
LOCAL_SRC_FILES_64  := lib64/libbt-vendor.so
LOCAL_MODULE_CLASS  := SHARED_LIBRARIES
LOCAL_MODULE_TAGS   := optional
LOCAL_MODULE_SUFFIX := .so
ifeq ($(BOARD_VNDK_VERSION),current)
LOCAL_VENDOR_MODULE := true
endif
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MULTILIB      := both
LOCAL_MODULE        := libwpa_client
LOCAL_SRC_FILES_32  := lib/libwpa_client.so
LOCAL_SRC_FILES_64  := lib64/libwpa_client.so
LOCAL_MODULE_CLASS  := SHARED_LIBRARIES
LOCAL_MODULE_TAGS   := optional
LOCAL_MODULE_SUFFIX := .so
ifeq ($(BOARD_VNDK_VERSION),current)
LOCAL_VENDOR_MODULE := true
endif
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MULTILIB      := both
LOCAL_MODULE        := libwifi-hal-rtk
LOCAL_SRC_FILES_32  := static_libraries/lib/libwifi-hal-rtk.a
LOCAL_SRC_FILES_64  := static_libraries/lib64/libwifi-hal-rtk.a
LOCAL_MODULE_CLASS  := STATIC_LIBRARIES
LOCAL_MODULE_TAGS   := optional
LOCAL_MODULE_SUFFIX := .a
ifeq ($(BOARD_VNDK_VERSION),current)
LOCAL_VENDOR_MODULE := true
endif
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE        := hostapd
LOCAL_SRC_FILES     := bin/hostapd
LOCAL_MODULE_CLASS  := EXECUTABLES
LOCAL_MODULE_TAGS   := optional
LOCAL_MODULE_RELATIVE_PATH := hw
ifeq ($(BOARD_VNDK_VERSION),current)
LOCAL_VENDOR_MODULE := true
endif
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE        := wpa_supplicant
LOCAL_SRC_FILES     := bin/wpa_supplicant
LOCAL_MODULE_CLASS  := EXECUTABLES
LOCAL_MODULE_TAGS   := optional
LOCAL_MODULE_RELATIVE_PATH := hw
ifeq ($(BOARD_VNDK_VERSION),current)
LOCAL_VENDOR_MODULE := true
endif
include $(BUILD_PREBUILT)

