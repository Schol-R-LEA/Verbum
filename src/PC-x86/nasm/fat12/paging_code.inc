%ifndef _PAGING_CODE__INC__
%define _PAGING_CODE__INC__

%line 0, "paging.asm"
bits 32

page_directory           equ 0x0040000
page_table_0             equ page_directory    + 0x1000
page_table_0x0300        equ page_table_0      + 0x1000
page_table_0x0301        equ page_table_0x0300 + 0x1000
page_table_0x0302        equ page_table_0x0301 + 0x1000
page_table_0x0303        equ page_table_0x0302 + 0x1000
page_table_0x0304        equ page_table_0x0303 + 0x1000
page_table_0x0305        equ page_table_0x0304 + 0x1000

init_page_directory:
        mov ebx, dword page_directory
        memset32 0, 0x0400, ebx                ; clear the page dir table

        populate_pte 0x00000000, 0x0100, page_table_0
        populate_pte 0x00100000, 0x1000, page_table_0x0300
        populate_pte 0x00400000, 0x1000, page_table_0x0301
        populate_pte 0x00800000, 0x1000, page_table_0x0302
        populate_pte 0x00C00000, 0x1000, page_table_0x0303
        populate_pte 0x01000000, 0x1000, page_table_0x0304
        populate_pte 0x01400000, 0x1000, page_table_0x0305

    .setup_directory:
        populate_pde 0, page_table_0
        populate_pde 0x0300, page_table_0x0300
        populate_pde 0x0301, page_table_0x0301
        populate_pde 0x0302, page_table_0x0302
        populate_pde 0x0303, page_table_0x0303
        populate_pde 0x0304, page_table_0x0304
        populate_pde 0x0305, page_table_0x0305

        ; set the page directory
        mov eax, page_directory
        mov cr3, eax
        ret


%endif