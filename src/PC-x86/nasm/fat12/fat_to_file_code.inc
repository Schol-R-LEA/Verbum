;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; routine for finding a directory entry

%ifndef FAT_TO_FILE_CODE__INC
%define FAT_TO_FILE_CODE__INC

%include "bios.inc"
%include "macros.inc"
%include "bpb.inc"
%include "fat_entry.inc"
%include "stage2_parameters.inc"
%include "simple_disk_handling_code.inc"

hi_nibble_mask   equ 0x0FFF
mid_nibble_mask  equ 0xFF0F
lo_nibble_shift  equ 4


;;; fat_to_file - read a chain of FAT entries to
;;;               get the file sectors it maps to
;;;               and read those sectors into a buffer
;;; Inputs:
;;;       AX - size of the file in sectors
;;;       BX - starting FAT entry
;;;       SI - buffer to read the entry to
;;; Outputs:
;;;       buffer to read file into
fat_to_file:
        
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
        shr ax, 1               ;  current_cluster / 2
        add ax, bx              ; (current_cluster + current_cluster / 2) == FAT entry offset
        add di, ax              ; index fat buffer by offset
        mov ax, [di]            ; get the indexed entry
        test bx, 1              ; check if the existing entry is odd
        jz .even
    .odd:
        shr ax, lo_nibble_shift ; extract the high bits
        ret
    .even:
        and ax, hi_nibble_mask  ; extract the low bits
        ret

%endif
