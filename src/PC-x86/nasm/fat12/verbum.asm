;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Verbum boot loader for FAT12
;;;* sets the segments for use in the boot process.
;;;* loads and verifies the boot image from the second sector, 
;;;   then transfers control  to it.
;;;
;;;Version History (note: build versions not shown) 
;;;pre      - June 2002 to February 2004 - early test versions
;;;               * sets segments, loads image from second sector          
;;;v 0.01 - 28 February 2004 Alice Osako 
;;;              * Code base cleaned up
;;;              * Added BPB data for future FAT12 support
;;;              * renamed "Verbum Boot Loader"
;;;v0.02 - 8 May 2004 Alice Osako
;;;              *  moved existing disk handling into separate functions
;;;v0.03 - 7 Sept 2006 Alice Osako
;;;              * resumed work on project. Placed source files under
;;;                version control (SVN)
;;;v0.04 - 18 April 2016 - restarting project, set up on Github
;;;v0.05 - 16 August 2017 - restructuring project, working on FAT12
;;;              support and better documentation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; data structure definitions
%include "bios.inc"
%include "consts.inc"
%include "fat_entry.inc"
%include "stage2_parameters.inc"
%include "macros.inc"


;;; local macros 
%macro write 1
        mov si, %1
        call near print_str
%endmacro

;;; constants
boot_base       equ 0x0000      ; the segment base:offset pair for the
boot_offset     equ 0x7C00      ; boot code entrypoint

;; ensure that there is no segment overlap
stack_segment   equ 0x1000  
stack_top       equ 0xFFFE

;;;operational constants 
tries           equ 0x03        ; number of times to attempt to access the FDD

        
[bits 16]
[org boot_offset]
[section .text]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; entry - the entrypoint to the code. Make a short jump past the BPB.
entry:
        jmp short start
        nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FAT12 Boot Parameter Block - required by FAT12 filesystem

boot_bpb:
%include "fat-12.inc"

   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; start
;;; This is the real begining of the code. The first order of
;;; business is clearing the interrupts, then setting the
;;; segment registers and the stack pointer.  

start:
        mov ax, stack_segment
        cli                     ;  ints out of an abundance of caution
        mov ss, ax              ; set to match the code segment
        ;; set up a stack frame for the disk info
        ;;  and other things passed by the boot sector
        mov ax, stack_top
        sub ax, stg2_parameters_size
        mov sp, ax
        mov bp, sp
        sti                     ; reset ints so BIOS calls can be used

        ;; set the remaining segment registers to match CS
        mov bx, es              ; save segment part of the PnP ptr
        mov ax, cs
        mov ds, ax
        mov es, ax

        ;; any other housekeeping that needs to be done at the start
        cld

        ;; find the start of the stage 2 parameter frame
        ;;  and populated the frame
        mov cx, fat_buffer
        mov [bp + stg2_parameters.drive], dx
        mov [bp + stg2_parameters.fat_0], cx
        mov [bp + stg2_parameters.PnP_Entry_Seg], bx
        mov [bp + stg2_parameters.PnP_Entry_Off], di
        mov [bp + stg2_parameters.reset_drive], word reset_disk
        mov [bp + stg2_parameters.read_sectors], word read_sectors
        mov [bp + stg2_parameters.print_str], word print_str
        mov [bp + stg2_parameters.halt_loop], word halted

;;; reset the disk drive
        call near reset_disk       

;;; get the location and size of the next stage of the boot loader
        
        ;; load the second stage code
        write loading
;        mov dx, [bp + stg2_parameters.drive]
        mov al, stage2_size
        mov dh, stage2_head
        mov ch, stage2_track
        mov cl, stage2_sector
        mov bx, stage2_buffer
        call near read_sectors
        write done
        
;;; jump to loaded second stage
        write stage2_jump
        jmp stage2_buffer

        jmp short halted


;;;  backstop - it shouldn't ever actually print this message
        write oops
        
halted:
        hlt
        jmp short halted
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Auxilliary functions      

;;;;print_str - prints the string point to by SI

print_str:
        pusha
        mov ah, ttype       ; set function to 'teletype mode'
        zero(bx)
        mov cx, 1
    .print_char:
        lodsb               ; update byte to print
        cmp al, NULL        ; test that it isn't NULL
        jz short .endstr
        int  VBIOS          ; put character in AL at next cursor position
        jmp short .print_char
    .endstr:
        popa
        ret

;;;reset_disk
reset_disk:
        mov si, 0
        mov di, tries        ; set count of attempts for disk resets
  .try_reset:
        mov ah, disk_reset
        int DBIOS
        jnc short .reset_end
        dec di
        jnz .try_reset
        ;;; if repeated attempts to reset the disk fail, report error code
        write failure_state
        write reset_failed
        write exit
        jmp halted
  .reset_end:
        ret
   
        
;;; read_sectors
read_sectors:
        pusha
        mov si, 0
        mov di, tries        ; set count of attempts for disk reads
        mov ah, disk_read
  .try_read:
        push ax
        int DBIOS
        pop ax
        jnc short .read_end
        dec di
        jnz .try_read
        ; if repeated attempts to read the disk fail, report error code
        write failure_state
        write read_failed    ; fall-thru to 'exit', don't needs separate write
        jmp halted
        
  .read_end:
        popa
        ret

;print_hex:
;;;  al = byte to print
;        pusha
;        mov ah, ttype           ; set function to 'teletype mode'
;        zero(bx)
;        mov cx, 1
;        zero(dh)
;        mov dl, al              ; have a copy of the byte in DL
;        and dl, 0x0f            ; isolate low nibble in DL
;        shr al, 4               ; isolate high nibble into low nibble in AL
;        cmp al, 9
;        jg short .alphanum_hi
;	add al, ascii_zero
;        jmp short .show_hi
;  .alphanum_hi:
;        add al, upper_numerals 
;  .show_hi:
;        int VBIOS
;        mov al, dl
;        cmp al, 9
;        jg short .alphanum_lo
;	add al, ascii_zero
;        jmp short .show_lo
;  .alphanum_lo:
;        add al, upper_numerals  
;  .show_lo:
;        int VBIOS
;
;        popa
;        ret
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  data
;;[section .data]
     
;;[section .rodata]

snd_stage_filename db 'STAGE2  SYS'

; reading_fat     db 'Get sector...', NULL
loading         db 'Load 2nd stage...', NULL
stage2_jump     db 'entering OS... ', NULL
;separator       db ':', NULL
comma_done      db ', '
done            db 'done.', CR, LF, NULL
failure_state   db 'Unable to ', NULL
reset_failed    db 'reset,', NULL
read_failed     db 'read,'
exit            db ' halted.', NULL
oops            db 'Oops.', NULL 

        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; pad out to 510, and then add the last two bytes needed for a boot disk
space     times (0x0200 - 2) - ($-$$) db 0
bootsig   dw 0xAA55
