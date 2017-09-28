	.text
	.global main
main:
	PUSH	{LR}
	LDR	R0, =file
	MOV	R1, #2
	BL	open
	LDR	R0, dump
	MOV	R1, #34
	STR	R1, dump
	MOV	R0, #0
	POP	{PC}

	.global dump
dump:
	.word 1300
	.word 42
	
	.data
	.global file
file:
	.asciz "/dev/fb0"
