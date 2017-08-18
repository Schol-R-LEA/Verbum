ASM = nasm -w+all -f bin
COPY = dd
BOOT = verbum
STAGE_TWO = stagetwo
FAT = table
FATSIZE = 18
STG2START = 19
STG2SIZE = 1
DISKTARGET = boot.img
DISKSIZE = 1440

build: boot stage2
	$(COPY) if=/dev/zero of=$(DISKTARGET) count=$(DISKSIZE) bs=1k
	$(COPY) if=$(BOOT).bin of=$(DISKTARGET) count=1 conv=notrunc
	$(COPY) if=$(FAT).bin of=$(DISKTARGET) seek=1 count=$(FATSIZE) conv=notrunc		
	$(COPY) if=$(STAGE_TWO).bin of=$(DISKTARGET) seek=$(STG2START) count=$(STG2SIZE) conv=notrunc

boot:
	$(ASM) $(BOOT).asm -o $(BOOT).bin -l $(BOOT).lst

stage2:
	$(ASM) $(STAGE_TWO).asm -o $(STAGE_TWO).bin -l $(STAGE_TWO).lst


