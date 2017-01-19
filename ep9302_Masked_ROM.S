
rom.bin:     file format binary

Disassembly of section .data:

00000000 <.data>:
@ jump to 0x80090018 where the rom image is located, and run from there
       0:	e3a03102 	mov	r3, #-2147483648	; 0x80000000
       4:	e3a04809 	mov	r4, #589824	; 0x90000
       8:	e1833004 	orr	r3, r3, r4
       c:	e3833018 	orr	r3, r3, #24	; 0x18
      10:	e1a00000 	nop			(mov r0,r0)
      14:	e1a0f003 	mov	pc, r3

80090018:	e1a00000 	nop			(mov r0,r0)
8009001c:	e59f00b0 	ldr	r0, [pc, #176]	; 0x800900d4 #0x80840020
80090020:	e3a01002 	mov	r1, #2	; 0x2
80090024:	e5801000 	str	r1, [r0]	@ turn red on and green off 

80090028:	e59f0098 	ldr	r0, [pc, #152]	; 0x800900c8 #0x80940000
8009002c:	e59f1098 	ldr	r1, [pc, #152]	; 0x800900cc #0x0000aa55
80090030:	e5801000 	str	r1, [r0]	@ dissable watchdog

80090034:	eb000252 	bl	0x80090984	@init uart and write buffer
80090038:	e1a00000 	nop			(mov r0,r0)

8009003c:	eb000266 	bl	0x800909dc	@configure sram/rom

80090040:	eb0001f8 	bl	0x80090828	@Configure_SDRAM

80090044:	e3a02000 	mov	r2, #0	; 0x0
80090048:	e3a00102 	mov	r0, #-2147483648	; 0x80000000
8009004c:	e3a01893 	mov	r1, #9633792	; 0x930000
80090050:	e1800001 	orr	r0, r0, r1	@ R0=0x80930000
80090054:	e5802058 	str	r2, [r0, #88]	@ MIRCLK=0

80090058:	e59f0074 	ldr	r0, [pc, #116]	; 0x800900d4	80840020
8009005c:	e3a01001 	mov	r1, #1	; 0x1
80090060:	e5801000 	str	r1, [r0]	@ red=off green=on

80090064:	e59f0064 	ldr	r0, [pc, #100]	; 0x800900d0	8093009c
80090068:	e5901000 	ldr	r1, [r0]
8009006c:	e3110c01 	tst	r1, #256	; 0x100	
80090070:	1a000067 	bne	0x80090214	@ boot from UART (serial)

80090074:	eb000274 	bl	0x80090a4c	@ try SPI EEPROM boot (doesn't return if successful)

80090078:	eb00001a 	bl	0x800900e8	@ try SRAM/ROM/SDRAM boot

8009007c:	eb000039 	bl	0x80090168	@ try SDRAM boot

@ booting failed flash Green LED forever
80090080:	e1a00000 	nop
80090084:	e59f0048 	ldr	r0, [pc, #72]	; 0x800900d4	80840020
80090088:	e3a01002 	mov	r1, #2	; 0x2
8009008c:	e5801000 	str	r1, [r0]	@ red=on green=off

80090090:	e3a03a02 	mov	r3, #8192	; 0x2000
80090094:	e1a00000 	nop
80090098:	e1a00000 	nop
8009009c:	e1a00000 	nop
800900a0:	e1a00000 	nop
800900a4:	e1a00000 	nop
800900a8:	e59f0024 	ldr	r0, [pc, #36]	; 0x800900d4	80840020
800900ac:	e5901000 	ldr	r1, [r0]
800900b0:	e2211002 	eor	r1, r1, #2	; 0x2
800900b4:	e5801000 	str	r1, [r0]	@ toggle green LED
800900b8:	e2533001 	subs	r3, r3, #1	; 0x1
800900bc:	1afffffd 	bne	0x800900b8	; delay 
800900c0:	eafffff2 	b	0x80090090	; loop again (flash forever)

800900c4:	80014000
800900c8:	80940000
800900cc:	0000aa55 
800900d0:	8093009c 
800900d4:	80840020
800900d8:	80840000 
800900dc:	00005dc0 
800900e0:	00002ee0 
800900e4:	00001770 

// --------------------
// try SRAM/ROM/SDRAM boot
800900e8:	e59f0058 	ldr	r0, [pc, #88]	; 0x80090148	00000007
800900ec:	e59f1b8c 	ldr	r1, [pc, #2956]	; 0x80090c80	53555243	@'CRUS'
800900f0:	e59f2b8c 	ldr	r2, [pc, #2956]	; 0x80090c84	43525553 	@'SURC'
800900f4:	e59f3048 	ldr	r3, [pc, #72]	; 0x80090144	8009014c
800900f8:	e4934004 	ldr	r4, [r3], #4
800900fc:	e5945000 	ldr	r5, [r4]
80090100:	e1510005 	cmp	r1, r5
80090104:	0a00000a 	beq	0x80090134	; found 'CRUS' offset 0
80090108:	e1520005 	cmp	r2, r5
8009010c:	0a000009 	beq	0x80090138	; found 'SURC' offset 0
80090110:	e2844a01 	add	r4, r4, #4096	; 0x1000
80090114:	e5945000 	ldr	r5, [r4]
80090118:	e1510005 	cmp	r1, r5
8009011c:	0a000006 	beq	0x8009013c	; found 'CRUS' offset 4k
80090120:	e1520005 	cmp	r2, r5
80090124:	0a000005 	beq	0x80090140	; found 'SURC' offset 4k
80090128:	e2500001 	subs	r0, r0, #1	; 0x1
8009012c:	1afffff1 	bne	0x800900f8	; try next address

80090130:	e1a0f00e 	mov	pc, lr

80090134:	e284f004 	add	pc, r4, #4	; 0x4	; jump to code
80090138:	e284f004 	add	pc, r4, #4	; 0x4	; jump to code
8009013c:	e244fa01 	sub	pc, r4, #4096	; 0x1000; jump to code
80090140:	e244fa01 	sub	pc, r4, #4096	; 0x1000; jump to code

80090144:	8009014c
80090148:	00000007
8009014c:	10000000
80090150:	20000000
80090154:	30000000
80090158:	60000000
8009015c:	70000000
80090160:	c0000000
80090164:	f0000000

80090168:	e59f0050 	ldr	r0, [pc, #80]	; 0x800901c0	1a2b3c4d
8009016c:	e59f3044 	ldr	r3, [pc, #68]	; 0x800901b8	00000000
80090170:	e59f5040 	ldr	r5, [pc, #64]	; 0x800901b8	00000000
80090174:	e5830000 	str	r0, [r3]
80090178:	e5932000 	ldr	r2, [r3]
8009017c:	e1500002 	cmp	r0, r2
80090180:	0a000001 	beq	0x8009018c	; if 0x00000000 is writable

80090184:	e59f3030 	ldr	r3, [pc, #48]	; 0x800901bc	80014000	
80090188:	e59f502c 	ldr	r5, [pc, #44]	; 0x800901bc	80014000
8009018c:	e59f001c 	ldr	r0, [pc, #28]	; 0x800901b0	800901c4
80090190:	e59f101c 	ldr	r1, [pc, #28]	; 0x800901b4	80090210
80090194:	e0412000 	sub	r2, r1, r0
80090198:	e1a02122 	mov	r2, r2, lsr #2
8009019c:	e4904004 	ldr	r4, [r0], #4
800901a0:	e4834004 	str	r4, [r3], #4
800901a4:	e2522001 	subs	r2, r2, #1	; 0x1
800901a8:	1afffffb 	bne	0x8009019c	; copy 0x800901c4-0x80090210 to (ether fifo) or 0x00000000 
800901ac:	e1a0f005 	mov	pc, r5		; and run it.

800901b0:	800901c4
800901b4:	80090210
800901b8:	00000000
800901bc:	80014000
800901c0:	1a2b3c4d

800901c4:	ea000007 	b	0x800901e8
800901c8:	ea000006 	b	0x800901e8
800901cc:	eafffffe 	b	0x800901cc
800901d0:	eafffffe 	b	0x800901d0
800901d4:	eafffffe 	b	0x800901d4
800901d8:	eafffffe 	b	0x800901d8
800901dc:	eafffffe 	b	0x800901dc
800901e0:	eafffffe 	b	0x800901e0
800901e4:	e1a00000 	nop
800901e8:	e3a00102 	mov	r0, #-2147483648	; 0x80000000
800901ec:	e3a01721 	mov	r1, #8650752	; 0x840000
800901f0:	e1800001 	orr	r0, r0, r1	; r0=0x8084000
800901f4:	e3a01001 	mov	r1, #1	; 0x1
800901f8:	e3a02801 	mov	r2, #65536	; 0x10000
800901fc:	e5801020 	str	r1, [r0, #32]	; red=off green=alternating
80090200:	e2522001 	subs	r2, r2, #1	; 0x1
80090204:	1afffffd 	bne	0x80090200	; delay
80090208:	e2211001 	eor	r1, r1, #1	; 0x1
8009020c:	eafffff9 	b	0x800901f8	; do forever
80090210:	00000000 	andeq	r0, r0, r0

//-----------------------
// boot from UART (serial)
80090214:	e59fc160 	ldr	ip, [pc, #352]	; 0x8009037c	808c0000
80090218:	e3a01000 	mov	r1, #0	; 0x0
8009021c:	e58c1004 	str	r1, [ip, #4]	@UART1RXSts=0
80090220:	e58c100c 	str	r1, [ip, #12]	@UART1LinCtrlMid=0 
80090224:	e3a0102e 	mov	r1, #46	; 0x2e
80090228:	e58c1010 	str	r1, [ip, #16]	@UART1LinCtrlMid=46
8009022c:	e3a01060 	mov	r1, #96	; 0x60
80090230:	e58c1008 	str	r1, [ip, #8]	@UART1LinCtrlHigh=96
80090234:	e3a01003 	mov	r1, #3	; 0x3
80090238:	e58c1100 	str	r1, [ip, #256]	@UART1ModemCtrl=3
8009023c:	e3a01001 	mov	r1, #1	; 0x1
80090240:	e58c1014 	str	r1, [ip, #20]	@UART1Ctrl=1, Uart enable
80090244:	e3a0003c 	mov	r0, #60	; 0x3c
80090248:	e5cc0000 	strb	r0, [ip]	@ output '<'
8009024c:	e3a03b02 	mov	r3, #2048	; 0x800
80090250:	e51f2194 	ldr	r2, [pc, #-404]	; 0x800900c4	80014000
80090254:	e51fb188 	ldr	fp, [pc, #-392]	; 0x800900d4	80840020
80090258:	e3a0a001 	mov	sl, #1	; 0x1
8009025c:	e58ba000 	str	sl, [fp]	@ red=off green=on
80090260:	e3a05000 	mov	r5, #0	; 0x0
80090264:	e3a04000 	mov	r4, #0	; 0x0
80090268:	e3a09008 	mov	r9, #8	; 0x8
8009026c:	e59c1018 	ldr	r1, [ip, #24]	@ UART1Flag
80090270:	e3110010 	tst	r1, #16	; 0x10	
80090274:	1afffffc 	bne	0x8009026c	@ loop, waiting for data RXFE

80090278:	e5dc0000 	ldrb	r0, [ip]	@ read data byte
8009027c:	e2056003 	and	r6, r5, #3	; 0x3
80090280:	e0070996 	mul	r7, r6, r9
80090284:	e1a08710 	mov	r8, r0, lsl r7
80090288:	e1844008 	orr	r4, r4, r8
8009028c:	e2855001 	add	r5, r5, #1	; 0x1

80090290:	e59c1018 	ldr	r1, [ip, #24]	@ UART1Flag		
80090294:	e3110010 	tst	r1, #16	; 0x10
80090298:	1afffffc 	bne	0x80090290	@ loop, waiting for data RXFE

8009029c:	e5dc0000 	ldrb	r0, [ip]
800902a0:	e2056003 	and	r6, r5, #3	; 0x3
800902a4:	e0070996 	mul	r7, r6, r9
800902a8:	e1a08710 	mov	r8, r0, lsl r7
800902ac:	e1844008 	orr	r4, r4, r8
800902b0:	e3560003 	cmp	r6, #3	; 0x3
800902b4:	e2855001 	add	r5, r5, #1	; 0x1
800902b8:	1afffff4 	bne	0x80090290	@ loop for all for bytes of data

800902bc:	e4824004 	str	r4, [r2], #4	@ store data word in fifo

800902c0:	e59ba000 	ldr	sl, [fp]
800902c4:	e22aa001 	eor	sl, sl, #1	; 0x1
800902c8:	e58ba000 	str	sl, [fp]	; flash green led, for each word

800902cc:	e3530b02 	cmp	r3, #2048	; 0x800
800902d0:	0a000005 	beq	0x800902ec	; if this is the first word, check it. might be "CRUS", "UART", "UANT"

800902d4:	e3a04000 	mov	r4, #0	; 0x0
800902d8:	e2533004 	subs	r3, r3, #4	; 0x4
800902dc:	1affffeb 	bne	0x80090290	; get next word

800902e0:	e3a0003e 	mov	r0, #62	; 0x3e 	; send '>' 
800902e4:	e5cc0000 	strb	r0, [ip]

800902e8:	e51ff22c 	ldr	pc, [pc, #-556]	; 0x800900c4	80014000 @ jump to start of ether fifo

800902ec:	e59f008c 	ldr	r0, [pc, #140]	; 0x80090380	54524155 @ "UART"
800902f0:	e1500004 	cmp	r0, r4
800902f4:	0a000003 	beq	0x80090308	; send values 0..255 repeatedly to serial, for test purposes

800902f8:	e59f0084 	ldr	r0, [pc, #132]	; 0x80090384	54524155 @ "UANT"
800902fc:	e1500004 	cmp	r0, r4
80090300:	0a000009 	beq	0x8009032c	;  output the names of the developers "Nexus Team"

80090304:	eafffff2 	b	0x800902d4

//------------
// send values 0..255 repeatedly to serial, for test purposes
80090308:	e3a00000 	mov	r0, #0	; 0x0	; signature was "UART"
8009030c:	e59c1018 	ldr	r1, [ip, #24]
80090310:	e3110080 	tst	r1, #128	; 0x80
80090314:	0afffffc 	beq	0x8009030c	; wait till transmit fifo is empty

80090318:	e5cc0000 	strb	r0, [ip]	; transmit 0..255 
8009031c:	e2800001 	add	r0, r0, #1	; 0x1
80090320:	e3500c01 	cmp	r0, #256	; 0x100
80090324:	0afffff7 	beq	0x80090308
80090328:	eafffff7 	b	0x8009030c	; loop again sending next value

//------------
// output the names of the developers "Nexus Team"
8009032c:	e59f3034 	ldr	r3, [pc, #52]	; 0x80090368	80090388; start
80090330:	e59f4034 	ldr	r4, [pc, #52]	; 0x8009036c	80090827; stop
80090334:	e0444003 	sub	r4, r4, r3
80090338:	e59c1018 	ldr	r1, [ip, #24]
8009033c:	e3110080 	tst	r1, #128	; 0x80
80090340:	0afffffc 	beq	0x80090338	; wait till transmit fifo is empty
80090344:	e4d35001 	ldrb	r5, [r3], #1
80090348:	e5cc5000 	strb	r5, [ip]
8009034c:	e2544001 	subs	r4, r4, #1	; 0x1
80090350:	1afffff8 	bne	0x80090338

80090354:	e3a04801 	mov	r4, #65536	; 0x10000
80090358:	e2544001 	subs	r4, r4, #1	; 0x1
8009035c:	1afffffd 	bne	0x80090358	; delay

80090360:	eafffff1 	b	0x8009032c	; print the names again
80090364:	eafffffe 	b	0x80090364	@ halt


80090368:	80090388
8009036c:	80090827
80090370:	00000000
80090374:	00000000
80090378:	00000000
8009037c:	808c0000
80090380:	54524155	@ "UART"
80090384:	544e4155	@ "UANT"

00000388  20 20 20 20 20 20 20 20  			            |        |
00000390  20 20 20 20 20 20 20 20  20 20 20 20 20 20 20 20  |                |
000003a0  20 20 20 20 20 20 4e 65  78 75 73 20 54 65 61 6d  |      Nexus Team|
000003b0  20 4d 65 6d 62 65 72 73  20 20 20 20 20 20 20 20  | Members        |
000003c0  20 0a 0d 41 64 72 69 61  6e 20 48 65 6e 64 72 6f  | ..Adrian Hendro|
000003d0  66 66 20 2d 20 41 6c 61  6e 20 43 68 65 6e 20 2d  |ff - Alan Chen -|
000003e0  20 41 6c 61 6e 20 54 75  6c 6c 20 2d 20 41 6c 69  | Alan Tull - Ali|
000003f0  20 49 7a 61 64 69 20 2d  20 41 6c 66 69 65 20 50  | Izadi - Alfie P|
00000400  68 69 6c 69 70 73 20 2d  20 0a 0d 41 6e 64 72 65  |hilips - ..Andre|
00000410  77 20 43 61 68 6f 6f 6e  20 2d 20 42 68 61 76 69  |w Cahoon - Bhavi|
00000420  6e 20 50 61 74 65 6c 20  2d 20 42 6f 62 20 53 74  |n Patel - Bob St|
00000430  61 6e 64 61 72 64 20 2d  20 42 6f 62 62 79 20 50  |andard - Bobby P|
00000440  75 72 63 65 6c 6c 20 2d  20 42 72 69 61 6e 20 43  |urcell - Brian C|
00000450  6c 69 6e 74 6f 6e 20 2d  20 0a 0d 42 72 69 61 6e  |linton - ..Brian|
00000460  20 53 74 72 61 75 70 20  2d 20 43 61 72 6c 20 48  | Straup - Carl H|
00000470  61 72 76 65 79 20 2d 20  43 65 64 72 69 63 20 42  |arvey - Cedric B|
00000480  65 6c 6c 69 74 74 6f 20  2d 20 43 68 72 69 73 20  |ellitto - Chris |
00000490  43 61 6e 65 73 74 61 72  6f 20 28 63 6c 63 29 20  |Canestaro (clc) |
000004a0  2d 20 44 61 6c 65 20 2d  20 0a 0d 44 61 76 65 20  |- Dale - ..Dave |
000004b0  42 61 72 72 65 72 61 20  2d 20 44 61 76 65 20 46  |Barrera - Dave F|
000004c0  72 65 6e 63 68 20 2d 20  44 61 76 69 64 20 4c 75  |rench - David Lu|
000004d0  6f 20 2d 20 44 61 76 69  64 20 53 68 69 65 6c 73  |o - David Shiels|
000004e0  20 2d 20 44 65 63 6c 61  6e 20 46 61 72 72 65 6c  | - Declan Farrel|
000004f0  6c 79 20 2d 20 0a 0d 44  69 61 72 6d 75 69 64 20  |ly - ..Diarmuid |
00000500  44 6f 72 61 6e 20 2d 20  44 6f 75 67 20 54 69 65  |Doran - Doug Tie|
00000510  64 74 20 2d 20 44 75 6b  65 20 48 75 64 73 6f 6e  |dt - Duke Hudson|
00000520  20 2d 20 45 72 69 63 20  46 61 67 67 69 6f 6e 61  | - Eric Faggiona|
00000530  74 6f 20 2d 20 46 61 68  65 65 6d 20 48 61 79 61  |to - Faheem Haya|
00000540  74 20 2d 20 0a 0d 46 65  72 67 75 73 20 4f 27 42  |t - ..Fergus O'B|
00000550  72 69 65 6e 20 2d 20 46  72 61 6e 6b 20 4d 61 72  |rien - Frank Mar|
00000560  63 68 61 6e 20 2d 20 46  72 61 6e 6b 20 54 61 6e  |chan - Frank Tan|
00000570  74 69 6c 6c 6f 20 2d 20  47 65 65 74 61 20 50 75  |tillo - Geeta Pu|
00000580  6a 75 72 61 20 2d 20 0a  0d 47 72 65 74 63 68 65  |jura - ..Gretche|
00000590  6e 20 57 68 69 74 65 20  2d 20 48 75 6e 67 20 54  |n White - Hung T|
000005a0  72 61 6e 20 2d 20 49 6b  65 20 4c 65 69 62 6f 77  |ran - Ike Leibow|
000005b0  69 74 7a 20 2d 20 4a 61  65 2d 48 79 75 63 6b 20  |itz - Jae-Hyuck |
000005c0  4b 77 61 6b 20 2d 20 4a  61 67 64 69 73 68 20 4a  |Kwak - Jagdish J|
000005d0  61 6a 61 6c 20 2d 20 0a  0d 4a 61 67 64 69 73 68  |ajal - ..Jagdish|
000005e0  20 44 6f 6d 61 20 2d 20  4a 61 6d 65 73 20 4f 27  | Doma - James O'|
000005f0  44 6f 6e 6f 76 61 6e 20  2d 20 4a 65 61 6e 20 41  |Donovan - Jean A|
00000600  6e 6e 65 20 42 6f 6f 74  68 20 2d 20 4a 65 66 66  |nne Booth - Jeff|
00000610  20 4b 6c 61 61 73 20 2d  20 0a 0d 4a 65 6e 6e 69  | Klaas - ..Jenni|
00000620  66 65 72 20 48 61 6d 69  6c 74 6f 6e 20 2d 20 4a  |fer Hamilton - J|
00000630  69 6d 20 41 6e 74 6f 6e  65 20 2d 20 4a 69 6d 20  |im Antone - Jim |
00000640  46 6f 78 20 2d 20 4a 69  6d 20 47 69 62 62 6f 6e  |Fox - Jim Gibbon|
00000650  73 20 2d 20 4a 69 6d 20  4f 27 42 72 69 65 6e 20  |s - Jim O'Brien |
00000660  2d 20 0a 0d 4a 75 6c 69  65 20 48 6f 67 61 6e 20  |- ..Julie Hogan |
00000670  2d 20 4b 65 61 6c 61 6e  20 4d 63 4b 75 73 6b 65  |- Kealan McKuske|
00000680  72 20 2d 20 4b 65 6e 6e  65 74 68 20 44 77 79 65  |r - Kenneth Dwye|
00000690  72 20 2d 20 4b 75 72 74  20 48 6f 75 73 74 6f 6e  |r - Kurt Houston|
000006a0  20 2d 20 4c 61 72 72 79  20 4c 69 20 2d 20 0a 0d  | - Larry Li - ..|
000006b0  4c 69 61 6d 20 42 6f 77  6c 65 73 20 2d 20 4c 79  |Liam Bowles - Ly|
000006c0  6e 6e 20 47 61 6c 6c 61  67 68 65 72 20 2d 20 4d  |nn Gallagher - M|
000006d0  61 6e 65 65 73 68 20 54  69 6c 61 6b 20 2d 20 4d  |aneesh Tilak - M|
000006e0  61 72 63 20 42 65 72 67  65 72 6f 6e 20 2d 20 4d  |arc Bergeron - M|
000006f0  61 74 20 53 74 72 6f 75  64 20 2d 20 0a 0d 4d 63  |at Stroud - ..Mc|
00000700  47 65 65 20 4f 6c 73 6f  6e 20 2d 20 4d 65 68 72  |Gee Olson - Mehr|
00000710  61 6e 20 4a 61 6c 61 6c  69 61 6e 69 20 2d 20 4d  |an Jalaliani - M|
00000720  69 63 68 61 65 6c 20 46  6c 6f 6f 64 20 2d 20 4d  |ichael Flood - M|
00000730  69 6b 65 20 4b 6f 73 74  20 2d 20 4e 6f 72 6d 61  |ike Kost - Norma|
00000740  20 46 69 74 7a 70 61 74  72 69 63 6b 20 2d 0a 0d  | Fitzpatrick -..|
00000750  4f 77 65 6e 20 56 69 6e  63 65 6e 74 20 2d 20 50  |Owen Vincent - P|
00000760  61 75 6c 20 4a 6f 72 64  61 6e 20 2d 20 52 69 63  |aul Jordan - Ric|
00000770  6b 20 53 74 61 6e 64 69  6e 67 20 2d 20 52 6f 62  |k Standing - Rob|
00000780  20 47 6f 72 73 65 67 6e  65 72 20 2d 20 52 75 73  | Gorsegner - Rus|
00000790  73 65 6c 6c 20 56 69 63  6b 65 72 73 20 2d 20 0a  |sell Vickers - .|
000007a0  0d 53 63 6f 74 74 20 42  75 74 6c 65 72 20 2d 20  |.Scott Butler - |
000007b0  53 65 62 61 73 74 69 65  6e 20 44 75 63 72 6f 73  |Sebastien Ducros|
000007c0  20 2d 20 53 74 65 76 65  20 4b 75 6c 69 6b 20 2d  | - Steve Kulik -|
000007d0  20 53 68 61 6e 65 20 54  6f 64 64 20 2d 20 53 74  | Shane Todd - St|
000007e0  75 61 72 74 20 42 6f 6e  6e 65 6d 61 20 2d 20 0a  |uart Bonnema - .|
000007f0  0d 54 61 6e 79 61 20 4f  72 74 65 67 61 20 2d 20  |.Tanya Ortega - |
00000800  57 69 6c 6c 69 61 6d 20  4d 63 4b 6e 69 67 68 74  |William McKnight|
00000810  20 2d 20 5a 68 6f 6e 67  63 68 75 6e 20 4c 69 75  | - Zhongchun Liu|
00000820  20 2d 20 0a 0d 0a 0d 00

//-----------------------
Configure_SDRAM
80090828:	e59f10e8 	ldr	r1, [pc, #232]	; 0x80090918 	00000bb8
8009082c:	e2511001 	subs	r1, r1, #1	; 0x1
80090830:	1afffffd 	bne	0x8009082c	@ short wait

80090834:	e51f076c 	ldr	r0, [pc, #-1900]; 0x800900d0 	8093009c syscfg
80090838:	e5901000 	ldr	r1, [r0]
8009083c:	e20120c0 	and	r2, r1, #192	; 0xc0
80090840:	e35200c0 	cmp	r2, #192	; 0xc0
80090844:	0a000005 	beq	0x80090860	@ if LCSn7 and LCSn6 are high

80090848:	e3520080 	cmp	r2, #128	; 0x80
8009084c:	0a000003 	beq	0x80090860	@ if LCSn7 high and LCSn6 low	

80090850:	e59f5100 	ldr	r5, [pc, #256]	; 0x80090958	002a002c
80090854:	e59f80e4 	ldr	r8, [pc, #228]	; 0x80090940	80060010
80090858:	e5885000 	str	r5, [r8]	@ SDRAMDevCfg0

8009085c:	ea000002 	b	0x8009086c

80090860:	e59f50f4 	ldr	r5, [pc, #244]	; 0x8009095c	002a0028
80090864:	e59f80d4 	ldr	r8, [pc, #212]	; 0x80090940	80060010
80090868:	e5885000 	str	r5, [r8]	@ SDRAMDevCfg0

8009086c:	e59f50dc 	ldr	r5, [pc, #220]	; 0x80090950	00220028
80090870:	e59f80d4 	ldr	r8, [pc, #212]	; 0x8009094c	8006001c
80090874:	e5885000 	str	r5, [r8]	@ SDRAMDevCfg3

80090878:	e59f1098 	ldr	r1, [pc, #152]	; 0x80090918	00000bb8
8009087c:	e2511001 	subs	r1, r1, #1	; 0x1
80090880:	1afffffd 	bne	0x8009087c	@ delay

80090884:	e59f8094 	ldr	r8, [pc, #148]	; 0x80090920	80060004
80090888:	e59f50a0 	ldr	r5, [pc, #160]	; 0x80090930	80000003
8009088c:	e5885000 	str	r5, [r8]	@ GiConfig

80090890:	e59f1084 	ldr	r1, [pc, #132]	; 0x8009091c	00001770
80090894:	e2511001 	subs	r1, r1, #1	; 0x1
80090898:	1afffffd 	bne	0x80090894	@ delay

8009089c:	e59f807c 	ldr	r8, [pc, #124]	; 0x80090920	80060004
800908a0:	e59f5080 	ldr	r5, [pc, #128]	; 0x80090928	80000001
800908a4:	e5885000 	str	r5, [r8]	@ GiConfig	

800908a8:	e59f8084 	ldr	r8, [pc, #132]	; 0x80090934	80060008
800908ac:	e3a0500a 	mov	r5, #10	; 0xa
800908b0:	e5885000 	str	r5, [r8]	@ Refrsh Timr

800908b4:	e59f105c 	ldr	r1, [pc, #92]	; 0x80090918	00000bb8
800908b8:	e2511001 	subs	r1, r1, #1	; 0x1
800908bc:	1afffffd 	bne	0x800908b8	@ delay

800908c0:	e59f806c 	ldr	r8, [pc, #108]	; 0x80090934	80060008
800908c4:	e59f506c 	ldr	r5, [pc, #108]	; 0x80090938	00000204
800908c8:	e5885000 	str	r5, [r8]	@ Refrsh Timr

800908cc:	e35200c0 	cmp	r2, #192	; 0xc0
800908d0:	0a000003 	beq	0x800908e4	@ if LCSn7 high and LCSn6 high

800908d4:	e3520080 	cmp	r2, #128	; 0x80
800908d8:	0a000001 	beq	0x800908e4	@ if LCSn7 high and LCSn6 low

800908dc:	e59f608c 	ldr	r6, [pc, #140]	; 0x80090970	c0046600
800908e0:	ea000000 	b	0x800908e8

800908e4:	e59f6088 	ldr	r6, [pc, #136]	; 0x80090974	c008c800

800908e8:	e59f7090 	ldr	r7, [pc, #144]	; 0x80090980	f000c800
800908ec:	e59f802c 	ldr	r8, [pc, #44]	; 0x80090920	80060004
800908f0:	e59f5034 	ldr	r5, [pc, #52]	; 0x8009092c	80000002
800908f4:	e5885000 	str	r5, [r8]	@ GIConfig
800908f8:	e5965000 	ldr	r5, [r6]	@ load from c008c800 to issue command to sdram
800908fc:	e5975000 	ldr	r5, [r7]	@ load from f000c800 to issue command to sdram

80090900:	e59f8018 	ldr	r8, [pc, #24]	; 0x80090920	80060004
80090904:	e59f5018 	ldr	r5, [pc, #24]	; 0x80090924	80000000
80090908:	e5885000 	str	r5, [r8]	@ GIConfig CKE=1, SDRAM normal operation mode

8009090c:	e1a0f00e 	mov	pc, lr

80090910:	80000c00
80090914:	00000001
80090918:	00000bb8
8009091c:	00001770
80090920:	80060004
80090924:	80000000
80090928:	80000001
8009092c:	80000002
80090930:	80000003
80090934:	80060008
80090938:	00000204
8009093c:	8006000c
80090940:	80060010
80090944:	80060014
80090948:	80060018
8009094c:	8006001c
80090950:	00220028
80090954:	00220008
80090958:	002a002c
8009095c:	002a0028
80090960:	0022000c
80090964:	00220008
80090968:	c0006600
8009096c:	c000c800
80090970:	c0046600
80090974:	c008c800
80090978:	d000c800
8009097c:	f008c800
80090980:	f000c800

//-----------------------
// init uart1 and cache
80090984:	e1a0c00e 	mov	ip, lr
80090988:	e59f0300 	ldr	r0, [pc, #768]	; 0x80090c90 #0x80930000
8009098c:	e3a010aa 	mov	r1, #170	; 0xaa
80090990:	e58010c0 	str	r1, [r0, #192]	@ unlock syscon

80090994:	e3a01701 	mov	r1, #262144	; 0x40000
80090998:	e5801080 	str	r1, [r0, #128]	@ enable UART1

8009099c:	e3a00078 	mov	r0, #120	; 0x78
800909a0:	ee010f10 	mcr	15, 0, r0, cr1, cr0, {0}	@ enable write buffer and 32bit modes
800909a4:	e1a00000 	nop			(mov r0,r0)
800909a8:	e1a00000 	nop			(mov r0,r0)
800909ac:	e1a00000 	nop			(mov r0,r0)
800909b0:	e1a00000 	nop			(mov r0,r0)
800909b4:	e1a00000 	nop			(mov r0,r0)

800909b8:	e1a0f00c 	mov	pc, ip

//-----------------------
// short delay
800909bc:	e59f400c 	ldr	r4, [pc, #12]	; 0x800909d0 #0x00000280
800909c0:	e2544001 	subs	r4, r4, #1	; 0x1
800909c4:	1afffffd 	bne	0x800909c0
800909c8:	e1a0f00e 	mov	pc, lr

800909cc:	00000000
800909d0:	00000280
800909d4:	000398e7
800909d8:	0003bb18

//-----------------------
// configure sram/rom
800909dc:	e59f005c 	ldr	r0, [pc, #92]	; 0x80090a40 #0x80080000
800909e0:	e59f105c 	ldr	r1, [pc, #92]	; 0x80090a44 #0x00001c61
800909e4:	e51f291c 	ldr	r2, [pc, #-2332] ; 0x800900d0 #0x8093009c
800909e8:	e5923000 	ldr	r3, [r2]
800909ec:	e20340c0 	and	r4, r3, #192	; 0xc0
800909f0:	e35400c0 	cmp	r4, #192	; 0xc0
800909f4:	0a000007 	beq	0x80090a18	@LCSn7,LCSn6 = 11 ;unknown

800909f8:	e3540080 	cmp	r4, #128	; 0x80
800909fc:	0a000005 	beq	0x80090a18	@LCSn7,LCSn6 = 10 ;unknown

80090a00:	e3540040 	cmp	r4, #64	; 0x40
80090a04:	0a000005 	beq	0x80090a20	@LCSn7,LCSn6 = 01 ;16-bit

80090a08:	e59f1038 	ldr	r1, [pc, #56]	; 0x80090a48 #00001861
80090a0c:	e3540000 	cmp	r4, #0	; 0x0
80090a10:	0a000003 	beq	0x80090a24
80090a14:	ea000002 	b	0x80090a24

//-----------------------
80090a18:	e3811202 	orr	r1, r1, #536870912	; 0x20000000; R1=20001c61
80090a1c:	ea000000 	b	0x80090a24
80090a20:	e3811201 	orr	r1, r1, #268435456	; 0x10000000; R1=10001c61

80090a24:	e5801000 	str	r1, [r0]		; sram bank 0
80090a28:	e5801004 	str	r1, [r0, #4]		; bank 1
80090a2c:	e5801008 	str	r1, [r0, #8]		; bank 2
80090a30:	e580100c 	str	r1, [r0, #12]		; bank 3
80090a34:	e5801018 	str	r1, [r0, #24]		; bank 6
80090a38:	e580101c 	str	r1, [r0, #28]		; bank 7
80090a3c:	e1a0f00e 	mov	pc, lr

80090a40:	80080000 
80090a44:	00001c61 
80090a48:	00001861 

//-----------------------
// try SPI EEPROM boot (doesn't return if successful)
80090a4c:	e1a0900e 	mov	r9, lr

80090a50:	eb00001a 	bl	0x80090ac0	; setup the SPI and clear some stack space

80090a54:	eb000001 	bl	0x80090a60	;

80090a58:	e1a0e009 	mov	lr, r9
80090a5c:	e1a0f00e 	mov	pc, lr

//
80090a60:	e92d47fc 	stmdb	sp!, {r2, r3, r4, r5, r6, r7, r8, r9, sl, lr} 	@ we have a stack now
80090a64:	e1a0c00e 	mov	ip, lr
80090a68:	e3a01001 	mov	r1, #1	; 0x1
80090a6c:	e59f221c 	ldr	r2, [pc, #540]	; 0x80090c90	80930000
80090a70:	e5923044 	ldr	r3, [r2, #68]	@ R3 = [ScatchReg1]
80090a74:	e0033001 	and	r3, r3, r1
80090a78:	e1530001 	cmp	r3, r1
80090a7c:	0a00000b 	beq	0x80090ab0	@ if bit0 is 1, set it again (redundant) and return

80090a80:	e3a03b02 	mov	r3, #2048	; 0x800
80090a84:	e3a04004 	mov	r4, #4	; 0x4
80090a88:	e59f522c 	ldr	r5, [pc, #556]	; 0x80090cbc	80014000
80090a8c:	eb00001c 	bl	0x80090b04	@ get the eeprom mode in R1 (either mode 3, mode 2, or mode 1)
							@ returns NEQ if success

80090a90:	08bd87fc 	ldmeqia	sp!, {r2, r3, r4, r5, r6, r7, r8, r9, sl, pc} @ exit if failed

80090a94:	e1a00004 	mov	r0, r4
80090a98:	eb000062 	bl	0x80090c28	@ get a word from the eeprom and return it in R0

80090a9c:	e4850004 	str	r0, [r5], #4	@ load eeprom into ethernet fifo
80090aa0:	e2533004 	subs	r3, r3, #4	; 0x4
80090aa4:	e2844004 	add	r4, r4, #4	; 0x4
80090aa8:	1afffff9 	bne	0x80090a94	@ get next word

80090aac:	e59ff20c 	ldr	pc, [pc, #524]	; 0x80090cc0	80014000	@jump to EEPROM code in ether fifo

// set scratch and exit
80090ab0:	e3a01001 	mov	r1, #1	; 0x1
80090ab4:	e59f21d4 	ldr	r2, [pc, #468]	; 0x80090c90	80930000
80090ab8:	e5821044 	str	r1, [r2, #68]	@ set bit0 of ScratchReg1 to 1 , seem to indicate an error
80090abc:	e1a0f00c 	mov	pc, ip		@ return

// setup the SPI and clear some stack space
80090ac0:	e59fb1d4 	ldr	fp, [pc, #468]	; 0x80090c9c	808a0000
80090ac4:	e59fa1b0 	ldr	sl, [pc, #432]	; 0x80090c7c	80090cd4
80090ac8:	e3a01004 	mov	r1, #4	; 0x4
80090acc:	e58b1010 	str	r1, [fp, #16]	@ set SPI clock prescale

80090ad0:	e59f11c8 	ldr	r1, [pc, #456]	; 0x80090ca0	000001c7
80090ad4:	e58b1000 	str	r1, [fp]	@ set SSPCR0, SCR=1, SPH=1, SPO=1, FRF=0, DSS=7
							@ meaning SPI, 8bit,  

80090ad8:	e3a01010 	mov	r1, #16	; 0x10
80090adc:	e58b1004 	str	r1, [fp, #4]	@ enable SSP

@ zeros out an area of 256 bytes for the stack
80090ae0:	e59fd1d0 	ldr	sp, [pc, #464]	; 0x80090cb8	800148fc
80090ae4:	e3a00000 	mov	r0, #0	; 0x0
80090ae8:	e3a0103f 	mov	r1, #63	; 0x3f

80090aec:	e58d0000 	str	r0, [sp]	@ [fifo+0x08fc to fifo+0x0800] = 0
80090af0:	e24dd004 	sub	sp, sp, #4	; 0x4
80090af4:	e2511001 	subs	r1, r1, #1	; 0x1
80090af8:	1afffffb 	bne	0x80090aec

80090afc:	e59fd1b4 	ldr	sp, [pc, #436]	; 0x80090cb8	800148fc
80090b00:	e1a0f00e 	mov	pc, lr		@ return

// find the eeprom mode, returned in R1 (either mode 3, mode 2, or mode 1) , with status NEQ if success
80090b04:	e92d47fc 	stmdb	sp!, {r2, r3, r4, r5, r6, r7, r8, r9, sl, lr}
80090b08:	e3a01003 	mov	r1, #3	; 0x3

80090b0c:	e3a00000 	mov	r0, #0	; 0x0
80090b10:	e59f2168 	ldr	r2, [pc, #360]	; 0x80090c80	53555243	@'CRUS'
80090b14:	eb000043 	bl	0x80090c28	@ r1=eeprom_type, r0=address of word to read
							@ returned word is in R0
80090b18:	e1500002 	cmp	r0, r2
80090b1c:	0a000003 	beq	0x80090b30
80090b20:	e59f215c 	ldr	r2, [pc, #348]	; 0x80090c84	43525553 	@'SURC'
80090b24:	e1500002 	cmp	r0, r2
80090b28:	0a000002 	beq	0x80090b38
80090b2c:	ea000003 	b	0x80090b40

80090b30:	e3510000 	cmp	r1, #0	; 0x0
80090b34:	e8bd87fc 	ldmia	sp!, {r2, r3, r4, r5, r6, r7, r8, r9, sl, pc}

80090b38:	e3510000 	cmp	r1, #0	; 0x0
80090b3c:	e8bd87fc 	ldmia	sp!, {r2, r3, r4, r5, r6, r7, r8, r9, sl, pc}

80090b40:	e2511001 	subs	r1, r1, #1	; 0x1
80090b44:	1afffff0 	bne	0x80090b0c
80090b48:	e8bd87fc 	ldmia	sp!, {r2, r3, r4, r5, r6, r7, r8, r9, sl, pc}


//
80090b4c:	e92d43fc 	stmdb	sp!, {r2, r3, r4, r5, r6, r7, r8, r9, lr}
80090b50:	e1a04001 	mov	r4, r1		 @ r1 starts at #3
80090b54:	e20010ff 	and	r1, r0, #255	; 0xff
80090b58:	e1a02420 	mov	r2, r0, lsr #8
80090b5c:	e20220ff 	and	r2, r2, #255	; 0xff
80090b60:	e1a03820 	mov	r3, r0, lsr #16
80090b64:	e20330ff 	and	r3, r3, #255	; 0xff
80090b68:	e3a05003 	mov	r5, #3	; 0x3
80090b6c:	e3a06000 	mov	r6, #0	; 0x0

80090b70:	e3540001 	cmp	r4, #1	; 0x1
80090b74:	0a000003 	beq	0x80090b88

80090b78:	e3540002 	cmp	r4, #2	; 0x2
80090b7c:	0a00000a 	beq	0x80090bac

80090b80:	e3540003 	cmp	r4, #3	; 0x3
80090b84:	0a00000d 	beq	0x80090bc0

80090b88:	e3100c01 	tst	r0, #256	; 0x100
80090b8c:	1a000001 	bne	0x80090b98

80090b90:	e3a05003 	mov	r5, #3	; 0x3
80090b94:	ea000000 	b	0x80090b9c

80090b98:	e3a0500b 	mov	r5, #11	; 0xb

80090b9c:	e1cb50b8 	strh	r5, [fp, #8]
80090ba0:	e1cb10b8 	strh	r1, [fp, #8]
80090ba4:	e1cb60b8 	strh	r6, [fp, #8]
80090ba8:	ea000009 	b	0x80090bd4

80090bac:	e1cb50b8 	strh	r5, [fp, #8]
80090bb0:	e1cb20b8 	strh	r2, [fp, #8]
80090bb4:	e1cb10b8 	strh	r1, [fp, #8]
80090bb8:	e1cb60b8 	strh	r6, [fp, #8]
80090bbc:	ea000004 	b	0x80090bd4

80090bc0:	e1cb50b8 	strh	r5, [fp, #8]
80090bc4:	e1cb30b8 	strh	r3, [fp, #8]
80090bc8:	e1cb20b8 	strh	r2, [fp, #8]
80090bcc:	e1cb10b8 	strh	r1, [fp, #8]
80090bd0:	e1cb60b8 	strh	r6, [fp, #8]

80090bd4:	e3a06001 	mov	r6, #1	; 0x1
80090bd8:	e3866004 	orr	r6, r6, #4	; 0x4
80090bdc:	e3a05000 	mov	r5, #0	; 0x0

80090be0:	e59b700c 	ldr	r7, [fp, #12]
80090be4:	e2855001 	add	r5, r5, #1	; 0x1
80090be8:	e3550801 	cmp	r5, #65536	; 0x10000
80090bec:	0affffaf 	beq	0x80090ab0	; timeout set sratch reg and return

80090bf0:	e0078006 	and	r8, r7, r6
80090bf4:	e1580006 	cmp	r8, r6		
80090bf8:	1afffff8 	bne	0x80090be0	;  loop while if (Transmit fifo not empty) or (receive fifo is empty)

// at this point the transmit is empty and their is data in the receive
80090bfc:	e3a05000 	mov	r5, #0	; 0x0

80090c00:	e59b700c 	ldr	r7, [fp, #12]
80090c04:	e2078004 	and	r8, r7, #4	; 0x4	@ receive fifo
80090c08:	e2855001 	add	r5, r5, #1	; 0x1
80090c0c:	e3550801 	cmp	r5, #65536	; 0x10000
80090c10:	0affffa6 	beq	0x80090ab0	; timeout set scratch reg and return

80090c14:	e3580004 	cmp	r8, #4	; 0x4
80090c18:	01db00b8 	ldreqh	r0, [fp, #8]	@ if receive fifo not empty read data
80090c1c:	0afffff7 	beq	0x80090c00	@ loop if receive fifo not empty 
80090c20:	e1a01004 	mov	r1, r4		@ restor r1 in case some routine overwrote it
80090c24:	e8bd83fc 	ldmia	sp!, {r2, r3, r4, r5, r6, r7, r8, r9, pc} @return

// get a word from the eeprom and return it in R0
80090c28:	e92d43fc 	stmdb	sp!, {r2, r3, r4, r5, r6, r7, r8, r9, lr}
80090c2c:	e1a05000 	mov	r5, r0
80090c30:	e3a04000 	mov	r4, #0	; 0x0
80090c34:	e3a09008 	mov	r9, #8	; 0x8
80090c38:	ebffffc3 	bl	0x80090b4c	; get half word from eeprom, only byte valid

80090c3c:	e2056003 	and	r6, r5, #3	; 0x3
80090c40:	e0070996 	mul	r7, r6, r9	; r7 = 0, 8, 16, 24 (shift value)
80090c44:	e1a08710 	mov	r8, r0, lsl r7
80090c48:	e1844008 	orr	r4, r4, r8	; build up the word
80090c4c:	e2855001 	add	r5, r5, #1	; 0x1 @ next byte
80090c50:	e1a00005 	mov	r0, r5
80090c54:	ebffffbc 	bl	0x80090b4c	; get half word from eeprom, only byte valid

80090c58:	e2056003 	and	r6, r5, #3	; 0x3
80090c5c:	e0070996 	mul	r7, r6, r9
80090c60:	e1a08710 	mov	r8, r0, lsl r7
80090c64:	e1844008 	orr	r4, r4, r8
80090c68:	e2560003 	subs	r0, r6, #3	; 0x3
80090c6c:	e2855001 	add	r5, r5, #1	; 0x1
80090c70:	1afffff6 	bne	0x80090c50
80090c74:	e1a00004 	mov	r0, r4
80090c78:	e8bd83fc 	ldmia	sp!, {r2, r3, r4, r5, r6, r7, r8, r9, pc}

80090c7c:	80090cd4 
80090c80:	53555243	@'CRUS' 
80090c84:	43525553 	@'SURC'
80090c88:	43525553 	@'SURC'
80090c8c:	53555243 	@'CRUS'
80090c90:	80930000 
80090c94:	baddcafe 
80090c98:	00000200 
80090c9c:	808a0000 
80090ca0:	000001c7 
80090ca4:	000002c7 
80090ca8:	000000c7 
80090cac:	00000100 
80090cb0:	80840000 
80090cb4:	80014000 
80090cb8:	800148fc 
80090cbc:	80014000 
80090cc0:	80014000 
80090cc4:	00000800 
80090cc8:	00000080 
80090ccc:	00000001 
80090cd0:	00000000 
80090cd4:	00000000 
80090cd8:	00000000 
80090cdc:	00000000 
80090ce0:	00000000 
80090ce4:	00000000 
80090ce8:	00000000 
80090cec:	00000000 
80090cf0:	00000000 
80090cf4:	00000000 
80090cf8:	00000000 
80090cfc:	00000000 
80090d00:	00000000 

	...

80091fa4:	00000000 
80091fa8:	00000000 
80091fac:	00000000 
80091fb0:	00000000 
80091fb4:	00000000 
80091fb8:	00000000 
80091fbc:	00000000 
80091fc0:	00000000 
80091fc4:	00000000 
80091fc8:	00000000 
80091fcc:	00000000 
80091fd0:	00000000 
80091fd4:	00000000 
80091fd8:	00000000 
80091fdc:	00000000 
80091fe0:	00000000 
80091fe4:	00000000 
80091fe8:	00000000 
80091fec:	00000000 
80091ff0:	00000000 
80091ff4:	00000000 
80091ff8:	00000000 
80091ffc:	00000000 

