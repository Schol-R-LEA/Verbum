%ifndef STAGE2_PARAMETERS__INC
%define STAGE2_PARAMETERS__INC

struc stg2_parameters
        .drive                resw 1   ; include a padding byte for stack alignment
        .fat_0                resw 1   ; offset for the FAT buffer
        .directory_buffer     resw 1
        .PnP_Entry_Seg        resw 1
        .PnP_Entry_Off        resw 1
        .boot_sig             resw 1
        .bpb                  resw 1
        .reserved             resw 9
endstruc

%endif
