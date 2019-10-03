#!/bin/bash -e
# SPDX-License-Identifier: Apache-2.0
# make_release_files.sh
# Copyright (C) 2019 Socionext Inc.

VENDOR=socionext
TARGET_DIR=proprietary/${VENDOR}
TARGET_BOOTLOADER_BOARD_NAME=sc1401aj1

TO_EXTRACT_MULTI_LIB=(
	"libomxprox.\${TARGET_BOOTLOADER_BOARD_NAME}.so OpenMAX/libomxil-prox/include"
	"libsc.\${TARGET_BOOTLOADER_BOARD_NAME}.so"
	"libvideo-out.\${TARGET_BOOTLOADER_BOARD_NAME}.so"
)

# --------------------------------------
# Extracting files from Build Env
# --------------------------------------
Extract_files() {
	echo \ \ Extracting files from Build Env
	mkdir -p ${TARGET_DIR}/lib
	mkdir -p ${TARGET_DIR}/lib64

	for ONE_FILE in "${TO_EXTRACT_MULTI_LIB[@]}"
	do
		data=(${ONE_FILE[@]})
		FILE_NAME=$(eval echo ${data[0]})
		echo copy ${OUT}/vendor/lib/${FILE_NAME}
		cp -a ${OUT}/vendor/lib/${FILE_NAME}   ${TARGET_DIR}/lib
		cp -a ${OUT}/vendor/lib64/${FILE_NAME} ${TARGET_DIR}/lib64
		if [ x"${TARGET_BOARD}" != x"akebi96" ]; then
			ln -sf ${FILE_NAME} ${TARGET_DIR}/lib/${FILE_NAME/${TARGET_BOOTLOADER_BOARD_NAME}/akebi96}
			ln -sf ${FILE_NAME} ${TARGET_DIR}/lib64/${FILE_NAME/${TARGET_BOOTLOADER_BOARD_NAME}/akebi96}
		fi
	done
}


Make_Android_mk() {
	echo \ \ make Android.mk

	rm -f ${TARGET_DIR}/Android.mk

	echo "LOCAL_PATH := \$(call my-dir)" >> ${TARGET_DIR}/Android.mk
	echo "" >> ${TARGET_DIR}/Android.mk
	regexp="^(.*\.so?)[\s ](.*)"
	for ONE_FILE in "${TO_EXTRACT_MULTI_LIB[@]}"
	do
		if [[ ${ONE_FILE[@]} =~ $regexp ]] ; then
			FILE_NAME=${BASH_REMATCH[1]}
			EXPORT_INCLUDE_NAME='$(LOCAL_PATH)/include/'${BASH_REMATCH[2]}
		else
			FILE_NAME=${ONE_FILE}
			EXPORT_INCLUDE_NAME=""
		fi
		base_name=`basename -s .so ${FILE_NAME}`
		echo "include \$(CLEAR_VARS)" >> ${TARGET_DIR}/Android.mk
		echo "LOCAL_MULTILIB      := both" >> ${TARGET_DIR}/Android.mk
		echo "LOCAL_MODULE        := ${base_name}" >> ${TARGET_DIR}/Android.mk
		echo "LOCAL_SRC_FILES_32  := lib/${FILE_NAME}" >> ${TARGET_DIR}/Android.mk
		echo "LOCAL_SRC_FILES_64  := lib64/${FILE_NAME}" >> ${TARGET_DIR}/Android.mk
		echo "LOCAL_MODULE_CLASS  := SHARED_LIBRARIES" >> ${TARGET_DIR}/Android.mk
		echo "LOCAL_MODULE_TAGS   := optional" >> ${TARGET_DIR}/Android.mk
		echo "LOCAL_MODULE_SUFFIX := .so" >> ${TARGET_DIR}/Android.mk
		if [ ! -z "${EXPORT_INCLUDE_NAME}" ] ; then
			echo "LOCAL_EXPORT_C_INCLUDE_DIRS := ${EXPORT_INCLUDE_NAME}" >> ${TARGET_DIR}/Android.mk
		fi
		echo "ifeq (\$(BOARD_VNDK_VERSION),current)" >> ${TARGET_DIR}/Android.mk
		echo "LOCAL_VENDOR_MODULE := true" >> ${TARGET_DIR}/Android.mk
		echo "endif" >> ${TARGET_DIR}/Android.mk
		echo "include \$(BUILD_PREBUILT)" >> ${TARGET_DIR}/Android.mk
		echo "" >> ${TARGET_DIR}/Android.mk
	done
}

copy_vendor_header_file() {
	for ONE_FILE in "${TO_EXTRACT_MULTI_LIB[@]}"
	do
		data=(${ONE_FILE[@]})
		EXPORT_INCLUDE_NAME=${data[1]}
		if [ x"${EXPORT_INCLUDE_NAME}" != x"" ]; then
			mkdir -p ${TARGET_DIR}/include/${EXPORT_INCLUDE_NAME}
			rsync -avm --delete \
			      --exclude='.git' \
			      --include='*.h' \
			      --include='*/' \
			      --exclude='*' \
			      ${ANDROID_BUILD_TOP}/vendor/${VENDOR}/${TARGET_BOOTLOADER_BOARD_NAME}/${EXPORT_INCLUDE_NAME}/* \
			      ${TARGET_DIR}/include/${EXPORT_INCLUDE_NAME}
		fi
	done
}

# ------------------------
# main
# ------------------------
if [ -z ${OUT} ]; then
	echo "Please select a build valiant using lunch command"
	exit 1;
fi

if [ -e ${TARGET_DIR} ] ; then
	rm -rf ${TARGET_DIR}
fi
mkdir -p ${TARGET_DIR}

copy_vendor_header_file
Extract_files
Make_Android_mk

