/*
 * Copyright 2014 Intel Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdio.h>
#include <malloc.h>
#include <unistd.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <cutils/properties.h>
#include <sys/mman.h>
#include "edify/expr.h"
#include <errno.h>
#include <string.h>

#define FORCE_RW_OPT            "0"
#define FILE_PATH_SIZE          64

#define EMMC_BOOT_SIZE (2048*1024)
#define EMMC_USER_SIZE (3959422976UL)

#define NUM_OF_NAME_INFO_TABLE (8)
typedef struct _name_info {
	int partition;	// 0: boot0, 1: boot1, 2: user
	int offset;		// offset of sector. need to convert byte
	char name[32];	// ROM name
} NAME_INFO;

#ifdef USE_BSP_1_0
NAME_INFO name_info[] = {
	{ 0, 0x00000000, "/tmp/boot_b.img" },
	{ 0, 0x00000080, "/tmp/boot_u.img" },
	{ 1, 0x00000800, "/tmp/boot_st.img"},
	{ 2, 0x00004000, "/tmp/bin_k.img"  },
	{ 2, 0x0000A000, "/tmp/bin_u.img"  },
};
#else /* USE_BSP_1_0 */
NAME_INFO name_info[] = {
	{ 0, 0x00000000, "/tmp/boot_b.img" },
	{ 0, 0x00000100, "/tmp/boot_u.img" },
	{ 1, 0x00000800, "/tmp/boot_st.img"},
	{ 2, 0x00004000, "/tmp/bin_k.img"  },
	{ 2, 0x0000A000, "/tmp/bin_u.img"  },
};
#endif /* USE_BSP_1_0 */

static int force_rw(char *name) {
	int ret, fd;

	fd = open(name, O_WRONLY);
	if (fd < 0) {
		fprintf(stderr, "force_ro(): failed to open %s\n", name);
		return fd;
	}

	ret = write(fd, FORCE_RW_OPT, sizeof(FORCE_RW_OPT));
	if (ret <= 0) {
		fprintf(stderr, "force_ro(): failed to write %s\n", name);
		close(fd);
		return ret;
	}

	close(fd);
	return 0;
}

static int write_emmc(uint32_t addr_offset, void *data, size_t size, int partition)
{
	int boot_fd = 0;
	char boot_partition[FILE_PATH_SIZE];
	char boot_partition_force_ro[FILE_PATH_SIZE];
	char *ptr;
	size_t offset = addr_offset*512; // convert to byte.

	printf("write eMMC : %d %08x\n", partition, addr_offset );
	switch (partition) {
		case 0: // mmcblk0boot0
		case 1: // mmcblk0boot1
			snprintf(boot_partition, FILE_PATH_SIZE, "/dev/block/mmcblk0boot%d", partition);
			snprintf(boot_partition_force_ro, FILE_PATH_SIZE, "/sys/block/mmcblk0boot%d/force_ro", partition);

			if (force_rw(boot_partition_force_ro)) {
				printf("%s:%d: unable to force_ro %s\n", __func__, __LINE__, boot_partition);
				goto err_boot1;
			}
			boot_fd = open(boot_partition, O_RDWR);
			if (boot_fd < 0) {
				printf("%s:%d: failed to open %s\n", __func__, __LINE__, boot_partition);
				goto err_boot1;
			}

			ptr = (char *)mmap(NULL, EMMC_BOOT_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, boot_fd, 0);
			if (ptr == MAP_FAILED) {
				printf("%s:%d: mmap failed on boot%d with error : %s\n", __func__, __LINE__, partition, strerror(errno));
				goto err_boot1;
			}
			/* Write the data */
			if (EMMC_BOOT_SIZE >= offset + size) {
				if (data == NULL) {
					memset(ptr + offset, 0, size);
				}
				else {
					memcpy(ptr + offset, data, size);
				}
			} else {
				printf("%s:%d: sizeover boot%d eMMC size=%d < %zu\n", __func__, __LINE__, partition, EMMC_BOOT_SIZE, offset + size);
			}
			munmap(ptr, EMMC_BOOT_SIZE);
			close(boot_fd);
			break;
		case 2:
			snprintf(boot_partition, FILE_PATH_SIZE, "/dev/block/mmcblk0");
			boot_fd = open(boot_partition, O_RDWR);
			if (boot_fd < 0) {
				printf("%s:%d: failed to open %s\n", __func__, __LINE__, boot_partition);
				goto err_boot1;
			}

			ptr = (char *)mmap(NULL, offset + size, PROT_READ|PROT_WRITE, MAP_SHARED, boot_fd, 0);
			if (ptr == MAP_FAILED) {
				printf("%s:%d: mmap failed on user with error : %s\n", __func__, __LINE__, strerror(errno));
				goto err_boot3;
			}
			/* Write the data */
			if (EMMC_USER_SIZE >= offset + size) {
				if (data == NULL) {
					memset(ptr + offset, 0, size);
				}
				else {
					memcpy(ptr + offset, data, size);
				}
			} else {
				printf("%s:%d: sizeover user eMMC size=%ld < %zu\n", __func__, __LINE__, EMMC_USER_SIZE , offset + size);
			}
			munmap(ptr, offset + size);
			close(boot_fd);
			break;
		default:
			return -1;
			break;
	}
	return 0;

err_boot2:
	munmap(ptr, EMMC_BOOT_SIZE);
	goto err_boot1;

err_boot3:
	munmap(ptr, offset + size);
	goto err_boot1;

err_boot1:
	close(boot_fd);
	return -1;
}

