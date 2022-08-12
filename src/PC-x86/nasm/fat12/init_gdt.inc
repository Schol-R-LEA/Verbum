%ifndef INIT_GDT__INC
%define INIT_GDT__INC

%include "gdt.inc"

system_code_selector equ (gdt_system_code - gdt)
system_data_selector equ (gdt_system_data - gdt)

setGdt_rm:
   XOR   EAX, EAX
   MOV   AX, DS
   SHL   EAX, 4

   ADD   EAX, gdt
   MOV   [gdtr + 2], eax
   MOV   EAX, gdt_end
   SUB   EAX, gdt
   MOV   [gdtr], AX
   LGDT  [gdtr]
   RET

align 8

gdtr:
istruc GDT_R
at GDT_R.limit,          dw gdt
at GDT_R.base,           dd (GDT_ENTRY_size * 32)
iend


gdt:
gdt_null:                dq 0

gdt_system_code:
istruc GDT_ENTRY
at GDT_ENTRY.limit_low,       dw 0xffff
at GDT_ENTRY.base_low,        dw 0
at GDT_ENTRY.base_mid,        db 0
at GDT_ENTRY.access,          db Seg_Present | Seg_Kernel | Seg_Desc_Gen | Seg_Code | Seg_Conforming | Seg_Readable
at GDT_ENTRY.limit_and_flags, db 0xfc
at GDT_ENTRY.base_high,       db 0
iend

gdt_system_data:
istruc GDT_ENTRY
at GDT_ENTRY.limit_low,       dw 0xffff
at GDT_ENTRY.base_low,        dw 0
at GDT_ENTRY.base_mid,        db 0
at GDT_ENTRY.access,          db Seg_Present | Seg_Kernel | Seg_Desc_Gen | Seg_Data | Seg_Conforming | Seg_Writeable
at GDT_ENTRY.limit_and_flags, db 0xfc
at GDT_ENTRY.base_high,       db 0
iend

gdt_system_tss:
istruc GDT_ENTRY
at GDT_ENTRY.limit_low,       dw TSS_size
at GDT_ENTRY.base_low,        dw default_tss
at GDT_ENTRY.base_mid,        db 0
at GDT_ENTRY.access,          db Seg_Present | Seg_Kernel | Seg_Desc_System | Seg_Sys_TSS32_Available
at GDT_ENTRY.limit_and_flags, db 0xfc
at GDT_ENTRY.base_high,       db 0
iend

gdt_user0_code:
istruc GDT_ENTRY
at GDT_ENTRY.limit_low,       dw 0xffff
at GDT_ENTRY.base_low,        dw 0
at GDT_ENTRY.base_mid,        db 0
at GDT_ENTRY.access,          db Seg_Present | Seg_User | Seg_Desc_Gen | Seg_Code | Seg_Conforming | Seg_Readable
at GDT_ENTRY.limit_and_flags, db 0x8c
at GDT_ENTRY.base_high,       db 0
iend

gdt_user0_data:
istruc GDT_ENTRY
at GDT_ENTRY.limit_low,       dw 0xffff
at GDT_ENTRY.base_low,        dw 0
at GDT_ENTRY.base_mid,        db 0
at GDT_ENTRY.access,          db Seg_Present | Seg_User | Seg_Desc_Gen | Seg_Data | Seg_Conforming | Seg_Writeable
at GDT_ENTRY.limit_and_flags, db 0x8c
at GDT_ENTRY.base_high,       db 0
iend

; space for additional GDT entries
gdt_Array                     resq 26 ; for a total of 32 entries
gdt_end:


%endif
