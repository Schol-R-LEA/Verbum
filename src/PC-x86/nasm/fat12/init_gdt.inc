%ifndef INIT_GDT__INC
%define INIT_GDT__INC

; Each define here is for a specific flag in the descriptor.
; Refer to the intel documentation for a description of what each one does.
%define SEG_DESCTYPE(x)  ((x) << 0x04) ;; Descriptor type (0 for system, 1 for code/data)
%define SEG_PRES(x)      ((x) << 0x07) ;; Present
%define SEG_SAVL(x)      ((x) << 0x0C) ;; Available for system use
%define SEG_LONG(x)      ((x) << 0x0D) ;; Long mode
%define SEG_SIZE(x)      ((x) << 0x0E) ;; Size (0 for 16-bit, 1 for 32)
%define SEG_GRAN(x)      ((x) << 0x0F) ;; Granularity (0 for 1B - 1MB, 1 for 4KB - 4GB)
%define SEG_PRIV(x)     (((x) &  0x03) << 0x05)   ;; Set privilege level (0 - 3)
 
%define SEG_DATA_RD        0x00 ;; Read-Only
%define SEG_DATA_RDA       0x01 ;; Read-Only, accessed
%define SEG_DATA_RDWR      0x02 ;; Read/Write
%define SEG_DATA_RDWRA     0x03 ;; Read/Write, accessed
%define SEG_DATA_RDEXPD    0x04 ;; Read-Only, expand-down
%define SEG_DATA_RDEXPDA   0x05 ;; Read-Only, expand-down, accessed
%define SEG_DATA_RDWREXPD  0x06 ;; Read/Write, expand-down
%define SEG_DATA_RDWREXPDA 0x07 ;; Read/Write, expand-down, accessed
%define SEG_CODE_EX        0x08 ;; Execute-Only
%define SEG_CODE_EXA       0x09 ;; Execute-Only, accessed
%define SEG_CODE_EXRD      0x0A ;; Execute/Read
%define SEG_CODE_EXRDA     0x0B ;; Execute/Read, accessed
%define SEG_CODE_EXC       0x0C ;; Execute-Only, conforming
%define SEG_CODE_EXCA      0x0D ;; Execute-Only, conforming, accessed
%define SEG_CODE_EXRDC     0x0E ;; Execute/Read, conforming
%define SEG_CODE_EXRDCA    0x0F ;; Execute/Read, conforming, accessed
 
%define GDT_CODE_PL0 SEG_DESCTYPE(1) | SEG_PRES(1) | SEG_SAVL(0) | \
                     SEG_LONG(0)     | SEG_SIZE(1) | SEG_GRAN(1) | \
                     SEG_PRIV(0)     | SEG_CODE_EXRD
 
%define GDT_DATA_PL0 SEG_DESCTYPE(1) | SEG_PRES(1) | SEG_SAVL(0) | \
                     SEG_LONG(0)     | SEG_SIZE(1) | SEG_GRAN(1) | \
                     SEG_PRIV(0)     | SEG_DATA_RDWR
 
%define GDT_CODE_PL3 SEG_DESCTYPE(1) | SEG_PRES(1) | SEG_SAVL(0) | \
                     SEG_LONG(0)     | SEG_SIZE(1) | SEG_GRAN(1) | \
                     SEG_PRIV(3)     | SEG_CODE_EXRD
 
%define GDT_DATA_PL3 SEG_DESCTYPE(1) | SEG_PRES(1) | SEG_SAVL(0) | \
                     SEG_LONG(0)     | SEG_SIZE(1) | SEG_GRAN(1) | \
                     SEG_PRIV(3)     | SEG_DATA_RDWR


struc GDT_R
    .limit               resw 1 
    .base                resd 1
endstruc          

struc GDT_ENTRY
    .limit_low           resw 1
    .base_low            resw 1
    .base_mid            resb 1
    .access              resb 1
    .limit_high          resb 1
    .flags               resb 1
    .base_high           resw 1
endstruc


gdtr:
istruc GDT_R
at GDT_R.limit,          dw 0
at GDT_R.base,           dd 0
iend

gdt:
gdt_null:                dq 0

gdt_system_code:
istruc GDT_ENTRY
at GDT_ENTRY.limit_low,  dw 0xffff
at GDT_ENTRY.base_low,   dw 0
at GDT_ENTRY.base_mid,   db 0
at GDT_ENTRY.access,     db 0
at GDT_ENTRY.limit_high, db 0xff
at GDT_ENTRY.flags,      db SEG_DESCTYPE(1) | SEG_PRES(1) | SEG_SAVL(0) | \
                            SEG_LONG(0) | SEG_SIZE(1) | SEG_GRAN(1) | \
                            SEG_PRIV(0) | SEG_CODE_EXRD
at GDT_ENTRY.base_high,  dw 0
iend

gdt_system_data:
istruc GDT_ENTRY
at GDT_ENTRY.limit_low,  dw 0xffff
at GDT_ENTRY.base_low,   dw 0
at GDT_ENTRY.base_mid,   db 0
at GDT_ENTRY.access,     db 0
at GDT_ENTRY.limit_high, db 0xff
at GDT_ENTRY.flags,      db SEG_DESCTYPE(1) | SEG_PRES(1) | SEG_SAVL(0) | \
                            SEG_LONG(0)     | SEG_SIZE(1) | SEG_GRAN(1) | \
                            SEG_PRIV(0)     | SEG_DATA_RDWR
at GDT_ENTRY.base_high,  dw 0
iend

gdt_user_code:
istruc GDT_ENTRY
at GDT_ENTRY.limit_low,  dw 0xffff
at GDT_ENTRY.base_low,   dw 0
at GDT_ENTRY.base_mid,   db 0
at GDT_ENTRY.access,     db 0
at GDT_ENTRY.limit_high, db 0xef
at GDT_ENTRY.flags,      db SEG_DESCTYPE(1) | SEG_PRES(1) | SEG_SAVL(0) | \
                            SEG_LONG(0)     | SEG_SIZE(1) | SEG_GRAN(1) | \
                            SEG_PRIV(3)     | SEG_CODE_EXRD
at GDT_ENTRY.base_high,  dw 0
iend

gdt_user_data:
istruc GDT_ENTRY
at GDT_ENTRY.limit_low,  dw 0xffff
at GDT_ENTRY.base_low,   dw 0
at GDT_ENTRY.base_mid,   db 0
at GDT_ENTRY.access,     db 0
at GDT_ENTRY.limit_high, db 0xef
at GDT_ENTRY.flags,      db SEG_DESCTYPE(1) | SEG_PRES(1) | SEG_SAVL(0) | \
                            SEG_LONG(0)     | SEG_SIZE(1) | SEG_GRAN(1) | \
                            SEG_PRIV(3)     | SEG_DATA_RDWR
at GDT_ENTRY.base_high,  dw 0
iend


%endif
