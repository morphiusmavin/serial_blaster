Copyright (C) 2005, Curtis Monroe. curtis@rytis.com

Custom modifications, support, and alternative licensing are available
for this project. please email   curtis@rytis.com  for details.


Serial_Blaster
==============

WARNING: this is advanced code that can leave a TS-72XX in an unbootable
state. Use it at your own risk.

The serial blaster released under the GPL and alternative licenses for developers 
who can't use the GPL. Please contact the author for more details: curtis@rytis.com

The serial blaster is intended to replace the TS-9420 "blaster board".
The blaster board is a pc104 daughterboard that connect to a ts-72XX
to bring up the board for the first time, or to correct a damaged 
board. With the serial_blaster you don't need the TS-9420.

The serial blaster lets people recover boards with corrupt EEPROM,
TS-BOOTROM, or RedBoot images.

It also contains code to make a custom EEPROM boot image. This can be
useful for companies purchasing large numbers of TS-7250 boards who
want to customize the boot process.

The serial_blaster bootloader can be configured to load redboot from flash or 
from serial. It can load the redboot image directly from flash with
ECC (error correction and detection). It does not need to load an
intermediate boot loader (as the current TS boot process does)

The serial_blaster bootloader is writen in hand optimized ARM 32 bit
assembly language. The serial_blaster is writen in C.

Do not attempt to use the serial blaster for a 166MHz TS-7200, as it does not
set the processor and memory timings correctly.

I have only tried the serial blaster on a TS-7250 32MB mem, 32MB Flash.




Making the ts7250 redboot with EEPROM support
==============================================

NOTE: You should already have experience installing ecos and compiling it.
There are tutorials on the net, to help you with this.

Before you start make sure your cross-compiler and ecos tools are in your path: 
   e.g.
   PATH=/usr/kerberos/bin:/opt/ecos/ecos-2.0/tools/bin:/opt/crosstool/arm-linux/gcc-3.3.4-glibc-2.3.2/bin:

download the TS version of ECOS: 
   ftp://ftp.embeddedarm.com/ecos-src.tar.gz

untar it to a dir, cd there and apply the eeprom patch:
   [curtis@pccurtis2 src]$ tar xzvf ecos-src.tar.gz
   [curtis@pccurtis2 src]$ mv ecos ecos_ts7250_eeprom
   [curtis@pccurtis2 src]$ cd ecos_ts7250_eeprom 
   [curtis@pccurtis2 ecos_ts7250_eeprom]$ patch -p1 < redboot_ts7250_eeprom.diff

set your ecos repository env var:
   ECOS_REPOSITORY=/path/to/ecos_ts7250_eeprom/packages

edit packages/hal/arm/arm9/ts7250/current/cdl/hal_arm_arm9_ts7250.cdl
to uses your favorite crosscompiler the default is: "arm-9tdmi-elf"
I use "arm-linux"

Create a parallel build directory and build the new redboot li:
   [curtis@pccurtis2 src]$ mkdir build
   [curtis@pccurtis2 src]$ cd build
   [curtis@pccurtis2 build]$ ecosconfig new ts7250 redboot
   [curtis@pccurtis2 build]$ ecosconfig import /path/to/ecos_ts7250_eeprom/packages/hal/arm/arm9/ts7250/current/misc/redboot_ROMRAM_ts7250.ecm
   [curtis@pccurtis2 build]$ ecosconfig tree
   [curtis@pccurtis2 build]$ make

Your resulting redboot image is: build/install/bin/redboot.bin
Copy this file to the serial_blaster directory



Making the serial_blaster
=========================

In the serial blaster directory type:
[curtis@pccurtis2 serial_blaster]$ make

This makes the serial_blaster executable and and boot.bin serial boot loader file




Running the serial_blaster
==========================

Set jumper JP1 on, to enable serial booting
Give yourself permissions for "/dev/ttyS0", (or become root)
run serial_blaster in its home directory.

Serial blaster will respond with:

   [curtis@pccurtis2 serial_blaster]$ ./serial_blaster
   START
   waiting for '<'
   found '<'

