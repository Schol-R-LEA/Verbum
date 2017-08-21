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
%include "stage2_parameters.inc"
%include "macros.inc"


;;; local macros 
%macro write 1
        mov si, %1
        call near print_str
%endmacro
        
   
;;; constants
boot_base       equ 0x07C0      ;; the segment base:offset pair for the
boot_offset     equ 0x0000      ;; boot code entrypoint

stack_segment   equ boot_base - 0x0200        
stack_top       equ 0xFFFE - stg2_parameters_size

fat_start       equ 2

stage2_size     equ 1
loaded_fat      equ boot_offset + 0x0200

;;;operational constants 
tries           equ 0x03        ;; number of times to attempt to access the FDD
        
        
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
    at BPB.OEM_ID,                    db "VERBUM_5"
    at BPB.Bytes_Per_Sector,          dw 0x0200
    at BPB.Sectors_Per_Cluster,       db 0x01
    at BPB.Reserved_Sectors,          dw 0x01
    at BPB.FATs,                      db 0x02
    at BPB.Root_Entries,              dw 0x00e0
    at BPB.Sectors_Short,             dw 0x0b40
    at BPB.Media_Descriptor,          db 0xf0      ; set at assembly time
    at BPB.Sectors_Per_FAT_Short,     dw 9
    at BPB.Sectors_Per_Cylinder,      dw 0x0012
    at BPB.Heads,                     dw 0x0002
    at BPB.Hidden_Sectors,            dd 0x00000000
    at BPB.Sectors_Long,              dd 0x00000000
iend
        
disk_info:
istruc Disk_Details
    at Disk_Details.Drive_Number,     db 0x00
    at Disk_Details.Extension_Flags,  db 0x00
    at Disk_Details.Signature,        db 0x29
    at Disk_Details.Serial_Number,    dd 0x000001
    at Disk_Details.Disk_Label,       db "VERBUM-0.5 "    ; must be exactly 11 characters
    at Disk_Details.File_System,      db "FAT12   "       ; must be exactly 8 characters
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

        ;; set the remaining segment registers to match CS
        mov ax, cs
        mov ds, ax
        mov es, ax
        mov gs, ax

        ;; any other housekeeping that needs to be done at the start
        cld
        
        ;; set up a stack frame for the disk info
        ;;  and other things passed by the boot sector
        mov bp, sp

        ;; find the start of the stage 2 parameter frame
        ;;  and populated the frame

        mov ax, [boot_bpb + BPB.Sectors_Per_Fat]
        mov cx, loaded_fat
        mov bx, [bp + stg2_parameters_size]
        mov [bx - stg2_parameters.drive], byte dl
        mov [bx - stg2_parameters.bpb], word boot_bpb
        mov [bx - stg2_parameters.fat_0], cx
        ;; Compute the address of the second FAT.
        ;; we can use a bit of a trick here: since the
        ;; allowed values of the sector size as
        ;; 200, 400, 800, and 1000, we can multiply
        ;; the upper 9 bits of the size by the # of
        ;; sectors to get an offset for the second FAT.        
        mov dx, [boot_bpb + BPB.Bytes_Per_Sector]
        shl dh, 1
        mul dh
        add cx, ax
        mov [bx - stg2_parameters.fat_1], cx
        ;; mov [bx - stg2_parameters.reset_drive], word reset_disk
        ;; mov [bx - stg2_parameters.read_drive], word read_disk
        ;; mov [bx - stg2_parameters.print_str], word print_str
        ;; mov [bx - stg2_parameters.halt_loop], word halted

;;; reset the disk drive
        write resetting_drive
        call near reset_disk
        write done

        ;; magic breakpoint for BOCHS
        ;; xchg bx, bx
        
;;; read in the first sector of the FAT from disk
;;; and load it after the boot code. the DL register
;;; should still have the correct drive value.
        write reading_fat
        mov bx, loaded_fat
        ;; calculate the number of sectors for both FATs
        mov al, [boot_bpb + BPB.Sectors_Per_FAT_Short]
        mov cl, fat_start
        zero(ch)
        zero(dh)
        ;;  make sure we have the right disk information 
        call near read_disk

        ;; magic breakpoint for BOCHS
        ;; xchg bx, bx
        
;;; get the location of the next stage of the boot loader
        

        
;;; and read a fixed number of consecutive sectors at
;;; a location
        
        
        ;; sanity check - is the loaded value valid?
        call print_hex
        write separator
        mov al, dl
        call print_hex
        write comma_done

        ;; magic breakpoint for BOCHS
        ;; xchg bx, bx
              
        ;; load the located sector after the end of the loaded
        ;; FAT - while we could probably overwrite the FAT sector,
        ;; there is no reason not to preserve it. 
       write loading
        mov al, stage2_size
        ;;  make sure we have the right disk information
        mov dx, [bp - 2]
        add bx, 0x200
        call near read_sectors
        write done
        
;;; jump to loaded second stage
        write stg2_jump

        ;; sanity check - is the loaded value valid?
        mov al, bh
        call print_hex
        mov al, bl
        call print_hex     

        ;; magic breakpoint for BOCHS
        ;; xchg bx, bx
       
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
        int DBIOS
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

print_hex:
;;;  al = byte to print
        pusha
        mov ah, ttype           ; set function to 'teletype mode'
        zero(bx)
        mov cx, 1
        zero(dh)
        mov dl, al              ; have a copy of the byte in DL
        and dl, 0x0f            ; isolate low nibble in DL
        shr al, 4               ; isolate high nibble into low nibble in AL
        cmp al, 9
        jg short .alphanum_hi
	add al, ascii_zero
        jmp short .show_hi
  .alphanum_hi:
        add al, upper_numerals 
  .show_hi:
        int VBIOS
        mov al, dl
        cmp al, 9
        jg short .alphanum_lo
	add al, ascii_zero
        jmp short .show_lo
  .alphanum_lo:
        add al, upper_numerals  
  .show_lo:
        int VBIOS

        popa
        ret
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  data
;;;  [section .data]
     
;;; [section .rodata]
        
resetting_drive db 'Reset drive...', NULL
reading_fat     db 'Get sector...', NULL
loading         db 'Load 2nd stage...', NULL
stg2_jump       db 'entering OS at ', NULL
separator       db ':', NULL
comma_done      db ', '
done            db 'done.', CR, LF, NULL
failure_state   db 'Could not ', NULL
reset_failed    db 'reset,', NULL
read_failed     db 'read,'
exit            db ' boot loader halted.', NULL
oops            db 'Oops.', NULL 

        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; pad out to 510, and then add the last two bytes needed for a boot disk
space     times (0x0200 - 2) - ($-$$) db 0
bootsig   dw 0xAA55
