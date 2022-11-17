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

    ;triggering timer exception
    mov rax,Timer
    add rdi,32*16
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

InitPIT:; programming the timer
    mov al,(1<<2)|(3<<4)
    out 0x43,al

    mov ax,11931
    out 0x40,al
    mov al,ah
    out 0x40,al

InitPIC:; programming the counter to sync to timer
    mov al,0x11
    out 0x20,al
    out 0xa0,al

    mov al,32
    out 0x21,al
    mov al,40
    out 0xa1,al

    mov al,4
    out 0x21,al
    mov al,2
    out 0xa1,al

    mov al,1
    out 0x21,al
    out 0xa1,al

    mov al,11111110b
    out 0x21,al
    mov al,11111111b
    out 0xa1,al

    ;sti

    push 0x18|3
    push 0x7c00
    push 0x2
    push 0x10|3
    push UserEntry
    iretq

End:
    hlt
    jmp End

UserEntry: ; ring 3 jump
    mov ax,cs
    and al,11b
    cmp al,3
    jne UEnd

    mov byte[0xb8010], 'U'
    mov byte[0xb8011], 0xE

UEnd:
    jmp UEnd


handler0:; divide by zero handler
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push rbp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15

    mov byte[0xb8000], 'D'
    mov byte[0xb8001], 0xc

    jmp End

    pop	r15
    pop	r14
    pop	r13
    pop	r12
    pop	r11
    pop	r10
    pop	r9
    pop	r8
    pop	rbp
    pop	rdi
    pop	rsi
    pop	rdx
    pop	rcx
    pop	rbx
    pop	rax

    iretq

Timer:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push rbp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15

    mov byte[0xb8010], 'T'
    mov byte[0xb8011], 0xe

    jmp End

    pop	r15
    pop	r14
    pop	r13
    pop	r12
    pop	r11
    pop	r10
    pop	r9
    pop	r8
    pop	rbp
    pop	rdi
    pop	rsi
    pop	rdx
    pop	rcx
    pop	rbx
    pop	rax
Gdt64:
    dq 0
    dq 0x0020980000000000
    dq 0x0020f80000000000
    dq 0x0000f20000000000

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