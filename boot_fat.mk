BCOUNT = $(shell expr $(BOARD_BOOTIMAGE_PARTITION_SIZE) \/ 512)

ramdisk: $(INSTALLED_RAMDISK_TARGET)
	mkimage -T ramdisk  -A arm64 -C gzip -n 'Android Ramdisk Image' -d $(PRODUCT_OUT)/ramdisk.img $(PRODUCT_OUT)/ramdisk

boot_fat_sparse.img: $(INSTALLED_KERNEL_TARGET) ramdisk
	dd if=/dev/zero of=$(PRODUCT_OUT)/boot_fat.img bs=512 count=$(BCOUNT)
	mkfs.vfat -n "boot" $(PRODUCT_OUT)/boot_fat.img
	mcopy -i $(PRODUCT_OUT)/boot_fat.img $(PRODUCT_OUT)/Image ::Image
	mcopy -i $(PRODUCT_OUT)/boot_fat.img $(PRODUCT_OUT)/uniphier-ld20-akebi96.dtb ::uniphier-ld20-akebi96.dtb
	mcopy -i $(PRODUCT_OUT)/boot_fat.img $(PRODUCT_OUT)/ramdisk ::ramdisk
	mmd -i $(PRODUCT_OUT)/boot_fat.img ::extlinux
	mcopy -i $(PRODUCT_OUT)/boot_fat.img $(PRODUCT_OUT)/extlinux.conf ::extlinux/extlinux.conf
	img2simg $(PRODUCT_OUT)/boot_fat.img $(PRODUCT_OUT)/boot_fat_sparse.img 4096

droidcore: boot_fat_sparse.img
