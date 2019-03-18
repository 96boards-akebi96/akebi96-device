#!/bin/bash -e

MANUFACTURER=socionext
DEVICE=sc1401aj1
OUT_DIR=$OUT
TARGET_DIR=proprietary

TO_EXTRACT_MULTI_LIB=(
	"libstagefrighthw.so"
	"libsettingvopot.so \$(LOCAL_PATH)/include/libpq/libsetting_vopot/audio \$(LOCAL_PATH)/include/libpq/libsetting_vopot/video"
	"libdvbsubdec.so \$(LOCAL_PATH)/include/middle/dvbsubdec"
	"libaterm.so \$(LOCAL_PATH)/include/libaq/include"
	"libavio_aq.so \$(LOCAL_PATH)/aqutils/avio_aq/include"
	"libsetting_vopot_aq.so \$(LOCAL_PATH)/include/aqutils/libsetting_vopot_aq/audio \$(LOCAL_PATH)/include/aqutils/libsetting_vopot_aq/include"
	"libvop.so"
	"libvpe_driver.so"
	"libvoc_driver.so"
	"libvpe.so"
	"libavio_veffect.so \$(LOCAL_PATH)/include/libpq/avio/include"
	"libtsinput.so"
	"libfilter_common.so"
	"libfilter_stream.so \$(LOCAL_PATH)/include/middle/msl_adapter_new/stream/msl_lib \$(LOCAL_PATH)/include/middle/msl_adapter_new/stream/"
	"libOmxDisplayManager.so \$(LOCAL_PATH)/include/middle/displaymanager/libOmxDisplayManager"
	"libDisplayManagerClient.so \$(LOCAL_PATH)/include/middle/displaymanager \$(LOCAL_PATH)/include/middle/displaymanager/libDisplayManagerClient"
	"libOmxDisplayController.so \$(LOCAL_PATH)/include/middle/displaymanager/libOmxDisplayController"
	"libhdmirx.so"
	"libAioOutput.so \$(LOCAL_PATH)/include/middle/libhdmirx/auido/libAioOutput"
	"libAioInput.so \$(LOCAL_PATH)/include/middle/libhdmirx/auido/libAioInput"
	"libHdmiAudio.so \$(LOCAL_PATH)/include/middle/libhdmirx/auido/libHdmiAudio"
	"libAudioManagerClient.so \$(LOCAL_PATH)/include/middle/audiomanager \$(LOCAL_PATH)/include/middle/audiomanager/libAudioManagerClient"
	"libomxil-bellagio.so frameworks/native/include/media/openmax \$(LOCAL_PATH)/include/OpenMAX/libomxil-bellagio/include/bellagio"
	"libomxprox.sc1401aj1.so \$(LOCAL_PATH)/include/OpenMAX/libomxil-prox/include"
	"libvoc.so \$(LOCAL_PATH)/include/libvio/libs/voc/ld20/voc_memout/include \$(LOCAL_PATH)/include/libvio/libs/voc/ld20/voc_vout/include"
	"libviorscmgr.sc1401aj1.so \$(LOCAL_PATH)/include/libvio/libs/viorscmgr/ld20"
	"libfa.so \$(LOCAL_PATH)/include/dbgutils/libfa/src"
	"libsif.so"
	"libslc.sc1401aj1.so \$(LOCAL_PATH)/include/libvio/libs/slc/ld20"
	"libsc.sc1401aj1.so"
	"libSubmcu.so"
	"libion_ext.so"
)

TO_EXTRACT_MULTI_LIB_HW=(
	"hwcomposer.sc1401aj1.so"
	"audio.primary.sc1401aj1.so"
	"hdmi_cec.default.so"
)

TO_EXTRACT_32BIT_LIB=(
)

TO_EXTRACT_SBIN=(
	"submcu_srv"
	"bootchecker2"
	"update_last_power_flag"
	"update_stm_config"
	"set_mac"
	"write_mac"
)

TO_EXTRACT_SYSTEM_BIN=(
	"eeprom"
	"test_msl_lib"
	"display_manager"
	"display_init"
	"audio_manager"
	"fa"
	"da"
	"umcd"
	"ntfs-3g"
	"DmControlSetSuspend"
)

