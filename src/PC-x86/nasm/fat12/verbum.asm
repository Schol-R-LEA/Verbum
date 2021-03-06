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
%include "fat_entry.inc"
%include "stage2_parameters.inc"
%include "macros.inc"


;;; local macros 
%macro write 1
        mov si, %1
        call near print_str
%endmacro

;;; constants
boot_base        equ 0x0000      ; the segment base:offset pair for the
boot_offset      equ 0x7C00      ; boot code entrypoint

;; ensure that there is no segment overlap
stack_segment    equ 0x1000  
stack_top        equ 0xFFFE

;;;operational constants 

high_nibble_mask equ 0x0FFF
mid_nibble_mask  equ 0xFF0F
nibble_shift     equ 4

        
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
%include "fat-12-data.inc"

   
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
;        mov cx, fat_buffer
;        mov [bp + stg2_parameters.drive], dx
;        mov [bp + stg2_parameters.fat_0], cx
;        mov [bp + stg2_parameters.PnP_Entry_Seg], bx ; BX == old ES value
;        mov [bp + stg2_parameters.PnP_Entry_Off], di
        ;; pointers to aux routines inside the boot loader
;        mov [bp + stg2_parameters.reset_drive], word reset_disk
;        mov [bp + stg2_parameters.read_LBA_sector], word read_LBA_sector
;        mov [bp + stg2_parameters.print_str], word print_str
;        mov [bp + stg2_parameters.halt_loop], word halted

;;; reset the disk drive
        call near reset_disk

;;; read the first FAT into memory
        mov cx, Sectors_Per_FAT_Short     
        mov ax, 0
        add ax, Reserved_Sectors          ; get location of the first FAT sector
        mov bx, fat_buffer
    .fat_loop:
        call near read_LBA_sector
        add bx, Bytes_Per_Sector
        loop .fat_loop

;;; read the root directory into memory
        mov cx, dir_sectors
        mov bx, dir_buffer
        mov ax, dir_start_sector
    .dir_loop:
        push cx
        call near read_LBA_sector
;;;;; test code
        cmp cx, word dir_sectors
        jl .dir_print_done
        push bx
        push ax
        mov cx, (dir_entry_size)
    .dir_entry_print:
        mov ax, [bx]
        call print_hex_byte
        inc bx
        mov ax, [bx]
        call print_hex_byte
        write space_char
        inc bx
        loop .dir_entry_print
        pop ax
        pop bx
.dir_print_done:
;;;;; test code ends
        add bx, Bytes_Per_Sector
        pop cx
        loop .dir_loop


;;; seek the directory for the stage 2 file
        mov bx, dir_buffer
        mov cx, Root_Entries
    .entry_test:
        mov di, bx
        mov si, snd_stage_file
        push cx
        mov cx, 11
        repe cmpsb              ; is the directory entry == the stg2 file?
        je .entry_found
        add bx, dir_entry_size
        pop cx
        loop .entry_test
        
    .entry_found:
;;;;; test code
;        write snd_stage_file
;        write space_char
;        write Found
;        mov ax, bx
;        call print_hex_word
;        write nl
;;;;; test code ends
        push bp
        mov bp, bx
        ;; position of first sector
        mov ax, [bp + directory_entry.file_size]
        mov dx, [bp + directory_entry.file_size + 1]
        mov cx, Bytes_Per_Sector
        div cx                  ; AX = number of sectors - 1
        inc ax                  ; round up
;;;;; test code
;        push ax
;        mov ax, bx
;        sub ax, dir_buffer
;        call print_hex_word
;        pop ax
;;;;; test code ends        
        mov cx, ax
        ;; get the position for the first FAT entry
        mov bx, [bp + directory_entry.cluster_lobits]

;;;;; test code
        push ax
        mov ax, bx      
        call print_hex_word
        pop ax
;;;;; test code ends
        
    .read_first_sector:
        mov ax, [bx]            ; get the two bytes of the FAT entry
        ;; if odd(BX), drop the top nibble of the high byte
        and bx, 1
        jnz .even
        and ax, high_nibble_mask
        jmp .odd
        ;; else drop the bottom nibble of the low byte  
    .even:
        shr ax, nibble_shift
        ;; find the sector based on the FAT entry   
    .odd:
;;;;; test code
;        push ax
;        call print_hex_word
;        pop ax
;;;;; test code ends
        
        mov bx, stage2_buffer
    ; requires all sectors of the stage 2 to be consecutive
    .get_sectors:
        call near read_LBA_sector
        loop .get_sectors

    .stg2_read_finished:
        pop bp                  ; restore bp

 ;;; jump to loaded second stage
        jmp stage2_buffer
        jmp short halted        ; in case of failure
 
    .no_file:
        write failure_state
        write read_failed
        jmp short halted


;;;  backstop - it shouldn't ever actually print this message
;;        write oops
        
halted:
        hlt
        jmp short halted
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Auxilliary functions      
%include "simple_text_print_code.inc"
%include "print_hex_code.inc"
%include "simple_disk_handling_code.inc"


        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  data
;;[section .data]
     
;;[section .rodata]

snd_stage_file  db 'STAGE2  SYS', NULL

; reading_fat     db 'Get sector...', NULL
;loading         db 'Load stage 2...', NULL
;separator       db ':', NULL
;comma_done      db ', '
;done            db 'done.',
;nl               db CR, LF, NULL
failure_state   db 'Unable to ', NULL
;reset_failed    db 'reset,', NULL
read_failed     db 'read,'
exit            db ' halted.', NULL
;oops            db 'Oops.', NULL 
space_char      db ' ', NULL
;Found           db 'Found at sector ', NULL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; pad out to 510, and then add the last two bytes needed for a boot disk
space     times (0x0200 - 2) - ($-$$) db 0
bootsig   dw 0xAA55
