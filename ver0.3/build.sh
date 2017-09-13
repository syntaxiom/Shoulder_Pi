arm-none-eabi-as -o vectors.o vectors.s
arm-none-eabi-gcc -Wall -Werror -O2 -nostdlib -nostartfiles -ffreestanding -c notmain.c -o notmain.o
arm-none-eabi-ld vectors.o notmain.o -T memmap -o notmain.elf
arm-none-eabi-objdump -D notmain.elf > notmain.list
arm-none-eabi-objcopy notmain.elf -O binary kernel.img