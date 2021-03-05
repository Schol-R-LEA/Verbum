;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; routine for printing integer values in hex

%ifndef SIMPLE_DISK_HANDLING_CODE__INC
%define SIMPLE_DISK_HANDLING_CODE__INC


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
;        write failure_state
;        write reset_failed
;        write exit
        jmp short halted
    .reset_end:
        ret
   

;;; read_LBA_sector - read a sector from a Linear Block Address 
;;; Inputs: 
;;;       AX = Linear Block Address to read from
;;;       ES = Segment to write result to
;;;       BX = offset to write result to
;;; Outputs:
;;;       AX = LBA+1 (i.e., the increment of previous LBA value) 
;;;       ES:BX - buffer written to

read_LBA_sector:
        pusha
        call near LBA_to_CHS
        mov ah, dh              ; temporary swap
        mov dx, [bp + stg2_parameters.drive] ; get the value for DL
        mov dh, ah
        mov al, 1
        call near read_sectors
    .read_end:                  ; read_LBA_sector
        popa
        inc ax
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
        zero(dh)
        mov bx, Sectors_Per_Cylinder
        ;; Sector =  (LBA % sectors per cyl) + 1    => in DL
        div bx
        inc dl
        mov cl, dl
        pop ax                  ; retrieve LBA value
        ;; Head = LBA / (sectors per cyl * # of heads)   => in AL
        ;; Cylinder = (LBA % (sectors per cyl * # of heads)) / sectors per cyl   
        ;;     => first part in DL, final in AL
        imul bx, Heads
        zero(dx)
        div bx
        xchg ax, dx             ; so you can divide previous result in DL
        mov dh, dl              ; put previous AL into DH
        push dx
        zero(dx)
        div bx                  ; get the final value for Cylinder
        mov ch, al
        pop dx
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
        pusha
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
;        write failure_state
;        write read_failed    ; fall-thru to 'exit', don't needs separate write
        jmp halted
        
  .read_end:
        popa
        ret

%endif
