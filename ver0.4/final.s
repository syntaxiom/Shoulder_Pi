	.global _start
_start:
	MOV	R0, #0
	MOV	R1, #0
	MOV	R2, #255
	MOV	R3, #0
	MOV	R4, #255
	BL	_put_pixel
	MOV	R0, #5
	BL	sleep
	BAL	_exit

/*
	r0 = x
	r1 = y
	r2 = b
	r3 = g
	r4 = r
	------
	r5--r7
	*/

	.global _put_pixel
_put_pixel:
	UXTB	R2, R2		// Extend b to unsigned 32-bit number
	UXTB	R3, R3		// Extend g to unsigned 32-bit number
	UXTB	R4, R4		// Extend r to unsigned 32-bit number
	MOV	R5, #3		// 3 bytes per pixel
	MUL	R5, R0, R5	// R5 = x * 3 bytes per pixel
	LDR	R6, _latch	// R6 = finfo
	LDR	R6, [R6, #44]	// R6 = finfo.line_length (redundant?)
	MUL	R6, R1, R6	// R6 = y * finfo.line_length
	ADD	R5, R5, R6	// R5 = x * 3 + y * finfo.line_length = pix_offset
	LDR	R6, _latch+4	// R6 = framebuffer
	MOV	R7, #0		// R7 = 0 Offset
	ADD	R7, R5, R7	// pix_offset += 0
	ADD	R6, R5, R6	// framebuffer += pix_offset
	STRB	R2, [R6]	// framebuffer + 0 = r
	MOV	R7, #1		// R7 = 1 Offset
	ADD	R7, R5, R7	// pix_offset += 1
	ADD	R6, R5, R6	// framebuffer += pix_offset + 1
	STRB	R3, [R6]	// framebuffer + 1 = g
	MOV	R7, #2		// R7 = 2 Offset
	ADD	R7, R5, R7	// pix_offset += 2
	ADD 	R6, R5, R6	// framebuffer += pix_offset + 2
	STRB	R4, [R6]	// framebuffer + 2 = r
	MOV	PC, LR
	
	.global _exit
_exit:
	MOVAL	R7, #1
	SWI	0

	.global _framebuffer
	.bss
	.align 2
	.type _framebuffer, %object
	.size _framebuffer, 4
_framebuffer:
	.space 4
	.comm vinfo, 160, 4
	.comm finfo, 68, 4

	.data
	.global _latch
_latch:
	.word finfo
	.word framebuffer
