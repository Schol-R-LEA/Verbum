;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Verbum boot loader for FAT12
; * sets the segments for use in the boot process.
; * loads and verifies the boot image from the second sector, 
;    then transfers control  to it.
;
; Version History (note: build versions not shown) 
; pre      - June 2002 to February 2004 - early test versions
;                * sets segments, loads image from second sector          
; v 0.01 - 28 February 2004 Joseph Osako 
;               * Code base cleaned up
;               * Added BPB data for future FAT12 support
;               * renamed "Verbum Boot Loader"
; v0.02 - 8 May 2004 Joseph Osako
;               *  moved existing disk handling into separate functions
; v0.03 - 7 Sept 2006 Joseph Osako
;               * resumed work on project. Placed source files under
;                 version control (SVN)
; v0.04 - 18 April 2016 - restarting project, set up on Github
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;;constants
;

%define boot_base   0x0000      ; the segment:offset pair for the
%define boot_offset 0x7C00	;  boot code entrypoint

stage2_base   	equ 0x1000      ; the segment:offset to load 
stage2_offset   equ 0x0000	; the second stage into
stack_seg  	equ 0x9000
stack_top	equ 0xFFFC

VBIOS	        equ 0x10        ; BIOS interrupt vector for video services
GOTO_XY         equ 0x02        ; VBIOS routine - go to the given x, y coordinates
block_write     equ 0x09        ; VBIOS routine - write a fixed number of times to the screen
ttype	        equ 0x0E        ; VBIOS routine - print character, teletype mode

DBIOS	        equ 0x13        ; BIOS interrupt vector for disk services
disk_reset	equ 0x00        ; disk reset service
disk_read	equ 0x02        ; disk read service

;  BIOS error codes
reset_failure   equ 0x01        ; error code returned on disk reset failure
read_failure    equ 0x02        ; error code returned on disk read failure

; operational constants 
tries           equ 0x03        ; number of times to attempt to access the FDD

;  character constants
NULL	        equ 0x00        ; end of string marker
CR	        equ 0x0D        ; carriage return
LF	        equ 0x0A        ; line feed 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; macros
;
%define zero(x) xor x, x

%macro write 1
   mov si, %1
   call printstr
%endmacro


[bits 16]
[org boot_offset]
[section text]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; entry - the entrypoint to the code. Make a short jump passed the BPB.
entry:
  jmp short redirect
  nop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; FAT12 Boot Parameter Block - required by filesystem
OEM_ID                  db "Verb0.04"
Bytes_Per_Sector	dw 0x0200
Sectors_Per_Cluster	db 0x01
Reserved_Sectors	dw 0x0001
FATs		        db 0x02
Root_Entries		dw 0x00E0
Sectors_Short		dw 0x0B40
Media_Descriptor	db 0xF0		   ; assumes 3.5" 1.44M disk
Sectors_Per_FAT_Short	dw 0x0009
Sectors_Per_Track	dw 0x0012
Heads		        dw 0x02
Hidden_Sectors	        dd 0x00000000
Sectors_Long		dd 0x00000000
Sectors_Per_FAT_Long	dd 0x00000000
Extension_Flags	        dw 0x0000
; extended BPB section
Drive_Number		db 0x00
Current_Head		db 0x00
BPB_Signature		db 0x28
Serial_Number		dd 0x000001
Disk_Label              db "Verbum Boot"    ; must be exactly 11 characters
File_System		db "FAT12   "       ; must be exactly 8 characters


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; redirect - do a far jump to ensure that you have the desired 
;          segment:offset location
redirect:
  jmp boot_base:start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; start
; This is the real begining of the code. The first order of
; business is clearing the interrupts, then setting the
; segment registers and the stack pointer.  

start:
  mov ax, stack_seg
  cli
  mov ss, ax          ; set the stack at an arbitrarily high point past ES.
  mov sp,  stack_top  ; put the stack pointer to the top of SS
  sti                 ; reset ints so BIOS calls can be used
  mov ax, cs
  mov ds, ax          ; set DS == CS	
  mov [bootdrv], dl   ; save boot drive info for later use

	
; read in the data from disk and load it to ES:BX (already initialized)
  write loading
  call read_disk
  cmp ax, reset_failure
  jne good_reset
  write reset_failed
  jmp short shutdown
good_reset:
  cmp ax, read_failure
  jne good_read
  write read_failed
  jmp short shutdown

good_read:
  write done

  mov al, [bootdrv]
  push ax            		; send boot drive information to 2nd stage
	
; set up fake return frame for code returning from second stage
  mov ax, cs
  push ax
  mov ax, re_enter
  push ax  

; fake a jump to the second stage entry point
  mov ax, stage2_base
  mov es, ax
  mov bx, stage2_offset
  push es
  push bx
  write snd_stage
  retf

re_enter:
  mov ax, cs
  mov ds, ax
  pop ax       			; clean up stack
  pop ax
  pop ax
  write returned

shutdown:
   write exit
halted:
   hlt
   jmp short halted
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Auxilliary functions      

;; printstr - prints the string point to by SI

printstr:
  push ax
  mov ah, ttype        ; set function to 'teletype mode'
  .print_char:   
    lodsb               ; update byte to print
    cmp al, NULL        ; test that it isn't NULL
    jz short .endstr
    int  VBIOS          ; put character in AL at next cursor position
    jmp short .print_char
.endstr:
  pop ax
  ret


; reset_disk
reset_disk:
  mov dl, [bootdrv]
  mov ah, disk_reset
  int DBIOS
  ret

; read_disk
read_disk:
  mov cx, tries        ; set count of attempts for disk reads
  .try_read:
    push cx
    mov cx, tries      ; set count of attempts to reset disk
    .try_reset:
      call reset_disk
      jnc short .read
      loop .try_reset       ; if the reset fails, try up to three times
      mov ax, reset_failure ; if all three fail, set an error code and return
      pop cx                ; make sure that the stack is correctly aligned
      jmp short .end_fail
  .read:
    mov ax, stage2_base
    mov es, ax
    mov dl, [bootdrv] 
    mov ch, [cyl]           ; cylinder
    mov dh, [head]          ; head
    mov cl, [startsector]   ; first sector 
    mov al, [numsectors]    ; number of sectors to load   
    mov ah, disk_read
    mov bx, stage2_offset
    int DBIOS
    jnc short .end_success
    pop cx
    loop .try_read
  mov ax, read_failure ; if attempts to read the disk fail, report error code
  jmp short .end_fail
.end_success:
  pop cx               ; make sure that the stack is correctly aligned
  zero(ax)
.end_fail:
  ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; data
	
[section data]
loading         db 'Loading stage two... ', NULL
done            db 'done.', CR, LF, NULL
snd_stage	db 'Second stage loaded, proceeding to switch context.', CR, LF, NULL
returned	db 'Control returned to first stage, ', NULL
reset_failed	db 'Could not reset drive,', NULL
read_failed	db 'Could not read second stage, ', NULL
exit            db ' system halted.', NULL

bootdrv	        resb 1      ; byte reserved for boot drive ID number

; DBIOS arguments, values given are defaults
cyl             db 0        ; cylinder to read from
head	        db 0        ; head to read from
startsector	db 2        ; sector to start reading at
numsectors	db 1        ; number of sectors to read
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pad out to 510, and then add the last two bytes needed for a boot disk

space   times (0x0200 - 2) - ($-$$) db 0
bootsig   dw 0xAA55 
