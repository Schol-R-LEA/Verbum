ASM = nasm -w+all -f bin
COPY = dd
FORMAT = mkfs.msdos -F 12 -n "VERBUM"
REIMAGE=qemu-img
SYS_INSTALL = ~/Deployments/ms-sys-2.5.3/bin/ms-sys --fat12 
BOOT = test_LBA_translation
DISKTARGET = boot.img
DISKSIZE = 1440

install: boot stage2
	dd if=/dev/zero of=$(DISKTARGET) count=$(DISKSIZE) bs=1k
	$(FORMAT) $(DISKTARGET)
	dd if=$(BOOT).bin of=$(DISKTARGET) count=1 conv=notrunc
	$(REIMAGE) convert -f raw -O qcow2 boot.img boot.qcow2

boot:
	$(ASM) $(BOOT).asm -o $(BOOT).bin -l $(BOOT).lst

