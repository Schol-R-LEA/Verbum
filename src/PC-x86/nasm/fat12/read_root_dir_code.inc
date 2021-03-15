;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; routine for finding a directory entry

%ifndef READ_ROOT_DIR_CODE__INC
%define READ_ROOT_DIR_CODE__INC

%include "bios.inc"
%include "macros.inc"
%include "bpb.inc"
%include "dir_entry.inc"
%include "stage2_parameters.inc"

%include "simple_disk_handling_code.inc"

;;; read_root_directory
;;; Inputs:
;;;       DI - buffer to read the entry to
;;; Outputs:
;;;       directory buffer
read_root_directory:
;;; read the root directory into memory
        pusha
        mov ax, dir_start_sector
        mov bl, dir_sectors
        call near read_LBA_sectors
        popa
        ret
        
%endif
