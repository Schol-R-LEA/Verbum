%ifndef FAT12_DATA__INC
%define FAT12_DATA__INC

%include "bpb.inc"

fat_size                  equ Sectors_Per_FAT_Short * Bytes_Per_Sector
fats_reserved_sectors     equ Reserved_Sectors + (FATs * Sectors_Per_FAT_Short)
fat_buffer                equ boot_offset + Bytes_Per_Sector
dir_start_sector          equ fats_reserved_sectors
dir_entry_size            equ 0x20        ; 32 bytes per entry
dir_size                  equ dir_entry_size * Root_Entries
dir_sectors               equ dir_size / Bytes_Per_Sector
dir_buffer                equ fat_buffer + fat_size
filename_length           equ 11
stage2_buffer             equ dir_buffer + dir_size
first_data_sector         equ fats_reserved_sectors + dir_sectors


Bytes_Per_Sector          equ 0x0200
Sectors_Per_Cluster       equ 0x01
Reserved_Sectors          equ 0x01
FATs                      equ 0x02
Root_Entries              equ 0x00e0
Sectors_Short             equ 0x0b40
Media_Descriptor          equ 0xf0
Sectors_Per_FAT_Short     equ 9
Sectors_Per_Cylinder      equ 0x0012
Heads                     equ 0x0002
Hidden_Sectors            equ 0x00000000
Sectors_Long              equ 0x00000000
Drive_Number              equ 0x00
Extension_Flags           equ 0x00
Signature                 equ 0x29
Serial_Number             equ 0x000001


istruc BPB
    at BPB.OEM_ID,                    db "VERBUM05"
    at BPB.Bytes_Per_Sector,          dw Bytes_Per_Sector
    at BPB.Sectors_Per_Cluster,       db Sectors_Per_Cluster
    at BPB.Reserved_Sectors,          dw Reserved_Sectors
    at BPB.FATs,                      db FATs
    at BPB.Root_Entries,              dw Root_Entries
    at BPB.Sectors_Short,             dw Sectors_Short
    at BPB.Media_Descriptor,          db Media_Descriptor
    at BPB.Sectors_Per_FAT_Short,     dw Sectors_Per_FAT_Short
    at BPB.Sectors_Per_Cylinder,      dw Sectors_Per_Cylinder
    at BPB.Heads,                     dw Heads
    at BPB.Hidden_Sectors,            dd Hidden_Sectors
    at BPB.Sectors_Long,              dd Sectors_Long
iend
        
disk_info:
istruc Disk_Details
    at Disk_Details.Drive_Number,     db Drive_Number
    at Disk_Details.Extension_Flags,  db Extension_Flags
    at Disk_Details.Signature,        db Signature
    at Disk_Details.Serial_Number,    dd 0x000001
    at Disk_Details.Disk_Label,       db "VERBUM-0.5 "    ; must be exactly 11 characters
    at Disk_Details.File_System,      db "FAT12   "       ; must be exactly 8 characters
iend

%endif
