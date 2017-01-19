ts-preboot-ts9.bin:     file format binary

80013ffc:	.ascii  	"CRUS"
// turn on green and red leds
80014000:	e59f0024 	ldr	r0, [pc, #36]	; 0x8001402c r0=0x80840020
80014004:	e3a01003 	mov	r1, #3	; 0x3	
80014008:	e5801000 	str	r1, [r0]	; Turn on Green and Red LEDs
// set full decending stack at top of MAC fifo
8001400c:	e59fd01c 	ldr	sp, [pc, #28]	; 0x80014030 sp=0x80015100
// dissable interupt and enter supervisor mode, get ready to jump into THUMB mode
80014010:	e3a000d3 	mov	r0, #211	; 0xd3
80014014:	e129f000 	msr	CPSR_fc, r0
80014018:	e3800020 	orr	r0, r0, #32	; 0x20
8001401c:	e169f000 	msr	SPSR_fc, r0
80014020:	e59f000c 	ldr	r0, [pc, #12]	; 0x80014034 r0=0x80014051
80014024:	e3a0e603 	mov	lr, #3145728	; return to 0x300000 SDRAM ARM mode, which will contain the TS-BOOTROM
80014028:	e1b0f000 	movs	pc, r0		; jump to THUMB instructions at 0x80014050 ? why the 1?
8001402c:	.word		0x80840020
80014030:	.word		0x80015100
80014034:	.word		0x80014051

// start of thumb instructions
80014038:	7800      	ldrb	r0, [r0, #0]
8001403a:	4770      	bx	lr

8001403c:	8800      	ldrh	r0, [r0, #0]
8001403e:	4770      	bx	lr

80014040:	6800      	ldr	r0, [r0, #0]
80014042:	4770      	bx	lr

80014044:	7001      	strb	r1, [r0, #0]
80014046:	4770      	bx	lr

80014048:	8001      	strh	r1, [r0, #0]
8001404a:	4770      	bx	lr

8001404c:	6001      	str	r1, [r0, #0]
8001404e:	4770      	bx	lr

// THUMB entrace point
80014050:	b530      	push	{r4, r5, lr}
80014052:	484e      	ldr	r0, [pc, #312]	(0x8001418c) r0 = 0x00002665
80014054:	fae8f000 	bl	0x80014628	; Microsecond_delay(r0)
80014058:	484d      	ldr	r0, [pc, #308]	(0x80014190) r0 = 0x800146fc	"\r\n\r\n>> TS-NANDBOOT, Rev 1.00 - built 10:14:31, Mar  7 2005\r\n"
8001405a:	fa6ff000 	bl	0x8001453c	;Print_string(R0)
8001405e:	484d      	ldr	r0, [pc, #308]	(0x80014194) r0 = 0x8001473c	">> Copyright (C) 2004, Technologic Systems\r\n"
80014060:	fa6cf000 	bl	0x8001453c	;Print_string(R0)
80014064:	484c      	ldr	r0, [pc, #304]	(0x80014198) r0 = 0x80840020
80014066:	2102      	mov	r1, #2
80014068:	fff0f7ff 	bl	0x8001404c	; str	r1, [r0]	; Red LED = ON, Green = OFF

8001406c:	f8faf000 	bl	0x80014264	; call Configure_SDRAM

80014070:	4849      	ldr	r0, [pc, #292]	(0x80014198) r0 = 0x80840020
80014072:	2103      	mov	r1, #3
80014074:	ffeaf7ff 	bl	0x8001404c	; str	r1, [r0]	; Red LED = ON, Green = ON

// configure the 32MB of SDRAM at 0x0000_0000-0x0FFF_FFFF, nSDCE3
80014078:	2180      	mov	r1, #128
8001407a:	2000      	mov	r0, #0
8001407c:	0409      	lsl	r1, r1, #16
8001407e:	f9a9f000 	bl	0x800143d4	;Memory_test:  start_address=0x0000_0000, num_words=0x0080_0000

80014082:	2080      	mov	r0, #128
80014084:	2180      	mov	r1, #128
80014086:	0440      	lsl	r0, r0, #17
80014088:	0409      	lsl	r1, r1, #16
8001408a:	f9a3f000 	bl	0x800143d4	;Memory_test:  start_address=0x0100_0000, num_words=0x0080_0000

8001408e:	2080      	mov	r0, #128
80014090:	2180      	mov	r1, #128
80014092:	04c0      	lsl	r0, r0, #19
80014094:	0409      	lsl	r1, r1, #16
80014096:	f99df000 	bl	0x800143d4	;Memory_test:  start_address=0x0400_0000, num_words=0x0080_0000

8001409a:	20a0      	mov	r0, #160
8001409c:	2180      	mov	r1, #128
8001409e:	04c0      	lsl	r0, r0, #19
800140a0:	0409      	lsl	r1, r1, #16
800140a2:	f997f000 	bl	0x800143d4	;Memory_test:  start_address=0x0500_0000, num_words=0x0080_0000

800140a6:	20e0      	mov	r0, #224
800140a8:	0600      	lsl	r0, r0, #24	; r0=0xE0000000 SDRAM start
800140aa:	faf3f000 	bl	0x80014694	; call Memory_detect
800140ae:	2800      	cmp	r0, #0
800140b0:	d017      	beq	0x800140e2	; optional memory not detected, don't configure it

// configure the optional 32MB of SDRAM at 0xE000_0000-0xEFFF-FFFF, nSDCE2
800140b2:	20e0      	mov	r0, #224
800140b4:	2180      	mov	r1, #128
800140b6:	0600      	lsl	r0, r0, #24
800140b8:	0409      	lsl	r1, r1, #16
800140ba:	f98bf000 	bl	0x800143d4	;Memory_test:  start_address=0xE000_0000, num_words=0x0080_0000

800140be:	20e1      	mov	r0, #225
800140c0:	2180      	mov	r1, #128
800140c2:	0600      	lsl	r0, r0, #24
800140c4:	0409      	lsl	r1, r1, #16
800140c6:	f985f000 	bl	0x800143d4	;Memory_test:  start_address=0xE100_0000, num_words=0x0080_0000

800140ca:	20e4      	mov	r0, #228
800140cc:	2180      	mov	r1, #128
800140ce:	0600      	lsl	r0, r0, #24
800140d0:	0409      	lsl	r1, r1, #16
800140d2:	f97ff000 	bl	0x800143d4	;Memory_test:  start_address=0xE400_0000, num_words=0x0080_0000

800140d6:	20e5      	mov	r0, #229
800140d8:	2180      	mov	r1, #128
800140da:	0600      	lsl	r0, r0, #24
800140dc:	0409      	lsl	r1, r1, #16
800140de:	f979f000 	bl	0x800143d4	;Memory_test:  start_address=0xE500_0000, num_words=0x0080_0000

800140e2:	20d0      	mov	r0, #208
800140e4:	0600      	lsl	r0, r0, #24	; r0=0xD0000000 SDRAM not used
800140e6:	fad5f000 	bl	0x80014694	; call Memory_detect
800140ea:	2800      	cmp	r0, #0
800140ec:	d017      	beq	0x8001411e

// configure the optional 32MB of SDRAM at 0xD000_0000-0xDFFF_FFFF, nSDCE1
800140ee:	20d0      	mov	r0, #208
800140f0:	2180      	mov	r1, #128
800140f2:	0600      	lsl	r0, r0, #24
800140f4:	0409      	lsl	r1, r1, #16
800140f6:	f96df000 	bl	0x800143d4	;Memory_test:  start_address=0xD000_0000, num_words=0x0080_0000

800140fa:	20d1      	mov	r0, #209
800140fc:	2180      	mov	r1, #128
800140fe:	0600      	lsl	r0, r0, #24
80014100:	0409      	lsl	r1, r1, #16
80014102:	f967f000 	bl	0x800143d4	;Memory_test:  start_address=0xD100_0000, num_words=0x0080_0000

80014106:	20d4      	mov	r0, #212
80014108:	2180      	mov	r1, #128
8001410a:	0600      	lsl	r0, r0, #24
8001410c:	0409      	lsl	r1, r1, #16
8001410e:	f961f000 	bl	0x800143d4	;Memory_test:  start_address=0xD400_0000, num_words=0x0080_0000

80014112:	20d5      	mov	r0, #213
80014114:	2180      	mov	r1, #128
80014116:	0600      	lsl	r0, r0, #24
80014118:	0409      	lsl	r1, r1, #16
8001411a:	f95bf000 	bl	0x800143d4	;Memory_test:  start_address=0xD500_0000, num_words=0x0080_0000

8001411e:	20c0      	mov	r0, #192
80014120:	0600      	lsl	r0, r0, #24	; r0=0xC0000000 SDRAM not used
80014122:	fab7f000 	bl	0x80014694	; call Memory_detect
80014126:	2800      	cmp	r0, #0
80014128:	d017      	beq	0x8001415a

// configure the optional 32MB of SDRAM at 0xC000_0000-0xCFFF_FFFF, nSDCE0
8001412a:	20c0      	mov	r0, #192
8001412c:	2180      	mov	r1, #128
8001412e:	0600      	lsl	r0, r0, #24
80014130:	0409      	lsl	r1, r1, #16
80014132:	f94ff000 	bl	0x800143d4	;Memory_test:  start_address=0xC000_0000, num_words=0x0080_0000

80014136:	20c1      	mov	r0, #193
80014138:	2180      	mov	r1, #128
8001413a:	0600      	lsl	r0, r0, #24
8001413c:	0409      	lsl	r1, r1, #16
8001413e:	f949f000 	bl	0x800143d4	;Memory_test:  start_address=0xC100_0000, num_words=0x0080_0000

80014142:	20c4      	mov	r0, #196
80014144:	2180      	mov	r1, #128
80014146:	0600      	lsl	r0, r0, #24
80014148:	0409      	lsl	r1, r1, #16
8001414a:	f943f000 	bl	0x800143d4	;Memory_test:  start_address=0xC400_0000, num_words=0x0080_0000

8001414e:	20c5      	mov	r0, #197
80014150:	2180      	mov	r1, #128
80014152:	0600      	lsl	r0, r0, #24
80014154:	0409      	lsl	r1, r1, #16
80014156:	f93df000 	bl	0x800143d4	;Memory_test:  start_address=0xC500_0000, num_words=0x0080_0000

8001415a:	480f      	ldr	r0, [pc, #60]	(0x80014198) r0 = 0x80840020
8001415c:	2101      	mov	r1, #1
8001415e:	ff75f7ff 	bl	0x8001404c	; str	r1, [r0] ; Red Off, Green On

// configure NAND FLASH region 0x6000_0000-0x6FFF_FFFF
80014162:	480e      	ldr	r0, [pc, #56]	(0x8001419c) r0 = 0x80080018
80014164:	490e      	ldr	r1, [pc, #56]	(0x800141a0) r1 = 0x00004508
80014166:	ff71f7ff 	bl	0x8001404c	; str	r1, [r0]; SRAM BANK6 0x6000_0000-0x6FFF_FFFF
							; NAND FLASH memory bank
							; WST2=8, RBLE=1, WST1=8, IDCY=8 

// copy 16k TS-BOOTROM from start of flash to SDRAM address 0x00300000
8001416a:	25c0      	mov	r5, #192
8001416c:	03ad      	lsl	r5, r5, #14	; r5=0x00300000, SDRAM
8001416e:	2400      	mov	r4, #0

80014170:	1c20      	mov	r0, r4
80014172:	1c29      	mov	r1, r5
80014174:	f816f000 	bl	0x800141a4	; call Read_flash(R0=16 bit flash address, r1=32 bit mem address)
80014178:	2380      	mov	r3, #128
8001417a:	009b      	lsl	r3, r3, #2
8001417c:	3401      	add	r4, #1		; next page
8001417e:	18ed      	add	r5, r5, r3	; next 512 byte SDRAM location
80014180:	2c1f      	cmp	r4, #31		; copy 32 pages, =16KB
80014182:	ddf5      	ble	0x80014170

80014184:	2000      	mov	r0, #0
80014186:	bc30      	pop	{r4, r5}
80014188:	bc02      	pop	{r1}
8001418a:	4708      	bx	r1

8001418c:	.word		0x00002665 
80014190:	.word		0x800146fc
80014194:	.word		0x8001473c
80014198:	.word		0x80840020
8001419c:	.word		0x80080018
800141a0:	.word		0x00004508


//=====================================================================================================
// Read_flash(R0=16 bit flash address, r1=32 bit mem address)
//
// copies 512 bytes from NAND flash
//
//ctrl: 
//(0x04 = CE,  Chip Enable) 
//(0x02 = CLE, Command Latch Enable) 
//(0x01 = ALE, Address Latch Enable)

800141a4:	b570      	push	{r4, r5, r6, lr}
// Command: 0
800141a6:	1c04      	mov	r4, r0
800141a8:	1c0e      	mov	r6, r1
800141aa:	482a      	ldr	r0, [pc, #168]	(0x80014254)	; r0=0x60400000	 NAND FLASH Control register (last 3 bits)
800141ac:	2106      	mov	r1, #6
800141ae:	ff49f7ff 	bl	0x80014044	; strb	r1, [r0] ; store #6 in flash controller, CE and CLE
800141b2:	20c0      	mov	r0, #192
800141b4:	05c0      	lsl	r0, r0, #23			; r0=0x6000000 NAND flash data register
800141b6:	2100      	mov	r1, #0
800141b8:	ff44f7ff 	bl	0x80014044	; strb	r1, [r0] ; store #0 in flash data register, read mode 1
// Address: 0, data bits 7-0, data bits 15-8, 0
800141bc:	4825      	ldr	r0, [pc, #148]	(0x80014254)	; r0=0x60400000	 NAND FLASH Control register
800141be:	2105      	mov	r1, #5
800141c0:	ff40f7ff 	bl	0x80014044	; strb	r1, [r0] ; store #5 in flash controller, CE and ALE
800141c4:	20c0      	mov	r0, #192
800141c6:	05c0      	lsl	r0, r0, #23			; r0=0x6000000 NAND flash data register
800141c8:	2100      	mov	r1, #0
800141ca:	ff3bf7ff 	bl	0x80014044	; strb	r1, [r0] ; store #0 in flash data register,  
800141ce:	0623      	lsl	r3, r4, #24
800141d0:	20c0      	mov	r0, #192
800141d2:	0e19      	lsr	r1, r3, #24	; just last byte
800141d4:	05c0      	lsl	r0, r0, #23			; r0=0x6000000 NAND flash data register
800141d6:	ff35f7ff 	bl	0x80014044	; strb	r1, [r0] ; store first byte passed into this function in flash data reg 
800141da:	23ff      	mov	r3, #255
800141dc:	021b      	lsl	r3, r3, #8
800141de:	4023      	and	r3, r4
800141e0:	20c0      	mov	r0, #192
800141e2:	0a19      	lsr	r1, r3, #8
800141e4:	05c0      	lsl	r0, r0, #23			; r0=0x6000000 NAND flash data register
800141e6:	ff2df7ff 	bl	0x80014044	; strb	r1, [r0] ; store second byte of word passed to this function
800141ea:	20c0      	mov	r0, #192
800141ec:	05c0      	lsl	r0, r0, #23			; r0=0x6000000 NAND flash data register
800141ee:	2100      	mov	r1, #0
800141f0:	ff28f7ff 	bl	0x80014044	; strb	r1, [r0]; store 0 in data register
800141f4:	4817      	ldr	r0, [pc, #92]	(0x80014254)	; r0=0x60400000	 NAND FLASH Control register
800141f6:	2104      	mov	r1, #4
800141f8:	ff24f7ff 	bl	0x80014044	; strb	r1, [r0]; store 4 in control register
// wait till flash is ready
800141fc:	4815      	ldr	r0, [pc, #84]	(0x80014254)	; r0=0x60400000	 NAND FLASH Control register
800141fe:	2104      	mov	r1, #4				
80014200:	4d15      	ldr	r5, [pc, #84]	(0x80014258)	; r5=0x000186a0 ;100000
80014202:	ff1ff7ff 	bl	0x80014044	; strb	r1, [r0]; store 4 in control reg
80014206:	e000      	b	0x8001420a

80014208:	3d01      	sub	r5, #1

8001420a:	20c1      	mov	r0, #193
8001420c:	05c0      	lsl	r0, r0, #23			; r0=0x6080000 NAND flash busy status (bit 5)
8001420e:	ff13f7ff 	bl	0x80014038	;ldrb	r0, [r0]
80014212:	0602      	lsl	r2, r0, #24
80014214:	0e12      	lsr	r2, r2, #24	; just the bottom byte
80014216:	2320      	mov	r3, #32
80014218:	401a      	and	r2, r3
8001421a:	2a00      	cmp	r2, #0
8001421c:	d101      	bne	0x80014222	; branch if busy bit is set
8001421e:	2d00      	cmp	r5, #0
80014220:	dcf2      	bgt	0x80014208	; try a max of 100,000 times

80014222:	2d00      	cmp	r5, #0
80014224:	d104      	bne	0x80014230
80014226:	480d      	ldr	r0, [pc, #52]	(0x8001425c)	; r0=0x8001476c  "flash timeout!"
80014228:	f988f000 	bl	0x8001453c	;Print_string(R0)
8001422c:	fa14f000 	bl	0x80014658	; Flash_leds_forever
// read flash memory
80014230:	2400      	mov	r4, #0
80014232:	20c0      	mov	r0, #192
80014234:	05c0      	lsl	r0, r0, #23	; r0=0x6000000 NAND flash data register
80014236:	fefff7ff 	bl	0x80014038	;ldrb	r0, [r0]
8001423a:	4b09      	ldr	r3, [pc, #36]	(0x80014260)	; r3=0x000001ff
8001423c:	5530      	strb	r0, [r6, r4]
8001423e:	3401      	add	r4, #1
80014240:	429c      	cmp	r4, r3		; compare count to 0x01FF
80014242:	ddf6      	ble	0x80014232
// turn of CE, to de-select flash
80014244:	4803      	ldr	r0, [pc, #12]	(0x80014254)	; r0=0x60400000 ; NAND FLASH Control register
80014246:	2100      	mov	r1, #0
80014248:	fefcf7ff 	bl	0x80014044	; strb	r1, [r0]; store 0 in ctrl
8001424c:	bc70      	pop	{r4, r5, r6}
8001424e:	bc01      	pop	{r0}
80014250:	4700      	bx	r0
80014252:	.hword		0x0000      	 
80014254:	.word		0x60400000
80014258:	.word		0x000186a0
8001425c:	.word		0x8001476c
80014260:	.word		0x000001ff

//=====================================================================================================
Configure_SDRAM:
80014264:	b530      	push	{r4, r5, lr}
80014266:	4c44      	ldr	r4, [pc, #272]	(0x80014378)	; r4=0x0021002c
80014268:	4844      	ldr	r0, [pc, #272]	(0x8001437c)	; r0=0x8006001c
8001426a:	1c21      	mov	r1, r4
8001426c:	feeef7ff 	bl	0x8001404c	; str	r1, [r0]; configure SDRAM Bank3 0x0000_0000
							; RAS Latency = 2, CAS Latency = 2, Four bank device
80014270:	1c21      	mov	r1, r4
80014272:	4843      	ldr	r0, [pc, #268]	(0x80014380)	; r0=0x80060018
80014274:	4d43      	ldr	r5, [pc, #268]	(0x80014384)	; r5=0x80060004
80014276:	fee9f7ff 	bl	0x8001404c	; str	r1, [r0]; configure SDRAM Bank2 0xE000_0000
							; RAS Latency = 2, CAS Latency = 2, Four bank device
8001427a:	1c21      	mov	r1, r4
8001427c:	4842      	ldr	r0, [pc, #264]	(0x80014388)	; r0=0x80060014
8001427e:	fee5f7ff 	bl	0x8001404c	; str	r1, [r0]; configure SDRAM Bank1 0xD000_0000
							; RAS Latency = 2, CAS Latency = 2, Four bank device
80014282:	1c21      	mov	r1, r4
80014284:	4841      	ldr	r0, [pc, #260]	(0x8001438c)	; r0=0x80060010
80014286:	fee1f7ff 	bl	0x8001404c	; str	r1, [r0]; configure SDRAM Bank0 0xC000_0000
							; RAS Latency = 2, CAS Latency = 2, Four bank device

8001428a:	4941      	ldr	r1, [pc, #260]	(0x80014390)	; r1=0x80000003
8001428c:	1c28      	mov	r0, r5
8001428e:	4c41      	ldr	r4, [pc, #260]	(0x80014394)	; r4=0x0000dead
80014290:	fedcf7ff 	bl	0x8001404c	; str	r1, [r0];GIConfig  CKE=1, issue NOP command to SDRAM 

80014294:	20c4      	mov	r0, #196
80014296:	f9c7f000 	bl	0x80014628	; Microsecond_delay(r0)  ; wait 200mSecs

8001429a:	493f      	ldr	r1, [pc, #252]	(0x80014398)	; r1=0x80000001
8001429c:	1c28      	mov	r0, r5
8001429e:	fed5f7ff 	bl	0x8001404c	; str	r1, [r0] ;GIConfig  CKE=1, issue pre-charge all command to SDRAM

800142a2:	1c21      	mov	r1, r4
800142a4:	2000      	mov	r0, #0
800142a6:	fecff7ff 	bl	0x80014048	; strh	r1, [r0] ; store 0xDEAD in 0x0000_0000

800142aa:	2080      	mov	r0, #128
800142ac:	1c21      	mov	r1, r4
800142ae:	0380      	lsl	r0, r0, #14
800142b0:	fecaf7ff 	bl	0x80014048	; strh	r1, [r0] ; store 0xDEAD in 0x0020_0000

800142b4:	2080      	mov	r0, #128
800142b6:	1c21      	mov	r1, r4
800142b8:	03c0      	lsl	r0, r0, #15
800142ba:	fec5f7ff 	bl	0x80014048	; strh	r1, [r0] ; store 0xDEAD in 0x0040_0000

800142be:	20c0      	mov	r0, #192
800142c0:	1c21      	mov	r1, r4
800142c2:	03c0      	lsl	r0, r0, #15
800142c4:	fec0f7ff 	bl	0x80014048	; strh	r1, [r0] ; store 0xDEAD in 0x0060_0000

800142c8:	20e0      	mov	r0, #224
800142ca:	1c21      	mov	r1, r4
800142cc:	0600      	lsl	r0, r0, #24
800142ce:	febbf7ff 	bl	0x80014048	; strh	r1, [r0] ; store 0xDEAD in 0xE000_0000

800142d2:	1c21      	mov	r1, r4
800142d4:	4831      	ldr	r0, [pc, #196]	(0x8001439c)	; r0=0xe0200000
800142d6:	feb7f7ff 	bl	0x80014048	; strh	r1, [r0] ; store 0xDEAD in 0xE020_0000

800142da:	1c21      	mov	r1, r4
800142dc:	4830      	ldr	r0, [pc, #192]	(0x800143a0)	; r0=0xe0400000
800142de:	feb3f7ff 	bl	0x80014048	; strh	r1, [r0] ; store 0xDEAD in 0xE040_0000

800142e2:	1c21      	mov	r1, r4
800142e4:	482f      	ldr	r0, [pc, #188]	(0x800143a4)	; r0=0xe0600000
800142e6:	feaff7ff 	bl	0x80014048	; strh	r1, [r0] ; store 0xDEAD in 0xE060_0000

800142ea:	20d0      	mov	r0, #208
800142ec:	1c21      	mov	r1, r4
800142ee:	0600      	lsl	r0, r0, #24
800142f0:	feaaf7ff 	bl	0x80014048	; strh	r1, [r0] ; store 0xDEAD in 0xD000_0000

800142f4:	1c21      	mov	r1, r4
800142f6:	482c      	ldr	r0, [pc, #176]	(0x800143a8)	; r0=0xd0200000
800142f8:	fea6f7ff 	bl	0x80014048	; strh	r1, [r0] ; store 0xDEAD in 0xD020_0000

800142fc:	1c21      	mov	r1, r4
800142fe:	482b      	ldr	r0, [pc, #172]	(0x800143ac)	; r0=0xd0400000
80014300:	fea2f7ff 	bl	0x80014048	; strh	r1, [r0] ; store 0xDEAD in 0xD040_0000

80014304:	1c21      	mov	r1, r4
80014306:	482a      	ldr	r0, [pc, #168]	(0x800143b0)	; r0=0xd0600000
80014308:	fe9ef7ff 	bl	0x80014048	; strh	r1, [r0] ; store 0xDEAD in 0xD060_0000

8001430c:	20c0      	mov	r0, #192
8001430e:	1c21      	mov	r1, r4
80014310:	0600      	lsl	r0, r0, #24
80014312:	fe99f7ff 	bl	0x80014048	; strh	r1, [r0] ; store 0xDEAD in 0xC000_0000

80014316:	1c21      	mov	r1, r4
80014318:	4826      	ldr	r0, [pc, #152]	(0x800143b4)	; r0=0xc0200000
8001431a:	fe95f7ff 	bl	0x80014048	; strh	r1, [r0] ; store 0xDEAD in 0xC020_0000

8001431e:	1c21      	mov	r1, r4
80014320:	4825      	ldr	r0, [pc, #148]	(0x800143b8)	; r0=0xc0400000
80014322:	fe91f7ff 	bl	0x80014048	; strh	r1, [r0] ; store 0xDEAD in 0xC040_0000

80014326:	1c21      	mov	r1, r4
80014328:	4c24      	ldr	r4, [pc, #144]	(0x800143bc)	; r4=0x80060008 ; RefrshTimr
8001432a:	4825      	ldr	r0, [pc, #148]	(0x800143c0)	; r0=0xc0600000
8001432c:	fe8cf7ff 	bl	0x80014048	; strh	r1, [r0] ; store 0xDEAD in 0xC060_0000

80014330:	2110      	mov	r1, #16
80014332:	1c20      	mov	r0, r4
80014334:	fe8af7ff 	bl	0x8001404c	; str	r1, [r0] ; set SDRAM refresh timer to 16 

80014338:	20c4      	mov	r0, #196
8001433a:	f975f000 	bl	0x80014628	; Microsecond_delay(r0) ; wait 200mSecs

8001433e:	1c20      	mov	r0, r4
80014340:	2173      	mov	r1, #115
80014342:	fe83f7ff 	bl	0x8001404c	; str	r1, [r0] ;  set SDRAM refresh timer to 115

80014346:	491f      	ldr	r1, [pc, #124]	(0x800143c4)	; r1=0x80000002
80014348:	1c28      	mov	r0, r5
8001434a:	fe7ff7ff 	bl	0x8001404c	; str	r1, [r0];  ;GIConfig  CKE=1, issue Enable access to SDRAM device mode register

8001434e:	208c      	mov	r0, #140
80014350:	01c0      	lsl	r0, r0, #7	; r0=0x00004600
80014352:	fe73f7ff 	bl	0x8001403c	; ldrh	r0, [r0]; load half word from bank3 0x00004600

80014356:	481c      	ldr	r0, [pc, #112]	(0x800143c8)	; r0=0xe0004600
80014358:	fe70f7ff 	bl	0x8001403c	; ldrh	r0, [r0]; load half word from bank2 0xE0004600

8001435c:	481b      	ldr	r0, [pc, #108]	(0x800143cc)	; r0=0xd0004600
8001435e:	fe6df7ff 	bl	0x8001403c	; ldrh	r0, [r0]; load half word from bank1 0xD0004600

80014362:	481b      	ldr	r0, [pc, #108]	(0x800143d0)	; r0=0xc0004600
80014364:	fe6af7ff 	bl	0x8001403c	; ldrh	r0, [r0]; load half word from bank0 0xC0004600

80014368:	2180      	mov	r1, #128
8001436a:	0609      	lsl	r1, r1, #24	; r1=0x8000_0000
8001436c:	1c28      	mov	r0, r5
8001436e:	fe6df7ff 	bl	0x8001404c	; str	r1, [r0];GIConfig  CKE=1, SDRAM normal operation mode

80014372:	bc30      	pop	{r4, r5}
80014374:	bc01      	pop	{r0}
80014376:	4700      	bx	r0

80014378:	.word		0x0021002c
8001437c:	.word		0x8006001c
80014380:	.word		0x80060018
80014384:	.word		0x80060004
80014388:	.word		0x80060014
8001438c:	.word		0x80060010
80014390:	.word		0x80000003
80014394:	.word		0x0000dead
80014398:	.word		0x80000001
8001439c:	.word		0xe0200000
800143a0:	.word		0xe0400000
800143a4:	.word		0xe0600000
800143a8:	.word		0xd0200000
800143ac:	.word		0xd0400000
800143b0:	.word		0xd0600000
800143b4:	.word		0xc0200000
800143b8:	.word		0xc0400000
800143bc:	.word		0x80060008
800143c0:	.word		0xc0600000
800143c4:	.word		0x80000002
800143c8:	.word		0xe0004600
800143cc:	.word		0xd0004600
800143d0:	.word		0xc0004600

//=====================================================================================================
Memory_test:  (r0=start address) (r1=num words to test)
800143d4:	b5f0      	push	{r4, r5, r6, r7, lr}
800143d6:	465f      	mov	r7, fp
800143d8:	4656      	mov	r6, sl
800143da:	464d      	mov	r5, r9
800143dc:	4644      	mov	r4, r8
800143de:	b4f0      	push	{r4, r5, r6, r7}
800143e0:	b083      	sub	sp, #12		; make room for 3 local variables
800143e2:	2300      	mov	r3, #0
800143e4:	9002      	str	r0, [sp, #8]	; starting location
800143e6:	9101      	str	r1, [sp, #4]	; words of memory to test
800143e8:	2500      	mov	r5, #0
800143ea:	2400      	mov	r4, #0
800143ec:	9300      	str	r3, [sp, #0]	; mask index (0-4)

800143ee:	9b01      	ldr	r3, [sp, #4]
800143f0:	2700      	mov	r7, #0
800143f2:	46b8      	mov	r8, r7
800143f4:	2b00      	cmp	r3, #0
800143f6:	d949      	bls	0x8001448c

800143f8:	9a02      	ldr	r2, [sp, #8]
800143fa:	9b00      	ldr	r3, [sp, #0]
800143fc:	4e46      	ldr	r6, [pc, #280]	(0x80014518)	; r6=0x800147bc
800143fe:	4691      	mov	r9, r2
80014400:	009b      	lsl	r3, r3, #2
80014402:	199e      	add	r6, r3, r6	; r6=0x800147bc+(local_0*4) = 0x00000000 0x0000aaaa 0x0000ffff 0x00005555
80014404:	44c1      	add	r9, r8		; r9=local_2 + memory_index
80014406:	8831      	ldrh	r1, [r6, #0]	; test bit  mask
80014408:	4648      	mov	r0, r9
8001440a:	fe1df7ff 	bl	0x80014048	; strh	r1, [r0]
8001440e:	4b43      	ldr	r3, [pc, #268]	(0x8001451c)	; r3=0x007ffffe
80014410:	1c1a      	mov	r2, r3
80014412:	4643      	mov	r3, r8		; 
80014414:	439a      	bic	r2, r3
80014416:	9b02      	ldr	r3, [sp, #8]
80014418:	4692      	mov	sl, r2
8001441a:	449a      	add	sl, r3
8001441c:	6833      	ldr	r3, [r6, #0]	; test bit  mask
8001441e:	4650      	mov	r0, sl
80014420:	43db      	mvn	r3, r3
80014422:	041b      	lsl	r3, r3, #16
80014424:	0c19      	lsr	r1, r3, #16
80014426:	fe0ff7ff 	bl	0x80014048	; strh	r1, [r0]
8001442a:	4648      	mov	r0, r9
8001442c:	fe06f7ff 	bl	0x8001403c	; ldrh	r0, [r0]
80014430:	4a3b      	ldr	r2, [pc, #236]	(0x80014520)	; r2=0x0000ffff
80014432:	6831      	ldr	r1, [r6, #0]	; test bit  mask
80014434:	0403      	lsl	r3, r0, #16
80014436:	4693      	mov	fp, r2
80014438:	0c1b      	lsr	r3, r3, #16
8001443a:	400a      	and	r2, r1
8001443c:	4293      	cmp	r3, r2
8001443e:	d003      	beq	0x80014448
80014440:	404b      	eor	r3, r1
80014442:	431c      	orr	r4, r3
80014444:	4643      	mov	r3, r8
80014446:	431d      	orr	r5, r3

80014448:	43c9      	mvn	r1, r1
8001444a:	0409      	lsl	r1, r1, #16
8001444c:	0c09      	lsr	r1, r1, #16
8001444e:	4648      	mov	r0, r9
80014450:	fdfaf7ff 	bl	0x80014048	; strh	r1, [r0]
80014454:	4650      	mov	r0, sl
80014456:	fdf1f7ff 	bl	0x8001403c	; ldrh	r0, [r0]
8001445a:	6836      	ldr	r6, [r6, #0]	; test bit  mask
8001445c:	465a      	mov	r2, fp
8001445e:	0403      	lsl	r3, r0, #16
80014460:	43b2      	bic	r2, r6
80014462:	0c1b      	lsr	r3, r3, #16
80014464:	4693      	mov	fp, r2
80014466:	4293      	cmp	r3, r2
80014468:	d003      	beq	0x80014472
8001446a:	4053      	eor	r3, r2
8001446c:	431c      	orr	r4, r3
8001446e:	4643      	mov	r3, r8
80014470:	431d      	orr	r5, r3

80014472:	0436      	lsl	r6, r6, #16
80014474:	0c31      	lsr	r1, r6, #16
80014476:	4650      	mov	r0, sl
80014478:	fde6f7ff 	bl	0x80014048	; strh	r1, [r0]
8001447c:	2201      	mov	r2, #1
8001447e:	3701      	add	r7, #1
80014480:	1c13      	mov	r3, r2
80014482:	40bb      	lsl	r3, r7
80014484:	4698      	mov	r8, r3		; incrememt memory index to the next word
80014486:	9b01      	ldr	r3, [sp, #4]
80014488:	4598      	cmp	r8, r3
8001448a:	d3b5      	bcc	0x800143f8	; continue till we reach 

8001448c:	9b00      	ldr	r3, [sp, #0]	; goto next bitmask test
8001448e:	3301      	add	r3, #1
80014490:	9300      	str	r3, [sp, #0]	
80014492:	2b03      	cmp	r3, #3
80014494:	d9ab      	bls	0x800143ee

80014496:	1c2b      	mov	r3, r5
80014498:	4323      	orr	r3, r4
8001449a:	2b00      	cmp	r3, #0
8001449c:	d032      	beq	0x80014504	; return is no error

8001449e:	4821      	ldr	r0, [pc, #132]	(0x80014524)	; r0=0x80060004
800144a0:	4921      	ldr	r1, [pc, #132]	(0x80014528)	; r1=0x80000001
800144a2:	fdd3f7ff 	bl	0x8001404c	; str	r1, [r0] ; issue pre-charge all to SDRAM

800144a6:	481f      	ldr	r0, [pc, #124]	(0x80014524)	; r0=0x80060004
800144a8:	2100      	mov	r1, #0
800144aa:	fdcff7ff 	bl	0x8001404c	; str	r1, [r0] ; SDRAM normal operations
800144ae:	2180      	mov	r1, #128
800144b0:	481c      	ldr	r0, [pc, #112]	(0x80014524)	; r0=0x80060004
800144b2:	05c9      	lsl	r1, r1, #23	
800144b4:	fdcaf7ff 	bl	0x8001404c	; str	r1, [r0] ; SDRAM SKE

800144b8:	9b02      	ldr	r3, [sp, #8]
800144ba:	481c      	ldr	r0, [pc, #112]	(0x8001452c)	; r0=0x8001477c		"sdram test failed!\r\n\taddr: "
800144bc:	431d      	orr	r5, r3
800144be:	f83df000 	bl	0x8001453c	;Print_string(R0)
800144c2:	261f      	mov	r6, #31
800144c4:	2301      	mov	r3, #1
800144c6:	40b3      	lsl	r3, r6
800144c8:	402b      	and	r3, r5
800144ca:	2b00      	cmp	r3, #0
800144cc:	d001      	beq	0x800144d2
800144ce:	4818      	ldr	r0, [pc, #96]	(0x80014530)	; r0=0x80014798		"X"
800144d0:	e000      	b	0x800144d4
800144d2:	4818      	ldr	r0, [pc, #96]	(0x80014534)	; r0=0x8001479c		"."
800144d4:	3e01      	sub	r6, #1
800144d6:	f831f000 	bl	0x8001453c	;Print_string(R0)
800144da:	2e00      	cmp	r6, #0
800144dc:	daf2      	bge	0x800144c4
800144de:	4816      	ldr	r0, [pc, #88]	(0x80014538)	; r0=0x800147a0		" ( 'X' - bad bit )\r\n\tdata: "
800144e0:	f82cf000 	bl	0x8001453c	;Print_string(R0)
800144e4:	251f      	mov	r5, #31
800144e6:	2301      	mov	r3, #1
800144e8:	40ab      	lsl	r3, r5
800144ea:	4023      	and	r3, r4
800144ec:	2b00      	cmp	r3, #0
800144ee:	d001      	beq	0x800144f4
800144f0:	480f      	ldr	r0, [pc, #60]	(0x80014530)	; r0=0x80014798		"X"
800144f2:	e000      	b	0x800144f6
800144f4:	480f      	ldr	r0, [pc, #60]	(0x80014534)	; r0=0x8001479c		"."
800144f6:	3d01      	sub	r5, #1
800144f8:	f820f000 	bl	0x8001453c	;Print_string(R0)
800144fc:	2d00      	cmp	r5, #0
800144fe:	daf2      	bge	0x800144e6
80014500:	f8aaf000 	bl	0x80014658	; Flash_leds_forever
// return
80014504:	b003      	add	sp, #12
80014506:	bc78      	pop	{r3, r4, r5, r6}
80014508:	4698      	mov	r8, r3
8001450a:	46a1      	mov	r9, r4
8001450c:	46aa      	mov	sl, r5
8001450e:	46b3      	mov	fp, r6
80014510:	bcf0      	pop	{r4, r5, r6, r7}
80014512:	bc01      	pop	{r0}
80014514:	4700      	bx	r0

80014516:	.hword		0x0000
80014518:	.word		0x800147bc
8001451c:	.word		0x007ffffe
80014520:	.word		0x0000ffff
80014524:	.word		0x80060004
80014528:	.word		0x80000001
8001452c:	.word		0x8001477c
80014530:	.word		0x80014798
80014534:	.word		0x8001479c
80014538:	.word		0x800147a0

//=====================================================================================================
// Print_string(R0)
8001453c:	b5f0      	push	{r4, r5, r6, r7, lr}
8001453e:	1c04      	mov	r4, r0	
80014540:	2084      	mov	r0, #132
80014542:	0540      	lsl	r0, r0, #21	; r0=0x10800000a ; TS7250 Jumpers/flash_status/UART1_DCD/ADC_Status
80014544:	fd78f7ff 	bl	0x80014038	;ldrb	r0, [r0] 
80014548:	0602      	lsl	r2, r0, #24
8001454a:	0e12      	lsr	r2, r2, #24	; just the last byte please
8001454c:	2301      	mov	r3, #1
8001454e:	4013      	and	r3, r2		; test for jumper 2 set Console enable and A/D option installed
80014550:	2b00      	cmp	r3, #0
80014552:	d05a      	beq	0x8001460a	; return is console dissabled
80014554:	2308      	mov	r3, #8
80014556:	4013      	and	r3, r2
80014558:	2b00      	cmp	r3, #0		; test for JP4 Console on COM2
8001455a:	d001      	beq	0x80014560
8001455c:	4f2c      	ldr	r7, [pc, #176]	(0x80014610)	; r7=0x808c0000 ; UART1Data
8001455e:	e000      	b	0x80014562

80014560:	4f2c      	ldr	r7, [pc, #176]	(0x80014614)	; r7=0x808d0000 ; UART2Data

80014562:	4e2d      	ldr	r6, [pc, #180]	(0x80014618)	; r6=0x800147cc	;
80014564:	6833      	ldr	r3, [r6, #0]
80014566:	42bb      	cmp	r3, r7
80014568:	d03c      	beq	0x800145e4
// setup the new UART is necessary
8001456a:	1c3d      	mov	r5, r7
8001456c:	3514      	add	r5, #20
8001456e:	1c28      	mov	r0, r5		; r0=UART CTRL reg
80014570:	2100      	mov	r1, #0
80014572:	fd6bf7ff 	bl	0x8001404c	; str	r1, [r0] ; disable UART and its interupts
80014576:	2380      	mov	r3, #128
80014578:	005b      	lsl	r3, r3, #1
8001457a:	18f8      	add	r0, r7, r3	; r0=UARTModemCTRL
8001457c:	2100      	mov	r1, #0
8001457e:	fd65f7ff 	bl	0x8001404c	; str	r1, [r0] ; zero UARTModemCTRL
80014582:	1d38      	add	r0, r7, #4	; UARTRXSts
80014584:	2100      	mov	r1, #0
80014586:	fd61f7ff 	bl	0x8001404c	; str	r1, [r0] ; clear any interupts UARTRXSts 
8001458a:	21aa      	mov	r1, #170
8001458c:	4823      	ldr	r0, [pc, #140]	(0x8001461c)	; r0=0x809300c0
8001458e:	fd5df7ff 	bl	0x8001404c	; str	r1, [r0]	; unlock syscon
80014592:	4823      	ldr	r0, [pc, #140]	(0x80014620)	; r0=0x80930080
80014594:	fd54f7ff 	bl	0x80014040	;ldr	r0, [r0]	; read  DeviceCFG
80014598:	4922      	ldr	r1, [pc, #136]	(0x80014624)	; r1=0xffebffff
8001459a:	4001      	and	r1, r0		; clear U2EN (UART2 enable), U1EN (UART1 enable)
8001459c:	4820      	ldr	r0, [pc, #128]	(0x80014620)	; r0=0x80930080
8001459e:	fd55f7ff 	bl	0x8001404c	; str	r1, [r0]	; clear U2EN (UART2 enable), U1EN (UART1 enable)
800145a2:	1c38      	mov	r0, r7		
800145a4:	3010      	add	r0, #16		; r0 = UARTLinCtrlLow
800145a6:	2103      	mov	r1, #3
800145a8:	fd50f7ff 	bl	0x8001404c	; str	r1, [r0]	; set baudrate low to 3; 115200 Baud
800145ac:	1c38      	mov	r0, r7		
800145ae:	300c      	add	r0, #12		; r0 = UARTLinCtrlMid	
800145b0:	2100      	mov	r1, #0
800145b2:	fd4bf7ff 	bl	0x8001404c	; str	r1, [r0]	; set baudrate mid to 0
800145b6:	1c38      	mov	r0, r7		
800145b8:	3008      	add	r0, #8		; r0 = UARTLinCtrlHigh
800145ba:	2170      	mov	r1, #112
800145bc:	fd46f7ff 	bl	0x8001404c	; str	r1, [r0]	; set baudrate high to FIFO enable, n81-odd
800145c0:	1c28      	mov	r0, r5		; r0=UART CTRL reg
800145c2:	2101      	mov	r1, #1
800145c4:	fd42f7ff 	bl	0x8001404c	; str	r1, [r0]	; Enable UART
800145c8:	21aa      	mov	r1, #170
800145ca:	4814      	ldr	r0, [pc, #80]	(0x8001461c)	; r0=0x809300c0
800145cc:	fd3ef7ff 	bl	0x8001404c	; str	r1, [r0] ; unlock syscon
800145d0:	4813      	ldr	r0, [pc, #76]	(0x80014620)	; r0=0x80930080
800145d2:	fd35f7ff 	bl	0x80014040	;ldr	r0, [r0]
800145d6:	21a0      	mov	r1, #160
800145d8:	0349      	lsl	r1, r1, #13
800145da:	4301      	orr	r1, r0
800145dc:	4810      	ldr	r0, [pc, #64]	(0x80014620)	; r0=0x80930080
800145de:	fd35f7ff 	bl	0x8001404c	; str	r1, [r0];  set U2EN (UART2 enable), U1EN (UART1 enable)
800145e2:	6037      	str	r7, [r6, #0]	; remember if we are using UART1 or UART2

800145e4:	7823      	ldrb	r3, [r4, #0]	; load first byte of string to send
800145e6:	2b00      	cmp	r3, #0
800145e8:	d00f      	beq	0x8001460a	; return if end of null terminated string
800145ea:	1c38      	mov	r0, r7		(add r0, r7, #0)
800145ec:	3018      	add	r0, #24
800145ee:	fd27f7ff 	bl	0x80014040	;ldr	r0, [r0]	; read UART flags
800145f2:	2320      	mov	r3, #32
800145f4:	4018      	and	r0, r3		; just transmit fifo full
800145f6:	2800      	cmp	r0, #0
800145f8:	d1f7      	bne	0x800145ea	; if full try again till fifo not full
800145fa:	7821      	ldrb	r1, [r4, #0]
800145fc:	1c38      	mov	r0, r7		
800145fe:	3401      	add	r4, #1		; increment pointer
80014600:	fd24f7ff 	bl	0x8001404c	; str	r1, [r0] ; output one byt to the fifo
80014604:	7823      	ldrb	r3, [r4, #0]
80014606:	2b00      	cmp	r3, #0
80014608:	d1ef      	bne	0x800145ea	; get next byte
8001460a:	bcf0      	pop	{r4, r5, r6, r7}
8001460c:	bc01      	pop	{r0}
8001460e:	4700      	bx	r0

80014610:	.word		0x808c0000
80014614:	.word		0x808d0000
80014618:	.word		0x800147cc
8001461c:	.word		0x809300c0
80014620:	.word		0x80930080
80014624:	.word		0xffebffff


//=====================================================================================================
// Timer4 ticks at 983.04 kHz
Microsecond_delay(r0):

80014628:	b510      	push	{r4, lr}
// disable timer4
8001462a:	2100      	mov	r1, #0
8001462c:	1c04      	mov	r4, r0		
8001462e:	4808      	ldr	r0, [pc, #32]	(0x80014650) 	; r0=0x80810064 ; Timer4 enable
80014630:	fd0cf7ff 	bl	0x8001404c			; str	r1, [r0]
// enable timer4 start at zero
80014634:	2180      	mov	r1, #128
80014636:	4806      	ldr	r0, [pc, #24]	(0x80014650)	; r0=0x80810064
80014638:	0049      	lsl	r1, r1, #1			
8001463a:	fd07f7ff 	bl	0x8001404c			; str	r1, [r0]
// wait ~r4 microseconds
8001463e:	4805      	ldr	r0, [pc, #20]	(0x80014654)	; r0=0x80810060 ; Timer4 low word
80014640:	fcfef7ff 	bl	0x80014040			; ldr	r0, [r0]
80014644:	42a0      	cmp	r0, r4
80014646:	d3fa      	bcc	0x8001463e
80014648:	bc10      	pop	{r4}
8001464a:	bc01      	pop	{r0}
8001464c:	4700      	bx	r0
8001464e:	.hword		0x0000
80014650:	.word		0x80810064 
80014654:	.word		0x80810060 


//=====================================================================================================
Flash_leds_forever:
80014658:	b500      	push	{lr}
8001465a:	208f      	mov	r0, #143
8001465c:	0580      	lsl	r0, r0, #22	; r0=0x23C00000 ; Watch Feed
8001465e:	2105      	mov	r1, #5
80014660:	fcf2f7ff 	bl	0x80014048	; strh	r1, [r0] ; feed watchdog
80014664:	208e      	mov	r0, #142
80014666:	0580      	lsl	r0, r0, #22	; r0=0x23800000 ; Watch dog control
80014668:	2100      	mov	r1, #0
8001466a:	fcedf7ff 	bl	0x80014048	; strh	r1, [r0] ; turn watchdog off
8001466e:	4807      	ldr	r0, [pc, #28]	(0x8001468c)	; r0=0x80840020 ; PEDR
80014670:	2101      	mov	r1, #1
80014672:	fcebf7ff 	bl	0x8001404c	; str	r1, [r0]; Turn Green LED on, Red off
80014676:	4806      	ldr	r0, [pc, #24]	(0x80014690)	; r0=0x0001dfef
80014678:	ffd6f7ff 	bl	0x80014628	; Microsecond_delay(r0) wait 1/8th of a second
8001467c:	4803      	ldr	r0, [pc, #12]	(0x8001468c)	; r0=0x80840020	; PEDR
8001467e:	fcdff7ff 	bl	0x80014040	;ldr	r0, [r0]
80014682:	2103      	mov	r1, #3
80014684:	4041      	eor	r1, r0				; reverse the LEDs
80014686:	4801      	ldr	r0, [pc, #4]	(0x8001468c)	; r0=0x80840020 ; PEDR
80014688:	e7f3      	b	0x80014672

8001468a:	.hword		0x0000
8001468c:	.word		0x80840020 
80014690:	.word		0x0001dfef 

//=====================================================================================================
Memory_detect:		;r0=address returns r0=1 if memory found else 0
80014694:	b5f0      	push	{r4, r5, r6, r7, lr}
80014696:	1c07      	mov	r7, r0		
80014698:	4916      	ldr	r1, [pc, #88]	(0x800146f4)	; r1=0xaaaaaaaa
8001469a:	1d3e      	add	r6, r7, #4
8001469c:	fcd6f7ff 	bl	0x8001404c	; str	r1, [r0] ; [address]=0xAAAAAAAA
800146a0:	1c30      	mov	r0, r6		
800146a2:	4915      	ldr	r1, [pc, #84]	(0x800146f8)	; r1=0x55555555
800146a4:	fcd2f7ff 	bl	0x8001404c	; str	r1, [r0] ; [address+4]=0x55555555
800146a8:	1c38      	mov	r0, r7		
800146aa:	fcc9f7ff 	bl	0x80014040	;ldr	r0, [r0]
800146ae:	4b11      	ldr	r3, [pc, #68]	(0x800146f4)	; r3=0xaaaaaaaa
800146b0:	1c05      	mov	r5, r0		
800146b2:	4298      	cmp	r0, r3
800146b4:	d11a      	bne	0x800146ec	; return 0 if write to write 0xaaaaaaaa in [address] failed
800146b6:	1c30      	mov	r0, r6		
800146b8:	fcc2f7ff 	bl	0x80014040	;ldr	r0, [r0]
800146bc:	4b0e      	ldr	r3, [pc, #56]	(0x800146f8)	;r3=0x55555555
800146be:	1c04      	mov	r4, r0		
800146c0:	4298      	cmp	r0, r3
800146c2:	d113      	bne	0x800146ec	; return 0 if write to write 0x55555555 in [address+4] failed
800146c4:	1c38      	mov	r0, r7		
800146c6:	1c21      	mov	r1, r4		; r1=0x55555555
800146c8:	fcc0f7ff 	bl	0x8001404c	; str	r1, [r0]
800146cc:	1c30      	mov	r0, r6		
800146ce:	1c29      	mov	r1, r5		; r5=0xaaaaaaaa
800146d0:	fcbcf7ff 	bl	0x8001404c	; str	r1, [r0]
800146d4:	1c38      	mov	r0, r7		
800146d6:	fcb3f7ff 	bl	0x80014040	;ldr	r0, [r0]
800146da:	42a0      	cmp	r0, r4
800146dc:	d106      	bne	0x800146ec	; return 0 if failed to store 0x55555555 in [address]
800146de:	1c30      	mov	r0, r6		
800146e0:	fcaef7ff 	bl	0x80014040	;ldr	r0, [r0]
800146e4:	42a8      	cmp	r0, r5
800146e6:	d101      	bne	0x800146ec	; return 0 if failed to store 0xAAAAAAAA in [address+4]
800146e8:	2001      	mov	r0, #1
800146ea:	e000      	b	0x800146ee	; return 1
800146ec:	2000      	mov	r0, #0
800146ee:	bcf0      	pop	{r4, r5, r6, r7}
800146f0:	bc02      	pop	{r1}
800146f2:	4708      	bx	r1

800146f4:	.word		0xaaaaaaaa 
800146f8:	.word		0x55555555


//=====================================================================================================
		.align 
800146FC:	.string		"\r\n\r\n>> TS-NANDBOOT, Rev 1.00 - built 10:14:31, Mar  7 2005\r\n"
		.align 
8001473C:	.string		">> Copyright (C) 2004, Technologic Systems\r\n"
		.align 
8001476C:	.string		"flash timeout!"
		.align 
8001477C:	.string		"sdram test failed!\r\n\taddr: "
		.align 
80014798:	.string		"X"
		.align 
8001479C:	.string		"."
		.align 
800147A0:	.string		" ( 'X' - bad bit )\r\n\tdata: "

800147bc:	.word		0x00000000
800147c0:	.word		0x0000aaaa
800147c4:	.word		0x0000ffff
800147c8:	.word		0x00005555 

800147cc:	.word		0x00000000 ;UART1 or UART2 base address for selection
800147d0:	.word		0x00000000 
