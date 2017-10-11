	.text

	/* R0 = Image list offset  */
	.global show_image
show_image:
	LDR	R1, =IMAGE_LIST
	LDR	R1, [R1, +R0]
	MOV	PC, LR
	
	.global IMAGE_LIST
IMAGE_LIST:
	.word	CYNDAQUIL
	.word	250
	.word	250

	.section	rodata
CYNDAQUIL:
	.ascii "/home/pi/Desktop/shoulder/images/cyndaquil.bin\000"
