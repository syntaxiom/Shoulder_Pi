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
	.global show_image
show_image:
	NOP

pixel_loop:
	MOV	PC, LR
	
	.text
	.align	2
	.global	main
main:
	//MOV	R1, #0
	//LDR	R0, =LATCH	// R0 -> LATCH
	//LDR	R0, [R0, +R1]
	LDR	R0, LATCH	// R0 -> LATCH = "/dev/fb0\000"
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	LDR	R1, LATCH+12	// R1 = 17920 (Opcode for FBIOGET_VSCREENINFO)
	LDR	R2, LATCH+4	// R2 -> .L6+4 -> vinfo (Changed)
	BL	ioctl		// Parameters: R0--R2
	LDR	R0, [SP]     	// R0 -> FP-8 = return of open(...);
	LDR	R1, LATCH+16	// R1 = 17922 (Opcode for FBIOGET_FSCREENINFO)
	LDR	R2, LATCH+8	// R2 -> .L6+8 -> finfo
	BL	ioctl		// Parameters: R0--R2
	MOV	R0, #0		// R0 = 0
	STR	R0, [SP, #4]	// SP+4 = 0
	LDR	R0, LATCH+4	// R0 -> LATCH+4 -> vinfo
	LDR	R0, [R0]	// R0 = vinfo+0 (dereferenced) ==> vinfo.xres
	LDR	R1, LATCH+4	// R1 -> LATCH+4 -> vinfo
	LDR	R1, [R1, #4]	// R1 = vinfo+4 (dereferenced) ==> vinfo.yres
	MUL	R1, R0, R1	// R1 = vinfo.xres * vinfo.yres
	LDR	R2, LATCH+4	// R2 -> LATCH+4 -> vinfo
	LDR	R2, [R2, #24]	// R2 = vinfo+24 (dereferenced) ==> vinfo.bits_per_pixel
	MUL	R2, R1, R2	// R2 = R1 * vinfo.bits_per_pixel
	LSR	R2, R2, #3	// R2 /= 8
	STR	R2, [SP, #8]	// SP+8 = screensize
	MOV	R0, #0		// R0 = 0
	LDR	R1, [SP, #8]	// SP+8 = screensize
	MOV	R2, #3		// R2 = 3 (Opcode for PROT_READ | PROT_WRITE)
	MOV	R3, #1		// R3 = 1 (Opcode for MAP_SHARED)
	BL	mmap		// Parameters: R0--R3, SP--SP+4
	LDR	R1, LATCH+20	// R1 -> fbp
	STR	R0, [R1]	// fbp = mmap(...)
	NOP
	LDR	R0, LATCH+24	// R0 -> LATCH+24 -> IMAGE
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	LDR	R1, [SP]	// R1 = open("/dev/fb0\000")
	STR	R1, [SP, #12]	// SP+12 = open("/dev/fb0\000")
	STR	R0, [SP]	// SP = open("/home/pi/Desktop/shoulder/images/image.bin\000")
	LDR	R0, [SP, #8]	// R0 = screensize
	ADD	R0, R0, #4	// R0 = screensize + 4 (for memory address)
	LDR	R1, LATCH+28	// R1 = 250 (Height)
	LDR	R2, LATCH+32	// R2 = 250 (Width)
	MUL	R1, R1, R2	// R1 = Height * Width
	MOV	R2, #4		// R2 = 4 (bytes per pixel)
	MUL	R1, R1, R2	// R1 = Height * Width * 4
	MOV	R2, #3		// R2 = 3 (Opcode for PROT_READ | PROT_WRITE)
	MOV	R3, #1		// R3 = 1 (Opcode for MAP_SHARED)
	BL	mmap		// Parameters: R0--R3, SP--SP+4
	STR	R0, [SP, #16]	// SP+16 = mmap(...)
	BL	show_image	// Parameters: R0--R1
	NOP
	LDR	R0, [SP, #12]	// R0 -> SP+12 = open("/dev/fb0\000")
	BL	close		// Parameters: R0
	NOP
	LDR	R0, [SP]	// R0 = open("/home/pi/Desktop/shoulder/images/image.bin\000")
	BL	close		// Parameters: R0
	NOP
	MOV	R0, #0		// R0 = 0 (return code)
	MOVAL	R7, #1		// R7 = 1 (exit syscall)
	SWI	0

	.align	2
LATCH:
	.word	FILE
	.word	vinfo
	.word	finfo
	.word	17920
	.word	17922
	.word	fbp
	.word	IMAGE
	.word	250
	.word	250

	.section	.rodata
	.align	2
FILE:
	.ascii	"/dev/fb0\000"

IMAGE:
	.ascii "/home/pi/Desktop/shoulder/images/image.bin\000"
