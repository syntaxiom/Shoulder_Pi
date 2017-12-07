	.text

	.global main
main:
	BL	wiringPiSetup	// Parameters: (none)
	MOV	R0, #2		// Data pin
	MOV	R1, #1		// Clock pin
	MOV	R2, #0		// Latch pin
	BL	setupNesJoystick // Parameters: R0--R2; Returns into R0
	LDR	R1, =JOYSTICK	// R1 -> JOYSTICK
	STR	R0, [R1]	// JOYSTICK = R0

input:
	LDR	R0, =JOYSTICK	// R0 -> JOYSTICK
	LDR	R0, [R0]	// R0 = JOYSTICK
	BL	readNesJoystick	// Parameters: R0; Returns into R0
	LDR	R1, =PRESSED	// R1 -> PRESSED
	STR	R0, [R1]	// PRESSED = buttons
	TST	R0, #0x20	// Is "Select" pressed?
	BEQ	done		// Break if "Select" is pressed
	BAL	input		// (Loop)

done:	
	BLAL	exit
	
	.data
	
	.global JOYSTICK
JOYSTICK:
	.word 0

	.global PRESSED
PRESSED:
	.byte 0
