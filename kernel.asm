[BITS 64]
[ORG 0X200000]
; sample kernel to test loading in long mode
start:
    mov byte[0xb8000], 'K'
    mov byte[0xb8001], 0xa

End:
    hlt
    jmp End