	.equ INPUT, 0
	.equ OUTPUT, 1
	.equ LOW, 0
	.equ HIGH, 1

	.equ PIN0, 0
	.equ PIN1, 1

	.global main
	.text
main:
	push {lr}
	bl wiringPiSetup

	mov r0, #PIN0
	bl pinMode

	mov r0, #255
	bl digitalWriteByte

	mov r0, #5
	bl sleep

	pop {pc}
