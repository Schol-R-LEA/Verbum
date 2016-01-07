ASM = nasm -f bin -l
COPY = dd
RUN = bochs

boot.img: verbum.bin stagetwo.bin
	$(COPY) if=verbum.bin of=boot.img
	$(COPY) if=stagetwo.bin of=boot.img seek=1
	$(RUN)

verbum.bin:
	$(ASM) verbum.asm -o verbum.bin

stagetwo.bin:
	$(ASM) stagetwo.asm -o stagetwo.bin


	
