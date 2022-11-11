[BITS 16] ;bit directive to set the number of bits for segment registers(real mode)
[ORG 0x7C00] ;org directive to set the starting address of the program in memory(RAM)

;the following code is the boot sector code
;it is the first sector of the bootable hard disk
;it is executed by the BIOS(in Real mode)
;we set ax to 0x0000 then initialize the segment registers
;we set the stack pointer to 0x7C00 that means RAM beyond 0x7C00 is for MBR while RAM below 0x7C00 is for stack to grow
start:
    xor ax, ax ;clear the ax register to 0
    mov ds, ax ;set the ds register to 0
    mov es, ax ;set the es register to 0
    mov ss, ax ;set the ss register to 0
    mov sp, 0x7C00 ;set the sp register to 0x7C00

;disk extension services are verified to write a loader
TestDiskExtension:
    mov [DriveId], dl
    mov ah,0x41
    mov bx,0x55aa
    int 0x13 ;call the BIOS interrupt 0x13 to get the disk parameters
    jc NotSupport ;if the carry flag is set then jump to DiskError
    cmp bx,0xaa55 ;check if the bx register is 0xaa55
    jne NotSupport ;if the bx register is not 0xaa55 then jump to DiskError

;load loader to memory
LoadLoader:
    mov si,ReadPacket; si now holds address of ReadPacket
    mov word[si],0x10;size = 16 bytes
    mov word[si+2],5; 5 sectors to read
    mov word[si+4],0x7e00; read to 0x7e00 (offset)
    mov word[si+6],0; read to 0x0000 (segment)
    mov dword[si+8],1
    mov dword[si+0xc],0
    mov dl,[DriveId] ;get the drive id
    mov ah,0x42 ;lba mode read from hard disk
    int 0x13 ;call the BIOS interrupt 0x13 to read the sectors
    jc ReadError ;if the carry flag is set then jump to ReadError
    mov dl,[DriveId]
    jmp 0x7e00 ;jump to the loader addess(we will add binary from loader.asm at this address)

;print requires BIOS services which need to be called by interrupt table where 0x10 is for print function
;we need to set parameters for the interrupt function to be called
NotSupport:
ReadError:
    mov ah, 0x13 ;string printing mode
    mov al, 1 ;print one character at a time from end of cursor
    mov bx, 0xa ;set the color to green and page to 0
    xor dx, dx ;clear the dx register to 0 hence rows and columns are 0
    mov bp, Message ;set the bp register to the address of the message
    mov cx, MessageLen ;set the cx register to the length of the message
    int 0x10 ;call the interrupt function 0x10 to print the message

End:
    hlt ;halt the CPU
    jmp End ;infinite loop

DriveId: db 0 ;drive id
Message: db "Error occured in boot process" ;the message to be printed
MessageLen: equ $ - Message ;the length of the message
ReadPacket: times 16 db 0 ;parameter structure for loader service = 16bytes size

times (0x1be-($-$$)) db 0 ;fill the remaining space with 0 until the partition table starts
db 0x80 ;bootable flag
db 0,2,0 ;starting head, sector and cylinder
db 0x0f0 ;partition type
db 0xff,0xff,0xff ;ending head, sector and cylinder
dd 1 ;starting sector of the partition(sector 1)
dd (20*16*63-1) ;size of the partition in sectors

times (16*3) db 0 ;fill the remaining space with 0 until the boot signature starts

dw 0xaa55 ;boot signature