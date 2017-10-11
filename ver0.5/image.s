	.text

	/* R1 = Image list offset  */
	.global show_image
show_image:
	LDR	R0, IMAGE_LIST
	MOV	R1, #2
	BL	open
	BAL	main2
	
	.align 2
IMAGE_LIST:
	.word	CYNDAQUIL
	.word	250
	.word	250

	.section	rodata
	.align	2
CYNDAQUIL:
	.asciz "/home/pi/Desktop/shoulder/images/cyndaquil.txt"
