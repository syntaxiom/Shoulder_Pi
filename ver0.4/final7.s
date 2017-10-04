	.global	fbp
	.bss
	.align	2
	.type	fbp, %object
	.size	fbp, 4
fbp:
	.space	4
	.comm	vinfo,160,4
	.comm	finfo,68,4

	/* R0 = x, R1 = y, R2 = r, R3 = g, R4 = b */
	.text
	.align	2
	.global	put_pixel
put_pixel:
	MOV	R5, #3		// R5 = 3 (bytes per pixel)
	MUL	R0, R0, R5	// R0 = x * 3
	LDR	R5, LATCH+8	// R5 -> finfo
	LDR	R5, [R5, #44]	// R5 = fino+44 (dereferenced) ==> finfo.line_length
	MUL	R1, R1, R5	// R1 = y * finfo.line_length
	ADD	R1, R0, R1	// R1 = x * 3 + y * finfo.line_length = pix_offset
	STR	R1, [FP, #-8]	// FP-8 = pix_offset
	LDR	R0, LATCH+20	// R0 -> fbp
	LDR	R0, [R0]	// R0 = fbp (dereferenced)
	ADD	R0, R0, R1	// R0 = fbp + pix_offset
	ADD	R0, R0, #2	// R0 = fbp + pix_offset + 2
	UXTB	R2, R2		// Extend R2 byte to 32-bit unsigned number
	STRB	R2, [R0]	// R0 = r (red byte)
	SUB	R0, R0, #1	// R0 = fbp + pix_offset + 1
	UXTB	R3, R3		// Extend R3 byte to 32-bit unsigned number
	STRB	R3, [R0]	// R0 = g (green byte)
	SUB	R0, R0, #1	// R0 = fbp + pix_offset + 0
	UXTB	R4, R4		// Extend R4 byte to 32-bit unsigned number
	STRB	R4, [R0]	// R0 = b (blue byte)
	MOV	PC, LR
	
	.text
	.align	2
	.global	put_pixel_RGB24
put_pixel_RGB24:
	@ args = 4, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!	// fp = blue?
	add	fp, sp, #0
	sub	sp, sp, #28
	str	r0, [fp, #-16]	// fp-16 = x
	str	r1, [fp, #-20]	// fp-20 = y
	str	r2, [fp, #-24]	// fp-24 = b
	str	r3, [fp, #-28]	// fp-28 = g
	ldr	r2, [fp, #-16]	// r2 = x
	mov	r3, r2		// r3 = x
	lsl	r3, r3, #1	// r3 *= 2
	add	r3, r3, r2	// r3 += x
	mov	r1, r3		// r1 = x * 3
	ldr	r3, LATCH+8	// r3 = finfo (CHANGED)
	ldr	r3, [r3, #44]	// r3 = finfo.line_length
	ldr	r2, [fp, #-20]	// r2 = y
	mul	r3, r2, r3	// r3 = y * finfo.line_length
	add	r3, r1, r3	// r3 = x * 3 + y * finfo.line_length = pix_offset
	str	r3, [fp, #-8]	// fp-8 = pix_offset
	ldr	r3, LATCH+20	// r3 = fbp (CHANGED)
	ldr	r2, [r3]	// r2 = fbp (dereferenced)
	ldr	r3, [fp, #-8]	// r3 = pix_offset
	add	r3, r2, r3	// r3 = fbp + pix_offset
	ldr	r2, [fp, #4]	// r2 = b
	uxtb	r2, r2		// extend r2 to 32-bit unsigned integer
	strb	r2, [r3]	// r3 = b
	ldr	r3, LATCH+20	// r3 = fbp
	ldr	r2, [r3]	// r2 = fbp (dereferenced)
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	add	r3, r2, r3
	ldr	r2, [fp, #-28]
	uxtb	r2, r2
	strb	r2, [r3]
	ldr	r3, LATCH+20
	ldr	r2, [r3]
	ldr	r3, [fp, #-8]
	add	r3, r3, #2
	add	r3, r2, r3
	ldr	r2, [fp, #-24]
	uxtb	r2, r2
	strb	r2, [r3]
	nop
	add	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
	
	.text
	.align	2
	.global	main
main:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #24
	LDR	R0, LATCH	// R0 -> .L6 -> "/dev/fb0\000"
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	STR	R0, [SP]	// SP = open(...)
	LDR	R1, LATCH+12	// R1 = 17920 (Opcode for FBIOGET_VSCREENINFO)
	LDR	R2, LATCH+4	// R2 -> .L6+4 -> vinfo (Changed)
	BL	ioctl		// Parameters: R0--R2
	LDR	R0, [SP]     	// R0 -> FP-8 = return of open(...);
	LDR	R1, LATCH+16	// R1 = 17922 (Opcode for FBIOGET_FSCREENINFO)
	LDR	R2, LATCH+8	// R2 -> .L6+8 -> finfo
	BL	ioctl		// Parameters: R0--R2
	LDR	R0, LATCH+4	// R0 -> LATCH+4 -> vinfo
	LDR	R0, [R0]	// R0 = vinfo+0 (dereferenced) ==> vinfo.xres
	LDR	R1, LATCH+4	// R1 -> LATCH+4 -> vinfo
	LDR	R1, [R1, #4]	// R1 = vinfo+4 (dereferenced) ==> vinfo.yres
	LDR	R2, LATCH+4	// R2 -> LATCH+4 -> vinfo
	LDR	R2, [R2, #24]	// R2 = vinfo+24 (dereferenced) ==> vinfo.bits_per_pixel
	MUL	R1, R0, R1	// R1 = vinfo.xres * vinfo.yres
	MUL	R2, R1, R2	// R2 = R1 * vinfo.bits_per_pixel
	LSR	R2, R2, #3	// R2 /= 8	
	STR	R2, [FP, #-4]	// FP-12 = screensize
	MOV	R0, #0		// R0 = 0
	LDR	R1, [FP, #-4]	// R1 -> FP-12 = screensize
	MOV	R2, #3		// R2 = 3 (Opcode for PROT_READ | PROT_WRITE)
	MOV	R3, #1		// R3 = 1 (Opcode for MAP_SHARED)
	STR	R0, [SP, #4]	// SP+4 = 0
	BL	mmap		// Parameters: R0--R3, SP--SP+4
	LDR	R1, LATCH+20	// R1 -> fbp
	STR	R0, [R1]	// fbp = mmap(...)
	mov	r3, #255
	str	r3, [sp]
	mov	r3, #255
	mov	r2, #255
	mov	r1, #0
	mov	r0, #0
	bl	put_pixel_RGB24
	LDR	R0, LATCH+20	// R0 -> LATCH+20 = fbp
	LDR	R0, [R0]	// R0 = fbp (dereferenced)
	LDR	R1, [FP, #-4]	// R1 -> FP-4 = screensize
	BL	munmap		// Parameters: R0--R1
	LDR	R0, [SP]	// R0 -> SP = open(...)
	BL	close		// Parameters: R0
	MOV	R0, #0		// R0 = 0 (return code)
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}

	.align	2
LATCH:
	.word	FILE
	.word	vinfo
	.word	finfo
	.word	17920
	.word	17922
	.word	fbp

	.section	.rodata
	.align	2
FILE:
	.ascii	"/dev/fb0\000"
