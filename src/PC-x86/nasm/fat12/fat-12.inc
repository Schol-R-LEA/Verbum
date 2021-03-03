%include "bpb.inc"

fat_head        equ 0
fat_track       equ 0
fat_sector      equ 2           ; first sector of the first FAT
dir_head        equ 1
dir_track       equ 0
dir_sector      equ 2           ; head 1, track 0, sector 2
stage2_head     equ 1
stage2_track    equ 0
stage2_sector   equ 0x10
stage2_size     equ 1

fat_buffer      equ boot_offset + 0x0200
dir_entry_size  equ 0x20        ; 32 bytes per entry
dir_buffer      equ fat_buffer + (Sectors_Per_FAT_Short * 0x200)
stage2_buffer   equ 0x7E00

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
