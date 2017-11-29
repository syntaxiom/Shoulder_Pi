	.global	fbp
	.bss
	.align	2
	.type	fbp, %object
	.size	fbp, 4
fbp:
	.space	4
	
	.comm	vinfo,160,4
	.comm	finfo,68,4
	.comm	delay,8,4

	.text

	/* R0 -> BUFFER, R1 -> fbp, R2 = screen size */
	.global put_screen
put_screen:
	/* LDRD	R4, [R0, #-8]!	// R4,R5 = BUFFER[-8] ==> R0 -= 8
	STRD	R4, [R1, #-8]!	// fbp[-8] = color ==> R1 -= 8
	SUBS	R2, #8		// R2 -= 8 ==> set flags
	BNE	put_screen	// While R2 > 0, loop */
	MOV	PC, LR		// (Go back)
	
	.global	main
main:
	MOV	FP, SP		// Set dynamic link
	SUB	SP, SP, #8	// Allocate 8 bytes on the stack
	LDR	R0, LATCH	// R0 -> LATCH -> "/dev/fb0\000"
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	STR	R0, [FP, #-4]	// SP = open("/dev/fb0\000")
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
	STR	R0, [FP, #0]	// SP+4 = 0
	BL	mmap		// Parameters: R0--R3, SP--SP+4
	LDR	R1, LATCH+20	// R1 -> fbp
	STR	R0, [R1]	// fbp = mmap(...)

done:
	LDR	R0, LATCH+20	// R0 -> fbp
	LDR	R0, [R0]	// R0 = fbp (dereferenced)
	LDR	R1, LATCH+24	// R1 -> screen size
	LDR	R1, [R1]	// R1 = screen size
	BL	munmap		// Parameters: R0--R1
	LDR	R0, [SP]	// R0 = open("/dev/fb0\000")
	BL	close		// Parameters: R0
	/* LDR	R0, [SP, #8]	// R0 = open("/home/pi/Desktop/image.bin\000")
	BL	close		// Parameters: R0 */
	MOV	R0, #0		// R0 = 0 (return code)
	BLAL	exit		// Terminate the program
	
LATCH:
	.word	FRAMEBUFFER
	.word	vinfo
	.word	finfo
	.word	17920
	.word	17922
	.word	fbp
	.word	SCREENSIZE
	.word	LINELENGTH
	.word	delay
IMAGE:
	.word	IMAGEFILE
	.word	COORDS

	.bss
BUFFER:
	.skip	0x7E9000

	.data
POSCOLOR:
	.skip	8
SIZE:
	.skip	4
SCREENSIZE:
	.word	0
LINELENGTH:
	.word	0
COORDS:
	.word	0x02000100
	
FRAMEBUFFER:
	.ascii	"/dev/fb0\000"
IMAGEFILE:
	.ascii	"/home/pi/Desktop/image.bin\000"

/* NOTES:
	*/
