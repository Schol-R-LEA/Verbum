ASM = nasm -w+all -f bin
COPY = dd
FORMAT = mkfs.msdos -F 12 -n "VERBUM"
SYS_INSTALL = ~/Deployments/ms-sys-2.5.3/bin/ms-sys --fat12 
BOOT = verbum
STAGE_TWO = stagetwo
FAT = model_fat_entry
FAT2_SEEK = 9 
STG2_SEEK = 18
STG2SIZE = 1
DISKTARGET = boot.img
DISKSIZE = 1440

install: boot stage2
	$(COPY) if=/dev/zero of=$(DISKTARGET) count=$(DISKSIZE) bs=1k
	$(FORMAT) $(DISKTARGET)
	$(COPY) if=$(BOOT).bin of=$(DISKTARGET) count=1 conv=notrunc
	$(COPY) if=$(FAT) of=$(DISKTARGET) count=1 seek=1 conv=notrunc
	$(COPY) if=$(FAT) of=$(DISKTARGET) count=1 seek=$(FAT2_SEEK) conv=notrunc 
	$(COPY) if=$(STAGE_TWO).bin of=$(DISKTARGET) count=1 seek=$(STG2_SEEK) conv=notrunc
boot:
	$(ASM) $(BOOT).asm -o $(BOOT).bin -l $(BOOT).lst

stage2:
	$(ASM) $(STAGE_TWO).asm -o $(STAGE_TWO).bin -l $(STAGE_TWO).lst