Now reset the ts7250 board (press the reset button)

   found '<'

   --------- SENDING 2K BOOT FILE: "boot.bin" ---------
   4352555301da8fe202c1a0e3d300a0e300f029e100f069e12c0000ebc20000eb310000ebed0000eb0125a0e3012052e2fdffff1a28008fe2c60000eb
   ba0000eb3d0000eb450000eb0000a0e35c0000ebfc0000ebc10100eb09faa0e368009fe5db0100ea0d0a0d0a3e3e204f50454e2054532d3732353020
   424f4f544c4f414445522c2052657620312e3030203c3c0d0a534452414d3a33324d422c20464c4153483a33324d422c20424f4f543a466c6173682c
   .....
   010754e3f9ffff1a000093e51c109fe5010050e10300000a18008fe2edfeffeb0c009fe50a0000ea1f80bde80040d001435255530000ffff4552523a
   2043525553206e6f7420696e20666c6173680d0a0000000021378ce20227a0e3012052e2fdffff1a031000e2201083e56001a0e1f8ffffeafeffffea
   0000000000000000
   2048 Bytes in 5 seconds.
   --------------------------------------------------

   waiting for '>'
   found '>'


   >> OPEN TS-7250 BOOTLOADER, Rev 1.00 <<
   SDRAM:32MB, FLASH:32MB, BOOT:Serial, BLD:"Sep 16 2005"


    length=259824
    waiting length acknowledgement '@'
    found '@'
    --------- SENDING FILE "redboot.bin" ---------
    ........................................................................................................................
    ........................................................................................................................
    ..............
    259824 Bytes in 22 seconds.
    --------------------------------------------------

    waiting for ']'
    found ']'

    Ethernet eth0: MAC address 00:d0:69:40:09:e1
    IP: 192.168.0.50/255.255.255.0, Gateway: 192.168.0.1
    Default server: 192.168.0.1

    RedBoot(tm) bootstrap and debug environment [ROMRAM]
    Non-certified release, version current-TS_5 - built 03:17:23, Sep  9 2005

    Platform: TS-7250 Board (ARM920T) Rev A
    Copyright (C) 2000, 2001, 2002, 2003, 2004 Red Hat, Inc.

    RAM: 0x00000000-0x02000000, [0x00052e00-0x01ff9000] available
    FLASH: 0x60000000 - 0x62000000, 2048 blocks of 0x00004000 bytes each.
    RedBoot> 
    ReadByte ERROR, no input after 10 seconds

Now the serial_blaster has loaded redboot from serial, and ran it. You can login
from minicom (make sure serial_blaster and minicom never run at the same time).

The new redboot has automatic scripting turned off so it doesn't load linux before 
you can stop it. see packages/redboot/current/src/main.c

now you can read and write the 2k ts7250 eeprom from redboot with:

   eeprom_read -b <location> -o <eeprom offset> -l <length> [-d dump]

   eeprom_write [-b <location>] -o <eeprom offset> [-l <length>] 



How it works
==============

The serial blaster waits for the TS7250 to send a serial boot request character '<'.
Then it send a 2KB boot loader image to the board. And waits for a confirmation response '>'.
Then the 2KB boot loader image is executed on the board, and the serial_blaster handles its
requests.

The boot loader then:
	- kills the watchdog
	- initializes the processor (to 200Mhz)
	- speeds up the serial UART to 115200 bps
	- initializes SRAM, and FLASH
	- initializes SDRAM
	- tests sdram
	- loads RedBoot from serial (or flash)	
	- runs RedBoot
	
In the event of an error the boot loader will often send an error message. It is best to
lookup these errors in the code, as space is limited so the errors are sparse. The bootloader
will also flash LEDs to indicate errors:
	
	ERROR_NO_FLASH_CRUS	- 	red and green flashing together slowly
	ERROR_NO_UART_CRUS	- 	red flashing then green alternating slowly
	ERROR_EXITED		- 	only red flashing slowly
	ERROR_FLASH_ERROR	- 	only green flashing slowly	
	ERROR_FLASH_ECC		- 	red solid, green flashing slowly
	ERROR_FLASH_TIMEOUT	- 	green solid, red flashing slowly
	ERROR_SDRAM_DATA	- 	red flashing slowly, green flashing fast
	ERROR_SDRAM_ADDR	- 	green flashing slowly, red flashing fast
	ERROR_SDRAM_CELL	- 	green flashing slowly then fast, red flashing fast
	

(from yahoo groups TS7000)

I have figured the patch out and got a compiled redboot.bin with enabled eeprom_write. 
Now, my problem is that I can not write the bootrom and redboot into the flash. 
The error information is as follows:

RedBoot> fis write -f 0x60000000 -b 0x00200000 -l 0x20000
Invalid FLASH address 0x60000000: FLASH sub-system not initialized
	valid range is 0x00000000 - 0x00000000

I tried to initialize the flash by "fis init -f", but the process seems to be no response 
for a long time after “*** Initialize FLASH Image System”. Does anybody ever see this 
problem? I am not sure about the reason. Any suggestion will be greatly appreciated. 
Thank you so much.


	
