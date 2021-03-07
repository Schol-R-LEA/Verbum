;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; routine for finding a directory entry

%ifndef DIRECTORY_ENTRY_SEEK_CODE__INC
%define DIRECTORY_ENTRY_SEEK_CODE__INC

%include "bios.inc"
%include "macros.inc"
%include "bpb.inc"
%include "fat_entry.inc"
%include "stage2_parameters.inc"

;;; seek_directory_entry - seek the directory for the stage 2 file
;;; Inputs:
;;;       SI - address of the filename to match against
;;;       directory buffer
;;;       DI - directory buffer
;;;       CX - max. number of entries
;;;       BX - size of an entry
;;; Outputs:
;;;       DI - location of the entry
seek_directory_entry:
    .dir_entry_test:
        push si
        push di
        push cx
        mov cx, filename_length
        repe cmpsb              ; does the directory entry match?
        pop cx
        pop di
        pop si
        je .entry_found
        add di, bx
        loop .dir_entry_test
        mov di, 0
    .entry_found:
        ret

%endif
