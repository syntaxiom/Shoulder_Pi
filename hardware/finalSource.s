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
	mov r1, #OUTPUT
	bl pinMode

	mov r0, #PIN0
	mov r1, #HIGH
	bl digitalWrite

	mov r0, #3
	bl sleep

	mov r0, #PIN0
	mov r1, #LOW
	bl digitalWrite

	pop {pc}
