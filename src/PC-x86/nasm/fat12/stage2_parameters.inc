struc stg2_parameters
        .drive           resw 1   ; include a padding byte for stack alignment
        .fat_0           resw 1
        .PnP_Entry_Seg   resw 1
        .PnP_Entry_Off   resw 1
        .reset_drive     resw 1
        .read_sectors    resw 1
        .print_str       resw 1
        .halt_loop       resw 1      
endstruc