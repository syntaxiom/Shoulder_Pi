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

	/* R0 -> BUFFER, R1 = fbp (dereferenced), R2 = screensize */
	.global put_screen
put_screen:
	LDRD	R4, [R0, #-8]!
	STRD	R4, [R1, #-8]!
	SUBS	R2, #8
	BNE	put_screen
	MOV	PC, LR
	
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
	LDR	R1, LATCH+24	// R1 = screen size
	MOV	R2, #3		// R2 = 3 (Opcode for PROT_READ | PROT_WRITE)
	MOV	R3, #1		// R3 = 1 (Opcode for MAP_SHARED)
	STR	R0, [SP, #4]	// SP+4 = 0
	BL	mmap		// Parameters: R0--R3, SP--SP+4
	LDR	R1, LATCH+20	// R1 -> fbp
	STR	R0, [R1]	// fbp = mmap(...)
	LDR	R1, [R1]	// R1 = fbp (dereferenced)
	STR	R1, [SP, #12]	// SP+12 = fbp
	LDR	R0, IMAGE	// R0 -> IMAGEFILE
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	STR	R0, [SP, #8]	// SP+8 = open("/home/pi/Desktop/image1080.bin\000")
	LDR	R3, =0x2BC	// R3 = x_offset
	LSL	R3, R3, #2	// R3 = x_offset * 4 (* bytes per pixel)
	LDR	R4, =0x2EE	// R4 = y_offset
	LDR	R5, LATCH+28	// R5 = line length
	MUL	R4, R4, R5	// R4 = y_offset * line length
	ADD	R3, R3, R4	// R3 = x_offset * 4 + (y_offset * line length) = total_offset
	LDR	R4, =BUFFER	// R4 -> BUFFER

image_loop:	
	LDR	R0, [SP, #8]	// R0 = open(...)
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #8		// R2 = 8 (bytes to read)
	BL	read		// Parameters: R0--R2
	CMP	R0, #0		// R0 ? 0 (end of file)
	BEQ	main1		// (Break)
	LDR	R0, =POSCOLOR	// R0 -> POSCOLOR
	LDRD	R0, [R0]	// R0,R1 = position,color
	ADD	R0, R0, R3	// R0 = position + total_offset = final_pos
	STR	R1, [R4, R0]	// BUFFER+final_pos = color
	BAL	image_loop	// (Loop)

main1:
	LDR	R0, =BUFFER	// R0 -> BUFFER
	LDR	R1, LATCH+20	// R1 -> fbp
	LDR	R1, [R1]	// R1 = fbp (dereferenced)
	LDR	R2, LATCH+24	// R2 = screen size
	ADD	R0, R0, R2	// R0 -> BUFFER + screen size
	ADD	R1, R1, R2	// R1 = fbp + screen size
	BL	put_screen	// Parameters: R0--R2

main2:
	LDR	R0, LATCH+20	// R0 -> fbp
	LDR	R0, [R0]	// R0 = fbp (dereferenced)
	LDR	R1, LATCH+24	// R1 = screen size
	BL	munmap		// Parameters: R0--R1
	LDR	R0, [SP]	// R0 = open("/dev/fb0\000")
	BL	close		// Parameters: R0
	LDR	R0, [SP, #8]	// R0 = open("/home/pi/Desktop/image1080.bin\000")
	BL	close		// Parameters: R0

quit:
	MOVAL	R0, #0		// R0 = 0 (return code)
	MOVAL	R7, #1		// R7 = 1 (exit syscall)
	SWI	0

LATCH:
	.word	FRAMEBUFFER
	.word	vinfo
	.word	finfo
	.word	17920
	.word	17922
	.word	fbp
	.word	0x7E9000	// screen size
	.word	0x1E00		// line length
IMAGE:
	.word	IMAGEFILE
	.word	0x7A120		// file size

	.data
BUFFER:
	.skip	0x7E9000
POSCOLOR:
	.skip	8
	
FRAMEBUFFER:
	.ascii	"/dev/fb0\000"
IMAGEFILE:
	.ascii	"/home/pi/Desktop/image1080.bin\000"
