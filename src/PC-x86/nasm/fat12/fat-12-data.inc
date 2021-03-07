%ifndef FAT12_DATA__INC
%define FAT12_DATA__INC

%include "bpb.inc"
%include "fat-12.inc"

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
