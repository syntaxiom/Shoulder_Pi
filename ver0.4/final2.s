	.text
	.global main
main:
	PUSH	{LR}
	LDR	R0, =file
	MOV	R1, #2
	BL	open
	MOV	R0, #42
	STR	R0, [SP]
	POP	{PC}

	.global dump
dump:
	.word 1300
	.word 42
	
	.data
	.global file
file:
	.asciz "/dev/fb0"
