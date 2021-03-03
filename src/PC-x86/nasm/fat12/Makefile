ASM = nasm -w+all -f bin
COPY = dd
FORMAT = mkfs.msdos -F 12 -n "VERBUM"
REIMAGE=qemu-img
SYS_INSTALL = ~/Deployments/ms-sys-2.5.3/bin/ms-sys --fat12 
BOOT = verbum
STAGE_TWO = stagetwo
FAT = verbum_fat_table.bin
FAT2_SEEK = 9 
STG2_SEEK = 18
STG2SIZE = 1
DISKTARGET = boot.img
DISKSIZE = 1440

install: boot stage2
	dd if=/dev/zero of=$(DISKTARGET) count=$(DISKSIZE) bs=1k
	$(FORMAT) $(DISKTARGET)
	dd if=$(BOOT).bin of=$(DISKTARGET) count=1 conv=notrunc
	mkdir temp
	sudo mount $(DISKTARGET) temp
	sudo cp $(STAGE_TWO).bin temp/STAGE2.BIN
	sudo umount temp
	rmdir temp
	$(REIMAGE) convert -f raw -O qcow2 boot.img boot.qcow2

boot:
	$(ASM) $(BOOT).asm -o $(BOOT).bin -l $(BOOT).lst

stage2:
	$(ASM) $(STAGE_TWO).asm -o $(STAGE_TWO).bin -l $(STAGE_TWO).lst


