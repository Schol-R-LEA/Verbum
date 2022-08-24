;;;;;;;;;;;;;;;;;
;; stagetwo.asm - second stage boot loader
;; 
;; v 0.01  Alice Osako 3 June 2002
;; v 0.02  Alice Osako 7 Sept 2006
;;         * restarted project, files place under source control.
;;         * Modifications for FAT12 based loader begun.
;;;Version History (note: build versions not shown) 
;;;pre      - June 2002 to February 2004 - early test versions
;;;               * sets segments, loads image from second sector          
;;;v 0.01 - 28 February 2004 Alice Osako 
;;;              * Code base cleaned up
;;;              * Added BPB data for future FAT12 support
;;;              * renamed "Verbum Boot Loader"
;;;v0.02 - 8 May 2004 Alice Osako
;;;              *  moved existing disk handling into separate functions
;;;v0.03 - 7 Sept 2006 Alice Osako
;;;              * resumed work on project. Placed source files under
;;;                version control (SVN)
;;;v0.04 - 18 April 2016 - restarting project, set up on Github
;;;v0.05 - 16 August 2017 - restructuring project, working on FAT12
;;;              support and better documentation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%include "bios.inc"
%include "consts.inc"
%include "macros.inc"
%include "fat-12.inc"
%include "stage2_parameters.inc"
%include "hi_mem_map.inc"
%include "gdt.inc"
%include "tss.inc"
%include "elf.inc"
%include "paging.inc"



stage2_base        equ 0x0000            ; the segment:offset to load 
stage2_offset      equ stage2_buffer     ; the second stage into

kernel_base        equ 0xffff

kdata_offset       equ 0xfffc

struc KData
    .mmap_cnt      resd 1
    .mmap          resd High_Mem_Map_size
    .drive         resd 1
    .fat           resd fat_size
endstruc

kcode_offset       equ 0x0000
kernel_raw_base    equ 0x1000
kernel_raw_offset  equ 0x0000


Protection         equ 1
Paging             equ 0x80000000

Kernel_linear_addr equ 0xc0000000


bits 16
org stage2_offset
section .text

entry:
        write success
        mov ax, stage2_base
        mov gs, ax
        mov ax, stage2_offset
        call print_hex_seg_offset
        write newline

A20_enable:
        write A20_gate_status
        lea di, [bp - stg2_parameters.boot_sig]
        call test_A20
        je .A20_on

    .A20_off:
        write off

    .A20_bios_attempt:
