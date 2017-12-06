	.text

	.global main
main:
	LDR	R0, =-1000
	MOVS	R1, R0
	LDR	R0, =PATTERN
	LDRMI	R1, =NEGATIVE
	BL	printf
	BLAL	exit

PATTERN:
	.ascii "%s"
ZERO:
	.ascii "Zero set\n"
NEGATIVE:
	.ascii "Negative set\n"
CARRY:
	.ascii "Carry set\n"
OVERFLOW:
	.ascii "Overflow set\n"
