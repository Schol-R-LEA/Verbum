%ifndef _PAGING_CODE__INC__
%define _PAGING_CODE__INC__

%include "paging.inc"

%line 0, "paging.asm"
bits 32

page_directory           equ 0x0040000
page_table_0x0000        equ page_directory    + 0x1000
page_table_0x0300        equ page_table_0x0000 + 0x1000
page_table_0x0301        equ page_table_0x0300 + 0x1000
page_table_0x0302        equ page_table_0x0301 + 0x1000
page_table_0x0303        equ page_table_0x0302 + 0x1000
page_table_0x0304        equ page_table_0x0303 + 0x1000
page_table_0x0305        equ page_table_0x0304 + 0x1000


init_page_directory:
        mov ebx, dword page_directory
        memset32 0, 0x1000, ebx              ; clear the page dir table

        populate_pte page_table_0x0000, 0x0100, 0x00000000, PTE_Present
        populate_pte page_table_0x0300, 0x1000, 0x00100000, PTE_Present
        populate_pte page_table_0x0301, 0x1000, 0x00400000, PTE_Present
        populate_pte page_table_0x0302, 0x1000, 0x00800000, PTE_Present
        populate_pte page_table_0x0303, 0x1000, 0x00C00000, PTE_Present
        populate_pte page_table_0x0304, 0x1000, 0x01000000, PTE_Present
        populate_pte page_table_0x0305, 0x1000, 0x01400000, PTE_Present


    .setup_directory:
        populate_pde page_table_0x0000, 0x0000, PDE_Present
        populate_pde page_table_0x0300, 0x0300, PDE_Present
        populate_pde page_table_0x0301, 0x0301, PDE_Present
        populate_pde page_table_0x0302, 0x0302, PDE_Present
        populate_pde page_table_0x0303, 0x0303, PDE_Present
        populate_pde page_table_0x0304, 0x0304, PDE_Present
        populate_pde page_table_0x0305, 0x0305, PDE_Present

        ; set the page directory
        mov eax, page_directory
        mov cr3, eax
        ret


%endif