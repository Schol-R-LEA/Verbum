;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; routine for printing integer values in hex

%ifndef SIMPLE_DISK_HANDLING_CODE__INC
%define SIMPLE_DISK_HANDLING_CODE__INC

%include "bios.inc"
%include "macros.inc"
%include "bpb.inc"
%include "dir_entry.inc"
%include "stage2_parameters.inc"

tries            equ 0x03        ; number of times to attempt to access the FDD

;;; reset_disk - reset the floppy drive
;;; Inputs:
;;;        DL - the disk ID
reset_disk:
        mov si, 0
        mov di, tries        ; set count of attempts for disk resets
    .try_reset:
        mov ah, disk_reset
        int DBIOS
        jnc short .reset_end
        dec di
        jnz short .try_reset
        ;;; if repeated attempts to reset the disk fail, report error code
        mov ax, 0xFFFF
    .reset_end:
        ret
   

;;; read_LBA_sectors - read n sectors from a Linear Block Address 
;;; Inputs: 
;;;       AX = Linear Block Address to read from
;;;       BL = number of sectors to read
;;;       ES = Segment to write result to
;;;       DI = offset to write result to
;;; Outputs:
;;;       AX = LBA+1 (i.e., the increment of previous LBA value) 
;;;       ES:DI - buffer written to

read_LBA_sectors:
        push ax
        call near LBA_to_CHS
        mov dl, byte [bp + stg2_parameters.drive] ; get the value for DL
        mov al, bl
        mov bx, di
        call near read_sectors
        cmp ax, 0xFFFF
        je .read_failed
    .read_end:                  ; read_LBA_sector
        pop ax
        inc ax
        ret
    .read_failed:
        pop ax
        ret



;;; LBA_to_CHS - compute the cylinder, head, and sector 
;;;              from a linear block address 
;;; Inputs: 
;;;       AX = Linear Block Address         
;;; Outputs:
;;;       CH = Cylinder
;;;       DH = Head
;;;       CL = Sector (bits 0-5)
LBA_to_CHS:
        push bx
        push ax                 ; save so it can be used twice
        zero(dx)
        mov bx, Sectors_Per_Cylinder
        ;; Sector =  (LBA % sectors per cyl) + 1    => in DL
        div bx
        inc dl
        mov cl, dl
        pop ax                  ; retrieve LBA value
        
        ;; Cylinder = LBA / (sectors per cyl * # of heads)   => in AL
        imul bx, Heads
        zero(dx)
        div bx                  ; AX = Cyl #, DL = partial result for Head
        mov ch, al              ; put previous AL into CH

        ;; Head = (LBA % (sectors per cyl * # of heads)) / sectors per cyl   
        ;;     => first part in DL, final in AL
        mov ax, dx
        zero(dx)
        mov bx, Sectors_Per_Cylinder
        div bx                  ; get the final value for Head
        mov dh, al
        pop bx
        ret

;;; read_sectors -  
;;; Inputs: 
;;;       AL = # of sectors to read
;;;       DL = drive number
;;;       CH = Cylinder
;;;       DH = Head
;;;       CL = Sector (bits 0-5)
;;; Outputs:
;;;       ES:BX = segment and offset for the buffer 
;;;               to save the read sector into
read_sectors:
        push di
        mov si, 0
        mov di, tries        ; set count of attempts for disk reads
        mov ah, disk_read
  .try_read:
        push ax
        int DBIOS
        pop ax
        jnc short .read_end
        dec di
        jnz short .try_read
        ; if repeated attempts to read the disk fail, report error code
        mov ax, 0xFFFF
  .read_end:
        pop di
        ret

%endif
