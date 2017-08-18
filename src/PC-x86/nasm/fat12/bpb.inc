;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FAT Boot Parameter Block - required by FAT filesystems.
;;; Header file defining a NASM structure describing the FAT filesystem
;;; BIOS Parameter Block. It has been separated to allow it to be
;;; used separately from the boot sector code.

struc BPB 
      .OEM_ID                  resb 8    ;;; must be exactly 8 characters  
      .Bytes_Per_Sector        resw 1
      .Sectors_Per_Cluster     resb 1
      .Reserved_Sectors        resw 1
      .FATs                    resb 1
      .Root_Entries            resw 1
      .Sectors_Short           resw 1
      .Media_Descriptor        resb 1
      .Sectors_Per_FAT_Short   resw 1
      .Sectors_Per_Cylinder    resw 1
      .Heads                   resw 1
      .Hidden_Sectors          resd 1
      .Sectors_Long            resd 1
      .Sectors_Per_FAT_Long    resd 1
      .Extension_Flags         resw 1
      ;;;extended BPB section
      .Drive_Number            resb 1
      .Current_Head            resb 1
      .BPB_Signature           resb 1
      .Serial_Number           resd 1
      .Disk_Label              resb 11   ;;; must be exactly 11 characters
      .File_System             resb 8    ;;; must be exactly 8 characters
endstruc