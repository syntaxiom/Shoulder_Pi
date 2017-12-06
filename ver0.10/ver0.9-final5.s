	.fpu neon

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

	/* R0 = *BUFFER, R1 = fbp, R2 = screen size (loop counter) */
	.global put_screen
put_screen:
	VLD1.32 {Q0,Q1}, [R0]!	// Q0 = BUFFER[0--3]!
	VST1.32 {Q0,Q1}, [R1]!	// fbp[0--3]! = Q0
	SUBS	R2, #32		// R2 -= 32 ==> set flags
	BNE	put_screen	// While R2 > 0, loop
	MOV	PC, LR		// (Go back)
	
	.global	main
main:
	BL	wiringPiSetup	// Setup wiringPi
	LDR	R0, =FRAMEBUF	// R0 -> FRAMEBUF
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	LDR	R1, =FB_FILED	// R1 -> FB_FILED
	STR	R0, [R1]	// FB_FILED = open("/dev/fb0\000")
	STR	R0, [SP]	// SP = open("/dev/fb0\000")
	LDR	R1, =17920	// R1 = 17920 (Opcode for FBIOGET_VSCREENINFO)
	LDR	R2, =vinfo	// R2 -> vinfo
	BL	ioctl		// Parameters: R0--R2
	LDR	R0, [SP]	// R0 = open("/dev/fb0\000")
	LDR	R1, =17922	// R1 = 17922 (Opcode for FBIOGET_FSCREENINFO)
	LDR	R2, =finfo	// R2 -> finfo
	BL	ioctl		// Parameters: R0--R2
	LDR	R0, =vinfo	// R0 -> vinfo
	LDR	R1, [R0, #0]	// R1 = vinfo.xres
	LSL	R1, R1, #2	// R1 = vinfo.xres * 4 = line length
	LDR	R2, =LINELENGTH	// R2 -> LINELENGTH
	STR	R1, [R2]	// LINELENGTH = line length
	LDR	R2, [R0, #4]	// R2 = vinfo.yres
	MUL	R1, R1, R2	// R1 = line length * vinfo.yres
	LDR	R0, =SCREENSIZE	// R0 -> screen size
	STR	R1, [R0]	// screen size = vinfo.xres * vinfo.yres * 4
	MOV	R0, #0		// R0 = 0
	LDR	R1, =SCREENSIZE	// R1 -> screen size
	LDR	R1, [R1]	// R1 = screen size
	MOV	R2, #3		// R2 = 3 (Opcode for PROT_READ | PROT_WRITE)
	MOV	R3, #1		// R3 = 1 (Opcode for MAP_SHARED)
	STR	R0, [SP, #4]	// SP+4 = 0
	BL	mmap		// Parameters: R0--R3, SP--SP+4
	LDR	R1, =fbp	// R1 -> fbp
	STR	R0, [R1]	// fbp = mmap(...)

open_image:
	LDR	R0, =IMAGEFILE	// R0 -> IMAGEFILE
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	LDR	R1, =IMG_FILED	// R1 -> IMG_FILED
	STR	R0, [R1]	// IMG_FILED = open("/home/pi/Desktop/image.bin\000")
	MOV	R4, #0		// R4 = 0 (track size of stack)

image_loop:
	LDR	R0, =IMG_FILED	// R0 -> IMG_FILED
	LDR	R0, [R0]	// R0 = IMG_FILED
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #12		// R2 = 12 (bytes to read)
	BL	read		// Parameters: R0--R2
	CMP	R0, #0		// R0 ? 0
	BEQ	set_stack	// (Break)
	LDR	R0, =POSCOLOR	// R0 -> POSCOLOR
	LDR	R1, [R0, #0]	// R1 = x
	LDR	R2, [R0, #4]	// R2 = y
	LDR	R3, [R0, #8]	// R3 = color
	LDR	R0, =LINELENGTH	// R0 -> LINELENGTH
	LDR	R0, [R0]	// R0 = LINELENGTH
	MUL	R2, R2, R0	// R2 = y * LINELENGTH
	LSL	R1, R1, #2	// R1 = x * 4
	ADD	R1, R1, R2	// R1 = (x * 4) + (y * LINELENGTH) (offset)
	LDR	R0, =BUFFER	// R0 -> BUFFER
	STR	R3, [R0, R1]	// BUFFER[offset] = color
	PUSH	{R1, R3}	// Push {offset, color}
	ADD	R4, #8		// R4 += 8
	BAL	image_loop	// (Loop)

set_stack:
	LDR	R0, =STACKSIZE	// R0 -> STACKSIZE
	STR	R4, [R0]	// STACKSIZE = R4
	MOV	FP, SP		// Set dynamic link

adj_coords:
	LDR	R0, =DELTA	// R0 -> DELTA
	LDR	R1, =LINELENGTH	// R1 -> LINELENGTH
	LDR	R1, [R1]	// R1 = LINELENGTH
	LDRD	R2, [R0]	// R2,R3 = dx,dy
	LSL	R2, R2, #2	// R2 = dx * 4
	MUL	R3, R3, R1	// R3 = dy * LINELENGTH
	ADD	R2, R2, R3	// R2 = (dx * 4) + (dy * LINELENGTH) (dOffset)
	LDR	R0, =OFFSET	// R0 -> OFFSET
	STR	R2, [R0]	// OFFSET = R2

prep_stack:
	LDR	R0, =STACKSIZE	// R0 -> STACKSIZE
	LDR	R0, [R0]	// @ R0 = STACKSIZE
	LDR	R1, =OFFSET	// R1 -> OFFSET
	LDR	R1, [r1]	// @ R1 = OFFSET
	LDR	R2, =BUFFER	// @ R2 -> BUFFER
	LDR	R3, =0		// @ R3 = 0

stack_loop:
	SUBS	R0, #8		// R0 -= 8
	BMI	prep_buffer	// (Break)
	LDRD	R4, [FP, R0]	// R4,R5 = offset,color
	STR	R3, [R2, R4]	// BUFFER[offset] = 0
	ADD	R4, R4, R1	// R4 = offset + OFFSET
	STRD	R4, [FP, R0]	// offset,color = R4,R5
	STR	R5, [R2, R4]	// BUFFER[offset] = color
	BAL	stack_loop	// (Loop)

prep_buffer:
	LDR	R0, =STACKSIZE	// R0 -> STACKSIZE
	LDR	R0, [R0]	// @ R0 = STACKSIZE
	LDR	R1, =BUFFER	// @ R1 = BUFFER

buffer_loop:
	SUBS	R0, #8		// R0 -= 8
	BMI	set_screen	// (Break)
	LDRD	R2, [FP, R0]	// R2,R3 = offset,color
	STR	R3, [R1, R2]	// BUFFER[offset] = color
	BAL	buffer_loop	// (Loop)
	
set_screen:
	LDR	R0, =BUFFER	// R0 -> BUFFER
	LDR	R1, =fbp	// R1 -> fbp
	LDR	R1, [R1]	// R1 = fbp
	LDR	R2, =SCREENSIZE	// R2 -> SCREENSIZE
	LDR	R2, [R2]	// R2 = SCREENSIZE
	BL	put_screen	// Parameters: R0--R2
	BAL	adj_coords	// (LOOP)

done:
	LDR	R0, =fbp	// R0 -> fbp
	LDR	R1, =SCREENSIZE	// R1 -> screen size
	LDR	R1, [R1]	// R1 = screen size
	BL	munmap		// Parameters: R0--R1
	LDR	R0, =FB_FILED	// R0 -> FB_FILED
	LDR	R0, [R0]	// R0 = FB_FILED
	BL	close		// Parameters: R0
	LDR	R0, =IMG_FILED	// R0 -> IMG_FILED
	LDR	R0, [R0]	// R0 = IMG_FILED
	BL	close		// Parameters: R0
	MOV	R0, #0		// R0 = 0 (return code)
	BLAL	exit		// Terminate the program

	.bss
BUFFER:
	.skip	0x7E9000

	.data
FB_FILED:
	.word	0
IMG_FILED:
	.word	0
POSCOLOR:
	.skip	12
SIZE:
	.skip	4
SCREENSIZE:
	.word	0
LINELENGTH:
	.word	0
STACKSIZE:
	.word	0
POS:
	.word	200
	.word	100
DELTA:
	.word	10
	.word	0
OFFSET:
	.word	0
	
FRAMEBUF:
	.ascii	"/dev/fb0\000"
IMAGEFILE:
	.ascii	"/home/pi/Desktop/image.bin\000"

/* NOTES
	*/
