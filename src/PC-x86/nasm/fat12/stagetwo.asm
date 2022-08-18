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
%include "gdt.inc"
%include "tss.inc"
%include "hi_mem_map.inc"

stage2_base       equ 0x0000            ; the segment:offset to load 
stage2_offset     equ stage2_buffer     ; the second stage into

kernel_base       equ 0xffff

kdata_offset      equ 0xfffc
struc KData
    .mmap_cnt     resd 1
    .mmap         resd High_Mem_Map_size
    .drive        resd 1
    .fat          resd fat_size


endstruc

kcode_offset      equ 0x1000


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
        zero(edx)
        mov dl, byte [bp - stg2_parameters.drive]
        mov [kdata_offset - KData.drive], edx


load_kernel_code:




load_GDT:
       cli
       call setGdt_rm


       ; switch to 32-bit protected mode
promote_pm:
        mov eax, cr0
        or al, 1       ; set PE (Protection Enable) bit in CR0 (Control Register 0)
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

        call clear_screen

        ; write 'Kernel started' to text buffer
        write32 kernel_start, 7

;;; halt the CPU
halted:
    .halted_loop:
        hlt
        jmp short .halted_loop


bits 16

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





%include "init_gdt.inc"
%include "init_tss.inc"
;%include "init_idt.inc"

