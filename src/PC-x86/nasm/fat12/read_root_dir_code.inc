;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; routine for finding a directory entry

%ifndef READ_ROOT_DIR_CODE__INC
%define READ_ROOT_DIR_CODE__INC

bits 16

%include "bios.inc"
%include "macros.inc"
%include "bpb.inc"
%include "dir_entry.inc"
%include "stage2_parameters.inc"

%include "simple_disk_handling_code.inc"

;;; read_root_directory
;;; Inputs:
;;;       AX - sector to begin reading at
;;;       BX - buffer to read the entry to
;;; Outputs:
;;;       directory buffer
read_root_directory:
;;; read the root directory into memory
        pusha
        mov cx, dir_sectors
        mov ax, dir_start_sector
    .dir_loop:
        push cx
        call near read_LBA_sector
        add bx, Bytes_Per_Sector
        pop cx
        loop .dir_loop
        popa
        ret
        
%endif
