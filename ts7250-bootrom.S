
ts-bootrom-7250.bin:     file format binary

Disassembly of section .data:

00300000 <.data>:
00300000:	53555243 	.ascii  	"CRUS"
00300004:	ea000001 	b	0x00300010

00300008:	00000000 	.word		0x00000000	; EEPROM related value
							; 00300008 = 0x00000000 if EEPROM 0x07ff = 0xff
							; 00300008 = 0x00000000 if EEPROM 0x07ff = 0x55
							; 00300008 = 0xffff0000 if EEPROM 0x07ff = ??
							; 00300008 = 0x000000ff if no EEPROM

0030000c:	05e42f91 	 ; checksum for memory 00300010-003024d4

00300010:	e59fd00c 	ldr	sp, [pc, #12]	; 0x300024 ; 80015100 ; stack to top of Ethernet FIFO
00300014:	e3a000d3 	mov	r0, #211	; 0xd3
00300018:	e129f000 	msr	CPSR_fc, r0	; dissable interupts and enter supervisor mode
0030001c:	e169f000 	msr	SPSR_fc, r0	; dissable interupts and enter supervisor mode
00300020:	ea000000 	b	0x00300028

00300024:	80015100 

00300028:	e52de004 	str	lr, [sp, #-4]!
0030002c:	e59f0054 	ldr	r0, [pc, #84]	; 0x300088 80014000 ; fifo buffer (good place to run code from)
00300030:	e59f2054 	ldr	r2, [pc, #84]	; 0x30008c 80014440 ; prob end of code marker	;CPDL model number
00300034:	e1500002 	cmp	r0, r2
00300038:	e24dd008 	sub	sp, sp, #8	; 0x8		; reserve space on stack
0030003c:	e59f104c 	ldr	r1, [pc, #76]	; 0x300090 00302094
00300040:	2a000003 	bcs	0x00300054

00300044:	e4913004 	ldr	r3, [r1], #4
00300048:	e4803004 	str	r3, [r0], #4	; copy from 00302094 to fifo buffer
0030004c:	e1500002 	cmp	r0, r2
00300050:	3afffffb 	bcc	0x00300044

00300054:	e59f1038 	ldr	r1, [pc, #56]	; 0x300094 80014440 	;CPDL model number
00300058:	e59f2038 	ldr	r2, [pc, #56]	; 0x300098 80014444
0030005c:	e1510002 	cmp	r1, r2
00300060:	2a000003 	bcs	0x00300074
00300064:	e3a03000 	mov	r3, #0	; 0x0
00300068:	e4813004 	str	r3, [r1], #4	; zero last 4 words
0030006c:	e1510002 	cmp	r1, r2
00300070:	3afffffb 	bcc	0x00300064

00300074:	e59f3020 	ldr	r3, [pc, #32]	; 0x30009c 003000a0
00300078:	e1a0e00f 	mov	lr, pc
0030007c:	e1a0f003 	mov	pc, r3		; gosub 3000a0
00300080:	e28dd008 	add	sp, sp, #8	; 0x8
00300084:	e8bd8000 	ldmia	sp!, {pc}

00300088:	80014000	; start of MAC RAM
0030008c:	80014440	;CPDL model number
00300090:	00302094
00300094:	80014440	;CPDL model number
00300098:	80014444
0030009c:	003000a0

//----------------------------------------------------------------------------
  3000a0:	e92d41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
  3000a4:	e3a00005 	mov	r0, #5	; 0x5
  3000a8:	e3a04603 	mov	r4, #3145728	; 0x300000

      ; configure 8-bit memory region 0x1XXX-XXXX
  3000ac:	e59f2760 	ldr	r2, [pc, #1888]	; 0x300814 80080004	;SRAM config ; SMCBCR1
  3000b0:	e59f3760 	ldr	r3, [pc, #1888]	; 0x300818 0000ffef
  3000b4:	e5823000 	str	r3, [r2]; SMCBCR1 = 8 bit SRAM Full wait states

	; configure 16-bit memory region 0x2XXX-XXXX
  3000b8:	e59f275c 	ldr	r2, [pc, #1884]	; 0x30081c 80080008	;SRAM config
  3000bc:	e59f375c 	ldr	r3, [pc, #1884]	; 0x300820 1000ffef
  3000c0:	e5823000 	str	r3, [r2]	; SMCBR2 = 16 bit SRAM Full wait states 


	; configure 16-bit memory region 0x6XXX-XXXX NAND FLASH REGION
  3000c4:	e59f2758 	ldr	r2, [pc, #1880]	; 0x300824 80080018	;SRAM config
  3000c8:	e59f3758 	ldr	r3, [pc, #1880]	; 0x300828 1000fdef
  3000cc:	e5823000 	str	r3, [r2]	; SMCBCR6 = 16 bit WST1=7

  3000d0:	e59f7754 	ldr	r7, [pc, #1876]	; 0x30082c 80014440	;CPDL model number

  3000d4:	e3a03422 	mov	r3, #570425344	; 0x22000000	; model number
  3000d8:	e1d330b0 	ldrh	r3, [r3]
  3000dc:	e2033007 	and	r3, r3, #7	; 0x7	; 3 LSBs
  3000e0:	e5873000 	str	r3, [r7]	; store model number in 80014440 ; end of fifo code; previously zeroed	;CPDL model number
 
  3000e4:	e3a030aa 	mov	r3, #170	; 0xaa
  3000e8:	e59f1740 	ldr	r1, [pc, #1856]	; 0x300830 809300c0
  3000ec:	e5813000 	str	r3, [r1]	; unlock syscon

	; Syscon Software Reset (primed) and GonK; HonIDE, GonIDE, EonIDE
  3000f0:	e59f173c 	ldr	r1, [pc, #1852]	; 0x300834 80930080
  3000f4:	e5913000 	ldr	r3, [r1]
  3000f8:	e3833522 	orr	r3, r3, #142606336	; 0x8800000
  3000fc:	e3833c0d 	orr	r3, r3, #3328	; 0xd00
  300100:	e5813000 	str	r3, [r1]

	; set Ethernet PHY to output and LCD_EN LCD_RS LCD_WR = input
  300104:	e59f172c 	ldr	r1, [pc, #1836]	; 0x300838 80840044
  300108:	e3a03004 	mov	r3, #4	; 0x4
  30010c:	e5813000 	str	r3, [r1]

	; set Ethernet PHY LOW = disable ethernet
  300110:	e59f3724 	ldr	r3, [pc, #1828]	; 0x30083c 80840040
  300114:	e3a06000 	mov	r6, #0	; 0x0
  300118:	e5836000 	str	r6, [r3]

	; if EP93XX chip revision > 4 change wait states for NOR flash region
  30011c:	e59f371c 	ldr	r3, [pc, #1820]	; 0x300840 80930094 ; System revision register top 4 bits
  300120:	e5933000 	ldr	r3, [r3]
  300124:	e1a03e23 	mov	r3, r3, lsr #28
  300128:	e3530004 	cmp	r3, #4	; 0x4, rev D1 = 4
  30012c:	9a000002 	bls	0x30013c ; branch if EP9302 <= rev D1

  300130:	e3a00006 	mov	r0, #6	; 0x6	else EP9302 >= rev E0
  300134:	e59f3708 	ldr	r3, [pc, #1800]	; 0x300844 1000feaf
  300138:	e5823000 	str	r3, [r2]	; SMCBCR6 = 16 bit WST1=21, ;SRAM config

  30013c:	e59f3704 	ldr	r3, [pc, #1796]	; 0x300848 00300dec
  300140:	e1a0e00f 	mov	lr, pc
  300144:	e1a0f003 	mov	pc, r3		; gosub Set_Sytem_Speed_and_Cache, r0 = 5 if rev D1 or less, 6 if E0 or more

  300148:	e59f56fc 	ldr	r5, [pc, #1788]	; 0x30084c 00301274	Print_String
  30014c:	e59f06fc 	ldr	r0, [pc, #1788]	; 0x300850 00301d60 "\r\n\r\n>> TS-BOOTROM, Rev 1.05 - built 11:50:53, Ju|n 22 2005\r\n"
  300150:	e1a0e00f 	mov	lr, pc
  300154:	e1a0f005 	mov	pc, r5	;Print intro 

  300158:	e59f06f4 	ldr	r0, [pc, #1780]	; 0x300854 00301d9c ">> Copyright (C) 2005, Technologic Systems\r\n"
  30015c:	e1a0e00f 	mov	lr, pc
  300160:	e1a0f005 	mov	pc, r5	;Print copyright

  300164:	e5973000 	ldr	r3, [r7]	; 80014440; 	;CPDL model number
  300168:	e3530000 	cmp	r3, #0	; 0x0
  30016c:	0a000003 	beq	0x300180

  300170:	e3a0358a 	mov	r3, #578813952	; 0x22800000
  300174:	e5d33000 	ldrb	r3, [r3]
  300178:	e3130004 	tst	r3, #4	; 0x4	; TS-9420 present
  30017c:	0a00006b 	beq	0x300330	; Using Blaster Board, skip memory test

  300180:	e59f26d0 	ldr	r2, [pc, #1744]	; 0x300858 80840020
  300184:	e3a03002 	mov	r3, #2	; 0x2	
  300188:	e5823000 	str	r3, [r2];Turn the red light on and green off

  30018c:	e59f36c8 	ldr	r3, [pc, #1736]	; 0x30085c 00300ed0 Initialize_SDRAM
  300190:	e1a0e00f 	mov	lr, pc
  300194:	e1a0f003 	mov	pc, r3

  300198:	e59f86c0 	ldr	r8, [pc, #1728]	; 0x300860 80014000 Test_SDRAM_Bank

  30019c:	e1a00006 	mov	r0, r6		; r6 = 0x00000000
  3001a0:	e3a01502 	mov	r1, #8388608	; 0x800000
  3001a4:	e1a0e00f 	mov	lr, pc
  3001a8:	e1a0f008 	mov	pc, r8		; Test_SDRAM_Bank

  3001ac:	e3a00401 	mov	r0, #16777216	; 0x1000000
  3001b0:	e3a01502 	mov	r1, #8388608	; 0x800000
  3001b4:	e1a0e00f 	mov	lr, pc
  3001b8:	e1a0f008 	mov	pc, r8		; Test_SDRAM_Bank

  3001bc:	e3a00301 	mov	r0, #67108864	; 0x4000000
  3001c0:	e3a01502 	mov	r1, #8388608	; 0x800000
  3001c4:	e1a0e00f 	mov	lr, pc
  3001c8:	e1a0f008 	mov	pc, r8		; Test_SDRAM_Bank

  3001cc:	e3a00405 	mov	r0, #83886080	; 0x5000000
  3001d0:	e3a01502 	mov	r1, #8388608	; 0x800000
  3001d4:	e1a0e00f 	mov	lr, pc
  3001d8:	e1a0f008 	mov	pc, r8		; Test_SDRAM_Bank

  3001dc:	e59f6680 	ldr	r6, [pc, #1664]	; 0x300864 00301648 	; Detect_SDRAM
  3001e0:	e3a00502 	mov	r0, #8388608	; 0x800000
  3001e4:	e1a0e00f 	mov	lr, pc
  3001e8:	e1a0f006 	mov	pc, r6		; Detect_SDRAM

  3001ec:	e3500000 	cmp	r0, #0	; 0x0
  3001f0:	0a00000f 	beq	0x300234

  3001f4:	e3a00502 	mov	r0, #8388608	; 0x800000 ; uses address bit 23, which is not
  						; brought out, so 0x00800000 mirrors 0x00000000
  3001f8:	e1a01000 	mov	r1, r0
  3001fc:	e1a0e00f 	mov	lr, pc
  300200:	e1a0f008 	mov	pc, r8		; Test_SDRAM_Bank

  300204:	e3a00506 	mov	r0, #25165824	; 0x1800000 , mirrors 0x01000000
  300208:	e3a01502 	mov	r1, #8388608	; 0x800000
  30020c:	e1a0e00f 	mov	lr, pc
  300210:	e1a0f008 	mov	pc, r8		; Test_SDRAM_Bank

  300214:	e3a00512 	mov	r0, #75497472	; 0x4800000 , mirrors 0x04000000
  300218:	e3a01502 	mov	r1, #8388608	; 0x800000
  30021c:	e1a0e00f 	mov	lr, pc
  300220:	e1a0f008 	mov	pc, r8		; Test_SDRAM_Bank

  300224:	e3a00516 	mov	r0, #92274688	; 0x5800000 , mirrors 0x05000000
  300228:	e3a01502 	mov	r1, #8388608	; 0x800000
  30022c:	e1a0e00f 	mov	lr, pc
  300230:	e1a0f008 	mov	pc, r8		; Test_SDRAM_Bank

  300234:	e3a0020e 	mov	r0, #-536870912	; 0xe0000000
  300238:	e1a0e00f 	mov	lr, pc
  30023c:	e1a0f006 	mov	pc, r6		; Detect_SDRAM

  300240:	e3500000 	cmp	r0, #0	; 0x0
  300244:	0a00000f 	beq	0x300288

  300248:	e3a0020e 	mov	r0, #-536870912	; 0xe0000000
  30024c:	e3a01502 	mov	r1, #8388608	; 0x800000
  300250:	e1a0e00f 	mov	lr, pc
  300254:	e1a0f008 	mov	pc, r8		; Test_SDRAM_Bank

  300258:	e3a004e1 	mov	r0, #-520093696	; 0xe1000000
  30025c:	e3a01502 	mov	r1, #8388608	; 0x800000
  300260:	e1a0e00f 	mov	lr, pc
  300264:	e1a0f008 	mov	pc, r8		; Test_SDRAM_Bank

  300268:	e3a00339 	mov	r0, #-469762048	; 0xe4000000
  30026c:	e3a01502 	mov	r1, #8388608	; 0x800000
  300270:	e1a0e00f 	mov	lr, pc
  300274:	e1a0f008 	mov	pc, r8		; Test_SDRAM_Bank

  300278:	e3a004e5 	mov	r0, #-452984832	; 0xe5000000
  30027c:	e3a01502 	mov	r1, #8388608	; 0x800000
  300280:	e1a0e00f 	mov	lr, pc
  300284:	e1a0f008 	mov	pc, r8		; Test_SDRAM_Bank

  300288:	e3a0020d 	mov	r0, #-805306368	; 0xd0000000
  30028c:	e1a0e00f 	mov	lr, pc
  300290:	e1a0f006 	mov	pc, r6		; Detect_SDRAM

  300294:	e3500000 	cmp	r0, #0	; 0x0
  300298:	0a00000f 	beq	0x3002dc
  30029c:	e3a0020d 	mov	r0, #-805306368	; 0xd0000000
  3002a0:	e3a01502 	mov	r1, #8388608	; 0x800000
  3002a4:	e1a0e00f 	mov	lr, pc
  3002a8:	e1a0f008 	mov	pc, r8		; Test_SDRAM_Bank

  3002ac:	e3a004d1 	mov	r0, #-788529152	; 0xd1000000
  3002b0:	e3a01502 	mov	r1, #8388608	; 0x800000
  3002b4:	e1a0e00f 	mov	lr, pc
  3002b8:	e1a0f008 	mov	pc, r8		; Test_SDRAM_Bank

  3002bc:	e3a00335 	mov	r0, #-738197504	; 0xd4000000
  3002c0:	e3a01502 	mov	r1, #8388608	; 0x800000
  3002c4:	e1a0e00f 	mov	lr, pc
  3002c8:	e1a0f008 	mov	pc, r8		; Test_SDRAM_Bank

  3002cc:	e3a004d5 	mov	r0, #-721420288	; 0xd5000000
  3002d0:	e3a01502 	mov	r1, #8388608	; 0x800000
  3002d4:	e1a0e00f 	mov	lr, pc
  3002d8:	e1a0f008 	mov	pc, r8		; Test_SDRAM_Bank

  3002dc:	e3a00103 	mov	r0, #-1073741824	; 0xc0000000
  3002e0:	e1a0e00f 	mov	lr, pc
  3002e4:	e1a0f006 	mov	pc, r6		; Detect_SDRAM
  3002e8:	e3500000 	cmp	r0, #0	; 0x0
  3002ec:	0a00000f 	beq	0x300330

  3002f0:	e3a00103 	mov	r0, #-1073741824	; 0xc0000000
  3002f4:	e3a01502 	mov	r1, #8388608	; 0x800000
  3002f8:	e1a0e00f 	mov	lr, pc
  3002fc:	e1a0f008 	mov	pc, r8		; Test_SDRAM_Bank

  300300:	e3a004c1 	mov	r0, #-1056964608	; 0xc1000000
  300304:	e3a01502 	mov	r1, #8388608	; 0x800000
  300308:	e1a0e00f 	mov	lr, pc
  30030c:	e1a0f008 	mov	pc, r8		; Test_SDRAM_Bank

  300310:	e3a00331 	mov	r0, #-1006632960	; 0xc4000000
  300314:	e3a01502 	mov	r1, #8388608	; 0x800000
  300318:	e1a0e00f 	mov	lr, pc
  30031c:	e1a0f008 	mov	pc, r8		; Test_SDRAM_Bank

  300320:	e3a004c5 	mov	r0, #-989855744	; 0xc5000000
  300324:	e3a01502 	mov	r1, #8388608	; 0x800000
  300328:	e1a0e00f 	mov	lr, pc
  30032c:	e1a0f008 	mov	pc, r8		; Test_SDRAM_Bank


  300330:	e59f652c 	ldr	r6, [pc, #1324]	; 0x300864 00301648 Detect_SDRAM
  300334:	e3a00103 	mov	r0, #-1073741824	; 0xc0000000
  300338:	e1a0e00f 	mov	lr, pc
  30033c:	e1a0f006 	mov	pc, r6		; Detect_SDRAM

  300340:	e3500000 	cmp	r0, #0	; 0x0
  300344:	159f651c 	ldrne	r6, [pc, #1308]	; 0x300868 00301dcc "128MB"
  300348:	1a00000b 	bne	0x30037c
  30034c:	e3a0020e 	mov	r0, #-536870912	; 0xe0000000
  300350:	e1a0e00f 	mov	lr, pc
  300354:	e1a0f006 	mov	pc, r6		; Detect_SDRAM		

  300358:	e3500000 	cmp	r0, #0	; 0x0
  30035c:	1a000005 	bne	0x300378
  300360:	e3a00502 	mov	r0, #8388608	; 0x800000
  300364:	e1a0e00f 	mov	lr, pc
  300368:	e1a0f006 	mov	pc, r6		; Detect_SDRAM

  30036c:	e3500000 	cmp	r0, #0	; 0x0
  300370:	059f64f4 	ldreq	r6, [pc, #1268]	; 0x30086c 00301dd4 "32MB"
  300374:	0a000000 	beq	0x30037c

  300378:	e59f64f0 	ldr	r6, [pc, #1264]	; 0x300870 00301ddc "64MB"
  30037c:	e59f34f0 	ldr	r3, [pc, #1264]	; 0x300874 00301098; EEPROM_set_version in 0x00300008
  300380:	e1a0e00f 	mov	lr, pc
  300384:	e1a0f003 	mov	pc, r3	; call EEPROM_set_version with r6="64MB", "32MB", or "128MB"

  300388:	e59f34e8 	ldr	r3, [pc, #1256]	; 0x300878 00300008 ; eeprom value ? 0xffff0000=unknown
  30038c:	e5933000 	ldr	r3, [r3]
  300390:	e3530000 	cmp	r3, #0	; 0x0
  300394:	0a00000d 	beq	0x3003d0	; branch if version is known

  300398:	e3730001 	cmn	r3, #1	; 0x1
  30039c:	059f04d8 	ldreq	r0, [pc, #1240]	; 0x30087c 00301de4 ">> starting initial burn-in...\r\n"
  3003a0:	159f04d8 	ldrne	r0, [pc, #1240]	; 0x300880 00301e08 ">> rerunning burn-in (already tested OK before)..."
  3003a4:	e1a0e00f 	mov	lr, pc
  3003a8:	e1a0f005 	mov	pc, r5	; print ">> starting initial burn-in...\r\n" if -1 or 
							;">> rerunning burn-in (already tested OK before)..."

  3003ac:	e3a0258f 	mov	r2, #599785472	; 0x23c00000
  3003b0:	e3a03005 	mov	r3, #5	; 0x5
  3003b4:	e1c230b0 	strh	r3, [r2]	; feed watchdog

  3003b8:	e3a0258e 	mov	r2, #595591168	; 0x23800000
  3003bc:	e3a03000 	mov	r3, #0	; 0x0
  3003c0:	e1c230b0 	strh	r3, [r2]	; turn off watchdog

  3003c4:	e59f34b8 	ldr	r3, [pc, #1208]	; 0x300884 800141c4 Test_SDRAM
  3003c8:	e1a0e00f 	mov	lr, pc
  3003cc:	e1a0f003 	mov	pc, r3		; jump to code in FIFO to Test_SDRAM

  3003d0:	e3a0358f 	mov	r3, #599785472	; 0x23c00000	Watch dog
  3003d4:	e1d330b0 	ldrh	r3, [r3]
  3003d8:	e2038002 	and	r8, r3, #2	; 0x2
  3003dc:	e3a0358f 	mov	r3, #599785472	; 0x23c00000	Watch dog
  3003e0:	e1d330b0 	ldrh	r3, [r3]
  3003e4:	e2033002 	and	r3, r3, #2	; 0x2
  3003e8:	e1530008 	cmp	r3, r8
  3003ec:	0afffffa 	beq	0x3003dc
  3003f0:	e59f3490 	ldr	r3, [pc, #1168]	; 0x300888 0030145c
  3003f4:	e1a0e00f 	mov	lr, pc
  3003f8:	e1a0f003 	mov	pc, r3
  3003fc:	e3a0358f 	mov	r3, #599785472	; 0x23c00000	Watch dog
  300400:	e1d330b0 	ldrh	r3, [r3]
  300404:	e2033002 	and	r3, r3, #2	; 0x2
  300408:	e1530008 	cmp	r3, r8
  30040c:	1afffffa 	bne	0x3003fc
  300410:	e59f5474 	ldr	r5, [pc, #1140]	; 0x30088c 80810060	Timer4
  300414:	e5955000 	ldr	r5, [r5]
  300418:	e3a0358f 	mov	r3, #599785472	; 0x23c00000	Watch dog
  30041c:	e1d330b0 	ldrh	r3, [r3]
  300420:	e2033002 	and	r3, r3, #2	; 0x2
  300424:	e1530008 	cmp	r3, r8
  300428:	0afffffa 	beq	0x300418
  30042c:	e3a0358f 	mov	r3, #599785472	; 0x23c00000	Watch dog
  300430:	e1d330b0 	ldrh	r3, [r3]
  300434:	e2033002 	and	r3, r3, #2	; 0x2
  300438:	e1530008 	cmp	r3, r8
  30043c:	1afffffa 	bne	0x30042c
  300440:	e59f3444 	ldr	r3, [pc, #1092]	; 0x30088c 80810060	Timer4
  300444:	e5933000 	ldr	r3, [r3]
  300448:	e0655003 	rsb	r5, r5, r3
  30044c:	e245300f 	sub	r3, r5, #15	; 0xf
  300450:	e35300b9 	cmp	r3, #185	; 0xb9
  300454:	9a00000d 	bls	0x300490
  300458:	e59f0430 	ldr	r0, [pc, #1072]	; 0x300890 00301e40	"internal error 2: "
  30045c:	e59f83e8 	ldr	r8, [pc, #1000]	; 0x30084c 00301274	Print_String
  300460:	e1a0e00f 	mov	lr, pc
  300464:	e1a0f008 	mov	pc, r8	;Print_String

  300468:	e59f3424 	ldr	r3, [pc, #1060]	; 0x300894 003013cc Print_Hex_Word
  30046c:	e1a00005 	mov	r0, r5
  300470:	e1a0e00f 	mov	lr, pc
  300474:	e1a0f003 	mov	pc, r3	;Print_Hex_Word

  300478:	e59f0418 	ldr	r0, [pc, #1048]	; 0x300898	;"\r\n"
  30047c:	e1a0e00f 	mov	lr, pc
  300480:	e1a0f008 	mov	pc, r8	;Print_String

  300484:	e59f3410 	ldr	r3, [pc, #1040]	; 0x30089c	Print_Hex_Word
  300488:	e1a0e00f 	mov	lr, pc
  30048c:	e1a0f003 	mov	pc, r3	;Print_Hex_Word

  300490:	e59f23c0 	ldr	r2, [pc, #960]	; 0x300858	80840020
  300494:	e3a03001 	mov	r3, #1	; 0x1
  300498:	e5823000 	str	r3, [r2]	; turn RED LED off and GREEN on

// test the CRC of this code
  30049c:	e59f03fc 	ldr	r0, [pc, #1020]	; 0x3008a0 00300010 ; start checksum here
  3004a0:	e59f33fc 	ldr	r3, [pc, #1020]	; 0x3008a4 003024d4 ; to here
  3004a4:	e0601003 	rsb	r1, r0, r3
  3004a8:	e59f33f8 	ldr	r3, [pc, #1016]	; 0x3008a8 003014d4 make_checksum function
  3004ac:	e1a0e00f 	mov	lr, pc
  3004b0:	e1a0f003 	mov	pc, r3
  3004b4:	e59f33f0 	ldr	r3, [pc, #1008]	; 0x3008ac 0030000c stored checksum
  3004b8:	e5933000 	ldr	r3, [r3]
  3004bc:	e1500003 	cmp	r0, r3
  3004c0:	0a000006 	beq	0x3004e0	; if checksum matches
  3004c4:	e59f3380 	ldr	r3, [pc, #896]	; 0x30084c 00301274 	print routine
  3004c8:	e59f03e0 	ldr	r0, [pc, #992]	; 0x3008b0 00301e54 	"TS-BOOTROM self-checksum failed!"
  3004cc:	e1a0e00f 	mov	lr, pc
  3004d0:	e1a0f003 	mov	pc, r3

  3004d4:	e59f33c0 	ldr	r3, [pc, #960]	; 0x30089c 003014fc Loop_and_Flash_LEDS_forever
  3004d8:	e1a0e00f 	mov	lr, pc
  3004dc:	e1a0f003 	mov	pc, r3

  3004e0:	e5973000 	ldr	r3, [r7]
  3004e4:	e3530000 	cmp	r3, #0	; 0x0
  3004e8:	1a000004 	bne	0x300500
  3004ec:	e59f03c0 	ldr	r0, [pc, #960]	; 0x3008b4	;">> TS-7200"
  3004f0:	e59f3354 	ldr	r3, [pc, #852]	; 0x30084c	Print_String
  3004f4:	e1a0e00f 	mov	lr, pc
  3004f8:	e1a0f003 	mov	pc, r3

  3004fc:	ea000017 	b	0x300560
  300500:	e3530001 	cmp	r3, #1	; 0x1
  300504:	059f03ac 	ldreq	r0, [pc, #940]	; 0x3008b8	;">> TS-7250"
  300508:	059f333c 	ldreq	r3, [pc, #828]	; 0x30084c	Print_String
  30050c:	0a000003 	beq	0x300520
  300510:	e3530006 	cmp	r3, #6	; 0x6
  300514:	e59f3330 	ldr	r3, [pc, #816]	; 0x30084c	Print_String
  300518:	1a00000a 	bne	0x300548
  30051c:	e59f0398 	ldr	r0, [pc, #920]	; 0x3008bc	;">> JNS200"
  300520:	e1a0e00f 	mov	lr, pc
  300524:	e1a0f003 	mov	pc, r3

  300528:	e3a0358a 	mov	r3, #578813952	; 0x22800000
  30052c:	e5d33000 	ldrb	r3, [r3]
  300530:	e3130004 	tst	r3, #4	; 0x4	; test TS-9420 present?
  300534:	159f2384 	ldrne	r2, [pc, #900]	; 0x3008c0 8008001c
  300538:	059f22e4 	ldreq	r2, [pc, #740]	; 0x300824 80080018
  30053c:	e59f3380 	ldr	r3, [pc, #896]	; 0x3008c4 00004508
  300540:	e5823000 	str	r3, [r2]
  300544:	ea000005 	b	0x300560

  300548:	e59f0378 	ldr	r0, [pc, #888]	; 0x3008c8
  30054c:	e1a0e00f 	mov	lr, pc
  300550:	e1a0f003 	mov	pc, r3

  300554:	e59f3340 	ldr	r3, [pc, #832]	; 0x30089c
  300558:	e1a0e00f 	mov	lr, pc
  30055c:	e1a0f003 	mov	pc, r3

  300560:	e59f0364 	ldr	r0, [pc, #868]	; 0x3008cc
  300564:	e59f52e0 	ldr	r5, [pc, #736]	; 0x30084c 00301274	Print_String
  300568:	e1a0e00f 	mov	lr, pc
  30056c:	e1a0f005 	mov	pc, r5

  300570:	e59f22c8 	ldr	r2, [pc, #712]	; 0x300840
  300574:	e5922000 	ldr	r2, [r2]
  300578:	e59f3350 	ldr	r3, [pc, #848]	; 0x3008d0; 80014384 ;00301d44 ;"A"
  30057c:	e1a02e22 	mov	r2, r2, lsr #28
  300580:	e7930102 	ldr	r0, [r3, r2, lsl #2]
  300584:	e1a0e00f 	mov	lr, pc
  300588:	e1a0f005 	mov	pc, r5

  30058c:	e59f0340 	ldr	r0, [pc, #832]	; 0x3008d4
  300590:	e1a0e00f 	mov	lr, pc
  300594:	e1a0f005 	mov	pc, r5

  300598:	e3a0358d 	mov	r3, #591396864	; 0x23400000 // CPLD Revisions number
  30059c:	e1d330b0 	ldrh	r3, [r3]
  3005a0:	e2033007 	and	r3, r3, #7	; 0x7
  3005a4:	e3530007 	cmp	r3, #7	; 0x7
  3005a8:	979ff103 	ldrls	pc, [pc, r3, lsl #2]
  3005ac:	ea00001b 	b	0x300620

  3005b0:	00300608 	; jump location for CPLD rev 0
  3005b4:	003005d0	; jump location for CPLD rev 1
  3005b8:	003005d8	; jump location for CPLD rev 2
  3005bc:	003005e0	; jump location for CPLD rev 3
  3005c0:	003005e8	; jump location for CPLD rev 4
  3005c4:	003005f0 	; jump location for CPLD rev 5
  3005c8:	003005f8 	; jump location for CPLD rev 6
  3005cc:	00300608 	; jump location for CPLD rev 7

	; CPLD rev 1 
  3005d0:	e59f0300 	ldr	r0, [pc, #768]	; 0x3008d8 00301d44 "A"
  3005d4:	ea000008 	b	0x3005fc

	; CPLD rev 2 
  3005d8:	e59f02fc 	ldr	r0, [pc, #764]	; 0x3008dc 00301dd0 "B"
  3005dc:	ea000006 	b	0x3005fc

	; CPLD rev 3 
  3005e0:	e59f02f8 	ldr	r0, [pc, #760]	; 0x3008e0 00301d48 "C"
  3005e4:	ea000004 	b	0x3005fc

	; CPLD rev 4 
  3005e8:	e59f02f4 	ldr	r0, [pc, #756]	; 0x3008e4 00301ec8 "D"
  3005ec:	ea000002 	b	0x3005fc

	; CPLD rev 5 
  3005f0:	e59f02f0 	ldr	r0, [pc, #752]	; 0x3008e8 00301ecc "E"
  3005f4:	ea000000 	b	0x3005fc

	; CPLD rev 6 
  3005f8:	e59f02ec 	ldr	r0, [pc, #748]	; 0x3008ec 00301ed0 "F"

  3005fc:	e1a0e00f 	mov	lr, pc
  300600:	e1a0f005 	mov	pc, r5
  300604:	ea000005 	b	0x300620

	; CPLD rev 0, & rev 7 
  300608:	e59f02e0 	ldr	r0, [pc, #736]	; 0x3008f0 00301ed4 "\r\ninternal error 0\r\n"
  30060c:	e1a0e00f 	mov	lr, pc
  300610:	e1a0f005 	mov	pc, r5

  300614:	e59f3280 	ldr	r3, [pc, #640]	; 0x30089c 003014fc Loop_and_Flash_LEDS_forever
  300618:	e1a0e00f 	mov	lr, pc
  30061c:	e1a0f003 	mov	pc, r3

  300620:	e59f5224 	ldr	r5, [pc, #548]	; 0x30084c 00301274	Print_String
  300624:	e59f02c8 	ldr	r0, [pc, #712]	; 0x3008f4 00301eec	" PLD, "
  300628:	e1a0e00f 	mov	lr, pc
  30062c:	e1a0f005 	mov	pc, r5		; print " PLD, "

  300630:	e1a00006 	mov	r0, r6
  300634:	e1a0e00f 	mov	lr, pc
  300638:	e1a0f005 	mov	pc, r5

  30063c:	e59f02b4 	ldr	r0, [pc, #692]	; 0x3008f8 00301ef4
  300640:	e1a0e00f 	mov	lr, pc
  300644:	e1a0f005 	mov	pc, r5

  300648:	e3a03589 	mov	r3, #574619648	; 0x22400000
  30064c:	e1d330b0 	ldrh	r3, [r3]
  300650:	e1a06803 	mov	r6, r3, lsl #16
  300654:	e1a06826 	mov	r6, r6, lsr #16
  300658:	e3160003 	tst	r6, #3	; 0x3
  30065c:	059f0234 	ldreq	r0, [pc, #564]	; 0x300898; "\r\n"
  300660:	0a00000b 	beq	0x300694
  300664:	e59f0290 	ldr	r0, [pc, #656]	; 0x3008fc; ", options ( "
  300668:	e1a0e00f 	mov	lr, pc
  30066c:	e1a0f005 	mov	pc, r5
  300670:	e3160001 	tst	r6, #1	; 0x1
  300674:	159f0284 	ldrne	r0, [pc, #644]	; 0x300900; "MAX197-ADC "
  300678:	11a0e00f 	movne	lr, pc
  30067c:	11a0f005 	movne	pc, r5
  300680:	e3160002 	tst	r6, #2	; 0x2
  300684:	159f0278 	ldrne	r0, [pc, #632]	; 0x300904; "RS485 " 
  300688:	11a0e00f 	movne	lr, pc
  30068c:	11a0f005 	movne	pc, r5
  300690:	e59f0270 	ldr	r0, [pc, #624]	; 0x300908; ")\r\n"
  300694:	e1a0e00f 	mov	lr, pc
  300698:	e1a0f005 	mov	pc, r5
  30069c:	e59f3268 	ldr	r3, [pc, #616]	; 0x30090c; Configure_TS5620
  3006a0:	e1a0e00f 	mov	lr, pc
  3006a4:	e1a0f003 	mov	pc, r3

  3006a8:	e59f3260 	ldr	r3, [pc, #608]	; 0x300910 00300bd4
  3006ac:	e1a0e00f 	mov	lr, pc
  3006b0:	e1a0f003 	mov	pc, r3	; Initialize_UARTS:

  3006b4:	e59f3258 	ldr	r3, [pc, #600]	; 0x300914 00300cbc
  3006b8:	e1a0e00f 	mov	lr, pc
  3006bc:	e1a0f003 	mov	pc, r3	; Initialize_TSETH10

  3006c0:	e5977000 	ldr	r7, [r7]
  3006c4:	e3570006 	cmp	r7, #6	; 0x6
  3006c8:	13570001 	cmpne	r7, #1	; 0x1
  3006cc:	1a000022 	bne	0x30075c

  3006d0:	e3a0358a 	mov	r3, #578813952	; 0x22800000
  3006d4:	e5d33000 	ldrb	r3, [r3]
  3006d8:	e3130004 	tst	r3, #4	; 0x4	TS-9420 present (blaster board)
  3006dc:	1a00001e 	bne	0x30075c	; branch if TS-9420 present

  3006e0:	e3a06902 	mov	r6, #32768	; 0x8000
  3006e4:	e59f022c 	ldr	r0, [pc, #556]	; 0x300918 0003e820
  3006e8:	e1a01006 	mov	r1, r6
  3006ec:	e59f5228 	ldr	r5, [pc, #552]	; 0x30091c 00301550
  3006f0:	e1a0e00f 	mov	lr, pc
  3006f4:	e1a0f005 	mov	pc, r5		;Copy_Flash_Page_to_Memory, 
							; (flash_source) = 0x0003e820*#512, = FLASH:0x07D04000
							;  r1(ram_dest) = 0x00008000

  3006f8:	e5d63000 	ldrb	r3, [r6]
  3006fc:	e3530043 	cmp	r3, #67	; 0x43	; "C"
  300700:	e59f7218 	ldr	r7, [pc, #536]	; 0x300920 07d04000; CYGNUM_REDBOOT_FLASH_RESERVED_BASE for 128 MB systems
  300704:	e3a04a09 	mov	r4, #36864	; 0x9000
  300708:	1a000008 	bne	0x300730

  30070c:	e5d63001 	ldrb	r3, [r6, #1]
  300710:	e3530052 	cmp	r3, #82	; 0x52	; "R"
  300714:	1a000005 	bne	0x300730

  300718:	e5d63002 	ldrb	r3, [r6, #2]
  30071c:	e3530055 	cmp	r3, #85	; 0x55	; "U"
  300720:	1a000002 	bne	0x300730

  300724:	e5d63003 	ldrb	r3, [r6, #3]
  300728:	e3530053 	cmp	r3, #83	; 0x53	; "S"
  30072c:	0a000000 	beq	0x300734

	// "CRUS" not found at FLASH:0x07D04000 (start of Redboot for 128MB flash version)
  300730:	e59f71ec 	ldr	r7, [pc, #492]	; 0x300924 flash:01d0f000; CYGNUM_REDBOOT_FLASH_RESERVED_BASE for 32MB version + 0xB000?

	// CRUS found r7=0x07d04000, else r7=0x01d0f000	; redboot image (based on 32 or 128 MB flash versions)
  300734:	e3a08000 	mov	r8, #0		; 0x0 r8=index
  300738:	e08804a7 	add	r0, r8, r7, lsr #9	; address is in pages,(r7/512)+index 
  30073c:	e1a01006 	mov	r1, r6		; #0x8000
  300740:	e2888001 	add	r8, r8, #1	; 0x1
  300744:	e1a0e00f 	mov	lr, pc
  300748:	e1a0f005 	mov	pc, r5		;Copy_Flash_Page_to_Memory, (flash_source) = r7, r1(ram_dest) = 0x00008000

  30074c:	e3580c02 	cmp	r8, #512	; 0x200	
  300750:	e2866c02 	add	r6, r6, #512	; 0x200	; increment destination to next page
  300754:	3afffff7 	bcc	0x300738	; only load 512 pages total (256KB)
  300758:	ea000019 	b	0x3007c4

  30075c:	e59f31c4 	ldr	r3, [pc, #452]	; 0x300928 60010000 ; TS-9420 blaster board present 
  300760:	e5933000 	ldr	r3, [r3]
  300764:	e59f21c0 	ldr	r2, [pc, #448]	; 0x30092c ; "CRUS"
  300768:	e1530002 	cmp	r3, r2		; cmp r3 == "CRUS"
  30076c:	1a000004 	bne	0x300784

  300770:	e59f01b8 	ldr	r0, [pc, #440]	; 0x300930 00301f24	// 60010000 == "CRUS"
  300774:	e59f41b8 	ldr	r4, [pc, #440]	; 0x300934 60010004
  300778:	e1a0e00f 	mov	lr, pc
  30077c:	e1a0f005 	mov	pc, r5		; Copy_Flash_Page_to_Memory, (flash_source) = 00301f24, r1(ram_dest) = 0x00008000

  300780:	ea00000f 	b	0x3007c4

  300784:	e59f31ac 	ldr	r3, [pc, #428]	; 0x300938 60e20000
  300788:	e5933000 	ldr	r3, [r3]
  30078c:	e1530002 	cmp	r3, r2		; cmp r3 == "CRUS"
  300790:	059f41a4 	ldreq	r4, [pc, #420]	; 0x30093c 60e20004
  300794:	0a00000a 	beq	0x3007c4

  300798:	e59f31a0 	ldr	r3, [pc, #416]	; 0x300940 60620000
  30079c:	e5933000 	ldr	r3, [r3]
  3007a0:	e1530002 	cmp	r3, r2		; cmp r3 == "CRUS"
  3007a4:	059f4198 	ldreq	r4, [pc, #408]	; 0x300944 60620004
  3007a8:	0a000005 	beq	0x3007c4

  3007ac:	e59f0194 	ldr	r0, [pc, #404]	; 0x300948 ;"Can't find CRUS bootup signature\r\n\0"
  3007b0:	e1a0e00f 	mov	lr, pc
  3007b4:	e1a0f005 	mov	pc, r5

  3007b8:	e59f30dc 	ldr	r3, [pc, #220]	; 0x30089c Loop_and_Flash_LEDS_forever
  3007bc:	e1a0e00f 	mov	lr, pc
  3007c0:	e1a0f003 	mov	pc, r3

  	// 256KB loaded from flash into 0x00008000
  3007c4:	e59f00cc 	ldr	r0, [pc, #204]	; 0x300898 ;"\r\n
  3007c8:	e59f307c 	ldr	r3, [pc, #124]	; 0x30084c Print_String
  3007cc:	e1a0e00f 	mov	lr, pc
  3007d0:	e1a0f003 	mov	pc, r3

  3007d4:	e59f2170 	ldr	r2, [pc, #368]	; 0x30094c 80010020
  3007d8:	e3a03c62 	mov	r3, #25088	; 0x6200
  3007dc:	e5823000 	str	r3, [r2]	; set ethernet clock divider 

  3007e0:	e59f2054 	ldr	r2, [pc, #84]	; 0x30083c 80840040	GPIO H
  3007e4:	e3a03004 	mov	r3, #4	; 0x4
  3007e8:	e5823000 	str	r3, [r2]	; Ethernet PHY enable

  3007ec:	e3a0258f 	mov	r2, #599785472	; 0x23c00000
  3007f0:	e3a03005 	mov	r3, #5	; 0x5	; Feed Watchdog
  3007f4:	e1c230b0 	strh	r3, [r2]

  3007f8:	e3a0358e 	mov	r3, #595591168	; 0x23800000
  3007fc:	e3a05000 	mov	r5, #0	; 0x0	; disable watchdog
  300800:	e1c350b0 	strh	r5, [r3]

  300804:	e1a0e00f 	mov	lr, pc
  300808:	e1a0f004 	mov	pc, r4		; jump to 60e20004 or 60620004 in NOR flash, 
							; or 0x9000 in sdram which we just copied 256KB of 
							; REDBOOT from flash too (base 0x8000) 
  30080c:	e1a00005 	mov	r0, r5

  300810:	e8bd81f0 	ldmia	sp!, {r4, r5, r6, r7, r8, pc}

  300814:	80080004
  300818:	0000ffef 
  30081c:	80080008 
  300820:	1000ffef
  300824:	80080018
  300828:	1000fdef
  30082c:	80014440 	;CPDL model number
  300830:	809300c0
  300834:	80930080
  300838:	80840044
  30083c:	80840040	; GPIO H
  300840:	80930094
  300844:	1000feaf
  300848:	00300dec
  30084c:	00301274	Print_String
  300850:	00301d60	;"\r\n\r\n>> TS-BOOTROM, Rev 1.05 - built 11:50:53, Jun 22 2005\r\n"
  300854:	00301d9c	;">> Copyright (C) 2005, Technologic Systems\r\n"
  300858:	80840020
  30085c:	00300ed0 	;Initialize_SDRAM
  300860:	80014000 	Test_SDRAM_Bank
  300864:	00301648 	Detect_SDRAM
  300868:	00301dcc 	;"128MB"
  30086c:	00301dd4 	;"32MB"
  300870:	00301ddc 	;"64MB"
  300874:	00301098 
  300878:	00300008 
  30087c:	00301de4	;">> starting initial burn-in...\r\n" 
  300880:	00301e08	;">> rerunning burn-in (already tested OK before)..."
  300884:	800141c4 	;Test_SDRAM
  300888:	0030145c 
  30088c:	80810060 
  300890:	00301e40 	;"internal error 2: "
  300894:	003013cc 	; Print_Hex_Word
  300898:	00301e74 	;"\r\n"
  30089c:	003014fc  	Loop_and_Flash_LEDS_forever
  3008a0:	00300010 
  3008a4:	003024d4 	
  3008a8:	003014d4 
  3008ac:	0030000c 
  3008b0:	00301e54 	;".TS-BOOTROM self-checksum failed!\r\n"
  3008b4:	00301e78 	;">> TS-7200"
  3008b8:	00301e84 	;">> TS-7250"
  3008bc:	00301e90 	;">> JNS200"
  3008c0:	8008001c 
  3008c4:	00004508 
  3008c8:	00301e9c 	;"\r\ninternal error 3\r\n"
  3008cc:	00301eb4 	;": Rev "
  3008d0:	80014384 	;00301d44 ;"A"
  3008d4:	00301ebc 	;" CPU, Rev "
  3008d8:	00301d44 	;"A"
  3008dc:	00301dd0 	;"B"
  3008e0:	00301d48 	;"C"
  3008e4:	00301ec8 	;"D"
  3008e8:	00301ecc 	;"E"
  3008ec:	00301ed0 	;"F"
  3008f0:	00301ed4 	;"\r\ninternal error 0\r\n"
  3008f4:	00301eec 	;" PLD, "
  3008f8:	00301ef4 	;" SDRAM"
  3008fc:	00301efc 	;", options ( "
  300900:	00301f0c 	;"MAX197-ADC "
  300904:	00301f18 	;"RS485 "
  300908:	00301f20 	;")\r\n"
  30090c:	00300950 	;Configure_TS5620
  300910:	00300bd4 
  300914:	00300cbc 
  300918:	0003e820 
  30091c:	00301550 
  300920:	07d04000 
  300924:	01d0f000 
  300928:	60010000 
  30092c:	53555243 	.ascii  	"CRUS"
  300930:	00301f24 
  300934:	60010004 
  300938:	60e20000 
  30093c:	60e20004 
  300940:	60620000 
  300944:	60620004 
  300948:	00301f64 	;"Can't find CRUS bootup signature\r\n\0"
  30094c:	80010020 

//----------------------------------------------------------------------------
Configure_TS5620:  
  300950:	e92d40f0 	stmdb	sp!, {r4, r5, r6, r7, lr}
  300954:	e3a0358a 	mov	r3, #578813952	; 0x22800000
  300958:	e1d330b0 	ldrh	r3, [r3]
  30095c:	e3130004 	tst	r3, #4	; 0x4
  300960:	0a000002 	beq	0x300970
  300964:	e3a02585 	mov	r2, #557842432	; 0x21400000
  300968:	e3a03004 	mov	r3, #4	; 0x4
  30096c:	e1c230b0 	strh	r3, [r2]
  300970:	e59f5104 	ldr	r5, [pc, #260]	; 0x300a7c
  300974:	e3a0207f 	mov	r2, #127	; 0x7f
  300978:	e5c52000 	strb	r2, [r5]
  30097c:	e59f60fc 	ldr	r6, [pc, #252]	; 0x300a80
  300980:	e3a030aa 	mov	r3, #170	; 0xaa
  300984:	e5c63000 	strb	r3, [r6]
  300988:	e3a0107e 	mov	r1, #126	; 0x7e
  30098c:	e5c51000 	strb	r1, [r5]
  300990:	e3a03055 	mov	r3, #85	; 0x55
  300994:	e5c63000 	strb	r3, [r6]
  300998:	e5c52000 	strb	r2, [r5]
  30099c:	e5d63000 	ldrb	r3, [r6]
  3009a0:	e20320ff 	and	r2, r3, #255	; 0xff
  3009a4:	e22220aa 	eor	r2, r2, #170	; 0xaa
  3009a8:	e5c51000 	strb	r1, [r5]
  3009ac:	e5d63000 	ldrb	r3, [r6]
  3009b0:	e20330ff 	and	r3, r3, #255	; 0xff
  3009b4:	e2233055 	eor	r3, r3, #85	; 0x55
  3009b8:	e1922003 	orrs	r2, r2, r3
  3009bc:	1a000026 	bne	0x300a5c
  3009c0:	e3a0700a 	mov	r7, #10	; 0xa
  3009c4:	e5c57000 	strb	r7, [r5]
  3009c8:	e3a03020 	mov	r3, #32	; 0x20
  3009cc:	e5c63000 	strb	r3, [r6]
  3009d0:	e59f00ac 	ldr	r0, [pc, #172]	; 0x300a84
  3009d4:	e59f40ac 	ldr	r4, [pc, #172]	; 0x300a88	00301274	Print_String
  3009d8:	e1a0e00f 	mov	lr, pc
  3009dc:	e1a0f004 	mov	pc, r4
  3009e0:	e3a0300d 	mov	r3, #13	; 0xd
  3009e4:	e5c53000 	strb	r3, [r5]
  3009e8:	e5d63000 	ldrb	r3, [r6]
  3009ec:	e3130080 	tst	r3, #128	; 0x80
  3009f0:	1a000003 	bne	0x300a04
  3009f4:	e59f0090 	ldr	r0, [pc, #144]	; 0x300a8c
  3009f8:	e1a0e00f 	mov	lr, pc
  3009fc:	e1a0f004 	mov	pc, r4
  300a00:	e8bd80f0 	ldmia	sp!, {r4, r5, r6, r7, pc}
  300a04:	e59f0084 	ldr	r0, [pc, #132]	; 0x300a90
  300a08:	e1a0e00f 	mov	lr, pc
  300a0c:	e1a0f004 	mov	pc, r4
  300a10:	e5c57000 	strb	r7, [r5]
  300a14:	e59f1064 	ldr	r1, [pc, #100]	; 0x300a80
  300a18:	e5d13000 	ldrb	r3, [r1]
  300a1c:	e3130080 	tst	r3, #128	; 0x80
  300a20:	1afffffb 	bne	0x300a14
  300a24:	e59f2050 	ldr	r2, [pc, #80]	; 0x300a7c
  300a28:	e3a0300b 	mov	r3, #11	; 0xb
  300a2c:	e5c23000 	strb	r3, [r2]
  300a30:	e3a03082 	mov	r3, #130	; 0x82
  300a34:	e5c13000 	strb	r3, [r1]
  300a38:	e59f0054 	ldr	r0, [pc, #84]	; 0x300a94
  300a3c:	e1a0e00f 	mov	lr, pc
  300a40:	e1a0f004 	mov	pc, r4
  300a44:	e59f304c 	ldr	r3, [pc, #76]	; 0x300a98
  300a48:	e1a0e00f 	mov	lr, pc
  300a4c:	e1a0f003 	mov	pc, r3
  300a50:	e59f0044 	ldr	r0, [pc, #68]	; 0x300a9c
  300a54:	e1a0e00f 	mov	lr, pc
  300a58:	e1a0f004 	mov	pc, r4
  300a5c:	e3a0358a 	mov	r3, #578813952	; 0x22800000
  300a60:	e1d330b0 	ldrh	r3, [r3]
  300a64:	e3130004 	tst	r3, #4	; 0x4
  300a68:	08bd80f0 	ldmeqia	sp!, {r4, r5, r6, r7, pc}
  300a6c:	e3a02585 	mov	r2, #557842432	; 0x21400000
  300a70:	e3a03000 	mov	r3, #0	; 0x0
  300a74:	e1c230b0 	strh	r3, [r2]
  300a78:	e8bd80f0 	ldmia	sp!, {r4, r5, r6, r7, pc}

  300a7c:	10b00000
  300a80:	11700000
  300a84:	00301f88	">> TS-5620: detected, battery "
  300a88:	00301274	Print_String
  300a8c:	00301fa8	"DEAD\r\n"
  300a90:	00301fb0	"OK\r\n"
  300a94:	00301fb4	", time ( "
  300a98:	00300aa0	
  300a9c:	00301fc0	" )\r\n"

//----------------------------------------------------------------------------
  300aa0:	e92d45f0 	stmdb	sp!, {r4, r5, r6, r7, r8, sl, lr}
  300aa4:	e3a03004 	mov	r3, #4	; 0x4
  300aa8:	e59f6100 	ldr	r6, [pc, #256]	; 0x300bb0
  300aac:	e5c63000 	strb	r3, [r6]
  300ab0:	e59f50fc 	ldr	r5, [pc, #252]	; 0x300bb4
  300ab4:	e5d53000 	ldrb	r3, [r5]
  300ab8:	e59f80f8 	ldr	r8, [pc, #248]	; 0x300bb8
  300abc:	e20300ff 	and	r0, r3, #255	; 0xff
  300ac0:	e3a01001 	mov	r1, #1	; 0x1
  300ac4:	e59f70f0 	ldr	r7, [pc, #240]	; 0x300bbc
  300ac8:	e1a0e00f 	mov	lr, pc
  300acc:	e1a0f007 	mov	pc, r7
  300ad0:	e59fa0e8 	ldr	sl, [pc, #232]	; 0x300bc0;00301274	Print_String
  300ad4:	e1a00008 	mov	r0, r8
  300ad8:	e1a0e00f 	mov	lr, pc
  300adc:	e1a0f00a 	mov	pc, sl
  300ae0:	e3a04002 	mov	r4, #2	; 0x2
  300ae4:	e5c64000 	strb	r4, [r6]
  300ae8:	e5d53000 	ldrb	r3, [r5]
  300aec:	e3a01001 	mov	r1, #1	; 0x1
  300af0:	e20300ff 	and	r0, r3, #255	; 0xff
  300af4:	e1a0e00f 	mov	lr, pc
  300af8:	e1a0f007 	mov	pc, r7
  300afc:	e1a00008 	mov	r0, r8
  300b00:	e1a0e00f 	mov	lr, pc
  300b04:	e1a0f00a 	mov	pc, sl
  300b08:	e3a08000 	mov	r8, #0	; 0x0
  300b0c:	e5c68000 	strb	r8, [r6]
  300b10:	e5d53000 	ldrb	r3, [r5]
  300b14:	e3a01001 	mov	r1, #1	; 0x1
  300b18:	e20300ff 	and	r0, r3, #255	; 0xff
  300b1c:	e1a0e00f 	mov	lr, pc
  300b20:	e1a0f007 	mov	pc, r7
  300b24:	e59f0098 	ldr	r0, [pc, #152]	; 0x300bc4
  300b28:	e1a0e00f 	mov	lr, pc
  300b2c:	e1a0f00a 	mov	pc, sl
  300b30:	e3a03008 	mov	r3, #8	; 0x8
  300b34:	e5c63000 	strb	r3, [r6]
  300b38:	e5d53000 	ldrb	r3, [r5]
  300b3c:	e20320ff 	and	r2, r3, #255	; 0xff
  300b40:	e59f3080 	ldr	r3, [pc, #128]	; 0x300bc8; 800143c4 ;00301fc4 ;0x00000000
	; 800143c4 is array of pointers to strings with 3 letter abbr. of the months
  300b44:	e7930102 	ldr	r0, [r3, r2, lsl #2]
  300b48:	e1a0e00f 	mov	lr, pc
  300b4c:	e1a0f00a 	mov	pc, sl
  300b50:	e59f0074 	ldr	r0, [pc, #116]	; 0x300bcc
  300b54:	e1a0e00f 	mov	lr, pc
  300b58:	e1a0f00a 	mov	pc, sl
  300b5c:	e3a03007 	mov	r3, #7	; 0x7
  300b60:	e5c63000 	strb	r3, [r6]
  300b64:	e5d53000 	ldrb	r3, [r5]
  300b68:	e20300ff 	and	r0, r3, #255	; 0xff
  300b6c:	e1a01008 	mov	r1, r8
  300b70:	e1a0e00f 	mov	lr, pc
  300b74:	e1a0f007 	mov	pc, r7
  300b78:	e59f0050 	ldr	r0, [pc, #80]	; 0x300bd0
  300b7c:	e1a0e00f 	mov	lr, pc
  300b80:	e1a0f00a 	mov	pc, sl
  300b84:	e3a03009 	mov	r3, #9	; 0x9
  300b88:	e5c63000 	strb	r3, [r6]
  300b8c:	e5d53000 	ldrb	r3, [r5]
  300b90:	e3a01001 	mov	r1, #1	; 0x1
  300b94:	e20300ff 	and	r0, r3, #255	; 0xff
  300b98:	e1a0e00f 	mov	lr, pc
  300b9c:	e1a0f007 	mov	pc, r7
  300ba0:	e3a0300b 	mov	r3, #11	; 0xb
  300ba4:	e5c63000 	strb	r3, [r6]
  300ba8:	e5c54000 	strb	r4, [r5]
  300bac:	e8bd85f0 	ldmia	sp!, {r4, r5, r6, r7, r8, sl, pc}

  300bb0:	10b00000 
  300bb4:	11700000
  300bb8:	00301fc8	":"
  300bbc:	00301368	Print_Hex_Byte
  300bc0:	00301274	Print_String
  300bc4:	00301ef0	", "
  300bc8:	800143c4 ;00301fc4 ;0x00000000
  300bcc:	00301fbc	" "
  300bd0:	00301fcc	" 20"

//----------------------------------------------------------------------------
Initialize_UARTS:
  300bd4:	e3a01000 	mov	r1, #0	; 0x0
  300bd8:	e92d4070 	stmdb	sp!, {r4, r5, r6, lr}
  300bdc:	e1a04001 	mov	r4, r1
  300be0:	e59f20bc 	ldr	r2, [pc, #188]	; 0x300ca4; 000003f8 ; start of ISA UART ports
  300be4:	e7922101 	ldr	r2, [r2, r1, lsl #2]
  300be8:	e2822547 	add	r2, r2, #297795584	; 0x11c00000 ; ISA registers
  300bec:	e2822007 	add	r2, r2, #7	; 0x7
  300bf0:	e3a030aa 	mov	r3, #170	; 0xaa
  300bf4:	e5c23000 	strb	r3, [r2]

  300bf8:	e3a0358d 	mov	r3, #591396864	; 0x23400000	; CPL revision Number
  300bfc:	e5d33000 	ldrb	r3, [r3]
  300c00:	e5d23000 	ldrb	r3, [r2]
  300c04:	e20330ff 	and	r3, r3, #255	; 0xff
  300c08:	e35300aa 	cmp	r3, #170	; 0xaa
  300c0c:	1a000008 	bne	0x300c34
  300c10:	e3a03055 	mov	r3, #85	; 0x55
  300c14:	e5c23000 	strb	r3, [r2]
  300c18:	e3a03589 	mov	r3, #574619648	; 0x22400000
  300c1c:	e5d33000 	ldrb	r3, [r3]
  300c20:	e5d23000 	ldrb	r3, [r2]
  300c24:	e20330ff 	and	r3, r3, #255	; 0xff
  300c28:	e3530055 	cmp	r3, #85	; 0x55
  300c2c:	03a03001 	moveq	r3, #1	; 0x1
  300c30:	01844113 	orreq	r4, r4, r3, lsl r1
  300c34:	e2811001 	add	r1, r1, #1	; 0x1
  300c38:	e351000b 	cmp	r1, #11	; 0xb
  300c3c:	9affffe7 	bls	0x300be0
  300c40:	e3540000 	cmp	r4, #0	; 0x0
  300c44:	08bd8070 	ldmeqia	sp!, {r4, r5, r6, pc}

  300c48:	e59f0058 	ldr	r0, [pc, #88]	; 0x300ca8  ">> Off-board serial at:" 
  300c4c:	e59f6058 	ldr	r6, [pc, #88]	; 0x300cac;	00301274	Print_String
  300c50:	e1a0e00f 	mov	lr, pc
  300c54:	e1a0f006 	mov	pc, r6		; Print ">> Off-board serial at:" 

  300c58:	e3a05000 	mov	r5, #0	; 0x0
  300c5c:	e3a03001 	mov	r3, #1	; 0x1
  300c60:	e0143513 	ands	r3, r4, r3, lsl r5
  300c64:	0a000006 	beq	0x300c84
  300c68:	e59f0040 	ldr	r0, [pc, #64]	; 0x300cb0 ; " "
  300c6c:	e1a0e00f 	mov	lr, pc
  300c70:	e1a0f006 	mov	pc, r6		; Print  " "

  300c74:	e59f3038 	ldr	r3, [pc, #56]	; 0x300cb4 ; 00301ce4 ;"COM1"
  300c78:	e7930105 	ldr	r0, [r3, r5, lsl #2]
  300c7c:	e1a0e00f 	mov	lr, pc
  300c80:	e1a0f006 	mov	pc, r6		; Print "COM1" or "COM2" ... "COM12" 

  300c84:	e2855001 	add	r5, r5, #1	; 0x1
  300c88:	e355000b 	cmp	r5, #11	; 0xb
  300c8c:	9afffff2 	bls	0x300c5c

  300c90:	e59f0020 	ldr	r0, [pc, #32]	; 0x300cb8	;"\r\n"
  300c94:	e59f3010 	ldr	r3, [pc, #16]	; 0x300cac;	00301274	Print_String
  300c98:	e1a0e00f 	mov	lr, pc
  300c9c:	e1a0f003 	mov	pc, r3		; Print "\r\n"

  300ca0:	e8bd8070 	ldmia	sp!, {r4, r5, r6, pc}

  300ca4:	00301c84 	;000003f8
  300ca8:	00301fd0	;">> Off-board serial at:"
  300cac:	00301274	Print_String
  300cb0:	00301fbc	;" "
  300cb4:	80014354	; 00301ce4 ;"COM1"
  300cb8:	00301e74	;"\r\n"

//----------------------------------------------------------------------------
Initialize_TSETH10:
  300cbc:	e92d41f0 	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
  300cc0:	e3a01000 	mov	r1, #0	; 0x0
  300cc4:	e1a04001 	mov	r4, r1
  300cc8:	e24dd010 	sub	sp, sp, #16	; 0x10
  300ccc:	e28d2010 	add	r2, sp, #16	; 0x10
  300cd0:	e1a00201 	mov	r0, r1, lsl #4
  300cd4:	e2803547 	add	r3, r0, #297795584	; 0x11c00000
  300cd8:	e5d33000 	ldrb	r3, [r3]
  300cdc:	e203300f 	and	r3, r3, #15	; 0xf
  300ce0:	e353000a 	cmp	r3, #10	; 0xa
  300ce4:	1a00000f 	bne	0x300d28
  300ce8:	e2800547 	add	r0, r0, #297795584	; 0x11c00000
  300cec:	e2800008 	add	r0, r0, #8	; 0x8
  300cf0:	e5d03000 	ldrb	r3, [r0]
  300cf4:	e203300f 	and	r3, r3, #15	; 0xf
  300cf8:	e3530005 	cmp	r3, #5	; 0x5
  300cfc:	1a000009 	bne	0x300d28
  300d00:	e5d03000 	ldrb	r3, [r0]
  300d04:	e203300f 	and	r3, r3, #15	; 0xf
  300d08:	e353000a 	cmp	r3, #10	; 0xa
  300d0c:	1a000005 	bne	0x300d28
  300d10:	e5d03000 	ldrb	r3, [r0]
  300d14:	e5d03000 	ldrb	r3, [r0]
  300d18:	e203300f 	and	r3, r3, #15	; 0xf
  300d1c:	e5023010 	str	r3, [r2, #-16]
  300d20:	e3a03001 	mov	r3, #1	; 0x1
  300d24:	e1844113 	orr	r4, r4, r3, lsl r1
  300d28:	e2811001 	add	r1, r1, #1	; 0x1
  300d2c:	e3510003 	cmp	r1, #3	; 0x3
  300d30:	e2822004 	add	r2, r2, #4	; 0x4
  300d34:	9affffe5 	bls	0x300cd0
  300d38:	e3540000 	cmp	r4, #0	; 0x0
  300d3c:	0a000021 	beq	0x300dc8
  300d40:	e59f0088 	ldr	r0, [pc, #136]	; 0x300dd0 ">> TS-ETH10 at:"
  300d44:	e59f8088 	ldr	r8, [pc, #136]	; 0x300dd4 Print_String
  300d48:	e1a0e00f 	mov	lr, pc
  300d4c:	e1a0f008 	mov	pc, r8
  300d50:	e3a07000 	mov	r7, #0	; 0x0
  300d54:	e28d6010 	add	r6, sp, #16	; 0x10
  300d58:	e3a05001 	mov	r5, #1	; 0x1
  300d5c:	e0143715 	ands	r3, r4, r5, lsl r7
  300d60:	0a000010 	beq	0x300da8
  300d64:	e59f006c 	ldr	r0, [pc, #108]	; 0x300dd8;" 0x3"
  300d68:	e1a0e00f 	mov	lr, pc
  300d6c:	e1a0f008 	mov	pc, r8
  300d70:	e59f3064 	ldr	r3, [pc, #100]	; 0x300ddc Print_Hex_Byte
  300d74:	e1a00207 	mov	r0, r7, lsl #4
  300d78:	e1a01005 	mov	r1, r5
  300d7c:	e1a0e00f 	mov	lr, pc
  300d80:	e1a0f003 	mov	pc, r3
  300d84:	e59f0054 	ldr	r0, [pc, #84]	; 0x300de0 ;"/"
  300d88:	e1a0e00f 	mov	lr, pc
  300d8c:	e1a0f008 	mov	pc, r8
  300d90:	e5163010 	ldr	r3, [r6, #-16]
  300d94:	e59f2048 	ldr	r2, [pc, #72]	; 0x300de4
  300d98:	e1a03533 	mov	r3, r3, lsr r5
  300d9c:	e7920103 	ldr	r0, [r2, r3, lsl #2]
  300da0:	e1a0e00f 	mov	lr, pc
  300da4:	e1a0f008 	mov	pc, r8
  300da8:	e2877001 	add	r7, r7, #1	; 0x1
  300dac:	e3570003 	cmp	r7, #3	; 0x3
  300db0:	e2866004 	add	r6, r6, #4	; 0x4
  300db4:	9affffe7 	bls	0x300d58

  300db8:	e59f0028 	ldr	r0, [pc, #40]	; 0x300de8	;"\r\n"
  300dbc:	e59f3010 	ldr	r3, [pc, #16]	; 0x300dd4 	00301274	Print_String
  300dc0:	e1a0e00f 	mov	lr, pc
  300dc4:	e1a0f003 	mov	pc, r3

  300dc8:	e28dd010 	add	sp, sp, #16	; 0x10
  300dcc:	e8bd81f0 	ldmia	sp!, {r4, r5, r6, r7, r8, pc}

  300dd0:	00302008	;">> TS-ETH10 at:"
  300dd4:	00301274	Print_String
  300dd8:	00302018	;" 0x3"
  300ddc:	00301368	Print_Hex_Byte
  300de0:	00302020	;"/"
  300de4:	80014410
  300de8:	00301e74	;"\r\n"

//----------------------------------------------------------------------------
// 
Set_Sytem_Speed_and_Cache:
  300dec:	e3500006 	cmp	r0, #6	; 0x6 chip >= rev E0, else 5
  300df0:	e52de004 	str	lr, [sp, #-4]!
  300df4:	9a000006 	bls	0x300e14	; should always branch r0 always 5 or 6

	// unknown rev number
  300df8:	e59f20a8 	ldr	r2, [pc, #168]	; 0x300ea8 80014350
  300dfc:	e3a03007 	mov	r3, #7	; 0x7	
  300e00:	e5823000 	str	r3, [r2]	; [80014350] = 7 unknown rev number

  300e04:	e3a03002 	mov	r3, #2	; 0x2
  300e08:	e59f109c 	ldr	r1, [pc, #156]	; 0x300eac 02b0b3b6
  300e0c:	e59f209c 	ldr	r2, [pc, #156]	; 0x300eb0 8001434c
  300e10:	ea000008 	b	0x300e38	; [8001434c] = 2 unknown rev number

  300e14:	e59f108c 	ldr	r1, [pc, #140]	; 0x300ea8 80014350

	// revision = D1 or -
  300e18:	13a03005 	movne	r3, #5	; 0x5	
  300e1c:	15813000 	strne	r3, [r1]	; [80014350] = 5; D1 or -

	// revision = E0 or +
  300e20:	03a03003 	moveq	r3, #3	; 0x3	; [8001434c] = 3(E1,+),
  300e24:	05810000 	streq	r0, [r1]	; [80014350] = 6(E0)
							; [80014350] = 5(D1 or -), 6(E0); 7(unknown rev number)
							; controler is Rev E0 or +, (ep9302? 200 MHz)

  300e28:	13a03001 	movne	r3, #1	; 0x1	; [8001434c] = 1  controler is pre E0, (ep9301? 166 MHz)
  300e2c:	e59f207c 	ldr	r2, [pc, #124]	; 0x300eb0 8001434c
  300e30:	059f107c 	ldreq	r1, [pc, #124]	; 0x300eb4 02a0bb36
  300e34:	159f107c 	ldrne	r1, [pc, #124]	; 0x300eb8 02b09a2f

  300e38:	e5823000 	str	r3, [r2]	;  [8001434c] = 1(A,B,C,D0,D1), 2(unknown), 3(E1,+), 

  300e3c:	e3811701 	orr	r1, r1, #262144	; 0x40000

  300e40:	e3a030aa 	mov	r3, #170	; 0xaa
  300e44:	e59f2070 	ldr	r2, [pc, #112]	; 0x300ebc 809300c0
  300e48:	e5823000 	str	r3, [r2]; unlock syscon

  300e4c:	e59f306c 	ldr	r3, [pc, #108]	; 0x300ec0 80930020
  300e50:	e5831000 	str	r1, [r3]; set clock speed
  300e54:	e1a00000 	nop	; 5 NOPs to flush the pipline
  300e58:	e1a00000 	nop
  300e5c:	e1a00000 	nop
  300e60:	e1a00000 	nop
  300e64:	e1a00000 	nop

	// Set MMU to Asyncronous
  300e68:	ee110f10 	mrc	15, 0, r0, cr1, cr0, {0}
  300e6c:	e3800103 	orr	r0, r0, #-1073741824	; 0xc0000000
  300e70:	ee010f10 	mcr	15, 0, r0, cr1, cr0, {0}
  300e74:	e1a00000 	nop	; 5 NOPs to flush the pipline
  300e78:	e1a00000 	nop
  300e7c:	e1a00000 	nop
  300e80:	e1a00000 	nop
  300e84:	e1a00000 	nop
  300e88:	e59f2034 	ldr	r2, [pc, #52]	; 0x300ec4 80930024
  300e8c:	e59f3034 	ldr	r3, [pc, #52]	; 0x300ec8 300dc317
  300e90:	e5823000 	str	r3, [r2]

	// wait 1 millisecond
  300e94:	e3a00ffa 	mov	r0, #1000	; 0x3e8
  300e98:	e59f302c 	ldr	r3, [pc, #44]	; 0x300ecc 00301410; Microsecond_Delay
  300e9c:	e1a0e00f 	mov	lr, pc
  300ea0:	e1a0f003 	mov	pc, r3; gosub microsecond delay (1 millisecond)

  300ea4:	e49df004 	ldr	pc, [sp], #4

  300ea8:	80014350 
  300eac:	02b0b3b6
  300eb0:	8001434c
  300eb4:	02a0bb36
  300eb8:	02b09a2f
  300ebc:	809300c0
  300ec0:	80930020
  300ec4:	80930024
  300ec8:	300dc317
  300ecc:	00301410	; Microsecond_Delay

//----------------------------------------------------------------------------
Initialize_SDRAM:

  300ed0:	e92d40f0 	stmdb	sp!, {r4, r5, r6, r7, lr}
  300ed4:	e59f7160 	ldr	r7, [pc, #352]	; 0x30103c; [8001434c] = 1(A,B,C,D0,D1), 2(unknown), 3(E1,+)
  300ed8:	e5973000 	ldr	r3, [r7]
  300edc:	e3530003 	cmp	r3, #3	; 0x3	; controler is Rev E0+,

  300ee0:	959f2158 	ldrls	r2, [pc, #344]	; 0x301040; 0021002c  Rev E0+
  300ee4:	93a04c46 	movls	r4, #17920	; 0x4600	; SDRAM command

  300ee8:	859f2154 	ldrhi	r2, [pc, #340]	; 0x301044; 0032002c  
  300eec:	83a04c66 	movhi	r4, #26112	; 0x6600	; SDRAM command

  300ef0:	e59f3150 	ldr	r3, [pc, #336]	; 0x301048; 8006001c
  300ef4:	e5832000 	str	r2, [r3]

  300ef8:	e59f314c 	ldr	r3, [pc, #332]	; 0x30104c; 80060018
  300efc:	e5832000 	str	r2, [r3]

  300f00:	e59f3148 	ldr	r3, [pc, #328]	; 0x301050; 80060014
  300f04:	e5832000 	str	r2, [r3]

  300f08:	e59f3144 	ldr	r3, [pc, #324]	; 0x301054; 80060010
  300f0c:	e5832000 	str	r2, [r3]

  300f10:	e59f5140 	ldr	r5, [pc, #320]	; 0x301058; 80060004
  300f14:	e3a0310e 	mov	r3, #-2147483645	; 0x80000003
  300f18:	e5853000 	str	r3, [r5]

// wait 200 Microsecond_Delay
  300f1c:	e3a000c8 	mov	r0, #200	; 0xc8
  300f20:	e59f6134 	ldr	r6, [pc, #308]	; 0x30105c; 00301410; Microsecond_Delay
  300f24:	e1a0e00f 	mov	lr, pc
  300f28:	e1a0f006 	mov	pc, r6		; wait 200 Microsecond_Delay

  300f2c:	e3a03106 	mov	r3, #-2147483647	; 0x80000001
  300f30:	e5853000 	str	r3, [r5]

// store 0x0000dead in [0x00000000], [0x00200000], [0x00400000], [0x00600000]
  300f34:	e3a03000 	mov	r3, #0	; 0x0
  300f38:	e59f2120 	ldr	r2, [pc, #288]	; 0x301060; 0000dead
  300f3c:	e1c320b0 	strh	r2, [r3]
  300f40:	e3a03602 	mov	r3, #2097152	; 0x200000
  300f44:	e1c320b0 	strh	r2, [r3]
  300f48:	e3a03501 	mov	r3, #4194304	; 0x400000
  300f4c:	e1c320b0 	strh	r2, [r3]
  300f50:	e3a03606 	mov	r3, #6291456	; 0x600000
  300f54:	e1c320b0 	strh	r2, [r3]

// store 0x0000dead in [0xe0000000], [0xe0200000], [0xe0400000], [0xe0600000]
  300f58:	e3a0320e 	mov	r3, #-536870912	; 0xe0000000
  300f5c:	e1c320b0 	strh	r2, [r3]
  300f60:	e59f30fc 	ldr	r3, [pc, #252]	; 0x301064 e0200000
  300f64:	e1c320b0 	strh	r2, [r3]
  300f68:	e59f30f8 	ldr	r3, [pc, #248]	; 0x301068 e0400000
  300f6c:	e1c320b0 	strh	r2, [r3]
  300f70:	e59f30f4 	ldr	r3, [pc, #244]	; 0x30106c e0600000
  300f74:	e1c320b0 	strh	r2, [r3]

// store 0x0000dead in [0xd0000000], [0xd0200000], [0xd0400000], [0xd0600000]
  300f78:	e3a0320d 	mov	r3, #-805306368	; 0xd0000000
  300f7c:	e1c320b0 	strh	r2, [r3]
  300f80:	e59f30e8 	ldr	r3, [pc, #232]	; 0x301070 d0200000
  300f84:	e1c320b0 	strh	r2, [r3]
  300f88:	e59f30e4 	ldr	r3, [pc, #228]	; 0x301074 e0400000
  300f8c:	e1c320b0 	strh	r2, [r3]
  300f90:	e59f30e0 	ldr	r3, [pc, #224]	; 0x301078 e0600000
  300f94:	e1c320b0 	strh	r2, [r3]

// store 0x0000dead in [0xc0000000], [0xc0200000], [0xc0400000], [0xc0600000]
  300f98:	e3a03103 	mov	r3, #-1073741824	; 0xc0000000
  300f9c:	e1c320b0 	strh	r2, [r3]
  300fa0:	e59f30d4 	ldr	r3, [pc, #212]	; 0x30107c c0200000
  300fa4:	e1c320b0 	strh	r2, [r3]
  300fa8:	e59f30d0 	ldr	r3, [pc, #208]	; 0x301080 c0400000
  300fac:	e1c320b0 	strh	r2, [r3]
  300fb0:	e59f30cc 	ldr	r3, [pc, #204]	; 0x301084 c0600000
  300fb4:	e1c320b0 	strh	r2, [r3]

//
  300fb8:	e59f50c8 	ldr	r5, [pc, #200]	; 0x301088 80060008
  300fbc:	e3a03010 	mov	r3, #16	; 0x10
  300fc0:	e5853000 	str	r3, [r5]

// wait 200 Microsecond_Delay
  300fc4:	e3a000c8 	mov	r0, #200	; 0xc8
  300fc8:	e1a0e00f 	mov	lr, pc
  300fcc:	e1a0f006 	mov	pc, r6		;Microsecond_Delay

  300fd0:	e5977000 	ldr	r7, [r7]
  300fd4:	e3570000 	cmp	r7, #0	; 0x0
  300fd8:	03a03073 	moveq	r3, #115	; 0x73
  300fdc:	0a000008 	beq	0x301004

  300fe0:	e3570001 	cmp	r7, #1	; 0x1	(rev A,B,C,D0,D1)
  300fe4:	059f30a0 	ldreq	r3, [pc, #160]	; 0x30108c 00000206
  300fe8:	0a000005 	beq	0x301004

  300fec:	e3570002 	cmp	r7, #2	; 0x2	(rev unknown)
  300ff0:	059f3098 	ldreq	r3, [pc, #152]	; 0x301090 000002b3
  300ff4:	0a000002 	beq	0x301004

  300ff8:	e3570003 	cmp	r7, #3	; 0x3	; controler is Rev E0, (ep9302? 200 MHz)
  300ffc:	059f3090 	ldreq	r3, [pc, #144]	; 0x301094 0000030d
  301000:	13a03e36 	movne	r3, #864	; 0x360

  301004:	e5853000 	str	r3, [r5]	; store 0x360, 0x30d, 0x2b3, or 0x206 in [80060008]
 
  301008:	e59f2048 	ldr	r2, [pc, #72]	; 0x301058 80060004
  30100c:	e3a0310a 	mov	r3, #-2147483646; 0x80000002
  301010:	e5823000 	str	r3, [r2]	; 

// read from all banks at a special address, this issues a command to sdram
  301014:	e1d430b0 	ldrh	r3, [r4]		; r4=0x6600 or 0x4600 (Rev E0+)
  	; CAS=2 for < rev E0, CAS=3 for >= E0, WBL=0, TM=0, Seq, BL=8

  301018:	e284320e 	add	r3, r4, #-536870912	; 0xe0000000
  30101c:	e1d330b0 	ldrh	r3, [r3]

  301020:	e284320d 	add	r3, r4, #-805306368	; 0xd0000000
  301024:	e1d330b0 	ldrh	r3, [r3]

  301028:	e2844103 	add	r4, r4, #-1073741824	; 0xc0000000
  30102c:	e1d430b0 	ldrh	r3, [r4]

  301030:	e3a03102 	mov	r3, #-2147483648	; 0x80000000
  301034:	e5823000 	str	r3, [r2]

  301038:	e8bd80f0 	ldmia	sp!, {r4, r5, r6, r7, pc}

  30103c:	8001434c
  301040:	0021002c
  301044:	0032002c
  301048:	8006001c
  30104c:	80060018
  301050:	80060014
  301054:	80060010
  301058:	80060004
  30105c:	00301410	; Microsecond_Delay
  301060:	0000dead
  301064:	e0200000
  301068:	e0400000
  30106c:	e0600000
  301070:	d0200000
  301074:	d0400000
  301078:	d0600000
  30107c:	c0200000
  301080:	c0400000
  301084:	c0600000
  301088:	80060008
  30108c:	00000206
  301090:	000002b3
  301094:	0000030d

//----------------------------------------------------------------------------
// sets version in 0x00300008
EEPROM_set_version:
  301098:	e92d4010 	stmdb	sp!, {r4, lr}
  30109c:	e59f30c8 	ldr	r3, [pc, #200]	; 0x30116c 80014440 ; Model number
  3010a0:	e5933000 	ldr	r3, [r3]
  3010a4:	e3530000 	cmp	r3, #0	; 0x0
  3010a8:	e24dd004 	sub	sp, sp, #4	; 0x4
  3010ac:	0a00002c 	beq	0x301164	; exit if this is a TS-7200

  3010b0:	e3a0358a 	mov	r3, #578813952	; 0x22800000
  3010b4:	e5d33000 	ldrb	r3, [r3]
  3010b8:	e2132004 	ands	r2, r3, #4	; 0x4
  3010bc:	1a000028 	bne	0x301164	; exit if TS-9420 not present

  3010c0:	e3a03423 	mov	r3, #587202560	; 0x23000000
  3010c4:	e1c320b0 	strh	r2, [r3]	; store #0 -> 0x23000000 probably eeprom chip select!!!

  3010c8:	e59f20a0 	ldr	r2, [pc, #160]	; 0x301170 808a0004
  3010cc:	e3a03010 	mov	r3, #16	; 0x10
  3010d0:	e5823000 	str	r3, [r2]	; enable SPI

  3010d4:	e59f3098 	ldr	r3, [pc, #152]	; 0x301174 808a000c
  3010d8:	e5933000 	ldr	r3, [r3]	; get status
  3010dc:	e3130010 	tst	r3, #16	; 0x10	; test for busy
  3010e0:	1afffffb 	bne	0x3010d4	; wait till not busy

  3010e4:	e59f3088 	ldr	r3, [pc, #136]	; 0x301174 808a000c
  3010e8:	e5933000 	ldr	r3, [r3]	; get status
  3010ec:	e2033005 	and	r3, r3, #5	; 0x5
  3010f0:	e3530001 	cmp	r3, #1	; 0x1	; 
  3010f4:	1afffffa 	bne	0x3010e4	; wait till transmit and receive are empty

  3010f8:	e3a03423 	mov	r3, #587202560	; 0x23000000
  3010fc:	e3a01002 	mov	r1, #2	; 0x2
  301100:	e1c310b0 	strh	r1, [r3]	; store #2 -> 0x23000000 probably eeprom chip select enable!!!

  301104:	e59f206c 	ldr	r2, [pc, #108]	; 0x301178 808a0000
  301108:	e3a030c7 	mov	r3, #199	; 0xc7
  30110c:	e5823000 	str	r3, [r2]	; set SPI 8 bit, SPH=1, SPO=1

  301110:	e59f3064 	ldr	r3, [pc, #100]	; 0x30117c 808a0010
  301114:	e5831000 	str	r1, [r3]	; set clock divisor to 2

  301118:	e59f3050 	ldr	r3, [pc, #80]	; 0x301170 808a0004
  30111c:	e3a04000 	mov	r4, #0	; 0x0
  301120:	e5834000 	str	r4, [r3]	; set, Master, Disabled, no-loopback, no-interupts

  301124:	e59f3054 	ldr	r3, [pc, #84]	; 0x301180 00301810	read_byte_from_eeprom
  301128:	e28d1003 	add	r1, sp, #3	; 0x3
  30112c:	e59f0050 	ldr	r0, [pc, #80]	; 0x301184 000007ff
  301130:	e1a0e00f 	mov	lr, pc
  301134:	e1a0f003 	mov	pc, r3		; read one byte from 0x07ff to the stack
							; EEPROM_write_version writes 0x55 here

  301138:	e5dd3003 	ldrb	r3, [sp, #3]	; read_byte_from_eeprom the byte read from EEPROM 0x07ff
  30113c:	e35300ff 	cmp	r3, #255	; 0xff
  301140:	059f2040 	ldreq	r2, [pc, #64]	; 0x301188 00300008
  301144:	03e03000 	mvneq	r3, #0	; 0x0
  301148:	0a000004 	beq	0x301160

  30114c:	e59f2034 	ldr	r2, [pc, #52]	; 0x301188 00300008
  301150:	e3530055 	cmp	r3, #85	; 0x55
  301154:	15824000 	strne	r4, [r2]
  301158:	1a000001 	bne	0x301164 ; exit

; 00300008 = 0x00000000 if EEPROM 0x07ff = 0xff
; 00300008 = 0x00000000 if EEPROM 0x07ff = 0x55
; 00300008 = 0xffff0000 if EEPROM 0x07ff = ??
; 00300008 = 0x000000ff if no EEPROM

  30115c:	e59f3028 	ldr	r3, [pc, #40]	; 0x30118c ffff0000

  301160:	e5823000 	str	r3, [r2]

  301164:	e28dd004 	add	sp, sp, #4	; 0x4
  301168:	e8bd8010 	ldmia	sp!, {r4, pc}

  30116c:	80014440 	;CPDL model number
  301170:	808a0004
  301174:	808a000c
  301178:	808a0000
  30117c:	808a0010	
  301180:	00301810	read_byte_from_eeprom
  301184:	000007ff
  301188:	00300008
  30118c:	ffff0000

//----------------------------------------------------------------------------
EEPROM_write_version:
  301190:	e92d4070 	stmdb	sp!, {r4, r5, r6, lr}
  301194:	e59f20bc 	ldr	r2, [pc, #188]	; 0x301258 80014440 	;CPDL model number
  301198:	e5922000 	ldr	r2, [r2]
  30119c:	e3520000 	cmp	r2, #0	; 0x0
  3011a0:	1a00000b 	bne	0x3011d4	; branch if not a TS-7200

  // configure the TS-7200 board, NO EEPROM
  // maybe configure some NOR flash?
  3011a4:	e59f10b0 	ldr	r1, [pc, #176]	; 0x30125c 00300008
  3011a8:	e3a03040 	mov	r3, #64	; 0x40
  3011ac:	e1c130b0 	strh	r3, [r1]	; store 0x0040 ->  0x00300008
  3011b0:	e1c120b0 	strh	r2, [r1]	; store 0x0000 ->  0x00300008
  3011b4:	e3a03070 	mov	r3, #112	; 0x70
  3011b8:	e1c130b0 	strh	r3, [r1]	; store 0x0070 ->  0x00300008
  3011bc:	e1d130b0 	ldrh	r3, [r1]	; load from 0x00300008
  3011c0:	e3130080 	tst	r3, #128	; 0x80
  3011c4:	0afffffc 	beq	0x3011bc	; wait till 0x00300008 set

  3011c8:	e3a030ff 	mov	r3, #255	; 0xff
  3011cc:	e1c130b0 	strh	r3, [r1]	; store 0x00FF ->  0x00300008
  3011d0:	e8bd8070 	ldmia	sp!, {r4, r5, r6, pc} return

  // configure a TS-7250
  3011d4:	e59f6084 	ldr	r6, [pc, #132]	; 0x301260 003016f8 read_eeprom_status
  3011d8:	e1a0e00f 	mov	lr, pc
  3011dc:	e1a0f006 	mov	pc, r6

  3011e0:	e2104001 	ands	r4, r0, #1	; 0x1
  3011e4:	1afffffa 	bne	0x3011d4	; wait while write is in progress

  3011e8:	e59f5074 	ldr	r5, [pc, #116]	; 0x301264 ; 003016b0	enable_eeprom
  3011ec:	e1a0e00f 	mov	lr, pc
  3011f0:	e1a0f005 	mov	pc, r5

  3011f4:	e1a00004 	mov	r0, r4		; turn off protection
  3011f8:	e59f4068 	ldr	r4, [pc, #104]	; 0x301268 write_eeprom_status
  3011fc:	e1a0e00f 	mov	lr, pc
  301200:	e1a0f004 	mov	pc, r4

  301204:	e1a0e00f 	mov	lr, pc
  301208:	e1a0f006 	mov	pc, r6		; read status again

  30120c:	e3100001 	tst	r0, #1	; 0x1
  301210:	1afffffb 	bne	0x301204	; wait

  301214:	e1a0e00f 	mov	lr, pc
  301218:	e1a0f005 	mov	pc, r5		; enable_eeprom

  30121c:	e59f0048 	ldr	r0, [pc, #72]	; 0x30126c 000007ff
  301220:	e3a01055 	mov	r1, #85	; 0x55
  301224:	e59f3044 	ldr	r3, [pc, #68]	; 0x301270 write_byte_to_eeprom
  301228:	e1a0e00f 	mov	lr, pc
  30122c:	e1a0f003 	mov	pc, r3

  301230:	e1a0e00f 	mov	lr, pc
  301234:	e1a0f006 	mov	pc, r6		; read status again

  301238:	e3100001 	tst	r0, #1	; 0x1
  30123c:	1afffffb 	bne	0x301230	; wait for write to finish

  301240:	e1a0e00f 	mov	lr, pc
  301244:	e1a0f005 	mov	pc, r5		; enable_eeprom

  301248:	e3a0001c 	mov	r0, #28	; 0x1c
  30124c:	e1a0e00f 	mov	lr, pc
  301250:	e1a0f004 	mov	pc, r4		; write eeproms status (protect all memory)
  301254:	e8bd8070 	ldmia	sp!, {r4, r5, r6, pc}

  301258:	80014440	;CPDL model number
  30125c:	00300008
  301260:	003016f8	read_eeprom_status
  301264:	003016b0	enable_eeprom
  301268:	00301750	write_eeprom_status
  30126c:	000007ff
  301270:	003017a0	write_byte_to_eeprom

//----------------------------------------------------------------------------
// r0=address pf string to print
Print_String:
  301274:	e92d40f0 	stmdb	sp!, {r4, r5, r6, r7, lr}
  301278:	e3a03542 	mov	r3, #276824064	; 0x10800000 
  30127c:	e24dd004 	sub	sp, sp, #4	; 0x4
  301280:	e5d33000 	ldrb	r3, [r3]
  301284:	e3130001 	tst	r3, #1	; 0x1	; test if jumper2 set Console enable and A/D option installed
  301288:	0a00002f 	beq	0x30134c

  30128c:	e59fc0c0 	ldr	ip, [pc, #192]	; 0x301354 8001443c
  301290:	e3130008 	tst	r3, #8	; 0x8	; jumper 4
  301294:	159f20bc 	ldrne	r2, [pc, #188]	; 0x301358 808c0000
  301298:	059f20bc 	ldreq	r2, [pc, #188]	; 0x30135c 808d0000
  30129c:	e59c3000 	ldr	r3, [ip]
  3012a0:	e1530002 	cmp	r3, r2
  3012a4:	0a00001c 	beq	0x30131c

  // setup the UART (first time only)
  3012a8:	e2824014 	add	r4, r2, #20	; 0x14
  3012ac:	e3a07000 	mov	r7, #0	; 0x0
  3012b0:	e5847000 	str	r7, [r4]	; [808x0014]=0

  3012b4:	e2823c01 	add	r3, r2, #256	; 0x100
  3012b8:	e5837000 	str	r7, [r3]	; [808x0100]=0

  3012bc:	e2823004 	add	r3, r2, #4	; 0x4
  3012c0:	e5837000 	str	r7, [r3]	; [808x0004]=0

  3012c4:	e59f6094 	ldr	r6, [pc, #148]	; 0x301360 809300c0
  3012c8:	e3a0e0aa 	mov	lr, #170	; 0xaa
  3012cc:	e586e000 	str	lr, [r6]	; [809300c0]=0xaa (unlock syscon)

  3012d0:	e59f508c 	ldr	r5, [pc, #140]	; 0x301364 80930080
  3012d4:	e5953000 	ldr	r3, [r5]
  3012d8:	e3c33705 	bic	r3, r3, #1310720	; 0x140000
  3012dc:	e5853000 	str	r3, [r5]	; [80930080]&=~0x140000

  3012e0:	e3a01003 	mov	r1, #3	; 0x3
  3012e4:	e2823010 	add	r3, r2, #16	; 0x10
  3012e8:	e5831000 	str	r1, [r3]	; [808x0010]=0x03

  3012ec:	e282300c 	add	r3, r2, #12	; 0xc
  3012f0:	e5837000 	str	r7, [r3]	; [808x000c]=0

  3012f4:	e3a03070 	mov	r3, #112	; 0x70
  3012f8:	e2821008 	add	r1, r2, #8	; 0x8
  3012fc:	e5813000 	str	r3, [r1]	; [808x0008]=0x70

  301300:	e3a03001 	mov	r3, #1	; 0x1	;
  301304:	e5843000 	str	r3, [r4]	; [808x0020]=0x01
  301308:	e586e000 	str	lr, [r6]	; [809300c0]=0xaa (unlock syscon)
  30130c:	e5953000 	ldr	r3, [r5]	; 
  301310:	e3833705 	orr	r3, r3, #1310720	; 0x140000
  301314:	e5853000 	str	r3, [r5]	; [80930080]|=0x1400000
  301318:	e58c2000 	str	r2, [ip]	; [8001443c]=808x0020

  // start print
  30131c:	e5d03000 	ldrb	r3, [r0]
  301320:	e3530000 	cmp	r3, #0	; 0x0
  301324:	0a000008 	beq	0x30134c

  301328:	e2823018 	add	r3, r2, #24	; 0x18
  30132c:	e5933000 	ldr	r3, [r3]
  301330:	e3130020 	tst	r3, #32	; 0x20
  301334:	1afffffb 	bne	0x301328	; branch if [808x0018] bit 9 set (wait if UART busy) 

  301338:	e5d03000 	ldrb	r3, [r0]
  30133c:	e5823000 	str	r3, [r2]	; output character to [808x0000]
  301340:	e5f03001 	ldrb	r3, [r0, #1]!
  301344:	e3530000 	cmp	r3, #0	; 0x0
  301348:	1afffff6 	bne	0x301328	; continue till '\0'

  30134c:	e28dd004 	add	sp, sp, #4	; 0x4
  301350:	e8bd80f0 	ldmia	sp!, {r4, r5, r6, r7, pc}

  301354:	8001443c
  301358:	808c0000
  30135c:	808d0000
  301360:	809300c0
  301364:	80930080

//----------------------------------------------------------------------------
// r0=byte to print
// r1=if 0 blank leading zeros
Print_Hex_Byte:
  301368:	e3510000 	cmp	r1, #0	; 0x0
  30136c:	e20020f0 	and	r2, r0, #240	; 0xf0
  301370:	159f3048 	ldrne	r3, [pc, #72]	; 0x3013c0	"0".."f"
  301374:	e1a02222 	mov	r2, r2, lsr #4	; r2= high nybble
  301378:	e92d4010 	stmdb	sp!, {r4, lr}
  30137c:	e200400f 	and	r4, r0, #15	; 0xf

  301380:	10830082 	addne	r0, r3, r2, lsl #1	; high hex digit
  301384:	159f3038 	ldrne	r3, [pc, #56]	; 0x3013c4 00301274	Print_String
  301388:	1a000004 	bne	0x3013a0

  30138c:	e3520000 	cmp	r2, #0	; 0x0
  301390:	e59f1028 	ldr	r1, [pc, #40]	; 0x3013c0	"0".."f"
  301394:	e59f3028 	ldr	r3, [pc, #40]	; 0x3013c4 00301274	Print_String

  301398:	059f0028 	ldreq	r0, [pc, #40]	; 0x3013c8	" "
  30139c:	10810082 	addne	r0, r1, r2, lsl #1

  3013a0:	e1a0e00f 	mov	lr, pc
  3013a4:	e1a0f003 	mov	pc, r3

  3013a8:	e59f3010 	ldr	r3, [pc, #16]	; 0x3013c0	"0".."f"
  3013ac:	e0830084 	add	r0, r3, r4, lsl #1
  3013b0:	e59f300c 	ldr	r3, [pc, #12]	; 0x3013c4 00301274	Print_String
  3013b4:	e1a0e00f 	mov	lr, pc
  3013b8:	e1a0f003 	mov	pc, r3

  3013bc:	e8bd8010 	ldmia	sp!, {r4, pc}

  3013c0:	00302073	; "0".."f"
  3013c4:	00301274	Print_String
  3013c8:	00301fbc	; " "

//----------------------------------------------------------------------------
// r0=word to print
Print_Hex_Word:
  3013cc:	e92d4030 	stmdb	sp!, {r4, r5, lr}
  3013d0:	e1a05000 	mov	r5, r0
  3013d4:	e3a04007 	mov	r4, #7	; 0x7
  3013d8:	e1a02104 	mov	r2, r4, lsl #2
  3013dc:	e3a0300f 	mov	r3, #15	; 0xf
  3013e0:	e0053213 	and	r3, r5, r3, lsl r2
  3013e4:	e1a02233 	mov	r2, r3, lsr r2
  3013e8:	e59f3018 	ldr	r3, [pc, #24]	; 0x301408; 00302073; "0".."f"
  3013ec:	e0830082 	add	r0, r3, r2, lsl #1
  3013f0:	e59f3014 	ldr	r3, [pc, #20]	; 0x30140c; 00301274 Print_String
  3013f4:	e1a0e00f 	mov	lr, pc
  3013f8:	e1a0f003 	mov	pc, r3
  3013fc:	e2544001 	subs	r4, r4, #1	; 0x1
  301400:	48bd8030 	ldmmiia	sp!, {r4, r5, pc}
  301404:	eafffff3 	b	0x3013d8

  301408:	00302073	"0".."f"
  30140c:	00301274	Print_String

//----------------------------------------------------------------------------
// 
Microsecond_Delay:
  301410:	e92d4010 	stmdb	sp!, {r4, lr}
  301414:	e0604200 	rsb	r4, r0, r0, lsl #4
  301418:	e0804104 	add	r4, r0, r4, lsl #2
  30141c:	e0844284 	add	r4, r4, r4, lsl #5
  301420:	e1a045a4 	mov	r4, r4, lsr #11
  301424:	e59f3024 	ldr	r3, [pc, #36]	; 0x301450 0030145c
  301428:	e1a0e00f 	mov	lr, pc
  30142c:	e1a0f003 	mov	pc, r3; gosub Reset_Timer4
  301430:	e59f301c 	ldr	r3, [pc, #28]	; 0x301454 80810060  ; timer4 low value
  301434:	e5933000 	ldr	r3, [r3]
  301438:	e1530004 	cmp	r3, r4
  30143c:	3afffffb 	bcc	0x301430; loop till time is up

  301440:	e59f2010 	ldr	r2, [pc, #16]	; 0x301458 80810064  ; timer4 high value
  301444:	e3a03000 	mov	r3, #0	; 0x0
  301448:	e5823000 	str	r3, [r2]	; disable timer and zero it

  30144c:	e8bd8010 	ldmia	sp!, {r4, pc}

  301450:	0030145c 
  301454:	80810060
  301458:	80810064
//----------------------------------------------------------------------------
// 
Reset_Timer4:
  30145c:	e59f2024 	ldr	r2, [pc, #36]	; 0x301488; 0x80810064 ; Timer4HighValue

  301460:	e3a03000 	mov	r3, #0	; 0x0
  301464:	e5823000 	str	r3, [r2]
  301468:	e59f301c 	ldr	r3, [pc, #28]	; 0x30148c; 0x80810060 ; Timer4LowValue

  30146c:	e5933000 	ldr	r3, [r3]
  301470:	e3530000 	cmp	r3, #0	; 0x0
  301474:	1afffffb 	bne	0x301468; wait for timer to zero

  301478:	e59f2008 	ldr	r2, [pc, #8]	; 0x301488; 0x80810064 ; Timer4HighValue
  30147c:	e3a03c01 	mov	r3, #256	; 0x100
  301480:	e5823000 	str	r3, [r2]	; restart timer4

  301484:	e1a0f00e 	mov	pc, lr

  301488:	80810064
  30148c:	80810060

//----------------------------------------------------------------------------
; r0 = result
; r1 = source
; r2 = max count
checksum:
  301490:	e3520000 	cmp	r2, #0	; 0x0
  301494:	e52de004 	str	lr, [sp, #-4]!	; push lr to stack for return
  301498:	049df004 	ldreq	pc, [sp], #4	; if count is 0 return
  30149c:	e3a0e000 	mov	lr, #0	; 0x0	; initial index = 0
  3014a0:	e15e0002 	cmp	lr, r2
  3014a4:	a49df004 	ldrge	pc, [sp], #4	; exit if done

  3014a8:	e7d1300e 	ldrb	r3, [r1, lr]	; load a byte source[index]
  3014ac:	e59fc01c 	ldr	ip, [pc, #28]	; 0x3014d0 00301884
  3014b0:	e0203003 	eor	r3, r0, r3	; EOR that byte with the current checksum
  3014b4:	e20330ff 	and	r3, r3, #255	; just use the LSByte 
  3014b8:	e79cc103 	ldr	ip, [ip, r3, lsl #2] ;
  3014bc:	e28ee001 	add	lr, lr, #1	; increment index
  3014c0:	e15e0002 	cmp	lr, r2		; done?
  3014c4:	e02c0420 	eor	r0, ip, r0, lsr #8	
  3014c8:	a49df004 	ldrge	pc, [sp], #4	; if done exit
  3014cc:	eafffff5 	b	0x3014a8

  3014d0:	00301884

//----------------------------------------------------------------------------
; result in r0
make_checksum:
  3014d4:	e1a03000 	mov	r3, r0		; r0=source
  3014d8:	e1a02001 	mov	r2, r1		; r1=count
  3014dc:	e52de004 	str	lr, [sp, #-4]!	; store the return address
  3014e0:	e1a01003 	mov	r1, r3		
  3014e4:	e3a00000 	mov	r0, #0		; initialize result to 0
  3014e8:	e59f3008 	ldr	r3, [pc, #8]	; 0x3014f8 ; 00301490
  3014ec:	e1a0e00f 	mov	lr, pc
  3014f0:	e1a0f003 	mov	pc, r3		; jump to checksum function
  3014f4:	e49df004 	ldr	pc, [sp], #4	; return

  3014f8:	00301490

//----------------------------------------------------------------------------
Loop_and_Flash_LEDS_forever:
  3014fc:	e52de004 	str	lr, [sp, #-4]!
  301500:	e3a0258f 	mov	r2, #599785472	; 0x23c00000
  301504:	e3a03005 	mov	r3, #5	; 0x5
  301508:	e1c230b0 	strh	r3, [r2]	; Feed Watchdog

  30150c:	e3a0258e 	mov	r2, #595591168	; 0x23800000
  301510:	e3a03000 	mov	r3, #0	; 0x0
  301514:	e1c230b0 	strh	r3, [r2]	; disable Watchdog

  301518:	e59f2024 	ldr	r2, [pc, #36]	; 0x301544 80840020
  30151c:	e3a03001 	mov	r3, #1	; 0x1	; Red Off, Green On

  301520:	e5823000 	str	r3, [r2]
  301524:	e59f001c 	ldr	r0, [pc, #28]	; 0x301548 0001e848
  301528:	e59f301c 	ldr	r3, [pc, #28]	; 0x30154c 00301410 ;Microsecond_Delay
  30152c:	e1a0e00f 	mov	lr, pc
  301530:	e1a0f003 	mov	pc, r3
  301534:	e59f2008 	ldr	r2, [pc, #8]	; 0x301544 80840020
  301538:	e5923000 	ldr	r3, [r2]
  30153c:	e2233003 	eor	r3, r3, #3	; 0x3	; swap Red Green
  301540:	eafffff6 	b	0x301520

  301544:	80840020 
  301548:	0001e848
  30154c:	00301410	;Microsecond_Delay

//----------------------------------------------------------------------------
// called with 
// r0(flash_source) = 0x0003e820
// r1(ram_dest) = 0x00008000
Copy_Flash_Page_to_Memory:
  301550:	e92d4010 	stmdb	sp!, {r4, lr}

  301554:	e1a0c000 	mov	ip, r0		; ip= 0x0003e820
  301558:	e1a04001 	mov	r4, r1		; r4= 0x00008000

  30155c:	e3a03006 	mov	r3, #6	; 0x6
  301560:	e59fe0c4 	ldr	lr, [pc, #196]	; 0x30162c 000186a0 #100000
  301564:	e59f00c4 	ldr	r0, [pc, #196]	; 0x301630 60400000 NAND CTRL	
  301568:	e5c03000 	strb	r3, [r0]	; store #6 in flash controller, CE and CLE

  30156c:	e3a01206 	mov	r1, #1610612736	; 0x60000000 NAND DATA
  301570:	e3a02000 	mov	r2, #0	; 0x0
  301574:	e5c12000 	strb	r2, [r1]	; store #0 in flash data register, read mode 1

  301578:	e3a03005 	mov	r3, #5	; 0x5
  30157c:	e5c03000 	strb	r3, [r0]	; store #5 in flash controller, CE and ALE

  301580:	e5c12000 	strb	r2, [r1]	; store #0 in flash data register,

  301584:	e20c30ff 	and	r3, ip, #255	; 0xff
  301588:	e5c13000 	strb	r3, [r1]	; store low address byte in flash data register

  30158c:	e20c3cff 	and	r3, ip, #65280	; 0xff00
  301590:	e1a03423 	mov	r3, r3, lsr #8
  301594:	e5c13000 	strb	r3, [r1]	;  store mid address byte in flash data register

  301598:	e20cc8ff 	and	ip, ip, #16711680	; 0xff0000
  30159c:	e1a0c82c 	mov	ip, ip, lsr #16
  3015a0:	e5c1c000 	strb	ip, [r1]	;  store high address byte in flash data register

  3015a4:	e3a03004 	mov	r3, #4	; 0x4
  3015a8:	e5c03000 	strb	r3, [r0]	; store 4 in control register, CLE

  3015ac:	e5c03000 	strb	r3, [r0]	; store 4 in control register, CLE

  3015b0:	e59f207c 	ldr	r2, [pc, #124]	; 0x301634 60800000 NAND flash busy status (bit 5)
  3015b4:	e5d23000 	ldrb	r3, [r2]	; 
  3015b8:	e3130020 	tst	r3, #32	; 0x20
  3015bc:	1a00000e 	bne	0x3015fc

  3015c0:	e24ee001 	sub	lr, lr, #1	; 0x1
  3015c4:	e5d23000 	ldrb	r3, [r2]
  3015c8:	e3130020 	tst	r3, #32	; 0x20
  3015cc:	1a000001 	bne	0x3015d8

  3015d0:	e35e0000 	cmp	lr, #0	; 0x0
  3015d4:	cafffff9 	bgt	0x3015c0	; wait for busy clear, max 100,000 tries

  3015d8:	e35e0000 	cmp	lr, #0	; 0x0
  3015dc:	1a000006 	bne	0x3015fc

  3015e0:	e59f3050 	ldr	r3, [pc, #80]	; 0x301638;00301274 	Print_String
  3015e4:	e59f0050 	ldr	r0, [pc, #80]	; 0x30163c "flash timeout!"
  3015e8:	e1a0e00f 	mov	lr, pc
  3015ec:	e1a0f003 	mov	pc, r3		; Print  "flash timeout!"

  3015f0:	e59f3048 	ldr	r3, [pc, #72]	; 0x301640 Loop_and_Flash_LEDS_forever
  3015f4:	e1a0e00f 	mov	lr, pc
  3015f8:	e1a0f003 	mov	pc, r3		; Flash_LEDS_forever

  3015fc:	e59f2040 	ldr	r2, [pc, #64]	; 0x301644 0000020f, #527
  301600:	e3a01000 	mov	r1, #0	; 0x0

  301604:	e3a03206 	mov	r3, #1610612736	; 0x60000000 NAND DATA
  301608:	e5d33000 	ldrb	r3, [r3]
  30160c:	e7c43001 	strb	r3, [r4, r1]	; store next byte from flash into destination 
  301610:	e2811001 	add	r1, r1, #1	
  301614:	e1510002 	cmp	r1, r2
  301618:	dafffff9 	ble	0x301604

  30161c:	e59f200c 	ldr	r2, [pc, #12]	; 0x301630 60400000 NAND CTRL
  301620:	e3a03000 	mov	r3, #0	; 0x0
  301624:	e5c23000 	strb	r3, [r2]	; all flash signals low
  301628:	e8bd8010 	ldmia	sp!, {r4, pc}

  30162c:	000186a0 	
  301630:	60400000	NAND CTRL
  301634:	60800000 	NAND BUSY (bit 5)
  301638:	00301274 	Print_String
  30163c:	00302064 	"flash timeout!"
  301640:	003014fc	Loop_and_Flash_LEDS_forever 
  301644:	0000020f 	#527

//----------------------------------------------------------------------------
// R0 = memory address to test.
// result r0 = 0 (no memory), or 1 (memory found)

Detect_SDRAM:
  301648:	e59f2058 	ldr	r2, [pc, #88]	; 0x3016a8 aaaaaaaa
  30164c:	e5802000 	str	r2, [r0]	; store 0xaaaaaaaa in [r0]

  301650:	e59f3054 	ldr	r3, [pc, #84]	; 0x3016ac 55555555
  301654:	e280c004 	add	ip, r0, #4	; 0x4
  301658:	e58c3000 	str	r3, [ip]	; store 0x55555555 in [r0+4]

  30165c:	e5901000 	ldr	r1, [r0]
  301660:	e1510002 	cmp	r1, r2		; does [r0] == 0xaaaaaaaa (the value we just stored)
  301664:	1a000002 	bne	0x301674	; exit if not equal

  301668:	e59c2000 	ldr	r2, [ip]
  30166c:	e1520003 	cmp	r2, r3		; does [r0+4] == 0x55555555 (the value we just stored)
  301670:	0a000001 	beq	0x30167c	; continue if equal

  301674:	e3a00000 	mov	r0, #0		; 0x0 "no memory" return value
  301678:	e1a0f00e 	mov	pc, lr		; return

  30167c:	e5802000 	str	r2, [r0]	; store 0x55555555 in [r0]
  301680:	e58c1000 	str	r1, [ip]	; store 0xaaaaaaaa in [r0+4]
  301684:	e5903000 	ldr	r3, [r0]
  301688:	e1530002 	cmp	r3, r2		; does [r0] == 0x55555555 (the value we just stored)
  30168c:	1a000003 	bne	0x3016a0	; exit if not equal

  301690:	e59cc000 	ldr	ip, [ip]
  301694:	e15c0001 	cmp	ip, r1		; does [r0+4] == 0xaaaaaaaa (the value we just stored)
  301698:	03a00001 	moveq	r0, #1		
  30169c:	01a0f00e 	moveq	pc, lr		; return 1 "memory found"

  3016a0:	e3a00000 	mov	r0, #0		; 0x0 "no memory" return value
  3016a4:	e1a0f00e 	mov	pc, lr		; return

  3016a8:	aaaaaaaa
  3016ac:	55555555

//----------------------------------------------------------------------------
enable_eeprom:
  3016b0:	e59f2034 	ldr	r2, [pc, #52]	; 0x3016ec 808a0008
  3016b4:	e3a03006 	mov	r3, #6	; 0x6
  3016b8:	e5823000 	str	r3, [r2]	; write 6 to SPI

  3016bc:	e59f202c 	ldr	r2, [pc, #44]	; 0x3016f0 808a0004
  3016c0:	e3a03010 	mov	r3, #16	; 0x10	; enable SSP (SPI)
  3016c4:	e5823000 	str	r3, [r2]

  3016c8:	e59f2024 	ldr	r2, [pc, #36]	; 0x3016f4 808a000c
  3016cc:	e5922000 	ldr	r2, [r2]
  3016d0:	e2122010 	ands	r2, r2, #16	; 0x10
  3016d4:	1afffffb 	bne	0x3016c8	; wait till not busy

  3016d8:	e59f300c 	ldr	r3, [pc, #12]	; 0x3016ec 808a0008
  3016dc:	e5933000 	ldr	r3, [r3]	; read the incoming byte and discard it

  3016e0:	e59f3008 	ldr	r3, [pc, #8]	; 0x3016f0 808a0004
  3016e4:	e5832000 	str	r2, [r3]	; disable SPI
  3016e8:	e1a0f00e 	mov	pc, lr

  3016ec:	808a0008
  3016f0:	808a0004
  3016f4:	808a000c

//----------------------------------------------------------------------------
read_eeprom_status:	; read status register
  3016f8:	e59f2044 	ldr	r2, [pc, #68]	; 0x301744 808a0008
  3016fc:	e3a03005 	mov	r3, #5	; 0x5
  301700:	e5823000 	str	r3, [r2]	; write 5 to spi

  301704:	e3a03000 	mov	r3, #0	; 0x0
  301708:	e5823000 	str	r3, [r2]	; write 0 to spi

  30170c:	e59f2034 	ldr	r2, [pc, #52]	; 0x301748 808a0004
  301710:	e3a03010 	mov	r3, #16	; 0x10
  301714:	e5823000 	str	r3, [r2] 	; enable SSP (SPI)

  301718:	e59f202c 	ldr	r2, [pc, #44]	; 0x30174c 808a000c
  30171c:	e5922000 	ldr	r2, [r2]
  301720:	e2122010 	ands	r2, r2, #16	; 0x10
  301724:	1afffffb 	bne	0x301718	; wait for not busy

  301728:	e59f1014 	ldr	r1, [pc, #20]	; 0x301744 808a0008
  30172c:	e5913000 	ldr	r3, [r1]	; discard input
  301730:	e5911000 	ldr	r1, [r1]	; read input

  301734:	e59f300c 	ldr	r3, [pc, #12]	; 0x301748 808a0004
  301738:	e20100ff 	and	r0, r1, #255	; 0xff

  30173c:	e5832000 	str	r2, [r3]	; disable SPI
  301740:	e1a0f00e 	mov	pc, lr

  301744:	808a0008
  301748:	808a0004
  30174c:	808a000c

//----------------------------------------------------------------------------
write_eeprom_status:
  301750:	e59f203c 	ldr	r2, [pc, #60]	; 0x301794 808a0008
  301754:	e3a03001 	mov	r3, #1	; 0x1
  301758:	e5823000 	str	r3, [r2]
  30175c:	e5820000 	str	r0, [r2]

  301760:	e59f2030 	ldr	r2, [pc, #48]	; 0x301798 808a0004
  301764:	e3a03010 	mov	r3, #16	; 0x10
  301768:	e5823000 	str	r3, [r2]

  30176c:	e59f2028 	ldr	r2, [pc, #40]	; 0x30179c 808a000c
  301770:	e5922000 	ldr	r2, [r2]
  301774:	e2122010 	ands	r2, r2, #16	; 0x10
  301778:	1afffffb 	bne	0x30176c

  30177c:	e59f1010 	ldr	r1, [pc, #16]	; 0x301794 808a0008
  301780:	e5913000 	ldr	r3, [r1]
  301784:	e5911000 	ldr	r1, [r1]

  301788:	e59f3008 	ldr	r3, [pc, #8]	; 0x301798 808a0004
  30178c:	e5832000 	str	r2, [r3]
  301790:	e1a0f00e 	mov	pc, lr

  301794:	808a0008
  301798:	808a0004
  30179c:	808a000c

//----------------------------------------------------------------------------
write_byte_to_eeprom:
// r0 = 16 bit address
// r1 = data byte to send
  3017a0:	e20110ff 	and	r1, r1, #255	; 0xff
  3017a4:	e59f2058 	ldr	r2, [pc, #88]	; 0x301804 808a0008
  3017a8:	e3a03002 	mov	r3, #2	; 0x2
  3017ac:	e5823000 	str	r3, [r2]	; send #2 write

  3017b0:	e2003cff 	and	r3, r0, #65280	; 0xff00
  3017b4:	e1a03423 	mov	r3, r3, lsr #8
  3017b8:	e5823000 	str	r3, [r2]	; send upper byte of address

  3017bc:	e20030ff 	and	r3, r0, #255	; 0xff
  3017c0:	e5823000 	str	r3, [r2]	; send lower byte of address

  3017c4:	e5821000 	str	r1, [r2]	; send byte

  3017c8:	e59f2038 	ldr	r2, [pc, #56]	; 0x301808 808a0004
  3017cc:	e3a03010 	mov	r3, #16	; 0x10
  3017d0:	e5823000 	str	r3, [r2]	; enable spi

  3017d4:	e59f2030 	ldr	r2, [pc, #48]	; 0x30180c 808a000c
  3017d8:	e5922000 	ldr	r2, [r2]
  3017dc:	e2122010 	ands	r2, r2, #16	; 0x10
  3017e0:	1afffffb 	bne	0x3017d4	; wait

  3017e4:	e59f1018 	ldr	r1, [pc, #24]	; 0x301804 808a0008
  3017e8:	e5913000 	ldr	r3, [r1]	; discard
  3017ec:	e5913000 	ldr	r3, [r1]	; discard
  3017f0:	e5913000 	ldr	r3, [r1]	; discard
  3017f4:	e5911000 	ldr	r1, [r1]	; discard

  3017f8:	e59f3008 	ldr	r3, [pc, #8]	; 0x301808 808a0004
  3017fc:	e5832000 	str	r2, [r3]	; disable spi
  301800:	e1a0f00e 	mov	pc, lr

  301804:	808a0008
  301808:	808a0004
  30180c:	808a000c

//----------------------------------------------------------------------------
read_byte_from_eeprom:
// r0 = 16 bit address
// r1 = address to store byte
  301810:	e59f2060 	ldr	r2, [pc, #96]	; 0x301878 808a0008
  301814:	e3a03003 	mov	r3, #3	; 0x3
  301818:	e5823000 	str	r3, [r2] 	; send #3 read

  30181c:	e2003cff 	and	r3, r0, #65280	; 0xff00
  301820:	e1a03423 	mov	r3, r3, lsr #8
  301824:	e5823000 	str	r3, [r2]	; send upper byte of address

  301828:	e20000ff 	and	r0, r0, #255	; 0xff
  30182c:	e5820000 	str	r0, [r2]	; send lower byte of address

  301830:	e3a03000 	mov	r3, #0	; 0x0	; send dumby
  301834:	e5823000 	str	r3, [r2]

  301838:	e59f203c 	ldr	r2, [pc, #60]	; 0x30187c 808a0004
  30183c:	e3a03010 	mov	r3, #16	; 0x10
  301840:	e5823000 	str	r3, [r2]	; enable

  301844:	e59f2034 	ldr	r2, [pc, #52]	; 0x301880 808a000c
  301848:	e5922000 	ldr	r2, [r2]
  30184c:	e2122010 	ands	r2, r2, #16	; 0x10
  301850:	1afffffb 	bne	0x301844	; wait

  301854:	e59f001c 	ldr	r0, [pc, #28]	; 0x301878 808a0008
  301858:	e5903000 	ldr	r3, [r0]	; discard
  30185c:	e5903000 	ldr	r3, [r0]	; discard
  301860:	e5903000 	ldr	r3, [r0]	; discard
  301864:	e5900000 	ldr	r0, [r0]	; read byte

  301868:	e59f300c 	ldr	r3, [pc, #12]	; 0x30187c 808a0004
  30186c:	e5c10000 	strb	r0, [r1]	; store the byte
  301870:	e5832000 	str	r2, [r3]	; disable SPI
  301874:	e1a0f00e 	mov	pc, lr

  301878:	808a0008
  30187c:	808a0004
  301880:	808a000c


//----------------------------------------------------------------------------

// 256 word of CRC keys
  301884:	0x00000000,0x77073096,0xEE0E612C,0x990951BA,
0x076DC419,0x706AF48F,0xE963A535,0x9E6495A3,0x0EDB8832,0x79DCB8A4,0xE0D5E91E,
0x97D2D988,0x09B64C2B,0x7EB17CBD,0xE7B82D07,0x90BF1D91,0x1DB71064,0x6AB020F2,
0xF3B97148,0x84BE41DE,0x1ADAD47D,0x6DDDE4EB,0xF4D4B551,0x83D385C7,0x136C9856,
0x646BA8C0,0xFD62F97A,0x8A65C9EC,0x14015C4F,0x63066CD9,0xFA0F3D63,0x8D080DF5,
0x3B6E20C8,0x4C69105E,0xD56041E4,0xA2677172,0x3C03E4D1,0x4B04D447,0xD20D85FD,
0xA50AB56B,0x35B5A8FA,0x42B2986C,0xDBBBC9D6,0xACBCF940,0x32D86CE3,0x45DF5C75,
0xDCD60DCF,0xABD13D59,0x26D930AC,0x51DE003A,0xC8D75180,0xBFD06116,0x21B4F4B5,
0x56B3C423,0xCFBA9599,0xB8BDA50F,0x2802B89E,0x5F058808,0xC60CD9B2,0xB10BE924,
0x2F6F7C87,0x58684C11,0xC1611DAB,0xB6662D3D,0x76DC4190,0x01DB7106,0x98D220BC,
0xEFD5102A,0x71B18589,0x06B6B51F,0x9FBFE4A5,0xE8B8D433,0x7807C9A2,0x0F00F934,
0x9609A88E,0xE10E9818,0x7F6A0DBB,0x086D3D2D,0x91646C97,0xE6635C01,0x6B6B51F4,
0x1C6C6162,0x856530D8,0xF262004E,0x6C0695ED,0x1B01A57B,0x8208F4C1,0xF50FC457,
0x65B0D9C6,0x12B7E950,0x8BBEB8EA,0xFCB9887C,0x62DD1DDF,0x15DA2D49,0x8CD37CF3,
0xFBD44C65,0x4DB26158,0x3AB551CE,0xA3BC0074,0xD4BB30E2,0x4ADFA541,0x3DD895D7,
0xA4D1C46D,0xD3D6F4FB,0x4369E96A,0x346ED9FC,0xAD678846,0xDA60B8D0,0x44042D73,
0x33031DE5,0xAA0A4C5F,0xDD0D7CC9,0x5005713C,0x270241AA,0xBE0B1010,0xC90C2086,
0x5768B525,0x206F85B3,0xB966D409,0xCE61E49F,0x5EDEF90E,0x29D9C998,0xB0D09822,
0xC7D7A8B4,0x59B33D17,0x2EB40D81,0xB7BD5C3B,0xC0BA6CAD,0xEDB88320,0x9ABFB3B6,
0x03B6E20C,0x74B1D29A,0xEAD54739,0x9DD277AF,0x04DB2615,0x73DC1683,0xE3630B12,
0x94643B84,0x0D6D6A3E,0x7A6A5AA8,0xE40ECF0B,0x9309FF9D,0x0A00AE27,0x7D079EB1,
0xF00F9344,0x8708A3D2,0x1E01F268,0x6906C2FE,0xF762575D,0x806567CB,0x196C3671,
0x6E6B06E7,0xFED41B76,0x89D32BE0,0x10DA7A5A,0x67DD4ACC,0xF9B9DF6F,0x8EBEEFF9,
0x17B7BE43,0x60B08ED5,0xD6D6A3E8,0xA1D1937E,0x38D8C2C4,0x4FDFF252,0xD1BB67F1,
0xA6BC5767,0x3FB506DD,0x48B2364B,0xD80D2BDA,0xAF0A1B4C,0x36034AF6,0x41047A60,
0xDF60EFC3,0xA867DF55,0x316E8EEF,0x4669BE79,0xCB61B38C,0xBC66831A,0x256FD2A0,
0x5268E236,0xCC0C7795,0xBB0B4703,0x220216B9,0x5505262F,0xC5BA3BBE,0xB2BD0B28,
0x2BB45A92,0x5CB36A04,0xC2D7FFA7,0xB5D0CF31,0x2CD99E8B,0x5BDEAE1D,0x9B64C2B0,
0xEC63F226,0x756AA39C,0x026D930A,0x9C0906A9,0xEB0E363F,0x72076785,0x05005713,
0x95BF4A82,0xE2B87A14,0x7BB12BAE,0x0CB61B38,0x92D28E9B,0xE5D5BE0D,0x7CDCEFB7,
0x0BDBDF21,0x86D3D2D4,0xF1D4E242,0x68DDB3F8,0x1FDA836E,0x81BE16CD,0xF6B9265B,
0x6FB077E1,0x18B74777,0x88085AE6,0xFF0F6A70,0x66063BCA,0x11010B5C,0x8F659EFF,
0xF862AE69,0x616BFFD3,0x166CCF45,0xA00AE278,0xD70DD2EE,0x4E048354,0x3903B3C2,
0xA7672661,0xD06016F7,0x4969474D,0x3E6E77DB,0xAED16A4A,0xD9D65ADC,0x40DF0B66,
0x37D83BF0,0xA9BCAE53,0xDEBB9EC5,0x47B2CF7F,0x30B5FFE9,0xBDBDF21C,0xCABAC28A,
0x53B39330,0x24B4A3A6,0xBAD03605,0xCDD70693,0x54DE5729,0x23D967BF,0xB3667A2E,
0xC4614AB8,0x5D681B02,0x2A6F2B94,0xB40BBE37,0xC30C8EA1,0x5A05DF1B,0x2D02EF8D

  301c84:	000003f8
  301c88:	000002f8
  301c8c:	000003e8
  301c90:	000002e8
  301c94:	000003a8
  301c98:	000002a8
  301c9c:	000003a0
  301ca0:	000002a0
  301ca4:	00000398
  301ca8:	00000298
  301cac:	00000390
  301cb0:	00000290

00301cb4:	.string		"Jan"
00301cb8:	.string		"Feb"
00301cbc:	.string		"Mar"
00301cc0:	.string		"Apr"
00301cc4:	.string		"May"
00301cc8:	.string		"Jun"
00301ccc:	.string		"Jul"
00301cd0:	.string		"Aug"
00301cd4:	.string		"Sep"
00301cd8:	.string		"Oct"
00301cdc:	.string		"Nov"
00301ce0:	.string		"Dec"	 

00301ce4:	.string		"COM1"	 
00301cec:	.string		"COM2"
00301cf4:	.string		"COM3"
00301cfc:	.string		"COM4"
00301d04:	.string		"COM5"
00301d0c:	.string		"COM6"
00301d14:	.string		"COM7"
00301d1c:	.string		"COM8"
00301d24:	.string		"COM9"
00301d2c:	.string		"COM10"
00301d34:	.string		"COM11"
00301d3c:	.string		"COM12"

00301d44:	.string		"A"
00301d48:	.string		"C"
00301d4c:	.string		"D0"
00301d50:	.string		"D1"
00301d54:	.string		"E0"
00301d58:	.string		"E1"
00301d5c:	.string		">E1"
00301d60:	.string		"\r\n\r\n>> TS-BOOTROM, Rev 1.05 - built 11:50:53, Jun 22 2005\r\n"
00301d9c:	.string		">> Copyright (C) 2005, Technologic Systems\r\n"
00301dcc:	.string		"128MB"
;00301dd0:	.string		"B"	; from line above
00301dd4:	.string		"32MB"
00301ddc:	.string		"64MB"
00301de4:	.string		">> starting initial burn-in...\r\n"
00301e08:	.string		">> rerunning burn-in (already tested OK before)..."
00301e40:	.string		"internal error 2: "
00301e54:	.string		".TS-BOOTROM self-checksum failed!\r\n"
00301e78:	.string		">> TS-7200"
00301e84:	.string		">> TS-7250"
00301e90:	.string		">> JNS200"
00301e9c:	.string		"\r\ninternal error 3\r\n"
00301eb4:	.string		": Rev "
00301ebc:	.string		" CPU, Rev "
00301ec8:	.string		"D"
00301ecc:	.string		"E"
00301ed0:	.string		"F"
00301ed4:	.string		"\r\ninternal error 0\r\n"
00301eec:	.string		" PLD, "
00301ef4:	.string		" SDRAM"
00301efc:	.string		", options ( "
00301f0c:	.string		"MAX197-ADC "
00301f18:	.string		"RS485 "
00301f20:	.string		")\r\n"
00301f24:	.string		">> override bootup signature found at 0x60010030   jumping\r\n"
00301f64:	.string		"Can't find CRUS bootup signature\r\n"
00301f88:	.string		">> TS-5620: detected, battery "
00301fa8:	.string		"DEAD\r\n"
00301fb0:	.string		"OK\r\n"
00301fb4:	.string		", time ( "
00301fc0:	.string		" )\r\n"
00301fc8:	.string		":"
00301fcc:	.string		" 20"
00301fd0:	.string		">> Off-board serial at:"
00301fe8:	.string		"IRQ?"
00301ff0:	.string		"IRQ5"
00301ff8:	.string		"IRQ6"
00302000:	.string		"IRQ7"
00302008:	.string		">> TS-ETH10 at:"
00302018:	.string		" 0x3"
00302020:	.string		"/"
00302024:	.string		"sdram test failed!\r\n\taddr: "
00302040:	.string		"X"
00302044:	.string		"."
00302048:	.string		" ( 'X' - bad bit )\r\n\tdata: "
00302060:	.string		"flash timeout!"

00302073:	.string		"0"
00302075:	.string		"1"
00302077:	.string		"2"
00302079:	.string		"3"
0030207b:	.string		"4"
0030207d:	.string		"5"
0030207f:	.string		"6"
00302081:	.string		"7"
00302083:	.string		"8"
00302085:	.string		"9"
00302087:	.string		"a"
00302089:	.string		"b"
0030208b:	.string		"c"
0030208d:	.string		"d"
0030208f:	.string		"e"
00302091:	.string		"f"

// this code copied to fifo (prob for execution) 
  302094:	e92d47f0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, lr}
	:::::::::::::::::::   se relocated code below!!!!
  3024d0:	00000000 	andeq	r0, r0, r0

//code as coppied to fifo

//----------------------------------------------------------------------------
// r0 = address
// r1 = size
Test_SDRAM_Bank:
80014000:	e92d47f0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, lr}
80014004:	e3a04000 	mov	r4, #0			; 0x0
80014008:	e1a0c000 	mov	ip, r0			; ip=address
8001400c:	e1a08001 	mov	r8, r1			; r8=size
80014010:	e1a05004 	mov	r5, r4			; 0x0
80014014:	e1a07004 	mov	r7, r4			; 0x0

80014018:	e3a06000 	mov	r6, #0			; 0x0
8001401c:	e1560008 	cmp	r6, r8			; cmp r6 to size
80014020:	e1a0e006 	mov	lr, r6			; 1<<index
80014024:	2a00002f 	bcs	0x800140e8

80014028:	e59f0174 	ldr	r0, [pc, #372]		; 0x800141a4 8001442c [00000000, 0000aaaa, 0000ffff, 00005555] 
8001402c:	e7903107 	ldr	r3, [r0, r7, lsl #2]	; r3 = test_pattern [00000000, 0000aaaa, 0000ffff, or 00005555]
80014030:	e1a03803 	mov	r3, r3, lsl #16		; clip the half-word
80014034:	e08ca00e 	add	sl, ip, lr		; sl = address+(1<<index))
80014038:	e1a03823 	mov	r3, r3, lsr #16		; just the low half-word
8001403c:	e1ca30b0 	strh	r3, [sl]		; store test half-word in memory
80014040:	e7903107 	ldr	r3, [r0, r7, lsl #2]	; r3 = test_pattern [00000000, 0000aaaa, 0000ffff, or 00005555]
80014044:	e1e0100e 	mvn	r1, lr			; r1 = -(1<<index)
80014048:	e3c1137f 	bic	r1, r1, #-67108863	; 0xfc000001, clip it
8001404c:	e1e03003 	mvn	r3, r3			; negate test bytes
80014050:	e3c1150e 	bic	r1, r1, #58720256	; 0x03800000 
80014054:	e1a03803 	mov	r3, r3, lsl #16		; clip the half-word
80014058:	e08c1001 	add	r1, ip, r1		; r1 = address+(0x007ffffe)-(1<<index)
8001405c:	e1a03823 	mov	r3, r3, lsr #16		; r3=~test_pattern    just the low half-word of 
80014060:	e1c130b0 	strh	r3, [r1]		; str ~test_pattern in [address+(0x007ffffe)-(1<<index)]
80014064:	e1da30b0 	ldrh	r3, [sl]		; ldrh r3 from [address+(1<<index)]
80014068:	e7909107 	ldr	r9, [r0, r7, lsl #2]	; r9 = test_pattern [00000000, 0000aaaa, 0000ffff, or 00005555]
8001406c:	e1a02803 	mov	r2, r3, lsl #16		;
80014070:	e1a03809 	mov	r3, r9, lsl #16		;   clip to lower half-word
80014074:	e1a02822 	mov	r2, r2, lsr #16		;
80014078:	e1a03823 	mov	r3, r3, lsr #16		;
8001407c:	e1520003 	cmp	r2, r3			; ? [address+(1<<index)] == [test_pattern]
80014080:	10222009 	eorne	r2, r2, r9		; r2 = r2^test; if error find the bit in error
80014084:	e1e09009 	mvn	r9, r9			; r2 = -r2
80014088:	e1a09809 	mov	r9, r9, lsl #16		; clip
8001408c:	11844002 	orrne	r4, r4, r2		; collect list of bad bits
80014090:	1185500e 	orrne	r5, r5, lr		; collect bad addresses
80014094:	e1a09829 	mov	r9, r9, lsr #16		; clip, now r9 = ~test_pattern
80014098:	e1ca90b0 	strh	r9, [sl]		; str ~test_pattern in [address+(1<<index)]
8001409c:	e1d130b0 	ldrh	r3, [r1]		; r3 = [address+(0x007ffffe)-(1<<index)]
800140a0:	e7900107 	ldr	r0, [r0, r7, lsl #2]	; r0 = test_pattern [00000000, 0000aaaa, 0000ffff, or 00005555]
800140a4:	e1a02803 	mov	r2, r3, lsl #16		; clip
800140a8:	e1e03000 	mvn	r3, r0			; r3 = ~test_pattern
800140ac:	e1a03803 	mov	r3, r3, lsl #16		; clip
800140b0:	e1a02822 	mov	r2, r2, lsr #16		; r2 = [address+(0x007ffffe)-(1<<index)]
800140b4:	e1a03823 	mov	r3, r3, lsr #16		; clip
800140b8:	e1520003 	cmp	r2, r3			; ?[address+(0x007ffffe)-(1<<index)] == ~data
800140bc:	10222003 	eorne	r2, r2, r3		; r2 = diff,  if error find the bit in error
800140c0:	e1a00800 	mov	r0, r0, lsl #16		; clip test_pattern
800140c4:	11844002 	orrne	r4, r4, r2		; collect list of bad bits
800140c8:	1185500e 	orrne	r5, r5, lr		; collect bad addresses (each bit represents an address)
800140cc:	e1a00820 	mov	r0, r0, lsr #16		; clip test
800140d0:	e1c100b0 	strh	r0, [r1]
800140d4:	e3a0e001 	mov	lr, #1	; 0x1
800140d8:	e2866001 	add	r6, r6, #1	; 0x1	; index++
800140dc:	e1a0e61e 	mov	lr, lr, lsl r6		; lr = (1<<index)
800140e0:	e15e0008 	cmp	lr, r8			; cmp lr to size
800140e4:	3affffcf 	bcc	0x80014028		; next address to test

800140e8:	e2877001 	add	r7, r7, #1	; 0x1	; next test pattern
800140ec:	e3570003 	cmp	r7, #3	; 0x3		; ? we done?
800140f0:	9affffc8 	bls	0x80014018		; if not done each test pattern

800140f4:	e1953004 	orrs	r3, r5, r4		; no bits set = no errors
800140f8:	08bd87f0 	ldmeqia	sp!, {r4, r5, r6, r7, r8, r9, sl, pc} ; exit if no errors

// shut down sdram and report an error
800140fc:	e59f20a4 	ldr	r2, [pc, #164]	; 0x800141a8, 80060004 SDRAM control status register

80014100:	e3a03106 	mov	r3, #0x80000001
80014104:	e5823000 	str	r3, [r2]		; issue precharge all to sdram
  
80014108:	e3a03000 	mov	r3, #0x0		
8001410c:	e5823000 	str	r3, [r2]		; SDRAM de-assert clock, normal operation mode

80014110:	e3a03101 	mov	r3, #0x40000000
80014114:	e5823000 	str	r3, [r2]		; SDRAM clockdown, normal operation mode

80014118:	e59f008c 	ldr	r0, [pc, #140]	; 0x800141ac "sdram test failed!\r\n\taddr: "
8001411c:	e59f308c 	ldr	r3, [pc, #140]	; 0x800141b0 00301274	Print_String
80014120:	e185500c 	orr	r5, r5, ip	; or the collected address error bits with the original address
							; since the original address is aligned to a bank, its bits
							; will not be in the range of the address bits that are in error
							; but by adding the bank bits to the error address we can see the bank
							; that is in error, and this will help debug the hardware.
80014124:	e1a0e00f 	mov	lr, pc
80014128:	e1a0f003 	mov	pc, r3		; Print "sdram test failed!\r\n\taddr: "

8001412c:	e3a0601f 	mov	r6, #31	; 0x1f
80014130:	e3a03001 	mov	r3, #1	; 0x1
80014134:	e0153613 	ands	r3, r5, r3, lsl r6
80014138:	159f0074 	ldrne	r0, [pc, #116]	; 0x800141b4 "X"
8001413c:	059f0074 	ldreq	r0, [pc, #116]	; 0x800141b8 "."
80014140:	e59f3068 	ldr	r3, [pc, #104]	; 0x800141b0 00301274	Print_String
80014144:	e2466001 	sub	r6, r6, #1	; 0x1
80014148:	e1a0e00f 	mov	lr, pc
8001414c:	e1a0f003 	mov	pc, r3		; print "X" if bad address bit, or "." if good

80014150:	e3560000 	cmp	r6, #0	; 0x0
80014154:	aafffff5 	bge	0x80014130

80014158:	e59f005c 	ldr	r0, [pc, #92]	; 0x800141bc " ( 'X' - bad bit )\r\n\tdata: "
8001415c:	e59f304c 	ldr	r3, [pc, #76]	; 0x800141b0 00301274	Print_String
80014160:	e1a0e00f 	mov	lr, pc
80014164:	e1a0f003 	mov	pc, r3		; Print_String " ( 'X' - bad bit )\r\n\tdata: "

80014168:	e3a0501f 	mov	r5, #31	; 0x1f
8001416c:	e3a03001 	mov	r3, #1	; 0x1
80014170:	e0143513 	ands	r3, r4, r3, lsl r5
80014174:	159f0038 	ldrne	r0, [pc, #56]	; 0x800141b4 "X"
80014178:	059f0038 	ldreq	r0, [pc, #56]	; 0x800141b8 "."
8001417c:	e59f302c 	ldr	r3, [pc, #44]	; 0x800141b0 00301274	Print_String
80014180:	e2455001 	sub	r5, r5, #1	; 0x1
80014184:	e1a0e00f 	mov	lr, pc
80014188:	e1a0f003 	mov	pc, r3		; print "X" if bad data bit, or "." if good

8001418c:	e3550000 	cmp	r5, #0	; 0x0
80014190:	aafffff5 	bge	0x8001416c

80014194:	e59f3024 	ldr	r3, [pc, #36]	; 0x800141c0 Loop_and_Flash_LEDS_forever
80014198:	e1a0e00f 	mov	lr, pc
8001419c:	e1a0f003 	mov	pc, r3		; Loop_and_Flash_LEDS_forever

800141a0:	e8bd87f0 	ldmia	sp!, {r4, r5, r6, r7, r8, r9, sl, pc}	; can't get here

800141a4:	8001442c
800141a8:	80060004 	SDRAM control status register
800141ac:	00302024	"sdram test failed!\r\n\taddr: "
800141b0:	00301274	Print_String
800141b4:	00302040 	"X"
800141b8:	00302044	"."
800141bc:	00302048	" ( 'X' - bad bit )\r\n\tdata: "
800141c0:	003014fc	Loop_and_Flash_LEDS_forever

//----------------------------------------------------------------------------
Test_SDRAM:
800141c4:	e92d40f0 	stmdb	sp!, {r4, r5, r6, r7, lr}
800141c8:	e3a04000 	mov	r4, #0	; 0x0
800141cc:	e59f315c 	ldr	r3, [pc, #348]	; 0x80014330 00300008
800141d0:	e5933000 	ldr	r3, [r3]
800141d4:	e3730001 	cmn	r3, #1	; 0x1	; CMP against -1
800141d8:	03a05002 	moveq	r5, #2	; 0x2	; just RED EEPROM related value = -1
800141dc:	13a05003 	movne	r5, #3	; 0x3	; RED and GREEN <> -1
800141e0:	e59f314c 	ldr	r3, [pc, #332]	; 0x80014334 80840020
800141e4:	e5835000 	str	r5, [r3]	; SET LEDs

800141e8:	e59f6148 	ldr	r6, [pc, #328]	; 0x80014338 0030145c Reset_Timer4:
800141ec:	e1a0e00f 	mov	lr, pc
800141f0:	e1a0f006 	mov	pc, r6

800141f4:	e59f3140 	ldr	r3, [pc, #320]	; 0x8001433c 0000707f
800141f8:	e1540003 	cmp	r4, r3
800141fc:	ca000022 	bgt	0x8001428c

80014200:	e59f3138 	ldr	r3, [pc, #312]	; 0x80014340 80810060 timer4 low value
80014204:	e5933000 	ldr	r3, [r3]
80014208:	e353090f 	cmp	r3, #245760	; 0x3c000
8001420c:	2a000014 	bcs	0x80014264

80014210:	e59f712c 	ldr	r7, [pc, #300]	; 0x80014344 80014000 Test_SDRAM_Bank

80014214:	e3a00000 	mov	r0, #0	; 0x0
80014218:	e3a01502 	mov	r1, #8388608	; 0x800000
8001421c:	e1a0e00f 	mov	lr, pc
80014220:	e1a0f007 	mov	pc, r7		;Test_SDRAM_Bank

80014224:	e3a00401 	mov	r0, #16777216	; 0x1000000
80014228:	e3a01502 	mov	r1, #8388608	; 0x800000
8001422c:	e1a0e00f 	mov	lr, pc
80014230:	e1a0f007 	mov	pc, r7		;Test_SDRAM_Bank

80014234:	e3a00301 	mov	r0, #67108864	; 0x4000000
80014238:	e3a01502 	mov	r1, #8388608	; 0x800000
8001423c:	e1a0e00f 	mov	lr, pc
80014240:	e1a0f007 	mov	pc, r7		;Test_SDRAM_Bank

80014244:	e3a00405 	mov	r0, #83886080	; 0x5000000
80014248:	e3a01502 	mov	r1, #8388608	; 0x800000
8001424c:	e1a0e00f 	mov	lr, pc
80014250:	e1a0f007 	mov	pc, r7		;Test_SDRAM_Bank

80014254:	e59f30e4 	ldr	r3, [pc, #228]	; 0x80014340 80810060 timer4 low value
80014258:	e5933000 	ldr	r3, [r3]
8001425c:	e353090f 	cmp	r3, #245760	; 0x3c000 Test for 1/4 second
80014260:	3affffea 	bcc	0x80014210	; do test again if less than 1/4 second of testing

80014264:	e1a0e00f 	mov	lr, pc
80014268:	e1a0f006 	mov	pc, r6		; Reset_Timer4

8001426c:	e59f20c0 	ldr	r2, [pc, #192]	; 0x80014334 80840020 GPIO E
80014270:	e5923000 	ldr	r3, [r2]
80014274:	e0233005 	eor	r3, r3, r5
80014278:	e5823000 	str	r3, [r2]	; toggle the LEDs, either both or just red (see above)

8001427c:	e59f30b8 	ldr	r3, [pc, #184]	; 0x8001433c 0000707f
80014280:	e2844001 	add	r4, r4, #1	; 0x1
80014284:	e1540003 	cmp	r4, r3
80014288:	daffffdc 	ble	0x80014200

8001428c:	e59f30b4 	ldr	r3, [pc, #180]	; 0x80014348 00301190 EEPROM_write_version
80014290:	e1a0e00f 	mov	lr, pc
80014294:	e1a0f003 	mov	pc, r3		; call EEPROM_write_version

80014298:	e59f2094 	ldr	r2, [pc, #148]	; 0x80014334 80840020
8001429c:	e3a03001 	mov	r3, #1	; 0x1
800142a0:	e5823000 	str	r3, [r2]	; turn on green only

800142a4:	e59f508c 	ldr	r5, [pc, #140]	; 0x80014338 0030145c Reset_Timer4
800142a8:	e1a0e00f 	mov	lr, pc
800142ac:	e1a0f005 	mov	pc, r5		; call Reset_Timer4

800142b0:	e59f3088 	ldr	r3, [pc, #136]	; 0x80014340 80810060 timer4 low value
800142b4:	e5933000 	ldr	r3, [r3]
800142b8:	e353090f 	cmp	r3, #245760	; 0x3c000 Test for 1/4 second
800142bc:	2a000014 	bcs	0x80014314

800142c0:	e59f407c 	ldr	r4, [pc, #124]	; 0x80014344 80014000 Test_SDRAM_Bank

800142c4:	e3a00000 	mov	r0, #0	; 0x0
800142c8:	e3a01502 	mov	r1, #8388608	; 0x800000
800142cc:	e1a0e00f 	mov	lr, pc
800142d0:	e1a0f004 	mov	pc, r4		; Test_SDRAM_Bank

800142d4:	e3a00401 	mov	r0, #16777216	; 0x1000000
800142d8:	e3a01502 	mov	r1, #8388608	; 0x800000
800142dc:	e1a0e00f 	mov	lr, pc
800142e0:	e1a0f004 	mov	pc, r4		; Test_SDRAM_Bank

800142e4:	e3a00301 	mov	r0, #67108864	; 0x4000000
800142e8:	e3a01502 	mov	r1, #8388608	; 0x800000
800142ec:	e1a0e00f 	mov	lr, pc
800142f0:	e1a0f004 	mov	pc, r4		; Test_SDRAM_Bank

800142f4:	e3a00405 	mov	r0, #83886080	; 0x5000000
800142f8:	e3a01502 	mov	r1, #8388608	; 0x800000
800142fc:	e1a0e00f 	mov	lr, pc
80014300:	e1a0f004 	mov	pc, r4		; Test_SDRAM_Bank

80014304:	e59f3034 	ldr	r3, [pc, #52]	; 0x80014340 80810060 timer4 low value
80014308:	e5933000 	ldr	r3, [r3]
8001430c:	e353090f 	cmp	r3, #245760	; 0x3c000 Test for 1/4 second
80014310:	3affffea 	bcc	0x800142c0	;wait

80014314:	e1a0e00f 	mov	lr, pc
80014318:	e1a0f005 	mov	pc, r5		; Reset_Timer4

8001431c:	e59f2010 	ldr	r2, [pc, #16]	; 0x80014334 80840020  GPIO E
80014320:	e5923000 	ldr	r3, [r2]
80014324:	e2233001 	eor	r3, r3, #1	; 0x1
80014328:	e5823000 	str	r3, [r2]	; toggle the green LED
8001432c:	eaffffdf 	b	0x800142b0

80014330:	00300008
80014334:	80840020 ; GPIO E
80014338:	0030145c
8001433c:	0000707f
80014340:	80810060 ;timer4 low value
80014344:	80014000 ;Test_SDRAM_Bank
80014348:	00301190
8001434c:	00000000	; 1(A,B,C,D0,D1), 2(unknown), 3(E1,+)
80014350:	00000000	; 5(A,B,C,D0,D1), 6(E0); 7(unknown rev number)

80014354:	00301ce4 ;"COM1"
80014358:	00301cec ;"COM2"
8001435c:	00301cf4 ;"COM3"
80014360:	00301cfc ;"COM4"
80014364:	00301d04 ;"COM5"
80014368:	00301d0c ;"COM6"
8001436c:	00301d14 ;"COM7"
80014370:	00301d1c ;"COM8"
80014374:	00301d24 ;"COM9"
80014378:	00301d2c ;"COM10"
8001437c:	00301d34 ;"COM11"
80014380:	00301d3c ;"COM12"

80014384:	00301d44 ;"A"
80014388:	00301dd0 ;"B"
8001438c:	00301d48 ;"C"
80014390:	00301d4c ;"D0"
80014394:	00301d50 ;"D1"
80014398:	00301d54 ;"E0"
8001439c:	00301d58 ;"E1"
800143a0:	00301d5c ;">E1"
800143a4:	00301d5c ;">E1"
800143a8:	00301d5c ;">E1"
800143ac:	00301d5c ;">E1"
800143b0:	00301d5c ;">E1"
800143b4:	00301d5c ;">E1"
800143b8:	00301d5c ;">E1"
800143bc:	00301d5c ;">E1"
800143c0:	00301d5c ;">E1"

800143c4:	00301fc4 ;0x00000000
800143c8:	00301cb4 ;"Jan"
800143cc:	00301cb8 ;"Feb"
800143d0:	00301cbc ;"Mar"
800143d4:	00301cc0 ;"Apr"
800143d8:	00301cc4 ;"May"
800143dc:	00301cc8 ;"Jun"
800143e0:	00301ccc ;"Jul"
800143e4:	00301cd0 ;"Aug"
800143e8:	00301cd4 ;"Sep"
800143ec:	00301fc4 ;", time ( "
800143f0:	00301fc4 ;", time ( "
800143f4:	00301fc4 ;", time ( "
800143f8:	00301fc4 ;", time ( "
800143fc:	00301fc4 ;", time ( "
80014400:	00301fc4 ;", time ( "
80014404:	00301cd8 ;"Oct"
80014408:	00301cdc ;"Nov"
8001440c:	00301ce0 ;"Dec"
80014410:	00301fe8 ;"IRQ?"
80014414:	00301ff0 ;"IRQ5"
80014418:	00301ff8 ;"IRQ6"
8001441c:	00301fe8 ;"IRQ?"
80014420:	00302000 ;"IRQ7"
80014424:	00301fe8 ;"IRQ?"
80014428:	00301fe8 ;"IRQ?"

8001442c:	00000000 
80014430:	0000aaaa 
80014434:	0000ffff 
80014438:	00005555 
8001443c:	00000000	; print string storage contains 808x0020 (UART1 or UART2)
    // END of code coppied to MAC FIFO BUFFER

;-------------- not in source, but memory used ----------
80014440: 	(CPLD Model Number)
80014444:	[not used]
