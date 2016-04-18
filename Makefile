ASM = nasm -f bin
COPY = dd
LIST1 = verbum.lst
LIST2 = stagetwo.lst
STAGE1 = verbum.asm
STAGE2 = stagetwo.asm
TARGET1 = verbum.bin
TARGET2 = stagetwo.bin
DISKTARGET = boot.img

$(DISKTARGET): $(TARGET1) $(TARGET2)
	$(COPY) if=$(TARGET1) of=$(DISKTARGET)
	$(COPY) if=$(TARGET2) of=$(DISKTARGET) seek=1

$(TARGET1):
	$(ASM) $(STAGE1) -o $(TARGET1) -l $(LIST1)

$(TARGET2):
	$(ASM)  $(STAGE2) -o $(TARGET2) -l $(LIST2)
