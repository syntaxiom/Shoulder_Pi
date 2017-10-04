	.text
	.align 2
	.global main
main:
	LDR	R0, file
	MOV	R1, #2
	MOV	R7, #5
	SWI	0

	.align 2
	.global _exit
_exit:
	MOV	R7, #1
	SWI	0

	.align	2
	.global file
file:
	.ascii	"/dev/fb0\000"
