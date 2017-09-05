	.global _start
_start:
	MOV		SP, #0x8000			// Stack Pointer points to 0x8000
	BL		FramebufferSetup	// Get framebuffer info (stored into R1)
	MOV		R4, R1				// Move framebuffer into into R4
	LDR		R3, [R4, #0x20]		// R3 points to GPU Address

render$:
	LDR		R0, =COLOR		// R0 = Color
	MOV		R1, #0			// R1 = X
	MOV		R2, #0			// R2 = Y

drawPixel$:
	STR		R0, [R3]
	ADD		R3, R3, #0x04
	ADD		R1, R1, #1
	CMP		R1, #1920
	BNE		drawPixel$

	ADD		R2, R2, #1
	BNE		drawPixel$
	BAL		render$

	.data
.equ COLOR, 0xFFC0CB
