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

	/* R0 -> BUFFER, R1 = offset, R2 = fbp, R3 = screensize * 2 */
	.global put_screen
put_screen:
	LDRD	R4, [R0, R1]	// R4 = BUFFER+R1 (dereferenced) = color
	STRD	R4, [R2]	// fbp + offset = color
	ADD	R2, R2, #8	// R2 = fbp + offset
	ADD	R1, R1, #8	// R1 = offset + 4 (incremented)
	CMP	R1, R3		// offset ? screensize
	MOVEQ	PC, LR		// (Go back)
	BAL	put_screen	// Parameters: R0--R3
	
	.align	2
	.global	main
main:
	LDR	R0, LATCH	// R0 -> LATCH -> "/dev/fb0\000"
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	STR	R0, [SP]	// SP = open("/dev/fb0\000")
	LDR	R1, LATCH+12	// R1 = 17920 (Opcode for FBIOGET_VSCREENINFO)
	LDR	R2, LATCH+4	// R2 -> vinfo
	BL	ioctl		// Parameters: R0--R2
	LDR	R0, [SP]	// R0 = open("/dev/fb0\000")
	LDR	R1, LATCH+16	// R1 = 17922 (Opcode for FBIOGET_FSCREENINFO)
	LDR	R2, LATCH+8	// R2 -> finfo
	BL	ioctl		// Parameters: R0--R2
	MOV	R0, #0		// R0 = 0
	LDR	R1, LATCH+24	// R1 = screensize
	MOV	R2, #3		// R2 = 3 (Opcode for PROT_READ | PROT_WRITE)
	MOV	R3, #1		// R3 = 1 (Opcode for MAP_SHARED)
	STR	R0, [SP, #4]	// SP+4 = 0
	BL	mmap		// Parameters: R0--R3, SP--SP+4
	LDR	R1, LATCH+20	// R1 -> fbp
	STR	R0, [R1]	// fbp = mmap(...)

main1:
	LDR	R0, SCREEN	// R0 -> TITLE
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	STR	R0, [SP, #8]	// SP+8 = open("/home/pi/Desktop/screen.bin\000")
	LDR	R1, =BUFFER	// R1 -> BUFFER
	LDR	R2, LATCH+24	// R2 = screensize (bytes to read)
	BL	read		// Parameters: R0--R2
	LDR	R0, =BUFFER	// R0 -> BUFFER
	MOV	R1, #0		// R1 = 0 (offset)
	LDR	R2, LATCH+20	// R2 -> fbp
	LDR	R2, [R2]	// R2 = fbp (dereferenced)
	LDR	R3, LATCH+24	// R3 = screensize
	MOV	R5, #0		// TESTING PURPOSES
	BL	put_screen	// Parameters: R0--R3

main2:
	LDR	R0, LATCH+20	// R0 -> fbp
	LDR	R0, [R0]	// R0 = fbp (dereferenced)
	LDR	R1, LATCH+24	// R1 = screensize
	BL	munmap		// Parameters: R0--R1
	LDR	R0, [SP]	// R0 = open("/dev/fb0\000")
	BL	close		// Parameters: R0
	LDR	R0, [SP, #8]	// R0 = open("/home/pi/Desktop/screen.bin\000")
	BL	close		// Parameters: R0

exit:
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
	.word	0x7E9000	// Hard-coded for now
SCREEN:
	.word	TITLE

	.data
BUFFER:
	.skip	0x7E9000

	.section	.rodata
	.align	2
FRAMEBUFFER:
	.ascii	"/dev/fb0\000"
TITLE:
	.ascii	"/home/pi/Desktop/screen.bin\000"
