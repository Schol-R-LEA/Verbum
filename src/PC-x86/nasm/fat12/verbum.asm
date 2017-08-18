;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Verbum boot loader for FAT12
;;;* sets the segments for use in the boot process.
;;;* loads and verifies the boot image from the second sector, 
;;;   then transfers control  to it.
;;;
;;;Version History (note: build versions not shown) 
;;;pre      - June 2002 to February 2004 - early test versions
;;;               * sets segments, loads image from second sector          
;;;v 0.01 - 28 February 2004 Joseph Osako 
;;;              * Code base cleaned up
;;;              * Added BPB data for future FAT12 support
;;;              * renamed "Verbum Boot Loader"
;;;v0.02 - 8 May 2004 Joseph Osako
;;;              *  moved existing disk handling into separate functions
;;;v0.03 - 7 Sept 2006 Joseph Osako
;;;              * resumed work on project. Placed source files under
;;;                version control (SVN)
;;;v0.04 - 18 April 2016 - restarting project, set up on Github
;;;v0.05 - 16 August 2017 - restructuring project, working on FAT12
;;;              support and better documentation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; data structure definitions
%include "bios.inc"
%include "consts.inc"
%include "bpb.inc"
%include "fat_entry.inc"

        
struc disk_parameters
        .drive resb 1
        .cylinder resb 1
        .head resb 1
        .sector resb 1
endstruc

   
;;; constants

boot_base       equ 0x07C0      ;; the segment base:offset pair for the
boot_offset     equ 0x0000      ;; boot code entrypoint

stack_segment   equ boot_base - 0x0200        
stack_top       equ 0xFFFC

fat_start       equ 2
fat_size        equ 0x0009      ;; number of sectors per FAT
reserved_size   equ 1 + (2 * fat_size)   
disk_type       equ 0xF0        ;; default - 3.5" 1.44M

stage2_size     equ 1
loaded_fat      equ boot_offset + 0x0200

;;;operational constants 
tries           equ 0x03        ;; number of times to attempt to access the FDD


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; macros
;
%define zero(x) xor x, x

%macro write 1
        push si
        mov si, %1
        call near printstr
        pop si
%endmacro
        
        
[bits 16]
[org boot_offset]
[section .text]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; entry - the entrypoint to the code. Make a short jump past the BPB.
entry:
        jmp short redirect
        nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FAT12 Boot Parameter Block - required by FAT12 filesystem

boot_bpb:
istruc BPB
    at BPB.OEM_ID,                db "Verb0.05"
    at BPB.Bytes_Per_Sector,      dw 0x0200
    at BPB.Sectors_Per_Cluster,   db 0x01
    at BPB.Reserved_Sectors,      dw 19
    at BPB.FATs,                  db 0x02
    at BPB.Root_Entries,          dw 0x00E0
    at BPB.Sectors_Short,         dw 0x0B40
    at BPB.Media_Descriptor,      db 0xf0      ; set at assembly time
    at BPB.Sectors_Per_FAT_Short, dw 9
    at BPB.Sectors_Per_Cylinder,  dw 0x0012
    at BPB.Heads,                 dw 0x02
    at BPB.Hidden_Sectors,        dd 0x00000000
    at BPB.Sectors_Long,          dd 0x00000000
    at BPB.Sectors_Per_FAT_Long,  dd 0x00000000
    at BPB.Extension_Flags,       dw 0x0000
    at BPB.Drive_Number,          db 0x00
    at BPB.Current_Head,          db 0x00
    at BPB.BPB_Signature,         db 0x28 
    at BPB.Serial_Number,         dd 0x000001
    at BPB.Disk_Label,            db "Verbum Boot"    ;;;must be exactly 11 characters
    at BPB.File_System,            db "FAT12   "       ;;;must be exactly 8 characters
iend
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;redirect - do a far jump to ensure that you have the desired 
;;;  segment:offset location set in CS and IP
redirect:
  jmp boot_base:start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; start
;;; This is the real begining of the code. The first order of
;;; business is clearing the interrupts, then setting the
;;; segment registers and the stack pointer.  

start:
        mov ax, stack_segment
        cli                     ;  ints out of an abundance of caution
        mov ss, ax              ; set to match the code segment
        mov sp, stack_top       ; put the stack pointer to the top of SS
        sti                     ; reset ints so BIOS calls can be used
        mov bp, sp
        mov ax, cs
        mov ds, ax              ; set DS == CS
        mov es, ax              ; set ES == CS
        ; save boot drive info for later use
        push dx

