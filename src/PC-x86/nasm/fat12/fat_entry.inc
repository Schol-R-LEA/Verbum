;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FAT directory entry - required by FAT filesystems.
;;; Header defining a NASM structure describing the FAT filesystem
;;; directory entries. It has been separated to allow it to be
;;; used separately from the boot sector code.

        
struc fat_entry
        .filename       resb 8
        .extension      resb 3
        .attribs        resb 1
        .nt_reserved    resb 1
        .time_created   resw 1
        .date_created   resw 1
        .date_accessed  resw 1
        .cluster_hibits resw 1
        .time_modified  resw 1
        .date_modified  resw 1
        .cluster_lobits resw 1
        .file_size      resd 1
endstruc