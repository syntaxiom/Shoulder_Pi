	.global	fbp
	.bss
	.align	2
	.type	fbp, %object
	.size	fbp, 4
fbp:
	.space	4
	.comm	vinfo,160,4
	.comm	finfo,68,4

	/* R0 = x, R1 = y, R2 = color */
	.text
	.align	2
	.global	put_pixel
put_pixel:
	MOV	R5, #4		// R5 = 4 (bytes per pixel)
	MUL	R0, R0, R5	// R0 = x * 4
	LDR	R5, LATCH+8	// R5 -> finfo
	LDR	R5, [R5, #44]	// R5 = fino+44 (dereferenced) ==> finfo.line_length
	MUL	R1, R1, R5	// R1 = y * finfo.line_length
	ADD	R1, R0, R1	// R1 = x * 4 + y * finfo.line_length = pix_offset
	LDR	R0, LATCH+20	// R0 -> fbp
	LDR	R0, [R0]	// R0 = fbp (dereferenced)
	ADD	R0, R0, R1	// R0 = fbp + pix_offset
	STR	R2, [R0]	// fbp + pix_offset = color
	MOV	PC, LR

	/* R0 = x, R1 = y, SP+12 = open(...) */
	.text
	.align	2
	.global	show_image
show_image:
	MOV	R2, #4		// R2 = 4
	MUL	R0, R0, R2	// x = x * 4
	LDR	R2, LATCH+8	// R2 -> finfo
	LDR	R2, [R2, #44]	// R2 = finfo+44 (dereferenced) ==> finfo.line_length
	STR	R2, [SP, #16]	// SP+16 = finfo.line_length
	MUL	R1, R1, R2	// y = y * finfo.line_length
	MOV	R2, #0		// R2 = 0
	STR	R0, [SP, #20]	// SP+20 = x * 4
	STR	R1, [SP, #24]	// SP+24 = y * finfo.line_length
	STR	R2, [SP, #28]	// SP+28 = offset
	STR	R2, [SP, #32]	// SP+32 = x_pos
	STR	R2, [SP, #36]	// SP+36 = y_pos
	NOP
	LDR	R0, [SP, #12]	// R0 = open(...)
	LDR	R1, =BUFFER	// R1 -> BUFFER
	MOV	R2, #4		// R2 = 4 (bytes to read)
	LDR	R3, [SP, #28]	// R3 = offset
	BL	pread		// Parameters: R0--R3
	LDR	R0, [SP, #20]	// R0 = x * 4
	LDR	R1, [SP, #24]	// R1 = y * finfo.line_length
	ADD	R1, R1, R0	// R1 = x * 4 + y * finfo.line_length = pix_offset
	LDR	R0, LATCH+20	// R0 -> fbp
	LDR	R0, [R0]	// R0 = fbp (dereferenced)
	ADD	R0, R0, R1	// R0 = fbp + pix_offset
	LDR	R1, =BUFFER	// R1 -> BUFFER
	LDR	R1, [R1]	// R1 = BUFFER (dereferenced) ==> color
	LDR	R2, =0xFF000000	// R2 = full_alpha
	CMP	R1, R2		// color ? R2
	STRGE	R1, [R0]	// If (color >= full_alpha), Then (fbp + pix_offset = color)
	NOP
	LDR	R0, [SP, #36]	// R0 = y_pos
	LDR	R1, IMAGES+8	// R1 = Height
	CMP	R0, R1		// y_pos ? Height
	ADDLT	R0, R0, #1	// R0 = y_pos + 1
	MOVGE	R0, #0		// R0 = 0
	STR	R0, [SP, #36]	// SP+36 = y_pos (incremented or reset)
	NOP
	LDR	R0, [SP, #32]	// R0 = x_pos
	LDR	R1, IMAGES+4	// R1 = Width
	CMP	R0, R1		// x_pos ? Height
	ADDLT	R0, R0, #1	// R0 = x_pos + 1
	MOVGE	R0, #0		// R0 = 0
	STR	R0, [SP, #32]	// SP+32 = x_pos (incremented or reset)
	NOP
	LDR	R0, [SP, #36]	// R0 = y_pos
	LDR	R1, [SP, #32]	// R1 = x_pos
	ORR	R0, R0, R1	// R0 = y_pos OR x_pos
	CMP	R0, #0		// y_pos OR x_pos ? 0
	BEQ	main2
	BAL	main2
	
	.text
	.align	2
	.global	main
main:
	LDR	R0, LATCH	// R0 -> LATCH -> "/dev/fb0\000"
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	STR	R0, [SP]	// SP = open(...)
	LDR	R1, LATCH+12	// R1 = 17920 (Opcode for FBIOGET_VSCREENINFO)
	LDR	R2, LATCH+4	// R2 -> LATCH+4 -> vinfo (Changed)
	BL	ioctl		// Parameters: R0--R2
	LDR	R0, [SP]     	// R0 -> SP = open(...);
	LDR	R1, LATCH+16	// R1 = 17922 (Opcode for FBIOGET_FSCREENINFO)
	LDR	R2, LATCH+8	// R2 -> LATCH+8 -> finfo
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
	STR	R2, [SP, #8]	// SP+8 = screensize
	MOV	R0, #0		// R0 = 0
	LDR	R1, [SP, #8]	// SP+8 = screensize
	MOV	R2, #3		// R2 = 3 (Opcode for PROT_READ | PROT_WRITE)
	MOV	R3, #1		// R3 = 1 (Opcode for MAP_SHARED)
	STR	R0, [SP, #4]	// SP+4 = 0
	BL	mmap		// Parameters: R0--R3, SP--SP+4
	LDR	R1, LATCH+20	// R1 -> fbp
	STR	R0, [R1]	// fbp = mmap(...)
	NOP
	LDR	R0, IMAGES	// R0 -> IMAGES -> TITLE
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	STR	R0, [SP, #12]	// SP+12 = open(...)
	MOV	R0, #800	// x
	MOV	R1, #800	// y
	BL	show_image	// Parameters: R0--R1, SP+12
	NOP

main2:	
	LDR	R0, LATCH+20	// R0 -> LATCH+20 = fbp
	LDR	R0, [R0]	// R0 = fbp (dereferenced)
	LDR	R1, [SP, #8]	// SP+8 = screensize
	BL	munmap		// Parameters: R0--R1
	LDR	R0, [SP]	// R0 -> SP = open(...)
	BL	close		// Parameters: R0
	NOP
	LDR	R0, [SP, #12]	// R0 -> SP+12 = open(...)
	BL	close		// Parameters: R0
	NOP
	MOVAL	R0, #0		// R0 = 0 (return code)
	MOVAL	R7, #1		// R7 = 1 (exit syscall)
	SWI	0

	.align	2
LATCH:
	.word	FRAMEBUFFER
	.word	vinfo
	.word	finfo
	.word	17920
	.word	17922
	.word	fbp
IMAGES:
	.word	TITLE
	.word	250
	.word	250

	.data
LENGTH:
	.word	0
BUFFER:
	.skip	4

	.section	.rodata
	.align	2
FRAMEBUFFER:
	.ascii	"/dev/fb0\000"
TITLE:
	.ascii	"/home/pi/Desktop/image.bin\000"