# --------------------------------------
# Extracting files from Build Env
# --------------------------------------
Extract_files() {
	echo \ \ Extracting files from Build Env
	mkdir -p $TARGET_DIR/system/lib/hw
	mkdir -p $TARGET_DIR/system/lib64/hw
	mkdir -p $TARGET_DIR/system/bin
	mkdir -p $TARGET_DIR/root/sbin
	mkdir -p $TARGET_DIR/recovery/root/sbin

	for ONE_FILE in "${TO_EXTRACT_MULTI_LIB[@]}"
	do
	 	data=(${ONE_FILE[@]})
		echo copy $OUT_DIR/system/lib/${data[0]}
		cp -a $OUT_DIR/system/lib/${data[0]}   $TARGET_DIR/system/lib
		cp -a $OUT_DIR/system/lib64/${data[0]} $TARGET_DIR/system/lib64
	done

	for ONE_FILE in ${TO_EXTRACT_MULTI_LIB_HW[@]}
	do
		echo copy $OUT_DIR/system/lib/hw/$ONE_FILE
		cp -a $OUT_DIR/system/lib/hw/$ONE_FILE   $TARGET_DIR/system/lib/hw
		cp -a $OUT_DIR/system/lib64/hw/$ONE_FILE $TARGET_DIR/system/lib64/hw
	done

	for ONE_FILE in ${TO_EXTRACT_32BIT_LIB[@]}
	do
		echo copy $OUT_DIR/system/lib/$ONE_FILE
		cp -a $OUT_DIR/system/lib/$ONE_FILE   $TARGET_DIR/system/lib
	done

	for ONE_FILE in ${TO_EXTRACT_SBIN[@]}
	do
		echo copy $OUT_DIR/root/sbin/$ONE_FILE
		cp -a $OUT_DIR/root/sbin/$ONE_FILE   $TARGET_DIR/root/sbin
#		cp -a $OUT_DIR/recovery/root/sbin/$ONE_FILE $TARGET_DIR/recovery/root/sbin
	done

	for ONE_FILE in ${TO_EXTRACT_SYSTEM_BIN[@]}
	do
		echo copy $OUT_DIR/system/bin/$ONE_FILE
		cp -a $OUT_DIR/system/bin/$ONE_FILE   $TARGET_DIR/system/bin
	done
}