;;; parts of this code based on examples given in the 
;;; A20 page of the OSDev wiki (https://wiki.osdev.org/A20_Line)
        write A20_gate_trying_bios
        mov ax, A20_supported
        int A20BIOS
        jb .a20_no_bios_support
        cmp ah, 0
        jnz .a20_no_bios_support
 
        mov ax, A20_status
        int A20BIOS
        jb .a20_no_bios_support     ; couldn't get status
        cmp ah, 0
        jnz .a20_no_bios_support    ; couldn't get status
 
        cmp al, 1
        jz .A20_on                   ; A20 is already activated
 
        mov ax, A20_activate
        int A20BIOS
        jb .a20_no_bios_support     ; couldn't activate the gate
        cmp ah, 0
        jz .A20_on                   ; couldn't activate the gate

    .a20_no_bios_support:
        call test_A20
        je .A20_on

    .a20_failed:
        write no_A20_Gate
        jmp halted

    .A20_on:
        write on


;; Attempt to get the full physical memory map for the system
;; this should be done before the move to protected mode
get_mem_maps:
        ; get the low memory map
        write low_mem
        int LMBIOS
        mov si, print_buffer
        call print_decimal_word
        write kbytes
        ; get the high memory map
        push es
        push si
        push di
        push bp
        mov ax, kernel_base
        mov es, ax
        mov di, (kdata_offset - KData.mmap - mem_map_buffer_size)
        mov si, (kdata_offset - KData.mmap_cnt)
        call get_hi_memory_map
        mov di, (kdata_offset - KData.mmap - mem_map_buffer_size)
        mov bp, es:[kdata_offset - KData.mmap_cnt]
        call print_hi_mem_map
        pop bp
        pop di
        pop si
        pop es

load_kernel_data:
        mov dx, word [bp - stg2_parameters.drive]
        mov [kdata_offset - KData.drive], edx
        lea ax, [kdata_offset - KData.fat - fat_size]
        memcopy_rm ax, [bp - stg2_parameters.fat_0], fat_size

        write newline

load_kernel_code:
        push ax
        push es
        mov si, kernel_filename
        mov di, word [bp - stg2_parameters.directory_buffer]
        mov cx, Root_Entries
        mov bx, dir_entry_size
        call near seek_directory_entry
        cmp di, word 0
        jnz .read_directory

        write no_kernel
        jmp local_halt_loop

    .read_directory:
        call read_directory_details
        write kernel_file_found

        ; reset the disk drive

        call near reset_disk

        mov di, word [bp - stg2_parameters.fat_0]
        mov ax, kernel_raw_base
        mov es, ax
        mov si, kernel_raw_offset
        call near fat_to_file
        pop es
        pop ax
        write kernel_loaded


find_kernel_code_block:
        push gs
        mov ax, kernel_raw_base
        mov gs, ax
        mov al, byte gs:[kernel_raw_offset + ELF32_Header.magic]
        cmp al, byte ELF_Magic
        je .test_signature
        write invalid_elf_magic
        jmp local_halt_loop

    .test_signature:
        mov cx, 3
        mov di, kernel_raw_offset + ELF32_Header.sig
        push es
        mov ax, kernel_raw_base
        mov es, ax
        mov si, ELF_Sig
    repe cmpsb
        pop es
        je .test_elf_endianness
        write invalid_elf_sig
        jmp local_halt_loop

    .test_elf_endianness:
        mov al, byte gs:[kernel_raw_offset + ELF32_Header.endianness]
        cmp al, ELF_little_endian
        je .test_elf_isa
        write elf_big_endian
        jmp local_halt_loop

    .test_elf_isa:
        mov al, byte gs:[kernel_raw_offset + ELF32_Header.isa]
        cmp al, ELF_ISA_x86
        je .test_elf_executable
        write elf_not_x86
        jmp local_halt_loop

    .test_elf_executable:
        mov ax, word gs:[kernel_raw_offset + ELF32_Header.type]
        cmp ax, ELF_type_executable
        je .read_elf_header_table
        write non_executable_elf_file
        jmp local_halt_loop

    .read_elf_header_table:
        write valid_elf_file
        ; set up an offset for the code sections in memory
        mov [section_offset_buffer], word kcode_offset
        mov cx, gs:[kernel_raw_offset + ELF32_Header.program_table_entry_count]

        write number_of_sections
        mov ax, cx
        call print_decimal_word
        write newline

        ; bx = pointer to the first program header
        mov bx, gs:[kernel_raw_offset + ELF32_Header.program_header_table]
        add bx, kernel_raw_offset                  ; bx = pointer to the first program header
    .program_header_loop:
        ; check to see if the section is loadable
        mov ax, gs:[bx + ELF32_Program_Header.p_type]
        cmp ax, ELF_Header_loadable_type
        jne .loop_continue                         ; not a loadable section, skip

        ; found a loadable section
        ; first, clear the region of memory to load to
        push es
        mov ax, kernel_base
        mov es, ax                                 ; set es to the segment to later map to higher half
        mov dx, gs:[bx + ELF32_Program_Header.p_memsz]
        push bx
        memset_rm 0, bx, dx
        pop bx

        ; move the code section of the file to the kernel code memory area
        ; keep ES set to the destination segment
        push ds                                    ; temporarily set DS = GS so the macro works on the right segments
        mov ax, gs
        mov ds, ax
        memcopy_rm [section_offset_buffer], [bx + ELF32_Program_Header.p_offset], [bx + ELF32_Program_Header.p_filesz]
        pop ds
        pop es

    .loop_continue:
        ; advance the pointer through the header array
        add bx, ELF32_Program_Header_size
        add [section_offset_buffer], dx            ; dx = total size to allocate to the kernel code memory area
        loop .program_header_loop
        pop gs


load_GDT:
       cli
       call setGdt_rm


       ; switch to 32-bit protected mode
promote_pm:
        mov eax, cr0
        or eax, Protection       ; set PE (Protection Enable) bit in CR0 (Control Register 0)
        mov cr0, eax


        ; Perform far jump to selector 08h (offset into GDT, pointing at a 32bit PM code segment descriptor) 
        ; to load CS with proper PM32 descriptor)
        jmp system_code_selector:PModeMain


