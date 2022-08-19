%ifndef ELF__INC
%define ELF__INC

struc ELF32_Header
    .magic                     resb 1
    .sig                       resb 3
    .width                     resb 1
    .header_version            resb 1
    .abi                       resb 1
    .reserved                  resb 8
    .type                      resw 1
    .isa                       resw 1
    .version                   resd 1
    .code_entry                resd 1
    .program_header_table      resd 1
    .section_header_table      resd 1
    .flags                     resd 1
    .header_size               resw 1
    .program_table_entry_size  resw 1
    .program_table_entry_count resw 1
    .section_table_entry_size  resw 1
    .section_table_entry_count resw 1
    .section_table_index       resw 1
endstruc

struc ELF64_Header
    .magic                     resb 1
    .sig                       resb 3
    .width                     resb 1
    .header_version            resb 1
    .abi                       resb 1
    .reserved                  resb 8
    .type                      resw 1
    .isa                       resw 1
    .version                   resd 1
    .code_entry                resq 1
    .program_header_table      resq 1
    .section_header_table      resq 1
    .flags                     resd 1
    .header_size               resw 1
    .program_table_entry_size  resw 1
    .program_table_entry_count resw 1
    .section_table_entry_size  resw 1
    .section_table_entry_count resw 1
    .section_table_index       resw 1
endstruc


struc ELF32_Program_Header
    .p_type                    resd 1
    .p_offset                  resd 1
    .p_vaddr                   resd 1
    .reserved                  resd 1
    .p_filesz                  resd 1
    .p_memsz                   resd 1
    .p_flags                   resd 1
    .p_align                   resd 1
endstruc


struc ELF64_Program_Header
    .p_type                    resd 1
    .p_flags                   resd 1
    .p_offset                  resq 1
    .p_vaddr                   resq 1
    .reserved                  resq 1
    .p_filesz                  resq 1
    .p_memsz                   resq 1
    .p_align                   resq 1
endstruc


%endif