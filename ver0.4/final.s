	.text
	.global main
	.func main
main:
	PUSH	{LR}
	LDR	R0, =file	// R0 = "/dev/fb0"
	STR	R0, [SP]	// SP+0 = "/dev/fb0"
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	LDR	R1, =opcodes	// R1 = 17920 (Opcode for FPIOGET_VSCREENINFO)
	LDR	R2, =latch+8	// R2 = vinfo
	BL	ioctl		// Parameters: R0--R2
	MOV	R1, #8		// R1 = 8
	STR	R1, [R2, #24]	// vinfo.bits_per_pixel = 8
	LDR	R1, =opcodes+4	// R1 = 17921 (Opcode for FBIOPUT_VSCREENINFO)
	BL	ioctl		// Parameters: R0--R2
	LDR	R1, =opcodes+8	// R1 = 17922 (Opcode for FBIOGET_FSCREENINFO)
	LDR	R2, =latch+12	// R2 = finfo
	BL	ioctl		// Parameters: R0--R2
	POP	{PC}

/* Parameters:
	R0 = x
	R1 = y
	R2 = g
	R3 = b
	R4 = r
   Clobbers:
	R5--R7 */
	.global put_pixel
	.type	put_pixel, %function
put_pixel:
	MOV	R5, #3		// R5 = 3
	MUL	R0, R0, R5	// R0 = x * 3
	LDR	R5, =latch	// R5 = finfo
	LDR	R5, [R5, #44]	// R5 = finfo.line_length
	MUL	R1, R1, R5	// R1 = y * finfo.line_length
	ADD	R5, R0, R1	// R5 = x * 3 + y * finfo.line_length
	LDR	R6, =latch+4	// R6 = framebuffer
	ADD	R6, R6, R5	// R6 = framebuffer + pix_offset
	MOV	R5, #0		// R5 = 0
	MOV	R7, #0		// R7 = 0
	ADD	R7, R6, R5	// R7 = R6 + 0
	STRB	R2, [R7]	// R7 = g (green, byte)
	MOV	R5, #1		// R5 = 1
	MOV	R7, #0		// R7 = 0
	ADD	R7, R6, R5	// R7 = R6 + 1
	STRB	R3, [R7]	// R7 = b (blue, byte)
	MOV	R5, #2		// R5 = 2
	MOV	R7, #0		// R7 = 0
	ADD	R7, R6, R5	// R7 = R6 + 2
	STRB	R4, [R7]	// R7 = r (red, byte)
	MOV	PC, LR

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
	
	.global latch
	.align	2
latch:
	.word	finfo
	.word	framebuffer
	.word	vinfo
	.word	finfo

	.global opcodes
	.align	2
opcodes:
	.word	17920
	.word	17921
	.word	17922