Make_Android_mk() {
	echo \ \ make Android.mk

	rm -f $TARGET_DIR/Android.mk

	echo "LOCAL_PATH := \$(call my-dir)" >> $TARGET_DIR/Android.mk
	echo "" >> $TARGET_DIR/Android.mk
	regexp="^(.*\.so?)[\s ](.*)"
	for ONE_FILE in "${TO_EXTRACT_MULTI_LIB[@]}"
	do
	    if [[ ${ONE_FILE[@]} =~ $regexp ]] ; then
			FILE_NAME=${BASH_REMATCH[1]}
			EXPORT_INCLUDE_NAME=${BASH_REMATCH[2]}
		else
			FILE_NAME=${ONE_FILE}
			EXPORT_INCLUDE_NAME=""
		fi
		base_name=`basename -s .so ${FILE_NAME}`
		echo "include \$(CLEAR_VARS)" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MULTILIB      := both" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE        := ${base_name}" >> $TARGET_DIR/Android.mk
		echo "LOCAL_SRC_FILES_32  := system/lib/${FILE_NAME}" >> $TARGET_DIR/Android.mk
		echo "LOCAL_SRC_FILES_64  := system/lib64/${FILE_NAME}" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE_CLASS  := SHARED_LIBRARIES" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE_TAGS   := optional" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE_SUFFIX := .so" >> $TARGET_DIR/Android.mk
		if [ ! -z "${EXPORT_INCLUDE_NAME}" ] ; then
			echo "LOCAL_EXPORT_C_INCLUDE_DIRS := ${EXPORT_INCLUDE_NAME}" >> $TARGET_DIR/Android.mk
		fi
		echo "include \$(BUILD_PREBUILT)" >> $TARGET_DIR/Android.mk
		echo "" >> $TARGET_DIR/Android.mk
	done

	for ONE_FILE in ${TO_EXTRACT_MULTI_LIB_HW[@]}
	do
	    if [[ ${ONE_FILE[@]} =~ $regexp ]] ; then
			FILE_NAME=${BASH_REMATCH[1]}
			EXPORT_INCLUDE_NAME=${BASH_REMATCH[2]}
		else
			FILE_NAME=${ONE_FILE}
			EXPORT_INCLUDE_NAME=""
		fi
		base_name=`basename -s .so ${FILE_NAME}`
		echo "include \$(CLEAR_VARS)" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MULTILIB      := both" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE        := ${base_name}" >> $TARGET_DIR/Android.mk
		echo "LOCAL_SRC_FILES_32  := system/lib/hw/${FILE_NAME}" >> $TARGET_DIR/Android.mk
		echo "LOCAL_SRC_FILES_64  := system/lib64/hw/${FILE_NAME}" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE_CLASS  := SHARED_LIBRARIES" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE_TAGS   := optional" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE_SUFFIX := .so" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE_RELATIVE_PATH := hw" >> $TARGET_DIR/Android.mk
		echo "include \$(BUILD_PREBUILT)" >> $TARGET_DIR/Android.mk
		echo "" >> $TARGET_DIR/Android.mk
	done

	for ONE_FILE in ${TO_EXTRACT_32BIT_LIB[@]}
	do
	    if [[ ${ONE_FILE[@]} =~ $regexp ]] ; then
			FILE_NAME=${BASH_REMATCH[1]}
			EXPORT_INCLUDE_NAME=${BASH_REMATCH[2]}
		else
			FILE_NAME=${ONE_FILE}
			EXPORT_INCLUDE_NAME=""
		fi
		base_name=`basename -s .so ${FILE_NAME}`
		echo "include \$(CLEAR_VARS)" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MULTILIB      := 32" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE        := ${base_name}" >> $TARGET_DIR/Android.mk
		echo "LOCAL_SRC_FILES_32  := system/lib/${FILE_NAME}" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE_CLASS  := SHARED_LIBRARIES" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE_TAGS   := optional" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE_SUFFIX := .so" >> $TARGET_DIR/Android.mk
		echo "include \$(BUILD_PREBUILT)" >> $TARGET_DIR/Android.mk
		echo "" >> $TARGET_DIR/Android.mk
	done

	for ONE_FILE in ${TO_EXTRACT_SBIN[@]}
	do
		base_name=${ONE_FILE}
		echo "include \$(CLEAR_VARS)" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE        := ${base_name}" >> $TARGET_DIR/Android.mk
		echo "LOCAL_SRC_FILES     := root/sbin/${ONE_FILE}" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE_CLASS  := EXECUTABLES" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE_TAGS   := optional" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE_SUFFIX := " >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE_PATH := \$(TARGET_ROOT_OUT_SBIN)" >> $TARGET_DIR/Android.mk
		echo "include \$(BUILD_PREBUILT)" >> $TARGET_DIR/Android.mk
		echo "" >> $TARGET_DIR/Android.mk
	done

	for ONE_FILE in ${TO_EXTRACT_SYSTEM_BIN[@]}
	do
		base_name=${ONE_FILE}
		echo "include \$(CLEAR_VARS)" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE        := ${base_name}" >> $TARGET_DIR/Android.mk
		echo "LOCAL_SRC_FILES     := system/bin/${ONE_FILE}" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE_CLASS  := EXECUTABLES" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE_TAGS   := optional" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE_SUFFIX := " >> $TARGET_DIR/Android.mk
		echo "include \$(BUILD_PREBUILT)" >> $TARGET_DIR/Android.mk
		echo "" >> $TARGET_DIR/Android.mk
	done
}

copy_vendor_header_file() {
	rsync -avm --delete \
			--exclude="/openmax-veri" \
			--exclude="/AndroidTV" \
			--exclude="/app" \
			--exclude=".git" \
			--include='*.h' \
		 	--include='*/' \
			--exclude='*' \
			$ANDROID_BUILD_TOP/vendor/socionext/sc1401aj1/* \
			$TARGET_DIR/include
}

# ------------------------
# main
# ------------------------
if [ -z $OUT ]; then
	echo "Please select a build valiant using lunch command"
	exit 1;
fi

if [ -e $TARGET_DIR ] ; then
	rm -rf $TARGET_DIR
fi
mkdir -p $TARGET_DIR

copy_vendor_header_file
Extract_files
Make_Android_mk

