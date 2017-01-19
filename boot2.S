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
=============================================================================*/		
		.text
rb		.req	r10
				
		.global		_start
_start:
		@.ascii  "CRUS"		@ address 0x80014000, the book is wrong this isn't needed for serial
		
		add	sp, pc, #0x1000 @ set decending stack near top off 
					@ ethernet fifo, our code is at
					@ the beginning of the fifo
					
		mov	rb, #0x80000000	@ used gobally (constant to base address of hardware)
										
	
		bl	Flush_UART
		

		@ wait one second		
1:		mov	r2, #0x00800000
2:		subs	r2, r2, #1
		bne	2b

		adr	r0, greetings
		bl	Output_String
		

		b	Flash_Leds_Forever
		
		.ltorg
		
@--------------------------------		
Flash_Leds_Forever:		
		add	r0, rb, #0x00840000
		mov	r1, #0x02
		
		@ wait one second		
1:		mov	r2, #0x00080000
2:		subs	r2, r2, #1
		bne	2b
		
		@ turn red and green leds on
		str	r1, [r0, #0x20]
		eor	r1, r1, #0x03

		b	1b
		.ltorg
		
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

		stmfd	sp!, {r0, lr}
		
		.rept	4
		mov	r1, r1, ROR #24
		bl	Output_Byte
		.endr
		
		ldmfd	sp!, {r0, pc}
		.ltorg

@--------------------------------		
@ Intput byte into R0, logical 32bit extended
Input_Byte:	
		stmfd	sp!, {r1-r2, lr}
		
		add	r2, rb, #0x008c0000

1:		ldr	r1, [r2, #0x18]		@ wait if buffer is full
		tst	r1, #0x10
		bne	1b

		ldrb	r0, [r2]
		
		ldmfd	sp!, {r1-r2, pc}		
		.ltorg
				
@--------------------------------		
@ word stored in R1
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

@--------------------------------		
@	r2 = start word address
@	r3 = last word address
Output_Memory_Range:

		stmfd	sp!, {r0-r3, lr}

		mov	r1, #0x02
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


@--------------------------------		
Halt:		b	Halt

@--------------------------------
		.ltorg
		.align
greetings:	.string	"\r\n\r\n>> OPEN TS-72XX BOOT2 SYSTEM, Rev 1.00\r\n" 


@		.org	2048-4
		.end
