%ifndef GDT__INC
%define GDT__INC

;; parts of this code were taken from https://wiki.osdev.org/GDT_Tutorial
;; and modified for NASM

struc GDT_R
    .limit               resw 1 
    .base                resd 1
endstruc          

struc GDT_ENTRY
    .limit_low           resw 1
    .base_low            resw 1
    .base_mid            resb 1
    .access              resb 1
    .limit_and_flags     resb 1
    .base_high           resb 1
endstruc


;; Each define here is for a specific flag in the descriptor.
;; Refer to the intel documentation for a description of what each one does.
%define Seg_Present       0x80       ; Present  
%define Seg_Kernel        0x00       ; DPL 0
%define Seg_User          0x60       ; DPL 3
%define Seg_Desc_System   0x00       ; System Segment
%define Seg_Desc_c_d      0x10       ; non-system segment
%define Seg_Code          0x08       ; code segment
%define Seg_Data          0x00       ; data segment
%define Seg_Conforming    0x00       ; grows up
%define Seg_Non_Conf      0x04       ; grows down
%define Seg_Non_Readable  0x00       ; non-readable code segment
%define Seg_Readable      0x02
%define Seg_Non_Writeable 0x00       ; non-writable data segment
%define Seg_Writeable     0x02
%endif
