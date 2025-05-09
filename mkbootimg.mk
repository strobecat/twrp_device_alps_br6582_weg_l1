LOCAL_PATH := $(call my-dir)

REPACKTOOL := $(LOCAL_PATH)/repack-MTK.pl

$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(REPACKTOOL) $(recovery_ramdisk) $(recovery_kernel)
	@echo -e ${PRT_IMG}"----- Making recovery image ------"${CL_RST}
	perl $(REPACKTOOL) -recovery $(recovery_kernel) $(recovery_ramdisk) $@ $(MKBOOTIMG)
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE))
	@echo -e ${PRT_IMG}"----- Made recovery image: $@ --------"${CL_RST}
