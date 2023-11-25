ARCH    = riscv32-unknown-elf
CC      = $(ARCH)-gcc
FLAGS   = -nostartfiles -g
LD      = $(ARCH)-ld
OBJCOPY = $(ARCH)-objcopy


all: clean coforth.img

coforth.img: coforth.elf
	$(OBJCOPY) coforth.elf -I binary coforth.img

coforth.elf: coforth.o uart0.o link.ld Makefile
	$(LD) -T link.ld --no-warn-rwx-segments -o coforth.elf coforth.o uart0.o

coforth.o: coforth.s
	$(CC) $(FLAGS) -c $< -o $@

uart0.o: uart0.s
	$(CC) $(FLAGS) -c $< -o $@

clean:
	rm -f *.o coforth.elf coforth.img

run: coforth.img
	qemu-system-riscv32 -M virt -bios none -serial stdio -display none -kernel coforth.img

