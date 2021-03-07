;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; macros
;

%ifndef MACROS__INC
%define MACROS__INC

%define zero(x) xor x, x


%macro write 1
   mov si, %1
   call near print_str
%endmacro


%endif
