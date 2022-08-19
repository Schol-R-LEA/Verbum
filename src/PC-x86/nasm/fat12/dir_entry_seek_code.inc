;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; routine for finding a directory entry

%ifndef DIRECTORY_ENTRY_SEEK_CODE__INC
%define DIRECTORY_ENTRY_SEEK_CODE__INC

bits 16

%include "bios.inc"
%include "macros.inc"
%include "bpb.inc"
%include "dir_entry.inc"
%include "stage2_parameters.inc"

;;; seek_directory_entry - seek the directory for the given filename
;;; Inputs:
;;;       SI - address of the filename to match against
;;;       ES:DI - directory buffer
;;;       CX - max. number of entries
;;;       BX - size of an entry
;;; Outputs:
;;;       DI - location of the entry
seek_directory_entry:
    .dir_entry_test:
        push di
        push si
        push cx
        mov cx, filename_length
    repe cmpsb                  ; does the directory entry match?
        pop cx
        pop si
        pop di
        je .entry_found
        add di, bx
        loop .dir_entry_test
        mov di, 0x0000          ; if not found, return 0
    .entry_found:
        ret


;;; read_directory_details -
;;; Inputs:
;;;       ES:DI - directory entry
;;; Outputs:
;;;       BX - First FAT entry of the file
read_directory_details:
        ;; position of first sector
        mov bx, es:[di + directory_entry.cluster_lobits]
       ret

%endif
