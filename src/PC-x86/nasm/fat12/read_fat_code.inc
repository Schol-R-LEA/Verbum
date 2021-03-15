;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; routine for finding a directory entry

%ifndef READ_FAT_CODE__INC
%define READ_FAT_CODE__INC

%include "bios.inc"
%include "macros.inc"
%include "bpb.inc"
%include "dir_entry.inc"
%include "stage2_parameters.inc"


;;; read_fat - read the first FAT into memory
;;; Inputs:
;;;       AX - location of first FAT
;;;       DI - buffer to read it into
;;; Outputs:
;;;
read_fat:
        mov bl, Sectors_Per_FAT_Short
        call near read_LBA_sectors
        add di, Bytes_Per_Sector
        ret
        
%endif
