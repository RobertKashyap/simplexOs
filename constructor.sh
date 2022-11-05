qemu-img create hardDisk.img 20M
touch build.sh
chmod +x build.sh
echo 'nasm -f bin -o boot.bin boot.asm' > build.sh
echo 'dd if=boot.bin of=hardDisk.img bs=512 count=1 conv=notrunc' >> build.sh
echo 'qemu-system-x86_64 hardDisk.img' >> build.sh

