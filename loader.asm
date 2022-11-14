[BITS 16];real mode 16 bits
[ORG 0x7e00];we start at 0x7e00

start:
    mov [DriveId],dl;save drive id temporarily

    mov eax,0x80000000
    cpuid
    cmp eax,0x80000001
    jb NotSupport

    mov eax, 0x80000001;get extended cpuid info
    cpuid
    test edx, (1<<29);check if the cpu supports long mode
    jz NotSupport
    test edx, (1<<26);check 1GB pages
    jz NotSupport

    mov ah, 0x13 ;string printing mode
    mov al, 1 ;print one character at a time from end of cursor
    mov bx, 0xa ;set the color to green and page to 0
    xor dx, dx ;clear the dx register to 0 hence rows and columns are 0
    mov bp, Message ;set the bp register to the address of the message
    mov cx, MessageLen ;set the cx register to the length of the message
    int 0x10 ;call the interrupt function 0x10 to print the message

NotSupport:
End:
    hlt
    jmp End

DriveId: db 0
Message: db "Long mode is supported" ;loader prompt
MessageLen: equ $-Message ;calculate the length of the message