;;;;;;;;;;;;;;;;;
;; stagetwo.asm - second stage boot loader
;; 
;; v 0.01  Joseph Osako 3 June 2002
;; v 0.02  Joseph Osako 7 Sept 2006
;;         * restarted project, files place under source control.
;;         * Modifications for FAT12 based loader begun. 
;;
;; 

%define stage2_base 0x1000      ; the segment:offset to load 
%define stage2_offset 0x0000	; the second stage into
	
VBIOS	        equ 0x10        ; BIOS interrupt vector for video services
set_cursor      equ 0x02        ; set the cursor to the given x,y coordinates
set_page_mode   equ 0x03
set_active_page equ 0x05
read_cursor     equ 0x08
write_cursor    equ 0x09
ttype	        equ 0x0E        ; print character, teletype mode	
NULL	        equ 0x00        ; end of string marker
CR	        equ 0x0D        ; carriage return
LF	        equ 0x0A        ; line feed 

DBIOS	        equ 0x13        ; BIOS interrupt vector for disk services
disk_reset	equ 0x00        ; disk reset service
disk_read	equ 0x02        ; disk read service
tries           equ 0x03        ; number of times to attempt to access the FDD
reset_failure   equ 0x01        ; error code returned on disk reset failure
read_failure    equ 0x02        ; error code returned on disk read failure

cyl             equ 0x00        ; cylinder to read from
head	        equ 0x00        ; head to read from
startsector	equ 0x02        ; sector to start reading at
numsectors	equ 0x01        ; number of sectors to read


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; macros
;	
%define zero(x) xor x, x
			
%macro write 1
   mov si, %1
   call printstr
%endmacro

[bits 16]
[org stage2_offset]
	
entry:
   mov ax, cs
   mov ds, ax
   write success
;  jmp $
  ; 'return' to the first stage via a faked call frame set up earlier
  retf


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
  zero (ah)
  mov al, disk_reset
  int DBIOS
  ret

	
;;;;;;;;;;;;;;;;;;;;;;;;;
;; data
success   db 'Control successfully transferred to second stage.', CR, LF, NULL

bootdrv	  db 0x00  ; byte reserved for boot drive ID number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pad out to 512

space   times 0x0200 - ($-$$) db 0 
