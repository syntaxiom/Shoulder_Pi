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
	.global main
main:
	PUSH	{LR}
	LDR	R0, =file	// R0 = "/dev/fb0"
	STR	R0, [SP, #4]	// SP+4 = "/dev/fb0"
	MOV	R1, #2		// R1 = 2 (Opcode for read+write)
	BL	open		// Parameters: R0--R1
	LDR	R0, [SP, #4]	// R0 = "/dev/fb0"
	LDR	R1, op		// R1 = 17920 (Opcode for FBIOGET_VSCREENINFO)
	LDR	R2, latch	// R2 = vinfo
	BL	ioctl		// Parameters: R0--R2
	LDR	R0, [SP, #4]	// R0 = "/dev/fb0"
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
	LDR	R4, =file	// R4 = "/dev/fb0"
	STR	R4, [SP, #0]	// SP+0 = "/dev/fb0"
//	STR	R0, [SP, #4]	// SP+4 = 0 (Parameter 6, mmap)
//	BL	mmap		// Parameters: R0--R3, SP+0--SP+4
	POP	{PC}

	.global op
op:
	.word	17920
	.word	17922

	.global latch
latch:
	.word	vinfo
	.word	finfo

	.data
	.global file
file:
	.asciz "/dev/fb0"

