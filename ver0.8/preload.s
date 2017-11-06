	.global	fbp
	.bss
	.align	2
	.type	fbp, %object
	.size	fbp, 4
fbp:
	.space	4
	.comm	vinfo,160,4
	.comm	finfo,68,4

	.text

	.global	main
main:
	LDR	R0, LATCH	// R0 -> LATCH -> "/dev/fb0\000"
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	STR	R0, [SP]	// SP = open(...)
	LDR	R1, LATCH+12	// R1 = 17920 (Opcode for FBIOGET_VSCREENINFO)
	LDR	R2, LATCH+4	// R2 -> vinfo
	BL	ioctl		// Parameters: R0--R2
	LDR	R0, [SP]     	// R0 -> SP = open(...);
	LDR	R1, LATCH+16	// R1 = 17922 (Opcode for FBIOGET_FSCREENINFO)
	LDR	R2, LATCH+8	// R2 -> finfo
	BL	ioctl		// Parameters: R0--R2
	LDR	R0, LATCH+8	// R0 -> finfo
	LDR	R1, [R0, #44]	// R1 = finfo.line_length
	STR	R1, [SP, #4]	// SP+4 = finfo.line_length
	LDR	R0, IMAGE1	// R0 -> FILE1
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	STR	R0, [SP, #8]	// SP+8 = open(...)
	
main1:
	NOP
	
main2:
	NOP
	
quit:
	MOVAL	R0, #0
	MOVAL	R7, #1
	SWI	0
	
LATCH:
	.word	FRAMEBUFFER
	.word	vinfo
	.word	finfo
	.word	17920
	.word	17922
	.word	fbp
FRAMEBUFFER:
	.ascii	"/dev/fb0\000"
IMAGE1:
	.word	FILE1
	.word	250
	.word	250
FILE1:	
	.asciz	"/home/pi/Desktop/image.bin\000"

	.data
BUFFER:
	.skip	8
