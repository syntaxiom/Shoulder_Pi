	.text

	.global main
main:
	LDR	R0, =0xA
	PUSH	{R0}
	LDR	R0, =0xB
	PUSH	{R0}
	LDR	R0, =0xC
	PUSH	{R0}
	LDR	R1, [SP]
	LDR	R2, [SP, #4]
	LDR	R3, [SP, #8]
	MOV	R0, #0
	MOV	R7, #1
	SWI	0
