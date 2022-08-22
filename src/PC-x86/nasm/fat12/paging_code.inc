%ifndef _PAGING_CODE__INC__
%define _PAGING_CODE__INC__

bits 16

align 4096
page_directory     resw 0x0400

page_table_0       resw 0x0400
page_table_768     resw 0x0400

page_table_1023    resw 0x0400

init_page_directory:
        mov bx, page_directory
        memset_rm 0, 0x0400, bx               ; clear the page dir table

        ; start by setting up the base page table
        mov bx, page_table_0                  ; get index into the base page table
        memset_rm 0, 0x0400, bx               ; clear the table entries
        ; entries 0-1024 - identity mapping the first 1 MiB of memory
        mov cx, 0x0100                        ; 256 entries * 4KiB = 1 MiB
        mov eax, PTE_Page_Index_Mask | PTE_Present
    .pt_0_fill:
        mov [bx], dword eax
        add eax, 0x1000
        add bx, 4
        loop .pt_0_fill

        ; set up the kernel code table
        mov bx, page_table_768                ; get index into the kernel code page table
        memset_rm 0, 0x0400, bx               ; clear the table entries
        ; entries 0-4096 - mapping the start of higher half
        mov cx, 0x0010                        ; 8 entries * 4KiB = 32 KiB
        mov edx, PTE_Page_Index_Mask | PTE_Present
        add edx, 0x100000
    .pt_768_fill:
        mov [bx], dword edx
        add edx, 0x1000
        add bx, 4
        loop .pt_768_fill

        ; set up the kernel stack table
        mov bx, page_table_1023               ; get index into the kernel stack page table
        memset_rm 0, 0x0400, bx               ; clear the table entries
        ; entries 0-4096 - mapping the start of higher half
        mov cx, 0x0004                        ; 4 entries * 4KiB = 16KiB
        mov edx, PTE_Page_Index_Mask | PTE_Present
        add edx, 0xffffff00
    .pt_1023_fill:
        mov [bx], dword edx
        add edx, 0x1000
        add bx, 4
        loop .pt_1023_fill


    .setup_directory:
        mov bx, page_directory
    .pd_fill:
        mov eax, page_table_0
        shl eax, 12
        or eax, PDE_Present
        mov [bx], eax
        add bx, 768 * 4
        mov eax, page_table_768
        shl eax, 12
        or eax, PDE_Present
        mov [bx], eax
        add bx, 1023 * 4
        mov eax, page_table_1023
        shl eax, 12
        or eax, PDE_Present
        mov [bx], eax


        ; set the page directory
        mov eax, page_directory
        mov cr3, eax
        ret


%endif