%line 0
%ifndef INIT_TSS__INC
%define INIT_TSS__INC

align 8

default_tss:
istruc TSS
at TSS.link,       dq 0
at TSS.esp0_reg,   dq 0
at TSS.ss0_reg,    dq 0
at TSS.esp1_reg,   dq 0
at TSS.ss1_reg,    dq 0
at TSS.esp2_reg,   dq 0
at TSS.ss2_reg,    dq 0
at TSS.eip_reg,    dq 0
at TSS.eflags_reg, dq 0
at TSS.eax_reg,    dq 0
at TSS.ecx_reg,    dq 0
at TSS.edx_reg,    dq 0
at TSS.ebx_reg,    dq 0
at TSS.esp_reg,    dq 0
at TSS.ebp_reg,    dq 0
at TSS.esi_reg,    dq 0
at TSS.edi_reg,    dq 0
at TSS.es_reg,     dq 0
at TSS.cs_reg,     dq 0
at TSS.ss_reg,     dq 0
at TSS.ds_reg,     dq 0
at TSS.fs_reg,     dq 0
at TSS.gs_reg,     dq 0
at TSS.ldtr_reg,   dq 0
at TSS.iopb,       dq 0
at TSS.ssp,        dq 0
iend


%endif