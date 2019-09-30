# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2015 Socionext Inc.

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_CFLAGS += -DMIXER_CARD=0
LOCAL_CFLAGS += -DPCM_CARD=0 -DPCM_DEVICE=0
LOCAL_CFLAGS += -DNUM_OF_CHANNELS=2
LOCAL_CFLAGS += -DOUT_PERIOD_SIZE=128
LOCAL_CFLAGS += -DOUT_LONG_PERIOD_COUNT=8
LOCAL_CFLAGS += -DOUT_SHORT_PERIOD_COUNT=2
LOCAL_CFLAGS += -DOUT_SAMPLING_RATE=48000
LOCAL_CFLAGS += -DALWAYS_ALSA_OPEN

LOCAL_MODULE := audio.primary.$(TARGET_BOARD_PLATFORM)
LOCAL_MODULE_RELATIVE_PATH := hw
LOCAL_SRC_FILES := \
	audio_hw.c
LOCAL_C_INCLUDES += \
	external/tinyalsa/include \
	$(call include-path-for, audio-utils) \
	$(call include-path-for, audio-route)
LOCAL_SHARED_LIBRARIES := liblog libcutils libtinyalsa libaudioutils libaudioroute libhardware libutils
LOCAL_MODULE_TAGS := optional

ifeq ($(BOARD_VNDK_VERSION),current)
LOCAL_VENDOR_MODULE := true
endif
include $(BUILD_SHARED_LIBRARY)

