GNU = $(CROSS_COMPILE)
objcopy = $(GNU)bin/arm-linux-objcopy
objdump = $(GNU)bin/arm-linux-objdump

all: serial_blaster.o boot-dissassemble.S boot2-dissassemble.S
	gcc -g -o serial_blaster serial_blaster.o

serial_blaster.o: serial_blaster.c
	gcc -g -c -o serial_blaster.o serial_blaster.c

boot-dissassemble.S: boot.bin
	$(objdump) -b binary -m arm7tdmi -z --adjust-vma=0x80014000 -D boot.bin > boot-dissassemble.S

boot.bin: boot.elf
	$(objcopy) --output-target binary boot.elf boot.bin

boot.elf: boot.S
	$(CC) -mcpu=arm920t -Wall -Wl,-Ttext,0x80014000 -nostdlib -o boot.elf boot.S

boot2-dissassemble.S: boot2.bin
	$(objdump) -b binary -m arm7tdmi -z --adjust-vma=0x300000 -D boot2.bin > boot2-dissassemble.S

boot2.bin: boot2.elf
	$(objcopy) --output-target binary boot2.elf boot2.bin

boot2.elf: boot2.S
	$(CC) -mcpu=arm920t -Wall -Wl,-Ttext,0x300000 -nostdlib -o boot2.elf boot2.S

clean:
	-rm serial_blaster.o
	-rm boot-dissassemble.S
	-rm boot.bin
	-rm boot.elf
	-rm boot2-dissassemble.S
	-rm boot2.bin
	-rm boot2.elf
	
debug:
	gdb serial_blaster

backup:
	cd .. ; tar cjvf ~/backup/serial_blaster-$(shell date +%F).tar.bz2 serial_blaster


# to make redboot patch:
#
# diff -Naur ts7250-ecos/ rytis-ecos/ >redboot_ts7250_eeprom.diff
#
#
