#
# Copyright (C) 2013 The Android Open-Source Project
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

# can this be done in bash? credits go to bgcngm
define make_header
  perl -e 'print pack("a4 L a32 a472", "\x88\x16\x88\x58", $$ARGV[0], $$ARGV[1], "\xFF"x472)' $(1) $(2) > $(3)
endef

$(recovery_kernel).mtk.header: $(recovery_kernel)
	size=$$($(call get-file-size,$(recovery_kernel))); \
		$(call make_header, $$((size)), "KERNEL", $@)

$(recovery_kernel).mtk: $(recovery_kernel).mtk.header
	$(call pretty,"Adding MTK header to recovery kernel.")
	$(hide) cat $(recovery_kernel).mtk.header $(recovery_kernel) > $(recovery_kernel).mtk

$(recovery_ramdisk).mtk.header: $(recovery_ramdisk)
	size=$$($(call get-file-size,$(recovery_ramdisk))); \
		$(call make_header, $$((size)), "ROOTFS", $@)

$(recovery_ramdisk).mtk: $(recovery_ramdisk).mtk.header
	$(call pretty,"Adding MTK header to recovery ramdisk.")
	$(hide) cat $(recovery_ramdisk).mtk.header $(recovery_ramdisk) > $(recovery_ramdisk).mtk

INTERNAL_MTK_RECOVERYIMAGE_ARGS := \
	$(addprefix --second ,$(INSTALLED_2NDBOOTLOADER_TARGET)) \
	--kernel $(recovery_kernel).mtk \
	--ramdisk $(recovery_ramdisk).mtk

ifdef BOARD_KERNEL_CMDLINE
  INTERNAL_MTK_RECOVERYIMAGE_ARGS += --cmdline "$(BOARD_KERNEL_CMDLINE)"
endif
ifdef BOARD_KERNEL_BASE
  INTERNAL_MTK_RECOVERYIMAGE_ARGS += --base $(BOARD_KERNEL_BASE)
endif
BOARD_KERNEL_PAGESIZE := $(strip $(BOARD_KERNEL_PAGESIZE))
ifdef BOARD_KERNEL_PAGESIZE
  INTERNAL_MTK_RECOVERYIMAGE_ARGS += --pagesize $(BOARD_KERNEL_PAGESIZE)
endif

$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) \
		$(recovery_ramdisk).mtk \
	  $(recovery_kernel).mtk	
	@echo -e ${PRT_IMG}"----- Making recovery image ------"${CL_RST}
	$(hide) $(MKBOOTIMG) $(INTERNAL_MTK_RECOVERYIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE))
	@echo -e ${PRT_IMG}"----- Made recovery image: $@ --------"${CL_RST}
