%ifndef HIGH_MEM_MAP__INC
%define HIGH_MEM_MAP__INC


struc High_Mem_Map
    .base   resq 1
    .length resq 1
    .type   resd 1
    .ext    resd 1
endstruc

mmap_size         equ 20
ext_mmap_size     equ High_Mem_Map_size

SMAP_Text         equ 0x0534D4150
mem_map_buffer_size          equ 16 * ext_mmap_size

%endif