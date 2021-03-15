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

stage2_base     equ 0x0000            ; the segment:offset to load 
stage2_offset   equ stage2_buffer     ; the second stage into
                        
bits 16
org stage2_offset
section .text
        
; entry:
;        mov ax, [bp + stg2_parameters.print_str]  
;        mov si, [success]
;        call ax

entry:
        write success
        jmp halted

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Auxilliary functions      

;; printstr - prints the string point to by SI

%include "simple_text_print_code.inc"

halted:
        hlt
        jmp short halted
        
        
        
;;;;;;;;;;;;;;;;;;;;;;;;;
;; data
;;         [section .data]
        
success   db 'Control successfully transferred to second stage.', CR, LF, NULL


