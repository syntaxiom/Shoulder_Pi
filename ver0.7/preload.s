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
	.global main
main:
	LDR	R0, IMAGE	// R0 -> FILE
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	STR	R0, [SP]	// SP = open(...)
	LDR	R0, LATCH	// R0 -> finfo
	LDR	R0, [R0, #44]	// R0 = finfo+44 (dereferenced) ==> finfo.line_length
	STR	R0, [SP, #4]	// SP+4 = finfo.line_length
	MOV	R0, #0		// R0 = 0
	STR	R0, [SP, #8]	// SP+8 = 0 (pix_offset)
	LDR	R0, IMAGE+4	// R0 = Width
	LDR	R1, IMAGE+8	// R1 = Height
	MUL	R2, R0, R1	// R2 = Width * Height
	LSL	R2, R2, #2	// R2 = Width * Height * 4
	STR	R0, [SP, #12]	// SP+12 = Width
	STR	R1, [SP, #16]	// SP+16 = Height
	STR	R2, [SP, #20]	// SP+20 = File_Size
	MOV	R0, #0		// R0 = 0
	STR	R0, [SP, #24]	// SP+24 = x_pos
	STR	R0, [SP, #28]	// SP+28 = y_pos
	BAL	set_pixels
	
	.global main2
main2:
	MOVAL	R0, #0
	MOVAL	R7, #1
	SWI	0

	.global	set_pixels
set_pixels:
	LDR	R0, [SP, #24]	// R0 = x_pos
	LSL	R0, R0, #2	// R0 = x_pos * 4
	LDR	R1, [SP, #28]	// R1 = y_pos
	LDR	R2, [SP, #4]	// R2 = finfo.line_length
	MUL	R1, R1, R2	// R1 =	y_pos * finfo.line_length
	ADD	R1, R0, R1	// R1 = x_pos * 4 + y_pos * finfo.line_length
	LDR	R0, [SP]	// R0 = open(...)
	MOV	R2, #4		// R2 = 4 (bytes to write)
	BL	write		// Parameters: R0--R2
	LDR	R0, [SP]	// R0 = open(...)
	MOV	R1, #4		// R1 = 4 (bytes to offset)
	MOV	R2, #1		// R2 = 1 (Opcode for SEEK_CUR)
	BL	lseek		// Parameters: R0--R2
	LDR	R0, [SP, #28]	// R0 = y_pos
	LDR	R1, [SP, #16]	// R1 = Height
	CMP	R0, R1		// y_pos ? Height
	BEQ	adjust_pos
	ADD	R0, R0, #1	// R0 = y_pos + 1
	STR	R0, [SP, #28]	// SP+28 = y_pos (incremented)
	BAL	set_pixels

adjust_pos:
	MOV	R0, #0		// R0 = 0
	STR	R0, [SP, #28]	// SP+28 = y_pos (reset)
	LDR	R2, [SP, #24]	// R2 = x_pos
	LDR	R3, [SP, #12]	// R3 = Width
	CMP	R2, R3		// R2 ? R3
	BEQ	main2
	ADD	R2, R2, #1	// R2 = x_pos + 1
	STR	R2, [SP, #24]	// SP+24 = x_pos (incremented)
	BAL	set_pixels

IMAGE:
	.word	FILE
	.word	250
	.word	250

LATCH:
	.word	finfo

	.data
BUFFER:
	.skip	4

	.section	.rodata
FILE:
	.ascii "/home/pi/Desktop/image.bin\000"
