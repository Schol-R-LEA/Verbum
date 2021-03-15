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
%include "bpb.inc"
%include "dir_entry.inc"
%include "fat-12.inc"
%include "stage2_parameters.inc"
%include "macros.inc"

;;; constants

;; ensure that there is no segment overlap
stack_segment    equ 0x1000  
stack_top        equ 0xFFFE

;;;operational constants

bits 16
org boot_offset
section .text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; entry - the entrypoint to the code. Make a short jump past the BPB.
entry:
        jmp short redirect
        nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FAT12 Boot Parameter Block - required by FAT12 filesystem

boot_bpb:
%include "fat-12-data.inc"

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
        mov [bp + stg2_parameters.PnP_Entry_Seg], bx ; BX == old ES value
        mov [bp + stg2_parameters.PnP_Entry_Off], di
        mov [bp + stg2_parameters.boot_sig], word bootsig

;;; reset the disk drive
        call near reset_disk
        cmp ax, 0xFFFF
        jne .read_fat_sectors
        write failure_state
        write reset_failed
        jmp halted
        
    .read_fat_sectors:
        mov ax, fat_start_sector          ; get location of the first FAT sector
        mov di, fat_buffer
        call read_fat
;        cmp ax, 0xFFFF
;        jne .read_root_directory
;        jmp halted

    .read_root_directory:
         mov di, dir_buffer
         call near read_root_directory
        cmp ax, 0xFFFF
        jne .read_root_directory
        jmp no_file

        mov si, snd_stage_file
        mov di, dir_buffer
        mov cx, Root_Entries
        mov bx, dir_entry_size
        call near seek_directory_entry
        cmp di, 0
        je no_file
        call read_directory_details

        mov ax, bx
        mov si, fat_buffer
        mov di, stage2_buffer
        call near fat_to_file

    .stg2_read_finished:

 ;;; jump to loaded second stage
 
        jmp stage2_buffer
        write oops
        jmp short halted        ; in case of failure
        
no_file:
        write failure_state
        write read_failed
        jmp short halted

;;;  
halted:
        write exit
    .halted_loop:
        hlt
        jmp short .halted_loop
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Auxilliary functions      
%include "simple_text_print_code.inc"
;%include "print_hex_code.inc"
%include "simple_disk_handling_code.inc"
%include "read_fat_code.inc"
%include "read_root_dir_code.inc"
%include "dir_entry_seek_code.inc"
%include "fat_to_file_code.inc"
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  data
;;[section .data]
     
;;[section .rodata]

snd_stage_file  db 'STAGETWOSYS', NULL

; reading_fat     db 'Get sector...', NULL
;loading         db 'Load stage 2...', NULL
;separator       db ':', NULL
;comma_done      db ', '
;done            db 'done.',
;nl              db CR, LF, NULL
failure_state   db 'Cannot ', NULL
reset_failed    db 'reset,', NULL
read_failed     db 'read,', NULL
;seek_failed     db 'find.', NULL
exit            db ' exit', NULL
oops            db 'Oops.', NULL 
;space_char      db ' ', NULL
;Found           db 'Found at sector ', NULL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; pad out to 510, and then add the last two bytes needed for a boot disk
space     times (0x0200 - 2) - ($-$$) db 0
bootsig   dw 0xAA55
