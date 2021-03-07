%ifndef FAT12__INC
%define FAT12__INC

%include "bpb.inc"

;;; constants
boot_base                 equ 0x0000      ; the segment base:offset pair for the
boot_offset               equ 0x7C00      ; boot code entrypoint
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

%endif
