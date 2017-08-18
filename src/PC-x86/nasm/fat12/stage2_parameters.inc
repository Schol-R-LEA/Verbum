struc stg2_parameters
        .drive           resb 2  ;; include a padding byte for stack alignment
        .p_bpb           resw 1
        .p_fat_sect_1    resw 1
        .p_reset_drive   resw 1  
        .p_read_drive    resw 1
        .p_print_str     resw 1
        .p_halt_loop     resw 1      
endstruc