#if defined(USE_SDK_25)
Value* FlashImgOffsetFn(const char *name, State * state, int argc, Expr * argv[]) {
#else /* defined(USE_SDK_25) */
Value* FlashImgOffsetFn(const char *name, State * state, const std::vector<std::unique_ptr<Expr>>& argv) {
#endif /* defined(USE_SDK_25) */

	Value *ret = NULL;
	char *filename = NULL;
	void *buffer = NULL;
	int rom_size;
	FILE *f = NULL;
	int partition, offset;
	int i;

#if defined(USE_SDK_25)
	if (argc != 1) {
		ErrorAbort(state, "%s() expected 1 arg, got %d", name, argc);
		return NULL;
	}
	if (ReadArgs(state, argv, 1, &filename) < 0) {
		ErrorAbort(state, "%s() invalid args ", name);
		return NULL;
	}
#else /* defined(USE_SDK_25) */
	if (argv.size() != 1) {
		ErrorAbort(state, "%s() expected 1 arg, got %d", name, argv.size());
		return NULL;
	}
	std::vector<std::string> args;
	if (!ReadArgs(state, argv, &args)) {
		ErrorAbort(state, "%s() invalid args ", name);
		return NULL;
	}
	const std::string& fname = args[0];
	if (fname.empty()) {
		ErrorAbort(state, "filename argument to %s can't be empty", name);
		return NULL;
	}
	filename = (char *)fname.c_str();
#endif /* defined(USE_SDK_25) */
	
	if (filename == NULL || strlen(filename) == 0) {
		ErrorAbort(state, "filename argument to %s can't be empty", name);
		goto done;
	}

	if ((f = fopen(filename,"rb")) == NULL) {
		ErrorAbort(state, "Unable to open file %s: %s ", filename, strerror(errno));
		goto done;
	}

	fseek(f, 0, SEEK_END);
	rom_size = ftell(f);
	if (rom_size < 0) {
		ErrorAbort(state, "Unable to get rom_size ");
		goto done;
	};
	fseek(f, 0, SEEK_SET);

	if ((buffer = malloc(rom_size)) == NULL) {
		ErrorAbort(state, "Unable to alloc flash buffer of size %d", rom_size);
		goto done;
	}
	fread(buffer, rom_size, 1, f);
	fclose(f);

	// select offset, mmcblk0boot0, mmcblk0boot1, mmcblk0.
	for (i = 0; i < NUM_OF_NAME_INFO_TABLE; i++) {
		if (strncmp(name_info[i].name, filename, sizeof(name_info[i].name)) == 0) {
			printf("Write Image : filename : %s partition : %d offset(sect, hex) : %08x\n", name_info[i].name, name_info[i].partition, name_info[i].offset);
			if(write_emmc(name_info[i].offset, buffer, rom_size, name_info[i].partition) !=0) {
				ErrorAbort(state, "Unable to flash in emmc %s to %d", filename, name_info[i].partition);
				free(buffer);
				goto done;
			};
			break;
		}
	}

	free(buffer);
	ret = StringValue(strdup(""));

done:
	if (filename)
		free(filename);

	return ret;
}

#ifdef EXPORT_C_FUNC
extern "C" {
#endif

void Register_librecovery_updater_sc1401aj1() {
	RegisterFunction("sc1401aj1.flash_ImgOffset", FlashImgOffsetFn);
}

#ifdef EXPORT_C_FUNC
};
#endif
