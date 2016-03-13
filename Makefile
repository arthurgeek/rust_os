default: build
.PHONY: clean

multiboot_header.o: multiboot_header.asm
	nasm -f elf64 multiboot_header.asm

boot.o: boot.asm
	nasm -f elf64 boot.asm

kernel.bin: multiboot_header.o boot.o linker.ld
	ld -n -o kernel.bin -T linker.ld multiboot_header.o boot.o

os.iso: kernel.bin grub.cfg
	mkdir -p isofiles/boot/grub
	cp grub.cfg isofiles/boot/grub
	cp kernel.bin isofiles/boot/
	grub-mkrescue /usr/lib/grub/i386-pc -o os.iso isofiles

build: os.iso

clean:
	rm -f multiboot_header.o
	rm -f asm.o
	rm -f kernel.bin
	rm -rf isofiles
	rm -f os.iso
