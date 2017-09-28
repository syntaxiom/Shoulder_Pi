	.text
	.global main
main:
	PUSH	{LR}
	LDR	R0, =file	// R0 = "/dev/fb0"
	MOV	R1, #2		// R1 = 2 (Opcode for read+write)
	BL	open
	LDR	R0, =dump
	LDR	R1, =dump+4
	POP	{PC}

	.data
	.global file
file:
	.asciz "/dev/fb0"

	.global dump
dump:
	.word 1300
	.word 42
