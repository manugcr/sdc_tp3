# !bin/bash

echo "  -> Assembling..."
as -g -o main.o protected_mode.S

echo "  -> Linking..."
ld --oformat binary -o main.img -T link.ld main.o

echo "  -> Launching QEMU in debug mode..."
gnome-terminal -- qemu-system-i386 -fda main.img -boot a -s -S -monitor stdio

# Open a new terminal window and execute GDB
echo "  -> Launching GDB linked with QEMU..."
gnome-terminal -- gdb -x gdb.gdb
