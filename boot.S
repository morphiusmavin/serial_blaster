/*=============================================================================
|   		Open TS-72XX system boot code
|
|	Set Jumper 1 on, to boot from serial port
|
| Building:
|     arm-linux-gcc -mcpu=arm920t -Wall -Wl,-Ttext,0x80014000 -nostdlib \
|       -o boot.elf boot.s
|     arm-linux-objcopy --output-target binary boot.elf boot.bin
|
| Author:
|	Curtis Monroe <curtis@rytis.com>
|
| Licence:
|
|   Copyright (C) 2005 Curtis Monroe.                                   
|   
|   This program is free software; you can redistribute it and/or modify
|   it under the terms of the GNU General Public License as published by
|   the Free Software Foundation; either version 2 of the License, or
|   (at your option) any later version.                                   
|                                                                         
|   This program is distributed in the hope that it will be useful,       
|   but WITHOUT ANY WARRANTY; without even the implied warranty of        
|   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         
|   GNU General Public License for more details.                          
|                                                                         
|   You should have received a copy of the GNU General Public License     
|   along with this program; if not, write to the                         
|   Free Software Foundation, Inc.,                                       
|   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             
|
|  DATE       |  NOTES
-------------------------------------------------------------------------------
| 2005-07-08  |  Created file
|             |  
|             |  
|             |  
-------------------------------------------------------------------------------
| Future Enhancements: (since we have some room left in our 2k boot image)
|   X add SDRAM test (serial boot only?) - Quick test for flash boot mode
|   N add flash ID check (NO, this is redboots responsability)
|   X add flash CRUS check
|   X add flash error messages
|   - embed eeprom image in redboot
|   - embed eeprom image in serial_blaster
|   - make serial blaster a redboot misc util, for the ts7250
|   - make serial blaster function as terminal when board reaches redboot state
|   X use ifdefs to load redboot from serial or flash
|   X support both 128MB and 32MB flash
|   X complex 32 bit LED error codes
|
=============================================================================
|
| The serial boot loader does a SDRAM test to make sure the board wiring and
| chips are functional. This test should not be needed in the embedded eeprom
| bootloader version, as the board will already have been verified. So a quick
| test is performed.
|
| This bootloader should NOT poll the hardware to determine its configuration.
| The configuration is defined at compile time. Thus the boot loaded
| is compiled specifically for the target board. The configuration of the board should not change
| ( e.g. flash size, SDRAM size) between boots (I guess you'd have to solder on
| chips between boots and thats not likely). This philosophy differs from the
| TS hardware detecting philosophy, but it saves enough space in the 2K boot  
| code that we can boot RedBoot without an intermediate 16k bootloaded being 
| loaded from flash, (as TS does).
|
| Because we don't use a 16K intermediate boot loader, we have only 2KB to kill
| the watchdog, init memory, and load redboot from flash (with ECC). So we
| need to move any extra init code to redboot. Fortunately redboot, and linux
| will handle most of the initialization for us.
| 
| ** Almost every byte the 2k for this boot loader is used **
| If you need to add more to this file you need to sacrifice!
|
=============================================================================*/		
#define FLASH 0
#define SERIAL 1

#define VERSION 1.00

@=============== HARDWARE SETTINGS ==============

#define SDRAM_SIZE 32
@#define SRAM_SIZE 64

#define FLASH_SIZE 32
@#define FLASH_SIZE 128

@#define BOOT_METHOD FLASH
#define BOOT_METHOD SERIAL
#define EEPROM_RESIDENT 1

@=========== LED FLASHING ERROR CODES ===========
@ 32 bit flashing pattern, even bits green, odd bits red
@    bits rotated right by 2, every 1/8th of a second
@  32 bit : RGRG-RGRG-RGRG-RGRG 
#define	ERROR_NO_FLASH_CRUS	0xffff0000	@ red and green flashing together slowly
#define	ERROR_NO_UART_CRUS	0xaaaa5555	@ red flashing then green alternating slowly
#define	ERROR_EXITED		0xaaaa0000	@ only red flashing slowly
#define ERROR_FLASH_ERROR	0x00005555	@ only green flashing slowly	
#define ERROR_FLASH_ECC		0xffffaaaa	@ red solid, green flashing slowly
#define ERROR_FLASH_TIMEOUT	0xffff5555	@ green solid, red flashing slowly
#define ERROR_SDRAM_DATA	0xeeee4444	@ red flashing slowly, green flashing fast
#define ERROR_SDRAM_ADDR	0xdddd8888	@ green flashing slowly, red flashing fast
#define ERROR_SDRAM_CELL	0xddddcccc	@ green flashing slowly then fast, red flashing fast
@
@================================================

#if (SDRAM_SIZE == 32)
   #define SDRAM_USE_DEVICE_3
#elif (SDRAM_SIZE == 64)
   #define SDRAM_USE_DEVICE_3
   #define SDRAM_USE_DEVICE_2
#else
   #error "ERROR: memory size!!"
#endif


#if (FLASH_SIZE == 32)		
    #define REDBOOT_FLASH_ADDRESS 0x01D04000
#elif (FLASH_SIZE == 128)
    #define REDBOOT_FLASH_ADDRESS 0x07D04000
#else
   #error "ERROR: flash size!!"
#endif		
 
 
#if (BOOT_METHOD == SERIAL)
	#define BOOTMETH Serial
#else
	#define BOOTMETH Flash
#endif	
#define STRINGIZE(_str_) #_str_
#define GREETING(_VERSION_, _SDRAM_, _FLASH_, _BOOT_METHOD_, _DATE_) STRINGIZE(\r\n\r\n>> OPEN TS-7250 BOOTLOADER\054 Rev _VERSION_ <<\r\nSDRAM:##_SDRAM_##MB\054 FLASH:##_FLASH_##MB\054 BOOT:##_BOOT_METHOD_##\054 BLD:##_DATE_##\r\n\r\n)
#define GEN_GREETING(_VERSION_, _SDRAM_, _FLASH_, _BOOT_METHOD_, _DATE_) GREETING(_VERSION_, _SDRAM_, _FLASH_, _BOOT_METHOD_, _DATE_)
	

@--------------------------------
@ print the value of a register		
		.macro	preg reg
		stmfd	sp!, {r0-r8,lr}
		mov	r4, \reg
		mrs	r3, cpsr
		
		mov	r1, #0x00
		bl	Output_Byte
		
		mov	r1, r4
		bl	Output_Word
		
		msr	cpsr_f, r3
		ldmfd	sp!, {r0-r8,lr}			
		.endm
		
