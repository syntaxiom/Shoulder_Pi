	.text

	.global main
main:
	LDR	R0, LATCH	// R0 -> NUMBER
	VLDR	S1, [R0]	// S1 = NUMBER
	MOV	R0, #0		// R0 = 0 (return code)
	BLAL	exit		// Terminate the program

	.global LATCH
LATCH:
	.word	NUMBER

	.data
NUMBER:
	.word	65
