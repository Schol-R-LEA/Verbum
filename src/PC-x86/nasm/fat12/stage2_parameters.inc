struc stg2_parameters
        .drive           resb 2  ;; include a padding byte for stack alignment
        .bpb             resw 1
        .fat_0           resw 1
        .reserved        resw 1
        .reset_drive     resw 1  
        .read_sectors    resw 1
        .print_str       resw 1
        .halt_loop       resw 1      
endstruc
