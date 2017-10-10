	.global show_image
show_image:
	LDR	R0, IMG_ADDR	// R0 -> IMG_ADDR -> "/home/pi/Desktop/shoulder/image.bin\000"
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	STR	R0, [SP]	// SP = open("/home/pi/Desktop/shoulder/image.bin\000")
	MOV	R0, #0		// R0 = 0
	STR	R0, [SP, #4]	// SP+4 = 0
	LDR	R0, WIDTH	// R0 -> WIDTH
	LDR	R0, [R0]	// R0 = 250
	LDR	R1, HEIGHT	// R1 -> HEIGHT
	LDR	R1, [R1]	// R1 = 250
	MUL	R1, R0, R1	// R1 = WIDTH * HEIGHT
	LDR	R0, [SP, #8]	// R0 = screensize
	MOV	R2, #3		// R2 = 3 (Opcode for PROT_READ | PROT_WRITE)
	MOV	R3, #1		// R3 = 1 (Opcode for MAP_SHARED)
	BL	mmap		// Parameters: RO--R3, SP--SP+4
	STR	R0, [SP, #20]	// SP+20 = mmap(...)
	
image_pixel:
	
	BAL	main2

IMG_ADDR:
	.word	IMAGE

	.section	rodata
IMAGE:
	.ascii	"/home/pi/Desktop/shoulder/image.bin\000"

	.data
WIDTH:
	.word	250
HEIGHT:
	.word	250
