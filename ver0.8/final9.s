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

	/* R0 -> BUFFER + screen size, R1 = fbp + screen size, R2 = screen size */
	.global put_screen
put_screen:
	LDRD	R4, [R0, #-8]!	// R4,R5 = BUFFER[-8] ==> R0 = R0 - 8
	STRD	R4, [R1, #-8]!	// fbp[-8] = color ==> R1 = R1 - 8
	SUBS	R2, #8		// R2 -= 8 ==> set flags
	BNE	put_screen	// While R2 > 0, loop
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
	LDR	R0, LATCH+4	// R0 -> vinfo
	LDR	R1, [R0, #0]	// R1 = vinfo.xres
	LSL	R1, R1, #2	// R1 = vinfo.xres * 4 = line length
	LDR	R2, LATCH+28	// R2 -> LINELENGTH
	STR	R1, [R2]	// LINELENGTH = line length
	LDR	R2, [R0, #4]	// R2 = vinfo.yres
	MUL	R1, R1, R2	// R1 = line length * vinfo.yres
	LDR	R0, LATCH+24	// R0 -> screen size
	STR	R1, [R0]	// screen size = vinfo.xres * vinfo.yres * 4
	MOV	R0, #0		// R0 = 0
	LDR	R1, LATCH+24	// R1 -> screen size
	LDR	R1, [R1]	// R1 = screen size
	MOV	R2, #3		// R2 = 3 (Opcode for PROT_READ | PROT_WRITE)
	MOV	R3, #1		// R3 = 1 (Opcode for MAP_SHARED)
	STR	R0, [SP, #4]	// SP+4 = 0
	BL	mmap		// Parameters: R0--R3, SP--SP+4
	LDR	R1, LATCH+20	// R1 -> fbp
	STR	R0, [R1]	// fbp = mmap(...)
	LDR	R0, IMAGE	// R0 -> IMAGEFILE
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	STR	R0, [SP, #8]	// SP+8 = open("/home/pi/Desktop/image1080.bin\000")
	LDR	R1, =SIZE	// R1 -> SIZE
	MOV	R2, #4		// R2 = 4 (bytes to read)
	BL	read		// Parameters: R0--R2
	LDR	R0, =0x0	// R0 = x_offset
	LDR	R1, =0x0	// R1 = y_offset
	LSL	R0, R0, #2	// R0 = x_offset * 4 (adjust)
	LDR	R2, LATCH+28	// R2 -> LINELENGTH
	LDR	R2, [R2]	// R2 = LINELENGTH
	MUL	R1, R1, R2	// R1 = y_offset * LINELENGTH (adjust)
	STR	R0, [SP, #12]	// SP+12 = x_offset (adjusted)
	STR	R1, [SP, #16]	// SP+16 = y_offset (adjusted)

image_loop:
	LDR	R0, [SP, #8]	// R0 = open(...)
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #8		// R2 = 8 (bytes to read)
	BL	read		// Parameters: R0--R2
	CMP	R0, #0		// R0 ? 0 (end of file)
	BEQ	main1		// (Break)
	LDR	R0, =POSCOLOR	// R0 -> POSCOLOR
	LDRH	R1, [R0, #0]	// R1 = 2 bytes POSCOLOR+0 = x
	LDRH	R2, [R0, #2]	// R2 = 2 bytes POSCOLOR+2 = y
	LDR	R3, [R0, #4]	// R3 = 4 bytes POSCOLOR+4 = color
	LDR	R0, LATCH+28	// R0 -> SCREENSIZE
	LDR	R0, [R0]	// R0 = SCREENSIZE
	LSL	R1, R1, #2	// R1 = x * 4
	MUL	R2, R2, R0	// R2 = y * SCREENSIZE
	LDR	R0, [SP, #12]	// R0 = x_offset
	ADD	R1, R1, R0	// R1 = x * 4 + x_offset
	LDR	R0, [SP, #16]	// R0 = y_offset
	ADD	R2, R2, R0	// R2 = y * SCREENSIZE + y_offset
	ADD	R1, R1, R2	// R1 = x * 4 + x_offset + y * SCREENSIZE + y_offset
	LDR	R0, =BUFFER	// R0 -> BUFFER
	STR	R3, [R0, R1]	// BUFFER+R1 = color
	BAL	image_loop	// (Loop)

main1:
	LDR	R0, =BUFFER	// R0 -> BUFFER
	LDR	R1, LATCH+20	// R1 -> fbp
	LDR	R1, [R1]	// R1 = fbp (dereferenced)
	LDR	R2, LATCH+24	// R2 -> screen size
	LDR	R2, [R2]	// R2 = screen size
	ADD	R0, R0, R2	// R0 = *BUFFER + screensize
	ADD	R1, R1, R2	// R1 = fbp + screensize
	BL	put_screen	// Parameters: R0--R2

main2:
	LDR	R0, LATCH+20	// R0 -> fbp
	LDR	R0, [R0]	// R0 = fbp (dereferenced)
	LDR	R1, LATCH+24	// R1 -> screen size
	LDR	R1, [R1]	// R1 = screen size
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
	.word	SCREENSIZE
	.word	LINELENGTH
IMAGE:
	.word	IMAGEFILE

	.data
BUFFER:
	.skip	0x7E9000
POSCOLOR:
	.skip	8
SIZE:
	.skip	4
SCREENSIZE:
	.word	0
LINELENGTH:
	.word	0
	
FRAMEBUFFER:
	.ascii	"/dev/fb0\000"
IMAGEFILE:
	.ascii	"/home/pi/Desktop/image.bin\000"
