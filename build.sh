nasm -f bin -o boot.bin boot.asm
dd if=boot.bin of=boot.iso bs=512 count=1 conv=notrunc