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

	/* R0 -> BUFFER, R1 -> fbp, R2 = screen size (loop counter) */
	.global put_screen
put_screen:
	LDM	R0!, {R3-R10}	// Load 8 words from BUFFER
	STM	R1!, {R3-R10}	// Store 8 words into fbp
	SUBS	R2, #32		// Decrement loop counter and set flags
	BNE	put_screen	// (Loop)
	MOV	PC, LR		// (Go back)
	
	.global	main
main:
	MOV	FP, SP		// Set dynamic link
	SUB	SP, #12		// Allocate 12 bytes on the stack
	LDR	R0, LATCH	// R0 -> LATCH -> "/dev/fb0\000"
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	STR	R0, [FP, #-8]	// SP = open("/dev/fb0\000")
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
	STR	R0, [FP, #-4]	// SP+4 = 0
	BL	mmap		// Parameters: R0--R3, SP--SP+4
	LDR	R1, LATCH+20	// R1 -> fbp
	STR	R0, [R1]	// fbp = mmap(...)

get_image:
	LDR	R0, IMAGE	// R0 -> IMAGEFILE
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	STR	R0, [FP, #-0]	// SP+8 = open("/home/pi/Desktop/image.bin\000")
	LDR	R1, =SIZE	// R1 -> SIZE
	MOV	R2, #4		// R2 = 4 (bytes to read)
	BL	read		// Parameters: R0--R2

setup_stack:	
	LDR	R0, =SIZE	// R0 -> SIZE
	LDR	R0, [R0]	// $ R0 = SIZE (loop counter)
	MOV	FP, SP		// Set dynamic link
	SUB	SP, R0		// Allocate SIZE bytes onto the stack
	LDR	R1, =POSCOLOR	// $ R1 -> POSCOLOR

stack_loop:
	PUSH	{R0-R1}		// (Toss)
	MOV	R0, #4		// R0 = open("/home/pi/Desktop/image.bin\000")
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #8		// R2 = 8 (bytes to read)
	BL	read		// Parameters: R0--R2
	POP	{R0-R1}		// (Fetch)
	SUBS	R0, #8		// Decrement loop counter and set flags
	BMI	setup_image	// (Break)
	LDRD	R2, [R1]	// R2,R3 = POSCOLOR
	STRD	R2, [FP, -R0]	// Store R2,R3 onto the stack
	BAL	stack_loop	// (Loop)

setup_image:
	LDR	R0, =BUFFER	// $ R0 -> BUFFER
	LDR	R1, =LINELENGTH	// R1 -> LINELENGTH
	LDR	R1, [R1]	// $ R1 = LINELENGTH
	LDR	R2, =COORDS+0	// R2 = x
	LDR	R3, =COORDS+4	// R3 = y
	MUL	R3, R3, R1	// R3 = y * LINELENGTH
	ADD	R2, R2, R3	// $ R2 = x + (y * LINELENGTH) (offset)
	LDR	R3, =POSCOLOR	// $ R3 -> POSCOLOR
	LDR	R4, =SIZE	// R4 -> SIZE
	LDR	R4, [R4]	// $ R4 = SIZE (loop counter)

image_loop:
	SUBS	R4, #8		// Decrement loop counter and set flags
	BMI	done		// (Break)
	LDRD	R6, [FP, -R4]	// R6,R7 = pos,color
	STRD	R6, [R3]	// POSCOLOR = pos,color
	LDRH	R5, [R3, #0]	// R5 = x
	LDRH	R6, [R3, #2]	// R6 = y
	MUL	R6, R6, R1	// R6 = y * LINELENGTH
	ADD	R6, R5, R6	// R6 = x + (y * LINELENGTH)
	ADD	R6, R2, R6	// R6 = offset + (x + (y * LINELENGTH))
	LDR	R7, [R3, #4]	// R7 = color
	STR	R7, [R0, R6]	// BUFFER+offset = color
	BAL	image_loop	// (Loop)

done:
	LDR	R0, =SIZE	// R0 -> SIZE
	LDR	R0, [R0]	// R0 = SIZE
	ADD	SP, R0		// Deallocate SIZE bytes from the stack
	LDR	R0, LATCH+20	// R0 -> fbp
	LDR	R0, [R0]	// R0 = fbp (dereferenced)
	LDR	R1, LATCH+24	// R1 -> screen size
	LDR	R1, [R1]	// R1 = screen size
	BL	munmap		// Parameters: R0--R1
	LDR	R0, [SP]	// R0 = open("/dev/fb0\000")
	BL	close		// Parameters: R0
	LDR	R0, [SP, #8]	// R0 = open("/home/pi/Desktop/image.bin\000")
	BL	close		// Parameters: R0
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
	.word	0x0200
	.word	0x0100
	
FRAMEBUFFER:
	.ascii	"/dev/fb0\000"
IMAGEFILE:
	.ascii	"/home/pi/Desktop/image.bin\000"

/* NOTES
	*/
