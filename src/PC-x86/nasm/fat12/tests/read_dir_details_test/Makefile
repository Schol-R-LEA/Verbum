ASM = nasm -w+all -f bin
COPY = dd
FORMAT = mkfs.msdos -F 12 -n "VERBUM"
REIMAGE=qemu-img
SYS_INSTALL = ~/Deployments/ms-sys-2.5.3/bin/ms-sys --fat12
BOOT = read_dir_details_test
STAGE_TWO = stagetwo
DISKTARGET = boot.img
DISKSIZE = 1440

install: boot stage2
	$(COPY) if=/dev/zero of=$(DISKTARGET) count=$(DISKSIZE) bs=1k
	$(FORMAT) $(DISKTARGET)
	$(COPY) if=$(BOOT).bin of=$(DISKTARGET) count=1 conv=notrunc
	mkdir temp
	sudo mount -t vfat $(DISKTARGET) temp
	sudo cp $(STAGE_TWO).bin temp/STAGETWO.BIN
	sudo umount temp
	rmdir temp
	$(REIMAGE) convert -f raw -O qcow2 boot.img boot.qcow2

boot:
	$(ASM) $(BOOT).asm -o $(BOOT).bin -l $(BOOT).lst

stage2:
	$(ASM) $(STAGE_TWO).asm -o $(STAGE_TWO).bin -l $(STAGE_TWO).lst
