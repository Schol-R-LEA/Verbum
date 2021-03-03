;;; file containing the binary structure of a 'model FAT'
;;; which the disk formatting utility can insert into the
;;; boot sector of a disk.
        
;;; 12 Mar 2018 - working on creating a static FAT12
;;;               for a 1.44M 3 1/2" disk.

%include "fat_entry.inc"

istruc directory_entry
        at .filename,        db 8
        at .extension,       db 3
        at .attribs,         db 1
        at .nt_reserved,     db 1
        at .decisec_created, db 1
        at .time_created,    dw 1
        at .date_created,    dw 1
        at .date_accessed,   dw 1
        at .cluster_hibits,  dw 1
        at .time_modified,   dw 1
        at .date_modified,   dw 1
        at .cluster_lobits,  dw 1
        at .file_size,       dd 1
iend
