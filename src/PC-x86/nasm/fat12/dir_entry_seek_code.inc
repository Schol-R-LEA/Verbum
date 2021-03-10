;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; routine for finding a directory entry

%ifndef DIRECTORY_ENTRY_SEEK_CODE__INC
%define DIRECTORY_ENTRY_SEEK_CODE__INC

%include "bios.inc"
%include "macros.inc"
%include "bpb.inc"
%include "dir_entry.inc"
%include "stage2_parameters.inc"

;;; seek_directory_entry - seek the directory for the stage 2 file
;;; Inputs:
;;;       SI - address of the filename to match against
;;;       DI - directory buffer
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
        repe cmpsb              ; does the directory entry match?
        pop cx
        pop si
        pop di
        je .entry_found
        add di, bx
        loop .dir_entry_test
        mov di, 0x0000          ; if not found, return 0
        ret
    .entry_found:
        ret


;;; read_directory_details - 
;;; Inputs:
;;;       DI - directory entry
;;; Outputs:
;;;       AX - low bytes of the file size
;;;       DX - high bytes of the file size
;;;       BX - First FAT entry of the file
read_directory_details:
        push cx
        ;; position of first sector
        mov bx, [di + directory_entry.cluster_lobits]
;        mov ax, [di + directory_entry.file_size]
;        mov dx, [di + directory_entry.file_size + 1]
;        mov cx, Bytes_Per_Sector
;        div cx
;        mov ax, [di + directory_entry.file_size]
;        cmp dx, word 0
;        jz .no_remainder
;        inc ax                  ; if there is a remainder, round up
;    .no_remainder:
        pop cx
       ret

%endif
