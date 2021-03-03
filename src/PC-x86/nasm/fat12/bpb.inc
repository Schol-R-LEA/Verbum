;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FAT Boot Parameter Block - required by FAT filesystems.
;;; Header file defining a NASM structure describing the FAT filesystem
;;; BIOS Parameter Block. It has been separated to allow it to be
;;; used separately from the boot sector code.

struc BPB
       .OEM_ID                 resb 8    ;;; must be exactly 8 characters  
      .Bytes_Per_Sector        resb 2
      .Sectors_Per_Cluster     resb 1
      .Reserved_Sectors        resb 2
      .FATs                    resb 1
      .Root_Entries            resb 2
      .Sectors_Short           resb 2
      .Media_Descriptor        resb 1
      .Sectors_Per_FAT_Short   resb 2
      .Sectors_Per_Cylinder    resb 2
      .Heads                   resb 2
      .Hidden_Sectors          resb 4
      .Sectors_Long            resb 4
endstruc


struc Disk_Details
      .Drive_Number            resb 1
      .Extension_Flags         resb 1
      .Signature               resb 1
      .Serial_Number           resb 4
      .Disk_Label              resb 11   ;;; must be exactly 11 characters
      .File_System             resb 8    ;;; must be exactly 8 characters  
endstruc

struc EBPB_32
      ;;;extended BPB section
      .Sectors_Per_FAT_Long    resb 4
      .Extension_Flags         resb 2 
      .FAT_Version             resb 2
      .Root_Cluster            resb 4
      .FSInfo_Sector           resb 2
      .Backup_Boot_Sector      resb 2
      .Reserved                resb 12
endstruc
