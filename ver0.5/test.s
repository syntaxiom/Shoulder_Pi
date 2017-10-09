	.global main
main:
	LDR	R0, =0x12345678
	MOVAL	R7, #1
	SWI	0
