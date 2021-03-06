// KEEP FRAMEBUFFER IN BSS
	
	.text
	.global main
	.func main
main:
	PUSH	{LR}
	LDR	R0, =file	// R0 = "/dev/fb0"
	STR	R0, [SP]	// SP+0 = "/dev/fb0"
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	MOVAL	R7, #5		// open (R0--R1)
	SVC	#0
	LDR	R0, [SP]	// R0 = "/dev/fb0"
	LDR	R1, opcodes	// R1 = 17920 (Opcode for FPIOGET_VSCREENINFO)
	LDR	R2, latch+8	// R2 = vinfo
	MOVAL	R7, #54		// ioctl (R0--R2)
	SVC	#0
	LDR	R0, [SP]	// R0 = "/dev/fb0"
	LDR	R1, opcodes+8	// R1 = 17922 (Opcode for FBIOGET_FSCREENINFO)
	LDR	R2, latch	// R2 = finfo
	MOVAL	R7, #54		// ioctl (R0--R2)
	SVC	#0
	MOV	R0, #0		// R0 = 0
	LDR	R1, latch+8	// R1 = vinfo
	LDR	R1, [R1]	// R1 = vinfo.xres
	LDR	R2, [R1, #4]	// R2 = vinfo.yres
	MUL	R1, R1, R2	// R1 = vinfo.xres * vinfo.yres
	STR	R1, [SP, #12]	// SP+12 = screensize
	MOV	R2, #3		// R2 = 3 (Opcode for PROT_READ | PROT_WRITE)
	MOV	R3, #1		// R3 = 1 (Opcode for MAP_SHARED)
	MOV	R4, #0		// R4 = 0
	STR	R4, [SP, #4]	// SP+4 = 0
	MOVAL	R7, #90		// mmap (R0--R3, SP--SP+4)
	SVC	#0
	LDR	R1, latch+4	// R1 = framebuffer
	STR	R0, [R1]	// framebuffer = mmap return
	MOV	R0, #0		// x = 0
	MOV	R1, #0		// y = 0
	MOV	R2, #255	// b = 255
	MOV	R3, #255	// g = 255
	MOV	R4, #255	// b = 255
	BL	put_pixel	// Parameters: R0--R4
	LDR	R0, latch+4	// R0 = framebuffer
	LDR	R1, [SP, #12]	// R1 = screensize
	MOVAL	R7, #91		// munmap (R0--R1)
	SVC	#0
	LDR	R0, [SP]	// R0 = "/dev/fb0"
	MOVAL	R7, #6		// close (R0)
	SVC	#0
	MOV	R0, #0		// R0 = 0 (return code)
	POP	{PC}

/*  Parameters:
	R0 = x
	R1 = y
	R2 = b
	R3 = g
	R4 = r
   Clobbers:
	R5--R7 */
	.global put_pixel
	.type	put_pixel, %function
put_pixel:
	MOV	R5, #3		// R5 = 3
	MUL	R0, R0, R5	// R0 = x * 3
	LDR	R5, latch	// R5 = finfo
	LDR	R5, [R5, #44]	// R5 = finfo.line_length
	MUL	R1, R1, R5	// R1 = y * finfo.line_length
	ADD	R5, R0, R1	// R5 = x * 3 + y * finfo.line_length
	LDR	R6, latch+4	// R6 = framebuffer
	ADD	R6, R6, R5	// R6 = framebuffer + pix_offset
	MOV	R5, #0		// R5 = 0
	MOV	R7, #0		// R7 = 0
	ADD	R7, R6, R5	// R7 = R6 + 0
	STRB	R2, [R7]	// R7 = b (blue, byte)
	MOV	R5, #1		// R5 = 1
	MOV	R7, #0		// R7 = 0
	ADD	R7, R6, R5	// R7 = R6 + 1
	STRB	R3, [R7]	// R7 = g (green, byte)
	MOV	R5, #2		// R5 = 2
	MOV	R7, #0		// R7 = 0
	ADD	R7, R6, R5	// R7 = R6 + 2
	STRB	R4, [R7]	// R7 = r (red, byte)
	MOV	PC, LR

	.global latch
	.align	2
latch:
	.word	finfo
	.word	framebuffer
	.word	vinfo

	.global opcodes
	.align	2
opcodes:
	.word	17920
	.word	17921
	.word	17922

	.data
	.global file
file:
	.asciz	"/dev/fb0"

	.global framebuffer
	.align	2
	.type	framebuffer, %object
	.size	framebuffer, 4
framebuffer:
	.space	4
	.comm	vinfo, 160, 4
	.comm	finfo, 68, 4
	
