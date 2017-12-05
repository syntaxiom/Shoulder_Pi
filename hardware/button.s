	.text
	
	.equ INPUT,	0
	.equ OUTPUT,	1
	.equ LOW,	0
	.equ HIGH,	1

	// Pin setup (Name, WPi)
	.equ LED1,	0
	.equ BUTTON1,	1
	.equ BUTTON2,	2

	.global main
main:
	BL	wiringPiSetup

	MOV	R0, #LED1
	MOV	R1, #OUTPUT
	BL	pinMode

	MOV	R0, #BUTTON1
	MOV	R1, #INPUT
	BL	pinMode

loop:
	MOV	R0, #BUTTON1
	BL	digitalRead
	CMP	R0, #HIGH
	MOVEQ	R1, #HIGH
	MOVNE	R1, #LOW
	MOV	R0, #LED1
	BL	digitalWrite
	MOV	R0, #BUTTON2
	BL	digitalRead
	CMP	R0, #HIGH
	BEQ	done
	BAL	loop
	
done:
	MOV	R0, #LED1
	MOV	R1, #LOW
	BL	digitalWrite
	BLAL	exit
