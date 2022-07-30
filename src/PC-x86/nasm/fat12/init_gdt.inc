%ifndef INIT_GDT__INC
%define INIT_GDT__INC

%include "gdt.inc"


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