@--------------------------------
		
		
		.text
rb		.req	r12
				
		.global		_start
_start:
		
#ifdef EEPROM_RESIDENT		
		.ascii  "CRUS"		@ address 0x80014000, the book is wrong!!! CRUS is not needed if 
					@ boot code is loaded from serial, only needed for eeprom,
					@ NOR flash, ROM, and RAM loading
					@ it is harmless to leave this marker, as it assembles to
					@ cmppl	r5, #0x30000004  ; which executes with no side effects
#endif // EEPROM_RESIDENT
		
		
		add	sp, pc, #0x1000 @ set decending stack near top off 
					@ ethernet fifo, our code is at
					@ the beginning of the fifo
					
		mov	rb, #0x80000000	@ used gobally (constant to base address of hardware)
										
		@ dissable interupts and enter supervisor mode
		mov	r0, #0xd3
		msr	CPSR_fc, r0
		msr	SPSR_fc, r0
	
		bl	Kill_Watchdog	
		bl	Flush_UART
		bl	Set_System_Speed
		bl	Set_UART_115200bps		

		@ wait half second		
		mov	r2, #0x00400000
1:		subs	r2, r2, #1
		bne	1b

		adr	r0, greetings
		bl	Output_String
		bl	Flush_UART
		
		bl	Config_SRAM_and_FLASH
		bl	Config_SDRAM
		
		mov	r0, #0x00000000		@ sdram device base address 
		bl	Test_SDRAM_Device
		
		
#if (BOOT_METHOD == FLASH)		

		bl	Create_ECC_Lookup_Table

@		bl	Test_ECC
@		bl	Test_Load_Flash	
		
		@ Load boot file from flash and execute (usually RedBoot)
		bl	Load_Redboot
		mov	pc, #0x00009000		@ redboot entry point
		
#endif // BOOT_METHOD == FLASH


#if (BOOT_METHOD == SERIAL)

		@ Load boot file from UART and execute (usually RedBoot)
		mov	r2, #0x00008000		@ start address
		bl	UART_Load_File
		
		mov	pc, #0x00009000		@ redboot entry point
		
#endif // BOOT_METHOD == SERIAL

		ldr	r0,=ERROR_EXITED
		b	Flash_Leds_Forever
		
greetings:	.string	GEN_GREETING(VERSION, SDRAM_SIZE, FLASH_SIZE, BOOTMETH, __DATE__) 
		.align	@ Must align after strings or bytes, so following code is aligned (stupid, eh!)
		.ltorg
		
@--------------------------------		
Kill_Watchdog:
		
		@ feed TS Watchdog, must feed the dog before killing it
		mov	r0, #0x23c00000
		mov	r1, #5
		strh	r1, [r0]
	
		@ turn off TS Watchdog
		mov	r0, #0x23800000
		mov	r1, #0
		strh	r1, [r0]

		bx	lr
		.ltorg
		

