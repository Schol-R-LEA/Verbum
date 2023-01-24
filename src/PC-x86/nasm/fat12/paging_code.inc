%ifndef _PAGING_CODE__INC__
%define _PAGING_CODE__INC__

%line 0, "paging.asm"
bits 32

page_directory           equ 0x0040000
page_table_0             equ page_directory    + 0x1000
page_table_0x0300        equ page_table_0      + 0x1000



init_page_directory:
        mov ebx, dword page_directory
        memset32 0, 0x0400, ebx                ; clear the page dir table

        populate_pte 0, 0, page_table_0
        populate_pte 0, 0x100000, page_table_0x0300

    .setup_directory:
        mov ebx, page_directory
    .pd_fill:
        mov eax, page_table_0
        or eax, PDE_Present
        mov [ebx], eax
        add ebx, 0x0300 * 4
        mov eax, page_table_0x0300
        or eax, PDE_Present
        mov [ebx], eax


        ; set the page directory
        mov eax, page_directory
        mov cr3, eax
        ret


%endif