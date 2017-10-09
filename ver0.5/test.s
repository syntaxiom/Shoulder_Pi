	.global main
main:
	LDR	R0, =0x12345678
	STR	R0, [SP]
	MOV	R1, #0
	ADD	R1, R1, [SP]
	MOVAL	R7, #1
	SWI	0
