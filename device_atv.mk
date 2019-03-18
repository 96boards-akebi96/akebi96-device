#
# Copyright (C) 2009 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

USE_CONFIG_DIR_NAME := p

PRODUCT_PROPERTY_OVERRIDES += \
    ro.sf.lcd_density=320 \
    persist.socionext.forteart=true \
    persist.socionext.pictureplayer=true

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    vendor.mode=atv

PRODUCT_CHARACTERISTICS := nosdcard,tv

# for Android TV
# PRODUCT_PACKAGES += \
#     android.hardware.tv.input@1.0-impl \
#     android.hardware.tv.input@1.0-service.sc1401aj1
PRODUCT_PACKAGES += LiveTv
PRODUCT_PACKAGES += TvSampleLeanbackLauncher

# for Bluetooth
PRODUCT_PACKAGES += Telecom

DEVICE_PACKAGE_OVERLAYS += device/socionext/akebi96/$(USE_CONFIG_DIR_NAME)/atv_overlay