%line 0 pmode.asm
bits 32
PModeMain:
        ; set the segment selectors
        mov ax, system_data_selector
        mov ds, ax
        mov ss, ax
        mov es, ax
        mov fs, ax
        mov gs, ax
        mov esp, 0x00090000

        call init_page_directory

        mov eax, cr0
        or eax, Paging           ; set Paging bit in CR0 (Control Register 0)
        mov cr0, eax
        mov esp, 0xc03ffffc

        ; write 'Kernel started' to text buffer
        write32 kernel_start, 7

        jmp Kernel_linear_addr

;;; halt the CPU
halted:
    .halted_loop:
        hlt
        jmp short .halted_loop


bits 16
local_halt_loop:
        hlt
        jmp short local_halt_loop


%line 0 aux.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Auxilliary functions
%include "simple_text_print_code.inc"
%include "print_hex_code.inc"
%include "print_hex_long_code.inc"
%include "print_decimal_code.inc"
%include "simple_disk_handling_code.inc"
%include "read_fat_code.inc"
%include "read_root_dir_code.inc"
%include "dir_entry_seek_code.inc"
%include "fat_to_file_code.inc"
%include "a20_code.inc"
%include "high_mem_map_code.inc"
%include "print32_code.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;
;; data
;;         [section .data]
kernel_filename              db "KERNEL  SYS", NULL
null                         dd 00000000
lparen                       db '(', NULL
rparen                       db ')', NULL
print_buffer                 resb 32
newline                      db CR, LF, NULL
exit                         db 'System Halted.', CR, LF, NULL
success                      db 'Control successfully transferred to second stage at ', NULL
A20_gate_status              db 'A20 Line Status: ', NULL
on                           db 'on.', CR, LF, NULL
off                          db 'off.', CR, LF, NULL
A20_gate_trying_bios         db 'Attempting to activate A20 line with BIOS... ', NULL
no_A20_Gate                  db 'A20 gate not found.', CR, LF, NULL
mmap_failed                  db 'Could not retrieve memory map.', NULL
low_mem                      db 'Low memory total: ', NULL
kbytes                       db ' KiB', CR, LF, NULL
kernel_start                 db 'Kernel Started', NULL
no_kernel                    db 'KERNEL.SYS not found.', NULL

kernel_file_found            db 'KERNEL.SYS found...', NULL
kernel_loaded                db 'loaded.', CR, LF, NULL


ELF_Sig                      db "ELF", NULL

elf_buffer                   db 0, 0, 0, 0

invalid_elf_magic            db "Invalid ELF header: bad magic", NULL
invalid_elf_sig              db "Invalid ELF header: bad signature", NULL

elf_big_endian               db 'ELF file not little-endian.', NULL

elf_not_x86                  db 'ELF file not for x86 ISA.', NULL

non_executable_elf_file      db 'ELF file not executable.', NULL


valid_elf_file               db 'Valid x86 ELF32 executable file.', CR, LF, NULL

number_of_sections           db 'Number of sections: ', NULL

section_offset_buffer        dw kcode_offset               ; initialize to the start of the code area


%include "init_gdt.inc"
%include "init_tss.inc"
;%include "init_idt.inc"
%include "paging_code.inc"