	.global _start
_start:
	LDR	R0, _file	// R0 = framebuffer file
	STR	R0, [SP]	// SP = framebuffer file
	MOV	R1, #2
	BL	open		// syscall 5
	LDR	R2, _latch+8	// R2 = vinfo
	MOV	R1, #17920	// R1 = opcode for FBIOGET_VSCREENINFO
	LDR	R0, [SP]
	BL	ioctl		// syscall 54
	MOV	R1, #17921	// R1 = opcode for FBIOPUT_VSCREENINFO
	LDR	R0, [SP]
	BL	ioctl		// syscall 54
	LDR	R2, _latch+12	// R2 = finfo
	MOV	R1, #17922	// R1 = opcode for FBIOGET_FSCREENINFO
	LDR	R0, [SP]
	BL	ioctl		// syscall 54
	MOV	R1, #0
	STR	R1, [SP, #4]	// SP+4 = 0
	MOV	R3, #1		// R3 = Opcode for MAP_SHARED
	LDR	R2, _latch+8	// R2 = vinfo
	LDR	R2, [R2]	// R2 = vinfo.xres (not sure if redundant)
	LDR	R1, _latch+8	// R1 = vinfo
	LDR	R1, [R1, #4]	// R1 = vinfo.yres
	MUL	R1, R1, R2	// R1 = vinfo.xres * vinfo.yres = screensize
	MOV	R2, #3		// R2 = Opcode for PROT_READ | PROT_WRITE
	MOV	R0, #0		// R0 = 0
	BL	mmap		// syscall 90; Params: R0--R3, SP, SP+4
	MOV	R0, #0		// R0 = x
	MOV	R1, #0		// R1 = y
	MOV	R2, #255	// R2 = b
	MOV	R3, #0		// R3 = g
	MOV	R4, #255	// R4 = r
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
	.align 2
	.global _put_pixel
_put_pixel:
	UXTB	R2, R2		// Extend b to unsigned 32-bit number (del?)
	UXTB	R3, R3		// Extend g to unsigned 32-bit number (del?)
	UXTB	R4, R4		// Extend r to unsigned 32-bit number (del?)
	MOV	R5, #3		// 3 bytes per pixel
	MUL	R5, R0, R5	// R5 = x * 3 bytes per pixel
	LDR	R6, _latch	// R6 = finfo
	LDR	R6, [R6, #44]	// R6 = finfo.line_length
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
	.align 2
	.global _latch
_latch:
	.word finfo
	.word framebuffer
	.word vinfo
	.word finfo

	.global _file
_file:
	.ascii "/dev/feb0\000"
