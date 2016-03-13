default: build
.PHONY: clean

build/multiboot_header.o: multiboot_header.asm
	mkdir -p build
	nasm -f elf64 multiboot_header.asm -o build/multiboot_header.o

build/boot.o: boot.asm
	mkdir -p build
	nasm -f elf64 boot.asm -o build/boot.o

build/kernel.bin: build/multiboot_header.o build/boot.o linker.ld
	ld -n -o build/kernel.bin -T linker.ld build/multiboot_header.o build/boot.o

build/os.iso: build/kernel.bin grub.cfg
	mkdir -p build/isofiles/boot/grub
	cp grub.cfg build/isofiles/boot/grub
	cp build/kernel.bin build/isofiles/boot/
	grub-mkrescue /usr/lib/grub/i386-pc -o build/os.iso build/isofiles

build: build/os.iso

clean:
	rm -rf build
