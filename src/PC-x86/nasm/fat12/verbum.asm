;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Verbum boot loader for FAT12
;;;* sets the segments for use in the boot process.
;;;* loads and verifies the boot image from the second sector, 
;;;   then transfers control  to it.
;;;
;;;Version History (note: build versions not shown) 
;;;pre      - June 2002 to February 2004 - early test versions
;;;               * sets segments, loads image from second sector          
;;;v 0.01 - 28 February 2004 Joseph Osako 
;;;              * Code base cleaned up
;;;              * Added BPB data for future FAT12 support
;;;              * renamed "Verbum Boot Loader"
;;;v0.02 - 8 May 2004 Joseph Osako
;;;              *  moved existing disk handling into separate functions
;;;v0.03 - 7 Sept 2006 Joseph Osako
;;;              * resumed work on project. Placed source files under
;;;                version control (SVN)
;;;v0.04 - 18 April 2016 - restarting project, set up on Github
;;;v0.05 - 16 August 2017 - restructuring project, working on FAT12
;;;              support and better documentation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; data structure definitions
%include "bpb.inc"
%include "fat_entry.inc"

        
struc disk_parameters
        .drive resb 1
        .cylinder resb 1
        .head resb 1
        .sector resb 1
endstruc

   
;;; constants

boot_base       equ 0x07C0      ;; the segment base:offset pair for the
boot_offset     equ 0x0000      ;; boot code entrypoint

stack_segment   equ boot_base - 0x0200        
stack_top       equ 0xFFFC

fat_start       equ 2
fat_size        equ 0x0009      ;; number of sectors per FAT
reserved_size   equ 1 + (2 * fat_size)   
disk_type       equ 0xF0        ;; default - 3.5" 1.44M

stage2_size     equ 1
loaded_fat      equ boot_offset + 0x0100
        
VBIOS           equ 0x10        ;; BIOS interrupt vector for video services
GOTO_XY         equ 0x02        ;; VBIOS routine - go to the given x, y coordinates
block_write     equ 0x09        ;; VBIOS routine - write a fixed number of times to the screen
ttype           equ 0x0E        ;; VBIOS routine - print character, teletype mode

DBIOS           equ 0x13        ;; BIOS interrupt vector for disk services
disk_reset      equ 0x00        ;; disk reset service
disk_read       equ 0x02        ;; disk read service

        
;;;BIOS error codes
reset_failure   equ 0x01        ;; error code returned on disk reset failure
read_failure    equ 0x02        ;; error code returned on disk read failure

;;;operational constants 
tries           equ 0x03        ;; number of times to attempt to access the FDD

;;; character constants
NULL            equ 0x00        ;; end of string marker
CR              equ 0x0D        ;; carriage return
LF              equ 0x0A        ;; line feed 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; macros
;
%define zero(x) xor x, x

%macro write 1
        mov si, %1
        call near printstr
%endmacro
        
        
[bits 16]
[org boot_offset]
[section text]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; entry - the entrypoint to the code. Make a short jump past the BPB.
entry:
        jmp short redirect
        nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FAT12 Boot Parameter Block - required by FAT12 filesystem

boot_bpb:
istruc BPB
    at BPB.OEM_ID,                db "Verb0.05"
    at BPB.Bytes_Per_Sector,      dw 0x0200
    at BPB.Sectors_Per_Cluster,   db 0x01
    at BPB.Reserved_Sectors,      dw 19
    at BPB.FATs,                  db 0x02
    at BPB.Root_Entries,          dw 0x00E0
    at BPB.Sectors_Short,         dw 0x0B40
    at BPB.Media_Descriptor,      db 0xf0      ; set at assembly time
    at BPB.Sectors_Per_FAT_Short, dw 9
    at BPB.Sectors_Per_Cylinder,  dw 0x0012
    at BPB.Heads,                 dw 0x02
    at BPB.Hidden_Sectors,        dd 0x00000000
    at BPB.Sectors_Long,          dd 0x00000000
    at BPB.Sectors_Per_FAT_Long,  dd 0x00000000
    at BPB.Extension_Flags,       dw 0x0000
    at BPB.Drive_Number,          db 0x00
    at BPB.Current_Head,          db 0x00
    at BPB.BPB_Signature,         db 0x28 
    at BPB.Serial_Number,         dd 0x000001
    at BPB.Disk_Label,            db "Verbum Boot"    ;;;must be exactly 11 characters
    at BPB.File_System,            db "FAT12   "       ;;;must be exactly 8 characters
iend
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;redirect - do a far jump to ensure that you have the desired 
;;;  segment:offset location set in CS and IP
redirect:
  jmp boot_base:start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; start
;;; This is the real begining of the code. The first order of
;;; business is clearing the interrupts, then setting the
;;; segment registers and the stack pointer.  

start:
        mov ax, stack_segment
        cli                     ;  ints out of an abundance of caution
        mov ss, ax              ; set to match the code segment
        mov sp, stack_top       ; put the stack pointer to the top of SS
        sti                     ; reset ints so BIOS calls can be used
        mov ax, cs
        mov ds, ax              ; set DS == CS
        mov es, ax              ; set ES == CS
        ; save boot drive info for later use
        push dx

;;; reset the disk drive
        call reset_disk
        cmp ax, reset_failure
        jg short fail_shutdown
        
;;; read in the first sector of the FAT from disk
;;; and load it after the boot code. the DL register
;;; should still have the correct drive value.
        write loading
        mov bx, loaded_fat
        mov ah, disk_read
        mov al, 1
        mov cl, fat_start
        mov ch, 0
        mov dh, 0
        call read_disk
        
        cmp si, read_failure
        jg short fail_shutdown

;;; get the location of the next stage of the boot loader
;;; and read a fixed number of consecutive sectors at
;;; a location 
        mov cl, byte [loaded_fat + fat_entry.cluster_lobits]
        ;;         mov
        
        
fail_shutdown:
        write read_failed
        write exit
halted:
        hlt
        jmp short halted
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Auxilliary functions      

;;;;printstr - prints the string point to by SI

printstr:
        mov ah, ttype        ;;;set function to 'teletype mode'
    .print_char:
        lodsb               ;;;update byte to print
        cmp al, NULL        ;;;test that it isn't NULL
        jz short .endstr
        int  VBIOS          ;;;put character in AL at next cursor position
        jmp short .print_char
    .endstr:
        ret

;;;reset_disk
reset_disk:
        mov ah, disk_reset
        int DBIOS
        ret

;;; read_disk
read_disk:
        mov si, 0
        mov di, tries        ;;; set count of attempts for disk reads
  .try_read: 
        int DBIOS
        jnc short .end
        dec di
        jnz .try_read
        ;;; if repeated attempts to read the disk fail, report error code
        mov si, read_failure
  .end:    
        ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; data
        
        ;; [section data]
loading         db 'Loading... ', NULL
done            db 'done.', CR, LF, NULL
read_failed     db 'Could not read OS,', NULL
exit            db ' system halted.', NULL

        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; pad out to 510, and then add the last two bytes needed for a boot disk
space     times (0x0200 - 2) - ($-$$) db 0
bootsig   dw 0xAA55
