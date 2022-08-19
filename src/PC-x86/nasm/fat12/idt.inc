%ifndef IDT__INC
%define IDT__INC

struc IDT_R
    .size                resw 1
    .offset              resd 1
endstruc


struc IDT_Gate_Descriptor
    .offset_low          resw 1
    .segment_selector    resw 1
    .reserved            resb 1
    .type_and_dpl        resb 1
    .offset_high         resw 1
endstruc


%endif