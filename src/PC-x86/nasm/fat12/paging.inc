%ifndef _PAGING__INC__
%define _PAGING__INC__


%define PDE_Present           0b00000000000000000000000000000001
%define PDE_Read_Write        0b00000000000000000000000000000010
%define PDE_User              0b00000000000000000000000000000100
%define PDE_Write_Thru        0b00000000000000000000000000001000
%define PDE_Cache_Disable     0b00000000000000000000000000010000
%define PDE_Acccessed         0b00000000000000000000000000100000
%define PDE_Dirty             0b00000000000000000000000001000000
%define PDE_Page_Size         0b00000000000000000000000010000000
%define PDE_Global            0b00000000000000000000000100000000
%define PDE_Availability_Mask 0b00000000000000000000111000000000
%define PDE_Page_Attr_Table   0b00000000000000000001000000000000
%define PDE_Page_Index_Mask   0b11111111111111111110000000000000



%define PTE_Present           0b00000000000000000000000000000001
%define PTE_Read_Write        0b00000000000000000000000000000010
%define PTE_User              0b00000000000000000000000000000100
%define PTE_Write_Through     0b00000000000000000000000000001000
%define PTE_Cache_Disable     0b00000000000000000000000000010000
%define PTE_Acccessed         0b00000000000000000000000000100000
%define PTE_Dirty             0b00000000000000000000000001000000
%define PTE_Page_Attr_Table   0b00000000000000000000000010000000
%define PTE_Global            0b00000000000000000000000100000000
%define PTE_Availability_Mask 0b00000000000000000000111000000000
%define PTE_Page_Index_Mask   0b11111111111111111111000000000000


%macro populate_pte 3
        ; set up the page table
        mov ebx, dword %3                      ; get location to save the table entry
        memset32 0, 0x0400, ebx                ; clear the table entries
        mov ecx, dword %2                      ; number of entries to fill
        mov eax, dword %1                      ; the physical address to map
    %%pt_fill:
        mov edx, eax
        or edx, PTE_Present
        mov [ebx], dword edx
        add eax, 0x1000
        add ebx, 4
        loop %%pt_fill
%endmacro


%macro populate_pde 2
        mov ebx, page_directory
        add ebx, %1 * 4
        mov eax, %2
        or eax, PDE_Present
        mov [ebx], eax
%endmacro

%endif
