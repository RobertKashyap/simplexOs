nasm -f bin -o boot.bin boot.asm
dd if=boot.bin of=hardDisk.img bs=512 count=1 conv=notrunc
qemu-system-x86_64 hardDisk.img
