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
at GDT_ENTRY.limit_low,       dw 0xffff
at GDT_ENTRY.base_low,        dw 0
at GDT_ENTRY.base_mid,        db 0
at GDT_ENTRY.access,          db Seg_Present | Seg_Kernel | Seg_Desc_c_d | Seg_Conforming | Seg_Code | Seg_Readable
at GDT_ENTRY.limit_and_flags, db 0x0c
at GDT_ENTRY.base_high,       db 0
iend

gdt_system_data:
istruc GDT_ENTRY
at GDT_ENTRY.limit_low,       dw 0xffff
at GDT_ENTRY.base_low,        dw 0
at GDT_ENTRY.base_mid,        db 0
at GDT_ENTRY.access,          db Seg_Present | Seg_Kernel | Seg_Desc_c_d | Seg_Conforming | Seg_Data | Seg_Writeable
at GDT_ENTRY.limit_and_flags, db 0x0c
at GDT_ENTRY.base_high,       db 0
iend

gdt_user_code:
istruc GDT_ENTRY
at GDT_ENTRY.limit_low,       dw 0xffff
at GDT_ENTRY.base_low,        dw 0
at GDT_ENTRY.base_mid,        db 0
at GDT_ENTRY.access,          db Seg_Present | Seg_User | Seg_Desc_c_d | Seg_Conforming | Seg_Code | Seg_Readable
at GDT_ENTRY.limit_and_flags, db 0x0c
at GDT_ENTRY.base_high,       db 0
iend

gdt_user_data:
istruc GDT_ENTRY
at GDT_ENTRY.limit_low,       dw 0xffff
at GDT_ENTRY.base_low,        dw 0
at GDT_ENTRY.base_mid,        db 0
at GDT_ENTRY.access,          db Seg_Present | Seg_User | Seg_Desc_c_d | Seg_Conforming | Seg_Data | Seg_Writeable
at GDT_ENTRY.limit_and_flags, db 0x0c 
at GDT_ENTRY.base_high,       db 0
iend


%endif
