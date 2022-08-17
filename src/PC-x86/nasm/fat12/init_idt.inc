%ifndef INIT_IDT__INC
%define INIT_IDT__INC

%include "idt.inc"

    istruc IDT_R
    at IDT_R.size,                dw 1
    at IDT_R.offset,              dd 1
    iend


Interrupt_Descriptor_Table:
irq_00:
    istruc IDT_Gate_Descriptor
    at IDT_Gate_Descriptor.offset_low,          dw 1
    at IDT_Gate_Descriptor.segment_selector,    dw 1
    at IDT_Gate_Descriptor.reserved,            db 1
    at IDT_Gate_Descriptor.type_and_dpl,        db 1
    at IDT_Gate_Descriptor.offset_high,         dw 1
    iend

irq_01:
    istruc IDT_Gate_Descriptor
    at IDT_Gate_Descriptor.offset_low,          dw 1
    at IDT_Gate_Descriptor.segment_selector,    dw 1
    at IDT_Gate_Descriptor.reserved,            db 1
    at IDT_Gate_Descriptor.type_and_dpl,        db 1
    at IDT_Gate_Descriptor.offset_high,         dw 1
    iend

irq_02:
    istruc IDT_Gate_Descriptor
    at IDT_Gate_Descriptor.offset_low,          dw 1
    at IDT_Gate_Descriptor.segment_selector,    dw 1
    at IDT_Gate_Descriptor.reserved,            db 1
    at IDT_Gate_Descriptor.type_and_dpl,        db 1
    at IDT_Gate_Descriptor.offset_high,         dw 1
    iend

irq_03:
    istruc IDT_Gate_Descriptor
    at IDT_Gate_Descriptor.offset_low,          dw 1
    at IDT_Gate_Descriptor.segment_selector,    dw 1
    at IDT_Gate_Descriptor.reserved,            db 1
    at IDT_Gate_Descriptor.type_and_dpl,        db 1
    at IDT_Gate_Descriptor.offset_high,         dw 1
    iend

irq_04:
    istruc IDT_Gate_Descriptor
    at IDT_Gate_Descriptor.offset_low,          dw 1
    at IDT_Gate_Descriptor.segment_selector,    dw 1
    at IDT_Gate_Descriptor.reserved,            db 1
    at IDT_Gate_Descriptor.type_and_dpl,        db 1
    at IDT_Gate_Descriptor.offset_high,         dw 1
    iend

irq_05:
    istruc IDT_Gate_Descriptor
    at IDT_Gate_Descriptor.offset_low,          dw 1
    at IDT_Gate_Descriptor.segment_selector,    dw 1
    at IDT_Gate_Descriptor.reserved,            db 1
    at IDT_Gate_Descriptor.type_and_dpl,        db 1
    at IDT_Gate_Descriptor.offset_high,         dw 1
    iend

irq_06:
    istruc IDT_Gate_Descriptor
    at IDT_Gate_Descriptor.offset_low,          dw 1
    at IDT_Gate_Descriptor.segment_selector,    dw 1
    at IDT_Gate_Descriptor.reserved,            db 1
    at IDT_Gate_Descriptor.type_and_dpl,        db 1
    at IDT_Gate_Descriptor.offset_high,         dw 1
    iend

irq_07:
    istruc IDT_Gate_Descriptor
    at IDT_Gate_Descriptor.offset_low,          dw 1
    at IDT_Gate_Descriptor.segment_selector,    dw 1
    at IDT_Gate_Descriptor.reserved,            db 1
    at IDT_Gate_Descriptor.type_and_dpl,        db 1
    at IDT_Gate_Descriptor.offset_high,         dw 1
    iend

%endif