;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; routine for finding a directory entry

%ifndef READ_FAT_CODE__INC
%define READ_FAT_CODE__INC

bits 16

%include "bios.inc"
%include "macros.inc"
%include "bpb.inc"
%include "dir_entry.inc"
%include "stage2_parameters.inc"


;;; read_fat - read the first FAT into memory
;;; Inputs:
;;;       AX - location of first FAT
;;;       BX - buffer to read it into
;;; Outputs:
;;;
;;; Clobbers:
;;;       CX
read_fat:
        mov cx, Sectors_Per_FAT_Short
    .fat_loop:
        call near read_LBA_sector
        add bx, Bytes_Per_Sector
        loop .fat_loop
        ret
%endif
