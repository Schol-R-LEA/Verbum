%ifndef TSS__INC
%define TSS__INC

struc TSS
    .link       resq 1
    .esp0_reg   resq 1
    .ss0_reg    resq 1
    .esp1_reg   resq 1
    .ss1_reg    resq 1
    .esp2_reg   resq 1
    .ss2_reg    resq 1
    .eip_reg    resq 1
    .eflags_reg resq 1
    .eax_reg    resq 1
    .ecx_reg    resq 1
    .edx_reg    resq 1
    .ebx_reg    resq 1
    .esp_reg    resq 1
    .ebp_reg    resq 1
    .esi_reg    resq 1
    .edi_reg    resq 1
    .es_reg     resq 1
    .cs_reg     resq 1
    .ss_reg     resq 1
    .ds_reg     resq 1
    .fs_reg     resq 1
    .gs_reg     resq 1
    .ldtr_reg   resq 1
    .iopb       resq 1
    .ssp        resq 1
endstruc

%endif