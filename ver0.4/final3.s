	.global	fbp
	.bss
	.align	2
	.type	fbp, %object
	.size	fbp, 4
fbp:
	.space	4
	.comm	vinfo, 160, 4
	.comm	finfo, 68, 4
	
	.text
	.align	2
	.global main
main:
	LDR	R0, file	// R0 = "/dev/fb0\000"
	MOV	R1, #2		// R1 = 2 (Opcode for read+write)
	BL	open		// Parameters: R0--R1
	STR	R0, [SP, #0]	// SP+0 = open("/dev/fb0", O_RDWR);
	LDR	R0, [SP, #0]	// R0 = open(...);
	LDR	R1, op		// R1 = 17920 (Opcode for FBIOGET_VSCREENINFO)
	LDR	R2, latch	// R2 = vinfo
	BL	ioctl		// Parameters: R0--R2
	LDR	R0, [SP, #0]	// R0 = open(...);
	LDR	R1, op+4	// R1 = 17922 (Opcode for FBIOGET_FSCREENINFO)
	LDR	R2, latch+4	// R2 = finfo
	BL	ioctl		// Parameters: R0--R2
	MOV	R0, #0		// R0 = 0 (Parameter 1, mmap)
	LDR	R1, latch	// R1 = vinfo
	LDR	R1, [R1]	// R1 = vinfo.xres
	LDR	R2, latch	// R2 = vinfo
	LDR	R2, [R2, #4]	// R2 = vinfo.yres
	MUL	R1, R1, R2	// R1 = vinfo.xres * vinfo.yres
	STR	R1, [SP, #8]	// SP+8 = screensize
	MOV	R2, #3		// R2 = 3 (Opcode for PROT_READ | PROT_WRITE)
	MOV	R3, #1		// R3 = 1 (Opcode for MAP_SHARED)
	STR	R0, [SP, #4]	// SP+4 = 0 (Parameter 6, mmap)
	BL	mmap		// Parameters: R0--R3, SP+0--SP+4
	LDR	R1, latch+8	// R1 = fbp
	STR	R0, [R1]	// fbp = mmap return
	MOV	R0, #0		// x = 0
	MOV	R1, #0		// y = 0
	MOV	R2, #255	// b = 255
	MOV	R3, #255	// g = 255
	MOV	R4, #255	// r = 255
	BL	put_pixel	// Parameters: R0--R4
	MOV	R0, #5		// R0 = 5
	BL	sleep		// Parameters: R0
	LDR	R0, latch+8	// R0 = fbp
	LDR	R1, [SP, #8]	// R1 = screensize
	BL	munmap		// Parameters: R0--R1
	LDR	R0, [SP, #0]	// R0 = open(...);
	BL	close		// Parameters: R0
	MOV	R0, #0		// R0 = 0 (return code)
	BAL	exit

/* put_pixel
Parameters:	R0 = x
		R1 = y
		R2 = b
		R3 = g
		R4 = r
	
Clobbers:	R5--R7 */

	.text
	.align 2
	.global	put_pixel
	.syntax unified
	.type	put_pixel, %function
put_pixel:
//	UXTB	R2, R2		// Extend R2 byte to unsigned 32-bit number
//	UXTB	R3, R3		// Extend R3 byte to unsigned 32-bit number
//	UXTB	R4, R4		// Extend R4 byte to unsigned 32-bit number
	MOV	R5, #3		// R5 = 3 (bytes per pixel)
	MUL	R0, R0, R5	// R0 = x * 3
	LDR	R5, latch+4	// R5 = finfo
	LDR	R5, [R5, #44]	// R5 = finfo.line_length
	MUL	R1, R1, R5	// R1 = y * finfo.line_length
	ADD	R5, R0, R1	// R5 = x * 3 + y * finfo.line_length = pix_offset
	LDR	R6, latch+8	// R6 = fbp
	ADD	R6, R6, R5	// R6 = fbp + pix_offset
	STRB	R2, [R7]	// R7 = b (blue, byte)
	MOV	R7, #0		// R7 = 0
	ADD	R7, R6, #1	// R7 = fbp + pix_offset + 1
	STRB	R3, [R7]	// R7 = g (green, byte)
	MOV	R7, #0		// R7 = 0
	ADD	R7, R6, #2	// R7 = fbp + pix_offset + 2
	STRB	R3, [R7]	// R7 = r (red, byte)
	MOV	PC, LR

	.global exit
exit:
	MOV	R7, #1
	SWI	0

	.global op
op:
	.word	17920
	.word	17922

	.global latch
latch:
	.word	vinfo
	.word	finfo
	.word	fbp
	
	.global file
file:
	.ascii "/dev/fb0\000"

