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

LoadKernel:
    mov si,ReadPacket; si now holds address of ReadPacket
    mov word[si],0x10;size = 16 bytes
    mov word[si+2],100; 100 sectors to read
    mov word[si+4],0; (offset)
    mov word[si+6],0x1000;(segment)
    mov dword[si+8],6 ;7th sector
    mov dword[si+0xc],0
    mov dl,[DriveId] ;get the drive id
    mov ah,0x42 ;lba mode read from hard disk
    int 0x13 ;call the BIOS interrupt 0x13 to read the sectors
    jc ReadError ;if the carry flag is set then jump to ReadError

GetMemInfoStart:
    mov eax,0xe820
    mov edx,0x534d4150
    mov ecx,20
    mov edi,0x9000
    xor ebx,ebx
    int 0x15
    jc NotSupport

GetMemInfo:
    add edi,20
    mov eax,0xe820
    mov edx,0x534d4150
    mov ecx,20
    int 0x15
    jc GetMemDone
    test ebx,ebx
    jnz GetMemInfo

GetMemDone:


TestA20:
    mov ax,0xffff
    mov es,ax
    mov word[ds:0x7c00],0xa200
    cmp word[es:0x7c10],0xa200
    jne SetA20LineDone
    mov word[0x7c00],0xb200
    mov word[es:0x7c10],0xb200
    je End

SetA20LineDone:
    xor ax,ax
    mov es,ax
    mov ah, 0x13 ;string printing mode
    mov al, 1 ;print one character at a time from end of cursor
    mov bx, 0xa ;set the color to green and page to 0
    xor dx, dx ;clear the dx register to 0 hence rows and columns are 0
    mov bp, Message ;set the bp register to the address of the message
    mov cx, MessageLen ;set the cx register to the length of the message
    int 0x10 ;call the interrupt function 0x10 to print the message

ReadError:
NotSupport:
End:
    hlt
    jmp End

DriveId: db 0
Message: db "a20 line is enabled" ;loader prompt
MessageLen: equ $-Message ;calculate the length of the message
ReadPacket: times 16 db 0