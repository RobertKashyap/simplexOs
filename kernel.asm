[BITS 64]
[ORG 0X200000]
; sample kernel to test loading in long mode
start:
    mov rdi,Idt
    mov rax,handler0

    mov [rdi],ax
    shr rax,16
    mov [rdi+6],ax
    shr rax,16
    mov [rdi+8],eax

    lgdt [Gdt64Ptr]
    lidt [IdtPtr]

    push 8
    push KernelEntry
    db 0x48
    retf

KernelEntry:
    mov byte[0xb8000], 'K'
    mov byte[0xb8001], 0xa

    xor rbx,rbx; trigger divide by zero
    div rbx

End:
    hlt
    jmp End

handler0:; divide by zero handler
    mov byte[0xb8000], 'D'
    mov byte[0xb8001], 0xc

    jmp End
    iretq
Gdt64:
    dq 0
    dq 0x0020980000000000

Gdt64Len: equ $-Gdt64

Gdt64Ptr: dw Gdt64Len-1
          dq Gdt64

Idt:
    %rep 256
        dw 0
        dw 0x8
        db 0
        db 0x8e
        dw 0
        dd 0
        dd 0
    %endrep

IdtLen: equ $-Idt
IdtPtr: dw IdtLen-1
        dq Idt