;;; reset the disk drive
        write resetting_drive
        call near reset_disk
        write done
        
;;; read in the first sector of the FAT from disk
;;; and load it after the boot code. the DL register
;;; should still have the correct drive value.
        write reading_fat
        mov bx, loaded_fat
        mov al, 1
        mov cl, fat_start
        mov ch, 0
        mov dh, 0
        ;;  make sure we have the right disk information
        pop dx
        push dx       
        call near read_disk
        
;;; get the location of the next stage of the boot loader
;;; and read a fixed number of consecutive sectors at
;;; a location
        mov ax, [loaded_fat + fat_entry.cluster_lobits]
        zero(dx)
        mov cx, [boot_bpb + BPB.Sectors_Per_Cylinder]
        div cx

        ;;  get adjusted sector number into CX
        mov cx, ax
        
        
        ;; sanity check - is the loaded value valid?
        call print_hex
        mov al, dl
        call print_hex
        write done

        ;; load the located sector after the end of the loaded
        ;; FAT - while we could probably overwrite the FAT sector,
        ;; there is no reason not to preserve it.
        write loading
        mov al, stage2_size
        ;;  make sure we have the right disk information
        mov dx, [bp - 2]
        add bx, 0x200
        call near read_disk       
        write done
        
;;; pass a pointer to 'spin' loop
;;; and the printstr routine
;;; and jump to loaded second stage

        mov al, bh
        ;; sanity check - is the loaded value valid?
        write stg2_jump
        call print_hex
        mov al, bl
        call print_hex     

        push halted
        push printstr
        jmp bx

;;;  backstop - it shouldn't actully print this message
        write oops
        
halted:
        hlt
        jmp short halted
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Auxilliary functions      

;;;;printstr - prints the string point to by SI

printstr:
        push ax
        push bx
        push cx
        mov ah, ttype        ; set function to 'teletype mode'
        zero(bx)
        mov cx, 1
    .print_char:
        lodsb               ; update byte to print
        cmp al, NULL        ; test that it isn't NULL
        jz short .endstr
        int  VBIOS          ; put character in AL at next cursor position
        jmp short .print_char
    .endstr:
        pop cx
        pop bx
        pop ax
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
        write reset_failed
        write exit
        jmp halted
  .reset_end:
        ret

;;; read_disk
read_disk:
        push ax
        mov si, 0
        mov di, tries        ; set count of attempts for disk reads
        mov ah, disk_read
  .try_read:
        int DBIOS
        jnc short .read_end
        dec di
        jnz .try_read
        ; if repeated attempts to read the disk fail, report error code
        write read_failed
        write exit
        jmp halted
        
  .read_end:
        pop ax
        ret

print_hex:
;;;  al = byte to print
        push ax
        push bx
        push cx
        push dx
        
        mov cx, 2
        mov ah, al              ; have a copy of the byte in each half reg
        and ah, 0x0f            ; isolate low nibble in AH
        shr al, 4               ; isolate high nibble into low nibble in AL
  .nibble_loop:
        cmp al, 9
        jg .alphanum
	add al, 0x30
        jmp short .store_char
  .alphanum:
        add al, (0x41 - 0xA)    ; NASM will compute imm. value
  
  .store_char:
        ror ax, 8               ; fast move AH -> AL
        loop .nibble_loop

        ;; AL == high numeral, AH == low numeral
        mov dl, ah 
        mov ah, ttype           ; set function to 'teletype mode'
        zero(bx)
        mov cx, 1
        int VBIOS
        mov al, dl
        int VBIOS

        pop dx
        pop cx
        pop bx
        pop ax
        ret
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  data
;;;  [section .data]
     
;;; [section .rodata]
        
resetting_drive db 'Reset drive...', NULL
reading_fat     db 'Get 2nd stage...', NULL
seperator       db ':', NULL  
loading         db 'Load second stage...', NULL
done            db ' done.', CR, LF, NULL
stg2_jump       db 'Jumping to ', NULL
        
reset_failed    db 'Could not reset,', NULL
read_failed     db 'Could not read,', NULL
exit            db ' boot loader halted.', NULL
oops            db 'Oops. ', NULL 

        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; pad out to 510, and then add the last two bytes needed for a boot disk
space     times (0x0200 - 2) - ($-$$) db 0
bootsig   dw 0xAA55
