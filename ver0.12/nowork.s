	.text

	.global main
main:
	MOV	R0, #16
	MVN	R1, #16

done:
	BLAL	exit
