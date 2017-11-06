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

	/* R0 -> BUFFER, R1 = offset, R2 = screensize * 2, R3 = fbp */
	.global put_screen
put_screen:
	LDRD	R4, [R0, R1]	// R4 = BUFFER+offset (dereferenced) = color
	STRD	R4, [R3]	// fbp + offset = color
	ADD	R3, R3, #8	// R2 = fbp + offset
	ADD	R1, R1, #8	// R1 = offset + 8 (incremented)
	CMP	R1, R2		// offset ? screensize
	MOVEQ	PC, LR		// (Go back)
	BAL	put_screen	// Parameters: R0--R3

	/* R0 -> BUFFER, R1 = offset, R2 = screensize, R3 = color */
	.global	fill_color
fill_color:
	STR	R3, [R0, R1]	// BUFFER+offset = color
	ADD	R1, R1, #4	// R1 = offset + 4 (incremented)
	CMP	R1, R2		// offset ? screensize
	MOVEQ	PC, LR		// (Go back)
	BAL	fill_color	// Parameters: R0--R3
	
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
	LDR	R0, =BUFFER	// R0 -> BUFFER
	MOV	R1, #0		// R1 = 0 (offset)
	LDR	R2, LATCH+24	// R2 = screensize

screen_loop:
	LDR	R3, =COLOR	// R3 -> COLOR
	LDR	R3, [R3]	// R3 = COLOR (dereferenced)
	BL	fill_color	// Parameters: R0--R3
	LSL	R2, R2, #2	// R2 = screensize * 2
	LDR	R3, LATCH+24	// R3 -> fbp
	LDR	R3, [R3]	// R3 = fbp
	BL	put_screen	// Parameters: R0--R3
	LDR	R3, =COLOR	// R3 -> COLOR
	LDR	R4, [R3]	// R4 = COLOR (dereferenced)
	LDR	R5, LATCH+28	// R5 = Max color
	CMP	R4, R5		// COLOR ? Max color
	MOVGT	R4, #0		// R4 = 0
	ADDLE	R4, R4, #1	// R4 = COLOR + 1 (incremented)
	STR	R4, [R3]	// COLOR = R4
	LSR	R2, R2, #2	// R2 = screensize / 2
	BAL	screen_loop	// Loop

main2:
	LDR	R0, LATCH+20	// R0 -> fbp
	LDR	R0, [R0]	// R0 = fbp (dereferenced)
	LDR	R1, LATCH+24	// R1 = screensize
	BL	munmap		// Parameters: R0--R1
	LDR	R0, [SP]	// R0 = open("/dev/fb0\000")
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
	.word	0x500000	// Hard-coded for now
	.word	0xFFFFFF	// Max color
SCREEN:
	.word	TITLE

	.data
BUFFER:
	.skip	0x500000
COLOR:
	.word	0x000000

	.section	.rodata
	.align	2
FRAMEBUFFER:
	.ascii	"/dev/fb0\000"
TITLE:
	.ascii	"/home/pi/Desktop/screen.bin\000"
