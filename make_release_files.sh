#!/bin/bash -e

OUT_DIR=$OUT
TARGET_DIR=proprietary

TO_EXTRACT_MULTI_LIB=(
	"libomxprox.sc1401aj1.so \$(LOCAL_PATH)/include/OpenMAX/libomxil-prox/include"
	"libsc.sc1401aj1.so \$(LOCAL_PATH)/include/libvideo-out/sc \$(LOCAL_PATH)/include/libvideo-out/sc/include \$(LOCAL_PATH)/include/libvideo-out/sc/include/reg"
	"libvideo-out.so \$(LOCAL_PATH)/include/libvideo-out/voc_vout/include"
)

# --------------------------------------
# Extracting files from Build Env
# --------------------------------------
Extract_files() {
	echo \ \ Extracting files from Build Env
	mkdir -p $TARGET_DIR/vendor/lib
	mkdir -p $TARGET_DIR/vendor/lib64

	for ONE_FILE in "${TO_EXTRACT_MULTI_LIB[@]}"
	do
	 	data=(${ONE_FILE[@]})
		echo copy $OUT_DIR/vendor/lib/${data[0]}
		cp -a $OUT_DIR/vendor/lib/${data[0]}   $TARGET_DIR/vendor/lib
		cp -a $OUT_DIR/vendor/lib64/${data[0]} $TARGET_DIR/vendor/lib64
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
		echo "LOCAL_SRC_FILES_32  := vendor/lib/${FILE_NAME}" >> $TARGET_DIR/Android.mk
		echo "LOCAL_SRC_FILES_64  := vendor/lib64/${FILE_NAME}" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE_CLASS  := SHARED_LIBRARIES" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE_TAGS   := optional" >> $TARGET_DIR/Android.mk
		echo "LOCAL_MODULE_SUFFIX := .so" >> $TARGET_DIR/Android.mk
		if [ ! -z "${EXPORT_INCLUDE_NAME}" ] ; then
			echo "LOCAL_EXPORT_C_INCLUDE_DIRS := ${EXPORT_INCLUDE_NAME}" >> $TARGET_DIR/Android.mk
		fi
		echo "ifeq (\$(BOARD_VNDK_VERSION),current)" >> $TARGET_DIR/Android.mk
		echo "LOCAL_VENDOR_MODULE := true" >> $TARGET_DIR/Android.mk
		echo "endif" >> $TARGET_DIR/Android.mk
		echo "include \$(BUILD_PREBUILT)" >> $TARGET_DIR/Android.mk
		echo "" >> $TARGET_DIR/Android.mk
	done
}

copy_vendor_header_file() {
	rsync -avm --delete \
			--exclude="middle" \
			--exclude="OpenMAX/libomxil-bellagio" \
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

