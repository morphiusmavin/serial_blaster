
boot2.bin:     file format binary

Disassembly of section .data:

00300000 <.data>:
  300000:	e28fda01 	add	sp, pc, #4096	; 0x1000
  300004:	e3a0a102 	mov	sl, #-2147483648	; 0x80000000
  300008:	eb00000d 	bl	0x300044
  30000c:	e3a02502 	mov	r2, #8388608	; 0x800000
  300010:	e2522001 	subs	r2, r2, #1	; 0x1
  300014:	1afffffd 	bne	0x300010
  300018:	e28f0e11 	add	r0, pc, #272	; 0x110
  30001c:	eb000013 	bl	0x300070
  300020:	eaffffff 	b	0x300024
  300024:	e28a0721 	add	r0, sl, #8650752	; 0x840000
  300028:	e3a01002 	mov	r1, #2	; 0x2
  30002c:	e3a02702 	mov	r2, #524288	; 0x80000
  300030:	e2522001 	subs	r2, r2, #1	; 0x1
  300034:	1afffffd 	bne	0x300030
  300038:	e5801020 	str	r1, [r0, #32]
  30003c:	e2211003 	eor	r1, r1, #3	; 0x3
  300040:	eafffff9 	b	0x30002c
  300044:	e92d4003 	stmdb	sp!, {r0, r1, lr}
  300048:	e28a0723 	add	r0, sl, #9175040	; 0x8c0000
  30004c:	e5901018 	ldr	r1, [r0, #24]
  300050:	e3110008 	tst	r1, #8	; 0x8
  300054:	1afffffc 	bne	0x30004c
  300058:	e8bd8003 	ldmia	sp!, {r0, r1, pc}
  30005c:	e92d4007 	stmdb	sp!, {r0, r1, r2, lr}
  300060:	ebfffff7 	bl	0x300044
  300064:	e28a2723 	add	r2, sl, #9175040	; 0x8c0000
  300068:	e5c21000 	strb	r1, [r2]
  30006c:	e8bd8007 	ldmia	sp!, {r0, r1, r2, pc}
  300070:	e92d4007 	stmdb	sp!, {r0, r1, r2, lr}
  300074:	e4f01001 	ldrbt	r1, [r0], #1
  300078:	e3510000 	cmp	r1, #0	; 0x0
  30007c:	0a000001 	beq	0x300088
  300080:	ebfffff5 	bl	0x30005c
  300084:	eafffffa 	b	0x300074
  300088:	e8bd8007 	ldmia	sp!, {r0, r1, r2, pc}
  30008c:	e92d4001 	stmdb	sp!, {r0, lr}
  300090:	e1a01c61 	mov	r1, r1, ror #24
  300094:	ebfffff0 	bl	0x30005c
  300098:	e1a01c61 	mov	r1, r1, ror #24
  30009c:	ebffffee 	bl	0x30005c
  3000a0:	e1a01c61 	mov	r1, r1, ror #24
  3000a4:	ebffffec 	bl	0x30005c
  3000a8:	e1a01c61 	mov	r1, r1, ror #24
  3000ac:	ebffffea 	bl	0x30005c
  3000b0:	e8bd8001 	ldmia	sp!, {r0, pc}
  3000b4:	e92d4006 	stmdb	sp!, {r1, r2, lr}
  3000b8:	e28a2723 	add	r2, sl, #9175040	; 0x8c0000
  3000bc:	e5921018 	ldr	r1, [r2, #24]
  3000c0:	e3110010 	tst	r1, #16	; 0x10
  3000c4:	1afffffc 	bne	0x3000bc
  3000c8:	e5d20000 	ldrb	r0, [r2]
  3000cc:	e8bd8006 	ldmia	sp!, {r1, r2, pc}
  3000d0:	e92d4002 	stmdb	sp!, {r1, lr}
  3000d4:	ebfffff6 	bl	0x3000b4
  3000d8:	e1a01000 	mov	r1, r0
  3000dc:	ebfffff4 	bl	0x3000b4
  3000e0:	e1811400 	orr	r1, r1, r0, lsl #8
  3000e4:	ebfffff2 	bl	0x3000b4
  3000e8:	e1811800 	orr	r1, r1, r0, lsl #16
  3000ec:	ebfffff0 	bl	0x3000b4
  3000f0:	e1811c00 	orr	r1, r1, r0, lsl #24
  3000f4:	e1a00001 	mov	r0, r1
  3000f8:	e8bd8002 	ldmia	sp!, {r1, pc}
  3000fc:	e92d400f 	stmdb	sp!, {r0, r1, r2, r3, lr}
  300100:	e3a01002 	mov	r1, #2	; 0x2
  300104:	ebffffd4 	bl	0x30005c
  300108:	e1a01002 	mov	r1, r2
  30010c:	ebffffde 	bl	0x30008c
  300110:	e1a01003 	mov	r1, r3
  300114:	ebffffdc 	bl	0x30008c
  300118:	e4921004 	ldr	r1, [r2], #4
  30011c:	ebffffda 	bl	0x30008c
  300120:	e1520003 	cmp	r2, r3
  300124:	dafffffb 	ble	0x300118
  300128:	e8bd800f 	ldmia	sp!, {r0, r1, r2, r3, pc}
  30012c:	eafffffe 	b	0x30012c
  300130:	0a0d0a0d 	beq	0x64296c
  300134:	4f203e3e 	swimi	0x00203e3e
  300138:	204e4550 	subcs	r4, lr, r0, asr r5
  30013c:	372d5354 	undefined
  300140:	20585832 	subcss	r5, r8, r2, lsr r8
  300144:	544f4f42 	strplb	r4, [pc], #3906	; 0x30014c
  300148:	59532032 	ldmpldb	r3, {r1, r4, r5, sp}^
  30014c:	4d455453 	cfstrdmi	mvd5, [r5, #-332]
  300150:	6552202c 	ldrvsb	r2, [r2, #-44]
  300154:	2e312076 	mrccs	0, 1, r2, cr1, cr6, {3}
  300158:	0a0d3030 	beq	0x64c220
  30015c:	00000000 	andeq	r0, r0, r0
