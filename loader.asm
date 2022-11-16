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

SetVideoMode:;video mode is text mode here to skip bios service for string printing
    mov ax,3
    int 0x10

    cli; clear interrupt flag
    lgdt [Gdt32Ptr]; load gdt
    lidt [Idt32Ptr]; load idt

    mov eax,cr0
    or eax,1
    mov cr0,eax

    jmp 8:PMEntry


ReadError:
NotSupport:
End:
    hlt
    jmp End


[BITS 32]
PMEntry:; protected mode entry
    mov ax,0x10
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov esp,0x7c00

    cld; clear direction flag
    mov edi, 0x80000
    xor eax, eax
    mov ecx, 0x10000/4
    rep stosd; repeat while equal, store string dword

    mov dword[0x80000], 0x81007
    mov dword[0x81000], 10000111b

    lgdt [Gdt64Ptr]

    mov eax,cr4
    or eax,(1<<5)
    mov cr4,eax

    mov eax,0x80000
    mov cr3,eax

    mov ecx,0xc0000080
    rdmsr
    or eax,(1<<8)
    wrmsr

    mov eax,cr0
    or eax,(1<<31)
    mov cr0,eax

    jmp 8:LMEntry

PEnd:
    hlt
    jmp PEnd

[BITS 64]
LMEntry:
    mov rsp,0x7c00

    mov byte[0xb8000],'L'
    mov byte[0xb8001],0xa

LEnd:
    hlt
    jmp LEnd

DriveId: db 0
ReadPacket: times 16 db 0

Gdt32:
    dq 0
Code32: ;code segment descriptor
    dw 0xffff
    dw 0
    db 0
    db 0x9a
    db 0xcf
    db 0
Data32:
    dw 0xffff
    dw 0
    db 0
    db 0x92
    db 0xcf
    db 0

Gdt32Len: equ $-Gdt32
Gdt32Ptr: dw Gdt32Len-1
          dd Gdt32

Idt32Ptr: dw 0
          dd 0

Gdt64:
    dq 0
    dq 0x0020980000000000

Gdt64Len: equ $-Gdt64

Gdt64Ptr: dw Gdt64Len-1
          dq Gdt64