;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; routines for loading a file from a FAT entry chain

%ifndef FAT_TO_FILE_CODE__INC
%define FAT_TO_FILE_CODE__INC

bits 16

%include "bios.inc"
%include "macros.inc"
%include "bpb.inc"
%include "dir_entry.inc"
%include "stage2_parameters.inc"
%include "simple_disk_handling_code.inc"

hi_nibble_mask        equ 0x0FFF
lo_nibble_shift       equ 4
end_of_chain_mask     equ 0x0FF8
    

;;; fat_to_file - read a chain of FAT entries to
;;;               get the file sectors it maps to
;;;               and read those sectors into a buffer
;;; Inputs:
;;;       BX - starting FAT entry
;;;       DI - FAT buffer
;;;       SI - buffer to read the entry to
;;; Outputs:
;;;       buffer to read file into
fat_to_file:
    .read_loop:
        mov ax, bx
        sub ax, 2
        add ax, first_data_sector
        push bx
        mov bx, si
        call read_LBA_sector
        pop bx
        call extract_next_fat12_entry
        mov bx, ax
        add si, Bytes_Per_Sector
        cmp ax, end_of_chain_mask
        jb .read_loop

    .end_of_file:
        ret

;;; extract_next_fat12_entry - read a FAT entry to
;;;               see where the next FAT entry is,
;;;               if any
;;; Inputs:
;;;       DI - FAT entry buffer 
;;;       BX - current FAT entry's value
;;; Outputs:
;;;       AX - next FAT entry's value
extract_next_fat12_entry:
;; address_of_FAT_entry = fat_buffer + (current_cluster + current_cluster / 2)
        mov ax, bx              ; BX == current cluster
        shr ax, 1               ; current_cluster / 2
        add ax, bx              ; (current_cluster + current_cluster / 2) == FAT entry offset
        push di
        add di, ax              ; index fat buffer by offset
        mov ax, [di]            ; get the indexed entry
        pop di
        test bx, 1              ; check if the existing entry is odd
        jz .even
    .odd:
        shr ax, lo_nibble_shift ; extract the high bits
        ret
    .even:
        and ax, hi_nibble_mask  ; extract the low bits
        ret

%endif
