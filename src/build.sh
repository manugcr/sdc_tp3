as -g -o main.o protected_mode.S
ld --oformat binary -o main.img -T link.ld main.o
qemu-system-i386 -drive format=raw,file=main.img,index=0,media=disk
# qemu-system-i386 -fda main.img -boot a -s -S -monitor stdio