@--------------------------------		
Set_System_Speed:
		@ speed up the controller to 200Mhz
		add	r0, rb, #0x00930000	@ R0 = base of syscon
		
		mov	r1, #0xaa
		str	r1, [r0, #0xc0]	@ unlock syscon
		
		ldr	r1, =0x02a4bb36
		str	r1, [r0, #0x20]
		
		@ flush the pipeline
		.rept	5
		nop
		.endr
		
		@ not sure this is necessary TS does it too. (but can it wait till Redboot?)
		mrc	p15, 0, r0, c1, c0, 0	@ set to #0x78 in the boot ROM
		orr	r0, r0, #0xc0000000	@ Asyncronous bus mode
	 	mcr	p15, 0, r0, c1, c0, 0
	 	
		@ flush the pipeline
		.rept	5
		nop
		.endr
		
		bx	lr
		.ltorg
			
		
@--------------------------------		
Config_SRAM_and_FLASH:

		add	r2, rb, #0x00080000	@ r9=0x80080000 sram base reg

		@ configure 8-bit memory region 0x1XXX-XXXX
		ldr	r3, =0x0000ffef		@ r3 = 0x0000ffef
		str	r3, [r2, #0x04]		@ SMCBCR1 = 8 bit SRAM Full wait states

		@ configure 16-bit memory region 0x2XXX-XXXX
		orr	r3, r3, #0x10000000	@ r3 = 0x1000ffef
		str	r3, [r2, #0x08]		@ SMCBR2 = 16 bit SRAM Full wait states

		@ configure 16-bit memory region 0x6XXX-XXXX NAND FLASH REGION
		bic	r3, r3, #0x00000300	@ r3 = 0x1000fdef
		str	r3, [r2, #0x18]		@ SMCBCR6 = 16 bit WST1=7

		bx	lr
		.ltorg
		
@--------------------------------		
Config_SDRAM:
		
		@ configure sdram RAS=2, CAS=2, quad-bank
		add	r9, rb, #0x00060000	@ r9=0x80060000
		
		ldr	r0, =0x0021002c		@ SDRAMDevCfgx, #0x32002c for 166MHz
		@ no auto-precharge, RAS latency=2, Write burst=read, Caslat=2
		@ SF config = normal, 2kpage=false, SROM lookalike = true, 
		@ SROM512=false, bank count=4 
		
#ifdef SDRAM_USE_DEVICE_0	 
		str	r0, [r9, #0x10]		@ [0x80060010] = #0x0021002c
#endif		
#ifdef SDRAM_USE_DEVICE_1	 
		str	r0, [r9, #0x14]		@ [0x80060014] = #0x0021002c
#endif		
#ifdef SDRAM_USE_DEVICE_2	 
		str	r0, [r9, #0x18]		@ [0x80060018] = #0x0021002c
#endif		
#ifdef SDRAM_USE_DEVICE_3	 
		str	r0, [r9, #0x1C]		@ [0x8006001C] = #0x0021002c
#endif		

		@ GIConfig CKE=1, issue NOP command to SDRAM
		add	r1, rb, #0x00000003	@ r1=0x80000003
		str	r1, [r9, #0x04]		@ [0x80060004] = #0x80000003
		
		@ wait 250msecs		
1:		mov	r2, #0x00200000
2:		subs	r2, r2, #1
		bne	2b		
		
		@ GIConfig CKE=1, issue pre-charge all
		add	r1, rb, #0x00000001	@ r1=0x80000001
		str	r1, [r9, #0x04]		@ [0x80060004] = #0x80000001
		
#if 0		
		@ write to all 4 banks of each device
		ldr	r1, =0x0000dead
		mov	r2, #0x00200000

#ifdef SDRAM_USE_DEVICE_0	 
		mov	r0, #0xC0000000
		strh	r1, [r0], +r2
		strh	r1, [r0], +r2
		strh	r1, [r0], +r2
		strh	r1, [r0], +r2
#endif
		
#ifdef SDRAM_USE_DEVICE_1	 
		mov	r0, #0xD0000000
		strh	r1, [r0], +r2
		strh	r1, [r0], +r2
		strh	r1, [r0], +r2
		strh	r1, [r0], +r2
#endif		

#ifdef SDRAM_USE_DEVICE_2	 
		mov	r0, #0xE0000000
		strh	r1, [r0], +r2
		strh	r1, [r0], +r2
		strh	r1, [r0], +r2
		strh	r1, [r0], +r2
#endif
			
#ifdef SDRAM_USE_DEVICE_3	 
		mov	r0, #0x00000000
		strh	r1, [r0], +r2
		strh	r1, [r0], +r2
		strh	r1, [r0], +r2
		strh	r1, [r0], +r2
#endif		
#endif			
		@ set SDRAM refresh to 16
		mov	r1, #16
		str	r1, [r9, #0x08]		@ [0x80060008] = #16

		@ wait 250msecs		
1:		mov	r2, #0x00200000
2:		subs	r2, r2, #1
		bne	2b		

		@ set SDRAM refresh to 115
		ldr	r1, =781
		str	r1, [r9, #0x08]		@ [0x80060008] = #781
		
		@ GIConfig CKE=1, issue NOP command to SDRAM
		add	r1, rb, #0x00000002	@ r1=0x80000002
		str	r1, [r9, #0x04]		@ [0x80060004] = #0x80000002
		
		@ read from each chip 
		mov	r0, #0x00004600		@ command to issue to sdram, #0x6600 for 166MHz
						@ CAS=3, WBL=0, TM=0, Seq, BL=8
#ifdef SDRAM_USE_DEVICE_0	 
		add	r2, r0, #0xC0000000
		ldrh	r1, [r2]
#endif		
			
#ifdef SDRAM_USE_DEVICE_1	 
		add	r2, r0, #0xD0000000
		ldrh	r1, [r2]
#endif
		
#ifdef SDRAM_USE_DEVICE_2	 
		add	r2, r0, #0xE0000000
		ldrh	r1, [r2]
#endif		

#ifdef SDRAM_USE_DEVICE_3	 
		ldrh	r1, [r0]	
#endif
		
		@ GIConfig CKE=1, SDRAM normal operation mode	
		str	rb, [r9, #0x04]		@ [0x80060004] = #0x80000000
		
		bx	lr
		.ltorg
		
@#if (BOOT_METHOD == SERIAL)		
@--------------------------------	
@ SDRAM Test comments 
@ [based on code by Wolfgang Denk, DENX Software Engineering, wd@denx.de]
@  
@   Data line test:
@   ---------------
@   This tests data lines for shorts and opens by forcing data
@   lines to opposite states. Because the data lines traces could be routed in
@   arbitrary manners we must test for every combination of
@   shorted line. (e.g. line 4 shorted with line 15, not just adjacent lines [3, and 5] )
@   
@       1010101010101010
@       0101010101010101
@       1100110011001100
@       0011001100110011
@       1111000011110000
@       0000111100001111
@       1111111100000000
@       0000000011111111
@  
@   Carrying this out, gives us eight hex patterns as follows:
@  
@       0xaaaa
@	0x5555
@       0xcccc
@	0x3333
@       0xf0f0
@	0x0f0f
@       0xff00
@	0x00ff
@  
@  After writing a test pattern. The complement pattern is written to a 
@  different address in case the data lines are floating.
@  Thus, if a line fails, you should see bits flipped on a floating bus.
@
@  Alternatively a "walking bit" test may be used to test data lines. It
@  is slightly less efficient, but reduces code size.  !!! WE USE THIS TEST !!!
@  
@  -   Floating buses can fool memory tests if the test routine writes
@      a value and then reads it back immediately.  The problem is, the
@      write will charge the residual capacitance on the data bus so the
@      bus retains its state briefely.  When the test program reads the
@      value back immediately, the capacitance of the bus can allow it
@      to read back what was written, even though the memory circuitry
@      is broken.  To avoid this, the test program should write a test
@      pattern to the target location, write a different pattern elsewhere
@      to charge the residual capacitance in a differnt manner, then read
@      the target location back.
@  
@  -   Test data lines first, if they are broken, nothing else will work.
@
@
@
@   Address line test:
@   ------------------
@  This function performs a test to verify that all the address lines
@  hooked up to the RAM work properly.  If there is an address line
@  fault, it usually shows up as two different locations in the address
@  map (related by the faulty address line) mapping to one physical
@  memory storage location.  The artifact that shows up is writing to
@  the first location "changes" the second location.
@  
@  To test all address lines, we start with the given base address and
@  xor the address with a '1' bit to flip one address line.  For each
@  test, we shift the '1' bit left to test the next address line.
@  
@  Example for a 4 bit address space (bottom and top base)
@     0000 = base       1111 = base
@     0001 <- test 1    1110 <- test 1
@     0010 <- test 2    1101 <- test 2
@     0100 <- test 3    1011 <- test 3
@     1000 <- test 4    0111 <- test 4
@  
@  The test locations are successively tested to make sure that they are
@  not "mirrored" onto the base address due to a faulty address line.
@  Note that the base and each test location are related by one address
@  line flipped.  Note that the base address need not be all zeros.
@  
@  The base address of the lowest memory location causes a '1' bit to
@  walk through a field of zeros on the address lines. 
@  
@  The base address of the highest memory location causes a '0' bit to
@  walk through a field of '1's on the address line.
@
@  Test address lines after testing the data lines, if the data lines are 
@  not working the address test will fail
@  
@
@
@   Memory tests (cell tests) 1-4:
@   ------------------------------
@  These tests verify RAM using sequential writes and reads
@  to/from RAM. There are several test cases that use different patterns to
@  verify RAM. Each test case fills a region of RAM with one pattern and
@  then reads the region back and compares its contents with the pattern.
@  The following patterns are used:
@  
@    1a) zero pattern (0x00000000) "all 0's" test
@    1b) negative pattern (0xffffffff) "all 1's" test
@    1c) checkerboard pattern (0x55555555) "checkerboard" test
@    1d) checkerboard pattern (0xaaaaaaaa) inverted "checkerboard" test
@    2)  bit-flip pattern ((1 << (offset % 32)) "walking bit" left test
@    3)  address pattern (offset)
@    4)  address pattern (~offset)
@
@
@ -----------------
@ Note: 
@      Always read the target location EXACTLY ONCE and save it in a local
@      variable.  The problem with reading the target location more than
@      once is that the second and subsequent reads may work properly,
@      resulting in a failed test that tells the poor technician that
@      "Memory error at 00000000, wrote aaaa, read aaaa" which
@      doesn't help him one bit and causes puzzled phone calls.  Been there,
@      done that.
@  
@
@ Possible SDRAM Errors, Detection and Identification: 
@ • Single data bits
@ • Power and noise related failures
@ • Solder opens and shorts
@ • Timing related failures 
@ • Data retention errors
@ • Intermittent failures
@
@ Possible tests: 
@ • Walk Bit Left (Walking bit 1s Marching up)
@ • Walk Bit Marching (Walking bit 1s Marching down)
@ • Inverted Walk Bit Left (Walking bits 0s Marching up)
@ • Inverted Walk Bit Marching (Walking bits 0s Marching down)
@ • Checkerboard
@ • Inversed Checkerboard
@ • Pseudo Random
@
@ --------------------------
@ r0 = base adress of device: 0x00000000, 0xC0000000, 0xD0000000, or 0xE0000000
Test_SDRAM_Device:
@		stmfd	sp!, {r0, r9, lr}
		
		mov	r9, r0
rbase		.req	r9

		@ -----------
		@ Test data lines, Walk Bit right (Walking bit 1s Marching down)
		mov	r1, #0x00008000		@ top bit of 16 bit value
		mov	r3, #0			@ collects error bits
		
1:		mov	r4, r1

@		orr	r4, r4, #0x00000003	@ test 2 lines stuck on
		
@		bic	r4, r4, #0x00000440	@ test 2 lines stuck off
		
@		tst	r4, #0x00000440		@ test
@		orrne	r4, r4, #0x00000440	@ test if any one of 2 lines is on, both lines on.

@		tst	r4, #0x00000020		@ test lines tied together, one is off they both are off
@		tstne	r4, #0x00000200		@ test lines tied together, one is off they both are off
@		biceq	r4, r4, #0x00000220  	@ test if any one of 2 lines is off, both are off
		
		strh	r4, [rbase]		@ store walking bit
		
		
		mvn	r2, r1			@ make the negative walking bit
		strh	r2, [rbase, #2]		@ flush floating bus with inverse of walking bit
		ldrh	r0, [rbase]		@ read back walking bit
		cmp	r0, r1
		eor	r2, r0, r1		@ what bits don't match?			
		orrne	r3, r3, r2		@ collect errors
		movs	r1, r1, lsr #1		@ walk the bit down, right
		bne	1b			@ if not done
		
		cmp	r3, #0			@ did we collect any bad data lines?
		bne	ram_data_err		@ branch if data line error
		
		@ -----------
		@ Test address lines
		@ 
		@ Note: - address lines 25 and 23 are not used, they mirrored to valid addresses
		@         We must skip errors caused by lines 25 and 23
		@       - address lines are used to send initiation commands to the sdram during
		@         initialization, errors in these lines can fail initiation, before this
		@         test even starts.
		@
		mov	r1, #0x04000000		@ top bit of address space
		ldr	r5, =0x057ffffe		@ top_base highest word in device, and mask for walk
		mov	r3, #0			@ collects error bits
		
1:		orr	r6, rbase, r1
		
@		tst	r6, #0x00000010		@ test address lines tied together, one is off they both are off
@		tstne	r6, #0x00000100		@ test address lines tied together, one is off they both are off
@		biceq	r6, r6, #0x00000110  	@ test (address bit 9 stuck on)
		
		ldrh	r2, [r6]		@ load
		eor	r2, r2, #0x00ff
		eor	r2, r2, #0xff00
		strh	r2, [rbase]		@ store inverted
		
@		orr	r7, rbase, #0x00000100  @ test (address bit 9 stuck on)
@		strh	r2, [r7]		@ test store it
		
		ldrh	r4, [r6]		@ load again to see if it changed
		cmp	r2, r4			@ are base and base+walk tied together, or walk stuck low?
		orreq	r3, r3, r1		@ collect errors
		
		bic	r6, r5, r1
		orr	r6, r6, rbase		@ everything relates to the base
		
@		tst	r6, #0x00000110		@ test address lines tied together, one is on they both are on
@		orrne	r6, r6, #0x00000110  	@ test (address bit 9 stuck on)
		
		ldrh	r2, [r6]		@ load
		eor	r2, r2, #0x00ff
		eor	r2, r2, #0xff00
		strh	r2, [r5]		@ store inverted
		
@		bic	r7, r5, #0x00000100  	@ test (address bit 9 stuck off)
@		strh	r2, [r7]		@ test store it
		
		ldrh	r4, [r6]		@ load again to see if it changed
		cmp	r2, r4			@ are top_base and top_base^walk tied together, or walk stuck high?
		orreq	r3, r3, r1		@ collect errors
		
		mov	r1, r1, lsr #1		@ walk the bit down, right
		cmp	r1, #1
		bne	1b
		
		bics	r3, r3, #0x02800000	@ disregard lines 25 and 23, we know they mirror
		bne	ram_addr_err		@ branch if address line error
		
		@ -----------
		@ Test memory cells, tests first 128KB
		@
		@ we fill all the memory, (even the mirrored memory), the check that it
		@ held the value
		ldr	r2, =0x00005555
		mov	r4, #0
		
@1:		mov	r1, r5			@ r5=0x057ffffe (max address)
1:		mov	r1, #0x00020000		@ tests 128KB
2:		strh	r4, [rbase, r1]
		subs	r1, r1, #2		@ if we reach bottom address
		bpl	2b
		
		mov	r1, #0x00020000		@ test 128KB
2:		ldrh	r3, [rbase, r1]
		cmp	r4, r3
		bne	ram_cell_err
@		beq	ram_cell_err		@ test
		subs	r1, r1, #2		@ if we reach bottom address
		bpl	2b

		add	r4, r4, r5		@ makes masks, 0x0000, 0x5555, 0xaaaa, 0xffff, 0x00015554
		tst	r5, #00010000		@ test for 0x00015554
		beq	1b			

		bx	lr
@		ldmfd	sp!, {r0, r9, pc}
			
ram_data_err:	mov	r2, rbase		@ r2=data word
		adr	r0, data_err_txt
		bl	Output_String
		bl	Output_Bits		@ r3=error mask, r2=data word
		ldr	r0, =ERROR_SDRAM_DATA
		b	Flash_Leds_Forever

ram_addr_err:	mov	r2, rbase		@ r2=data word
		adr	r0, addr_err_txt
		bl	Output_String
		bl	Output_Bits		@ r3=error mask, r2=data word
		ldr	r0, =ERROR_SDRAM_ADDR
		b	Flash_Leds_Forever

ram_cell_err:	adr	r0, cell_err_txt
		bl	Output_String
		ldr	r0, =ERROR_SDRAM_CELL
		b	Flash_Leds_Forever

		.ltorg
data_err_txt:	.string	"ERR: RAM Data:\r\n" 
addr_err_txt:	.string	"ERR: RAM Addr:\r\n" 
cell_err_txt:	.string	"ERR: RAM Cell:\r\n" 
		.align	@ Must align after strings or bytes, so following code is aligned (stupid, eh!)
		
@#endif // BOOT_METHOD == SERIAL
		
@--------------------------------		
Flush_UART:		
		@ flush UART, so control program get the '>' character
		stmfd	sp!, {r0, r1, lr}
		add	r0, rb, #0x008c0000
1:		ldr	r1, [r0, #0x18]
		tst	r1, #0x08
		bne	1b
		ldmfd	sp!, {r0, r1, pc}	
		.ltorg
		
@--------------------------------		
@ Output byte in R1
Output_Byte:	
		stmfd	sp!, {r0-r2, lr}
		
		bl	Flush_UART	
		
		add	r2, rb, #0x008c0000
		strb	r1, [r2]
		
		ldmfd	sp!, {r0-r2, pc}		
		.ltorg
				
@--------------------------------	
@ string stored in R0	
Output_String:	
		stmfd	sp!, {r0-r2, lr}
		
1:		ldrbt	r1, [r0], #1
		cmp	r1, #0
		beq	2f
		
		bl	Output_Byte
		
		b	1b
		
2:		ldmfd	sp!, {r0-r2, pc}		
		.ltorg

@--------------------------------		
@ word stored in R1
Output_Word:	
		stmfd	sp!, {r1, lr}
		
		.rept	4
		mov	r1, r1, ROR #24
		bl	Output_Byte
		.endr
		
		ldmfd	sp!, {r1, pc}
		.ltorg
		
@--------------------------------		
@ R2 = word, 1=show '1', 0=show '0' 
@ R3 = mask, 1=error/unknown/na bit, show 'X'
Output_Bits:
		stmfd	sp!, {r0-r3, lr}
		mov	r0, #32		@ do all 32 bits
				
1:		movs	r3, r3, lsl #1	@ error word
		movcs	r1, #'X'	@ print 'X' if error bit
		movcs	r2, r2, lsl #1	@ data bits don't matter if error bit set, just advance it
		bcs	2f
		
		movs	r2, r2, lsl #1	@ data word 
		movcs	r1, #'1'	@ print '1' if date bit set
		movcc	r1, #'0'	@ print '0' if date bit not set
		
2:		bl 	Output_Byte
		subs	r0, r0, #1
		bne	1b
		
		mov	r1, #'\r'
		bl 	Output_Byte
		
		mov	r1, #'\n'
		bl 	Output_Byte
		
		ldmfd	sp!, {r0-r3, pc}		
		.ltorg	
	
#if (BOOT_METHOD == SERIAL)
@--------------------------------		
@ Intput byte into R0, logical 32bit extended
Input_Byte:	
		stmfd	sp!, {r1-r4, lr}
		
		add	r2, rb, #0x008c0000

1:		ldr	r1, [r2, #0x18]		@ wait if buffer is empty
		tst	r1, #0x10
		bne	1b

		ldrb	r0, [r2]

		ldmfd	sp!, {r1-r4, pc}		
		.ltorg
				
@--------------------------------		
@ word returned in R0
Input_Word:	

		stmfd	sp!, {r1, lr}

		bl	Input_Byte
		mov	r1, r0

		bl	Input_Byte
		orr	r1, r1, r0, LSL #8

		bl	Input_Byte
		orr	r1, r1, r0, LSL #16

		bl	Input_Byte
		orr	r1, r1, r0, LSL #24

		mov	r0, r1

		ldmfd	sp!, {r1, pc}
		
		.ltorg
#endif // BOOT_METHOD == SERIAL

@--------------------------------		
Set_UART_115200bps:	

@		stmfd	sp!, {r0-r3, lr}

		add	r2, rb, #0x008c0000	@ UART base address
		add	r3, rb, #0x00930000	@ SYSCON base address

		mov	r0, #0
		str	r0, [r2, #0x00000014]	@ UART1Ctrl
		str	r0, [r2, #0x00000004]	@ UART1RXSts

		mov	r0, #3
		str	r0, [r2, #0x00000100]	@ UART1ModemCtrl

		mov	r0, #0xaa
		str	r0, [r3, #0xc0]		@ unlock syscon
		
		ldr	r0, [r3, #0x80]
		bic	r0, r0, #0x00040000	
		str	r0, [r3, #0x80]		@ disable UART1
		
		mov	r0, #3
		str	r0, [r2, #0x00000010]	@ UART1LinCtrlLow
		
		mov	r0, #0
		str	r0, [r2, #0x0000000c]	@ UART1LinCtrlMid

		mov	r0, #0x70
 		str	r0, [r2, #0x00000008]	@ UART1LinCtrlHigh

		mov	r0, #0x1
 		str	r0, [r2, #0x00000014]	@ UART1Ctrl

		mov	r0, #0xaa
		str	r0, [r3, #0xc0]		@ unlock syscon
		
		ldr	r0, [r3, #0x80]
		orr	r0, r0, #0x00040000	
		str	r0, [r3, #0x80]		@ enable UART1

@		ldmfd	sp!, {r0-r3, pc}
		bx	lr
				
		.ltorg
#if 0
@--------------------------------		
@	r2 = start word address
@	r3 = last word address
Output_Memory_Range:

		stmfd	sp!, {r0-r3, lr}

		mov	r1, #0x01
		bl	Output_Byte
		
		mov	r1, r2
		bl	Output_Word
			
		mov	r1, r3
		bl	Output_Word
		
1:		ldr	r1, [r2], #4 
		bl	Output_Word
		cmp	r2, r3
		ble	1b
		
		ldmfd	sp!, {r0-r3, pc}		
		.ltorg
#endif

#if (BOOT_METHOD == SERIAL)
@--------------------------------		
@ 	r2 = start address, inclusive, word aligned
UART_Load_File:

		stmfd	sp!, {r0-r4, lr}
		mov	r4, r2

		mov	r1, #0x03		@ Load File Command
		bl	Output_Byte

		bl	Input_Word		@ get file length 
		mov	r3, r0		
		add	r3, r3, r2		@ add starting address to
						@ get ending address

		mov	r1, #'@'		@ length acknowledgement
		bl	Output_Byte

1:		bl	Input_Word
		str	r0, [r2], #4 
		cmp	r2, r3			@ Get the data
		blt	1b	
		
		mov	r1, #']'		@ File Load Acnowledgement
		bl	Output_Byte

		bl	Flush_UART

		ldr	r0, [r4]
		ldr	r1, =0x53555243		@"CRUS"
		cmp	r0, r1
		beq	2f
		
		adr	r0, no_CRUS
		bl	Output_String
		ldr	r0, =ERROR_NO_UART_CRUS
		b	Flash_Leds_Forever

2:		ldmfd	sp!, {r0-r4, pc}
		
		.ltorg
no_CRUS:	.string	"ERR: CRUS not in serial.\r\n" 
		.align	@ Must align after strings or bytes, so following code is aligned (stupid, eh!)
		
#endif // BOOT_METHOD == SERIAL
		
		
#if (BOOT_METHOD == FLASH)
@--------------------------------		
@ 	Use SDRAM for the table, FIFO Ram doesn't support byte access
@	table starts at 0x00007000 and is 256 bytes
@	table bits 0-5 hold column parity for bytes in flash
@	bit 6 holds parity for whole byte (used in line parity)
Create_ECC_Lookup_Table:

@		stmfd	sp!, {r0-r6, lr}
		
		mov	r5, #0x00007000		@ start off ecc lookup table
		mov	r4, #0xff		@ count 256 bytes in table

1:		ldr	r6, =0xaaccf000		@ four masks, (negatives are calculated)

2:		and	r2, r4, r6		@ r2 = index ORed with positive mask
		
		eor	r2, r2, r2, lsr #4	@ XOR top 4 bits with bottom 4
		eor	r2, r2, r2, lsr #2	@ then XOR the top 2 of those with the bottom 2
		eor	r2, r2, r2, lsr #1	@ then X0R the top 1 of those with the bottom 1
						@ now the LSB is the parity
		
		movs	r2, r2, rrx 		@ shift the parity bit to the carry
		adc	r0, r0, r0		@ shift r0 left by one and shift in the carry
		
		eor	r6, r6, #0xff		@ generate negative mask
		tst	r6, #1			@ if we are back to a positive mask them we should:
		moveqs	r6, r6, lsr #8		@	shift to the next mask
		bne	2b			@ do again, unless we are out of masks
		
		strb	r0, [r5, r4]		@ store the generated parity lookup
		
		subs	r4, r4, #1		@ make the next index in the table
		bge	1b			@ do indexes from 255-0, (R4 >= 0)
		
@		ldmfd	sp!, {r0-r6, pc}		
		bx	lr
		
		.ltorg

@--------------------------------		
@ generates an ecc from a 256 byte half-page stored in memory 
@ R0 returns ECC as 32bit { 0x00, ECC2, ECC1, ECC0 } st format
@ R6 = location of 256 byte half-page to ECC
@
@ Note: Redboot reverses the definition of ECC1, and ECC0
@
@ 	we use the ST format where ECC0=[LP07,LP06,LP05,LP04,LP03,LP02,LP01,LP00]
@                              and ECC1=[LP15,LP14,LP13,LP12,LP11,LP10,LP09,LP08]
@
@    Redboot uses the format where ECC0=[LP15,LP14,LP13,LP12,LP11,LP10,LP09,LP08]
@                              and ECC1=[LP07,LP06,LP05,LP04,LP03,LP02,LP01,LP00]
@
@ We convert from the redboot format when reading, (we have no write command	
@ cause we leave all writting to redboot)
Generate_HalfPage_ECC:

		stmfd	sp!, {r1-r9, lr}
		
		mov	r5, #0x00007000		@ start off ecc lookup table
		mov	r7, #0x00		@ r7 is reg1
		mov	r8, #0x00		@ r8 is reg2
		mov	r9, #0x00		@ r9 is reg3

		mov	r4, #0xff		@ count 256 bytes in table
1:		ldrb	r1, [r6, r4]		@ get next byte to ECC
		ldrb	r2, [r5, r1]		@ look-up-table, r2 is idx
		
		tst	r2, #0x40
		eor	r7, r7, r2
		eorne	r8, r8, r4
		eorne	r9, r9, r4		
		eorne	r9, r9, #0xff		
		
		subs	r4, r4, #1		@ make the next index in the table
		bge	1b			@ do indexes from 255-0
    		
    		
    		mov	r7, r7, lsl #26		@ remove the top bit of r7
    		
    		mov	r4, #8
    		mov 	r1, #0
1:   		movs	r9, r9, lsr #1 		@ shift the parity bit to the carry
    		mov	r1, r1, rrx		@ shift the bit into r0
   		movs	r8, r8, lsr #1 		@ shift the parity bit to the carry
    		mov	r1, r1, rrx		@ shift the bit into r0
    		subs	r4, r4, #1
    		bne	1b
    				
    		mov	r0, r1, lsr #16
    		orr	r0, r0, r7, lsr #8		@ move into byte 3 position. non used bits are 0
    		
   		mvn	r0, r0
  		bic	r0, r0, #0xff000000
  		
		ldmfd	sp!, {r1-r9, pc}		
		.ltorg
@--------------------------------		
@ use calculated and read ecc to fix 256 byte half-page stored in memory 
@ R0 returns bits 0=NO_ERROR, 1=ERROR_CORRECTED, 2=ECC_CODE_INVALID, 4=UNCORRECTABLE_ERROR
@
@	NO_ERROR 		= the half-page had no errors, (most likely situation, data is good)
@	ERROR_CORRECTED 	= the half-page had one error that we corrected, (the data is good)
@	ECC_CODE_INVALID	= the ECC code was read with an error in it, (the data might still be good?)
@	UNCORRECTABLE_ERROR	= the data had 2 errors or more, (data bad, page unrecoverable)
@
@ R6 = location of 256 byte half-page to correct
@ R0 = calculated ECC as 32bit { 0x00, ECC2, ECC1, ECC0 } st format
@ R1 = read ECC (read from flash)  as 32bit { 0x00, ECC2, ECC1, ECC0 } st format
@
@ See note on ST/RedBoot ECC format above
@
Correct_HalfPage_using_ECC:

@		preg	r1
@		preg	r0
		eors	r0, r0, r1		@ now r1 holds the "d" value
		bxeq	lr			@ return r0=0 (NO_ERROR)
		
		stmfd	sp!, {r1-r10, lr}
		
		ldr	r1, =0x00545555
		eor	r2, r0, r0, lsr #1
		and	r2, r2, r1
		cmp	r2, r1
		bne	2f
		
		@ remove odd bits (every second bit)
    		mov	r4, #32
    		mov 	r1, #0
1:   		mov	r0, r0, lsr #1 		@ shift the parity bit to the carry 
		movs	r0, r0, lsr #1 		@ shift the parity bit to the carry
    		mov	r1, r1, rrx		@ shift the bit into r1 (top)
    		subs	r4, r4, #1
    		bne	1b		
		
@		preg	r1
		
		and	r2, r1, #0xff		@ st format for ecc0, ecc1, ecc2
		
		mov	r3, r1, lsr #9		
		and	r3, r3, #0x07		@ r3 = error bit index
		
		ldrb	r4, [r6, r2]
		mov	r0, #1			@ return code, and bit mask
		eor	r4, r4, r0, lsl r3
		strb	r4, [r6, r2]
		
		ldmfd	sp!, {r1-r10, pc}	@ return r0=1 (ERROR_CORRECTED)
		
2:		@ count '1' bits
		mov	r2, #0
		
3:		movs	r0, r0, lsr #1 		@ shift last bit to the carry
    		adc	r2, r2, r2		@ add carry to count
		bne	3b
		
		cmp	r2, #1
		movne	r0, #4			@ return r0=4 (UNCORRECTABLE_ERROR)
		moveq	r0, #2			@ return r0=2 (ECC_CODE_INVALID)
		
		ldmfd	sp!, {r1-r10, pc}		
		.ltorg
@--------------------------------
@  r0 = 0=NO_ERROR, 1=ERROR_CORRECTED, 2=ECC_CODE_INVALID, 4=UNCORRECTABLE_ERROR

Show_Flash_Error:		
		stmfd	sp!, {r0-r4, lr}
		
		cmp	r0, #4
		bne	1f
		adr	r0, un_flash
		bl	Output_String
		ldr	r0, =ERROR_FLASH_ERROR
		b	Flash_Leds_Forever
				 			
1:		cmp	r0, #2
		bne	1f
		adr	r0, ecc_error
		bl	Output_String
		ldr	r0, =ERROR_FLASH_ECC
		b	Flash_Leds_Forever
		
1:		cmp	r0, #1
		bne	1f
		adr	r0, ecc_warning
		bl	Output_String

1:
		ldmfd	sp!, {r0-r4, pc}		
		
		.ltorg
un_flash:	.string	"ERR: Uncorrectable flash error.\r\n" 
ecc_error:	.string	"ERR: flash ECC corrupt.\r\n" 
ecc_warning:	.string	"Warn: flash error corrected.\r\n" 
		.align	@ Must align after strings or bytes, so following code is aligned (stupid, eh!)

@--------------------------------
@
@ Load and correct a 512 byte page
@
@ on error: prints message and flashes LED error message
@ R0 = flash address for page (aligned 512)
@ R1 = destination in memory (aligned 512) 
@ 16 byte spare data is stores in 0x00007100-0x000071ff 
@
Load_Flash_Page:		
		stmfd	sp!, {r0-r11, lr}
		
		mov	r9, #0x60000000
nand_data	.req	r9			@ address of NAND data register
		
		add	r10, nand_data, #0x00400000
nand_ctrl	.req	r10			@ address of NAND control register
		
		add	r11, nand_data, #0x00800000
nand_stat	.req	r11			@ address of NAND status register
		
		mov	r2, #6
		strb	r2, [nand_ctrl]		@ CE, CLE	
		 	
		mov	r2, #0
		strb	r2, [nand_data]		@ 0 - Read1 command	
		 	
		mov	r2, #5
		strb	r2, [nand_ctrl]		@ CE, ALE
		 	
		mov	r2, #0
		strb	r2, [nand_data]		@ 0 - byte address in page (always 0)
						@ A8 infered as 0 from read1 command
		 	
		mov	r2, r0, lsr #9
		strb	r2, [nand_data]		@ low byte of page (512 byte) flash address
		 	
		mov	r2, r0, lsr #17
		strb	r2, [nand_data]		@ mid byte of page (512 byte) flash address
		 	
		mov	r2, r0, lsr #25
		strb	r2, [nand_data]		@ high byte of page (512 byte) flash address
		
		mov	r2, #4
		strb	r2, [nand_ctrl]		@ CLE
		strb	r2, [nand_ctrl]		@ CLE
			
		mov	r0, #0x00000100		@ cycles till timeout
1:		subs	r0, r0, #1		@ decrement timeout
		bne	2f			@ if we didn't timeout
		adr	r0, flash_timeout	@ we timed out
		bl	Output_String
		ldr	r0, =ERROR_FLASH_TIMEOUT
		b	Flash_Leds_Forever
2:		ldrb	r2, [nand_stat]
		tst	r2, #0x20		@ test busy bit
		beq	1b 			@ wait till flash not busy
		 	
		mov	r2, #0			@ load the 512 byte page
1:		ldrb	r0, [nand_data] 	@ get flash data byte
		strb	r0, [r1, r2]		@ store byte
		add	r2, r2, #1
		cmp	r2, #512
		bne	1b
		
@		@@@@@@@@ testing: data change a bit
@		ldrb	r0, [r1, #0xA3]
@		eor	r0, r0, #0x80
@		strb	r0, [r1, #0xA3]
		
		mov	r3, #0x00007100		@ copy spare data to location after ecc lookup table
		mov	r2, #0
1:		ldrb	r0, [nand_data] 	@ get data byte
		strb	r0, [r3, r2]
		add	r2, r2, #1
		cmp	r2, #16
		bne	1b
		
@		@@@@@@@@ testing: ecc change a bit
@		ldrb	r0, [r3, #0x01]
@		eor	r0, r0, #0x80
@		strb	r0, [r3, #0x01]
		
		ldrb	r4, [r3, #1]		@ note ecc format translation (swap ECC0 <==> ECC1)
		ldrb	r2, [r3, #0]		
		orr	r4, r4, r2, lsl #8	@ note ecc format translation (swap ECC0 <==> ECC1)	
		ldrb	r2, [r3, #2]		
		orr	r4, r4, r2, lsl #16	@ r4 has ecc low half-page	
				
		ldrb	r5, [r3, #6]		@ note ecc format translation (swap ECC0 <==> ECC1)
		ldrb	r2, [r3, #3]		
		orr	r5, r5, r2, lsl #8	@ note ecc format translation (swap ECC0 <==> ECC1)	
		ldrb	r2, [r3, #7]		
		orr	r5, r5, r2, lsl #16	@ r5 has ecc high half-page		
				
		mov	r0, #0
		strb	r0, [nand_ctrl]		@ all signals low		
				
		mov	r6, r1
		mov	r1, r4
		bl	Generate_HalfPage_ECC		@ returns ecc in r0
		bl	Correct_HalfPage_using_ECC	
		cmp	r0, #0
		blne	Show_Flash_Error

		add	r6, r6, #0x0100
		mov	r1, r5
		bl	Generate_HalfPage_ECC		@ returns ecc in r0
		bl	Correct_HalfPage_using_ECC	
		cmp	r0, #0
		blne	Show_Flash_Error
		
		ldmfd	sp!, {r0-r11, pc}	
			
		.ltorg
flash_timeout:	.string	"ERR: flash timeout.\r\n" 
		.align	@ Must align after strings or bytes, so following code is aligned (stupid, eh!)		
@--------------------------------
Load_Redboot:

		stmfd	sp!, {r0-r4, lr}
		ldr	r2, =REDBOOT_FLASH_ADDRESS	@ flash address
		mov	r3, #0x00008000		@ memory address
		mov	r4, #0
		
1:		add	r0, r2, r4		
		add	r1, r3, r4
		bl	Load_Flash_Page
		
@		cmp	r0, #0
@		beq	2f
@		preg	r0
@		preg	r4
		
@2:		cmp	r1, #0
@		beq	3f
@		preg	r1
@		preg	r4
		
3:		add	r4, r4, #0x0200
		cmp	r4, #0x00040000		@ load 256 k 
		bne	1b
	
		ldr	r0, [r3]
		ldr	r1, =0x53555243		@"CRUS"
		cmp	r0, r1
		beq	2f
@		bne	2f
				
		adr	r0, no_CRUS
		bl	Output_String
		ldr	r0, =ERROR_NO_FLASH_CRUS
		b	Flash_Leds_Forever
		
2:		ldmfd	sp!, {r0-r4, pc}
		
		.ltorg
no_CRUS:	.string	"ERR: CRUS not in flash\r\n" 
		.align	@ Must align after strings or bytes, so following code is aligned (stupid, eh!)

#if 0
@--------------------------------
Test_ECC:

		stmfd	sp!, {r1-r7, lr}
					
		@ clear memory for table and test
		ldr	r2, =0x00007000		@ start address
		ldr	r3, =0x000071ff		@ last address
		mov	r0, #0
1:		strb	r0, [r2], #+1
		cmp	r2, r3
		bne	1b
		
		bl	Create_ECC_Lookup_Table
		
		ldr	r7, =0x000071ff
		mov	r0, #0xff
		strb	r0, [r7]		@ set byte	
		
		ldr	r6, =0x00007100
		bl	Generate_HalfPage_ECC
		mov	r2, r0			@ store old ecc
		preg	r0
		
		ldr	r7, =0x000071ff
		mov	r0, #0xff
		strb	r0, [r7]		@ set byte
		
		ldr	r6, =0x00007100
		bl	Generate_HalfPage_ECC	@ get new ecc
		mov	r3, r0
		preg	r0			@ output ecc word

		ldr	r6, =0x00007100
		mov	r1, r2
		mov	r0, r3
		eor	r1, r1, #1
		bl	Correct_HalfPage_using_ECC
		preg	r0			@ result

		ldr	r2, =0x00007000		@ start address
		ldr	r3, =0x000071ff		@ last address
		bl	Output_Memory_Range
		
		ldmfd	sp!, {r1-r7, pc}		
		.ltorg

@--------------------------------
Test_Load_Flash:

		stmfd	sp!, {r1-r3, lr}
		
		@ clear memory
		ldr	r2, =0x00007100		@ start address
		ldr	r3, =0x00007400		@ last address
		mov	r0, #0
1:		strb	r0, [r2], #+1
		cmp	r2, r3
		bne	1b
							
		ldr	r0, =0x07D04000		@ flash address
		mov	r1, #0x00007200		@ memory address
		
		bl	Load_Flash_Page
		preg	r0
		preg	r1
		
		ldr	r2, =0x00007000		@ start address
		ldr	r3, =0x00007400		@ last address
		bl	Output_Memory_Range		
		
		ldmfd	sp!, {r1-r3, pc}		
		.ltorg
#endif			
#endif // BOOT_METHOD == FLASH	

@--------------------------------
@ R0 = 32 bit flashing pattern, even bits green, odd bits red
@	bits rotated right by 2, every 1/8th of a second 		
Flash_Leds_Forever:		
		add	r3, rb, #0x00840000
@		mov	r1, #0x03
		
		@ wait 1/8 second		
1:		mov	r2, #0x00080000
2:		subs	r2, r2, #1
		bne	2b
		
		@ turn red and green leds on
		and	r1, r0, #3
		str	r1, [r3, #0x20]
		mov	r0, r0, ror #2

		b	1b
		.ltorg
		
	
@--------------------------------		
Halt:		b	Halt

@--------------------------------
		.ltorg
		.align

		.org	2048			@ ensures the file is 2k in size. (no more, no less)
		.end
