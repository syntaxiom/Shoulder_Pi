	.fpu neon

	.global	fbp
	.bss
	.align	2
	.type	fbp, %object
	.size	fbp, 4
fbp:
	.space	4
	
	.comm	vinfo,160,4

	.text

	.equ	A, 	0x80
	.equ	B, 	0x40
	.equ	SELECT,	0x20
	.equ	START,	0x10
	.equ	UP,	0x08
	.equ	DOWN,	0x04
	.equ	LEFT,	0x02
	.equ	RIGHT,	0X01

	.equ	_A,	0
	.equ	_B,	1
	.equ	_UP,	2
	.equ	_DOWN,	3
	.equ	_LEFT,	4
	.equ	_RIGHT,	5

	.equ	STOP,	150
	.equ	TIME,	1000
	.equ	CEASE,	10

	/* R0 -> BUFFER, R1 = fbp, R2 = screen size (loop counter) */
	.global put_screen
put_screen:
	VLDM	R0!, {Q0-Q3}	// Q0--Q3 = BUFFER[0--15]!
	VSTM	R1!, {Q0-Q3}	// fbp[0--15]! = Q0--Q3
	SUBS	R2, #64		// R2 -= pixels * bit depth ==> set flags
	BNE	put_screen	// While R2 > 0, loop
	MOV	PC, LR		// (Go back)
	
	.global	main
main:
	BL	wiringPiSetup	// Parameters: (None)
	MOV	R0, #2		// R0 = wiringPi pin 2 (data, yellow)
	MOV	R1, #1		// R1 = wiringPi pin 1 (clock, red)
	MOV	R2, #0		// R2 = wiringPi pin 0 (latch, orange)
	BL	setupNesJoystick  // Parameters: R0--R2
	LDR	R1, =JOYSTICK	// R1 -> JOYSTICK
	STR	R0, [R1]	// JOYSTICK = setup controller
	LDR	R0, =FRAMEBUF	// R0 -> FRAMEBUF
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	LDR	R1, =FB_FILED	// R1 -> FB_FILED
	STR	R0, [R1]	// FB_FILED = open("/dev/fb0\000")
	STR	R0, [SP]	// SP = open("/dev/fb0\000")
	LDR	R1, =17920	// R1 = 17920 (Opcode for FBIOGET_VSCREENINFO)
	LDR	R2, =vinfo	// R2 -> vinfo
	BL	ioctl		// Parameters: R0--R2
	LDR	R0, =vinfo	// R0 -> vinfo
	LDR	R1, [R0, #0]	// R1 = vinfo.xres
	LDR	R2, =X_RES	// R2 -> X_RES
	STR	R1, [R2]	// X_RES = vinfo.xres
	LSL	R1, R1, #2	// R1 = vinfo.xres * 4 = line length
	LDR	R2, =LINELENGTH	// R2 -> LINELENGTH
	STR	R1, [R2]	// LINELENGTH = line length
	LDR	R2, [R0, #4]	// R2 = vinfo.yres
	LDR	R3, =Y_RES	// R3 -> Y_RES
	STR	R2, [R3]	// Y_RES = vinfo.yres
	MUL	R1, R1, R2	// R1 = line length * vinfo.yres
	LDR	R0, =SCREENSIZE	// R0 -> screen size
	STR	R1, [R0]	// screen size = vinfo.xres * vinfo.yres * 4
	MOV	R0, #0		// R0 = 0
	LDR	R1, =SCREENSIZE	// R1 -> screen size
	LDR	R1, [R1]	// R1 = screen size
	MOV	R2, #3		// R2 = 3 (Opcode for PROT_READ | PROT_WRITE)
	MOV	R3, #1		// R3 = 1 (Opcode for MAP_SHARED)
	STR	R0, [SP, #4]	// SP+4 = 0
	BL	mmap		// Parameters: R0--R3, SP--SP+4
	LDR	R1, =fbp	// R1 -> fbp
	STR	R0, [R1]	// fbp = mmap(...)

	// Get 9 symbol

prep_num_9_sym:
	LDR	R0, =NUM_9_IMG	// R0 -> NUM_9_IMG
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1 (R0 = open(...))
	LDR	R1, =NUM_9_FILED // R1 -> NUM_9_FILED
	STR	R0, [R1]	// NUM_9_FILED = R0
	MOV	R4, #0		// R4 = 0 (Later: size)

num_9_sym_loop:
	LDR	R0, =NUM_9_FILED  // R0 -> NUM_9_FILED
	LDR	R0, [R0]	// R0 = NUM_9_FILED
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #12		// R2 = 12 (bytes to read)
	BL	read		// Parameters: R0--R2
	CMP	R0, #0		// R0 ? 0
	BEQ	end_num_9_sym	// (Break)
	LDR	R0, =POSCOLOR	// R0 -> POSCOLOR
	LDR	R1, [R0, #0]	// R1 = x
	LDR	R2, [R0, #4]	// R2 = y
	LDR	R3, [R0, #8]	// R3 = color
	LDR	R0, =LINELENGTH	// R0 -> LINELENGTH
	LDR	R0, [R0]	// R0 = LINELENGTH
	MUL	R2, R2, R0	// R2 = y * LINELENGTH
	LSL	R1, R1, #2	// R1 = x * 4
	ADD	R1, R1, R2	// R1 = (x * 4) + (y * LINELENGTH) (offset)
	PUSH	{R1, R3}	// Push {offset, color}
	ADD	R4, #8		// R4 += 8
	BAL	num_9_sym_loop	// (Loop)

end_num_9_sym:
	LDR	R0, =NUM_9_STACK  // R0 -> NUM_9_STACK
	STR	R4, [R0, #0]	// size = R4
	STR	SP, [R0, #4]	// location = SP

	// Get 8 symbol

prep_num_8_sym:
	LDR	R0, =NUM_8_IMG	// R0 -> NUM_8_IMG
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1 (R0 = open(...))
	LDR	R1, =NUM_8_FILED // R1 -> NUM_8_FILED
	STR	R0, [R1]	// NUM_8_FILED = R0
	MOV	R4, #0		// R4 = 0 (Later: size)

num_8_sym_loop:
	LDR	R0, =NUM_8_FILED  // R0 -> NUM_8_FILED
	LDR	R0, [R0]	// R0 = NUM_8_FILED
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #12		// R2 = 12 (bytes to read)
	BL	read		// Parameters: R0--R2
	CMP	R0, #0		// R0 ? 0
	BEQ	end_num_8_sym	// (Break)
	LDR	R0, =POSCOLOR	// R0 -> POSCOLOR
	LDR	R1, [R0, #0]	// R1 = x
	LDR	R2, [R0, #4]	// R2 = y
	LDR	R3, [R0, #8]	// R3 = color
	LDR	R0, =LINELENGTH	// R0 -> LINELENGTH
	LDR	R0, [R0]	// R0 = LINELENGTH
	MUL	R2, R2, R0	// R2 = y * LINELENGTH
	LSL	R1, R1, #2	// R1 = x * 4
	ADD	R1, R1, R2	// R1 = (x * 4) + (y * LINELENGTH) (offset)
	PUSH	{R1, R3}	// Push {offset, color}
	ADD	R4, #8		// R4 += 8
	BAL	num_8_sym_loop	// (Loop)

end_num_8_sym:
	LDR	R0, =NUM_8_STACK  // R0 -> NUM_8_STACK
	STR	R4, [R0, #0]	// size = R4
	STR	SP, [R0, #4]	// location = SP

	// Get 7 symbol

prep_num_7_sym:
	LDR	R0, =NUM_7_IMG	// R0 -> NUM_7_IMG
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1 (R0 = open(...))
	LDR	R1, =NUM_7_FILED // R1 -> NUM_7_FILED
	STR	R0, [R1]	// NUM_7_FILED = R0
	MOV	R4, #0		// R4 = 0 (Later: size)

num_7_sym_loop:
	LDR	R0, =NUM_7_FILED  // R0 -> NUM_7_FILED
	LDR	R0, [R0]	// R0 = NUM_7_FILED
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #12		// R2 = 12 (bytes to read)
	BL	read		// Parameters: R0--R2
	CMP	R0, #0		// R0 ? 0
	BEQ	end_num_7_sym	// (Break)
	LDR	R0, =POSCOLOR	// R0 -> POSCOLOR
	LDR	R1, [R0, #0]	// R1 = x
	LDR	R2, [R0, #4]	// R2 = y
	LDR	R3, [R0, #8]	// R3 = color
	LDR	R0, =LINELENGTH	// R0 -> LINELENGTH
	LDR	R0, [R0]	// R0 = LINELENGTH
	MUL	R2, R2, R0	// R2 = y * LINELENGTH
	LSL	R1, R1, #2	// R1 = x * 4
	ADD	R1, R1, R2	// R1 = (x * 4) + (y * LINELENGTH) (offset)
	PUSH	{R1, R3}	// Push {offset, color}
	ADD	R4, #8		// R4 += 8
	BAL	num_7_sym_loop	// (Loop)

end_num_7_sym:
	LDR	R0, =NUM_7_STACK  // R0 -> NUM_7_STACK
	STR	R4, [R0, #0]	// size = R4
	STR	SP, [R0, #4]	// location = SP

	// Get 6 symbol

prep_num_6_sym:
	LDR	R0, =NUM_6_IMG	// R0 -> NUM_6_IMG
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1 (R0 = open(...))
	LDR	R1, =NUM_6_FILED // R1 -> NUM_6_FILED
	STR	R0, [R1]	// NUM_6_FILED = R0
	MOV	R4, #0		// R4 = 0 (Later: size)

num_6_sym_loop:
	LDR	R0, =NUM_6_FILED  // R0 -> NUM_6_FILED
	LDR	R0, [R0]	// R0 = NUM_6_FILED
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #12		// R2 = 12 (bytes to read)
	BL	read		// Parameters: R0--R2
	CMP	R0, #0		// R0 ? 0
	BEQ	end_num_6_sym	// (Break)
	LDR	R0, =POSCOLOR	// R0 -> POSCOLOR
	LDR	R1, [R0, #0]	// R1 = x
	LDR	R2, [R0, #4]	// R2 = y
	LDR	R3, [R0, #8]	// R3 = color
	LDR	R0, =LINELENGTH	// R0 -> LINELENGTH
	LDR	R0, [R0]	// R0 = LINELENGTH
	MUL	R2, R2, R0	// R2 = y * LINELENGTH
	LSL	R1, R1, #2	// R1 = x * 4
	ADD	R1, R1, R2	// R1 = (x * 4) + (y * LINELENGTH) (offset)
	PUSH	{R1, R3}	// Push {offset, color}
	ADD	R4, #8		// R4 += 8
	BAL	num_6_sym_loop	// (Loop)

end_num_6_sym:
	LDR	R0, =NUM_6_STACK  // R0 -> NUM_6_STACK
	STR	R4, [R0, #0]	// size = R4
	STR	SP, [R0, #4]	// location = SP

	// Get 5 symbol

prep_num_5_sym:
	LDR	R0, =NUM_5_IMG	// R0 -> NUM_5_IMG
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1 (R0 = open(...))
	LDR	R1, =NUM_5_FILED // R1 -> NUM_5_FILED
	STR	R0, [R1]	// NUM_5_FILED = R0
	MOV	R4, #0		// R4 = 0 (Later: size)

num_5_sym_loop:
	LDR	R0, =NUM_5_FILED  // R0 -> NUM_5_FILED
	LDR	R0, [R0]	// R0 = NUM_5_FILED
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #12		// R2 = 12 (bytes to read)
	BL	read		// Parameters: R0--R2
	CMP	R0, #0		// R0 ? 0
	BEQ	end_num_5_sym	// (Break)
	LDR	R0, =POSCOLOR	// R0 -> POSCOLOR
	LDR	R1, [R0, #0]	// R1 = x
	LDR	R2, [R0, #4]	// R2 = y
	LDR	R3, [R0, #8]	// R3 = color
	LDR	R0, =LINELENGTH	// R0 -> LINELENGTH
	LDR	R0, [R0]	// R0 = LINELENGTH
	MUL	R2, R2, R0	// R2 = y * LINELENGTH
	LSL	R1, R1, #2	// R1 = x * 4
	ADD	R1, R1, R2	// R1 = (x * 4) + (y * LINELENGTH) (offset)
	PUSH	{R1, R3}	// Push {offset, color}
	ADD	R4, #8		// R4 += 8
	BAL	num_5_sym_loop	// (Loop)

end_num_5_sym:
	LDR	R0, =NUM_5_STACK  // R0 -> NUM_5_STACK
	STR	R4, [R0, #0]	// size = R4
	STR	SP, [R0, #4]	// location = SP

	// Get 4 symbol

prep_num_4_sym:
	LDR	R0, =NUM_4_IMG	// R0 -> NUM_4_IMG
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1 (R0 = open(...))
	LDR	R1, =NUM_4_FILED // R1 -> NUM_4_FILED
	STR	R0, [R1]	// NUM_4_FILED = R0
	MOV	R4, #0		// R4 = 0 (Later: size)

num_4_sym_loop:
	LDR	R0, =NUM_4_FILED  // R0 -> NUM_4_FILED
	LDR	R0, [R0]	// R0 = NUM_4_FILED
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #12		// R2 = 12 (bytes to read)
	BL	read		// Parameters: R0--R2
	CMP	R0, #0		// R0 ? 0
	BEQ	end_num_4_sym	// (Break)
	LDR	R0, =POSCOLOR	// R0 -> POSCOLOR
	LDR	R1, [R0, #0]	// R1 = x
	LDR	R2, [R0, #4]	// R2 = y
	LDR	R3, [R0, #8]	// R3 = color
	LDR	R0, =LINELENGTH	// R0 -> LINELENGTH
	LDR	R0, [R0]	// R0 = LINELENGTH
	MUL	R2, R2, R0	// R2 = y * LINELENGTH
	LSL	R1, R1, #2	// R1 = x * 4
	ADD	R1, R1, R2	// R1 = (x * 4) + (y * LINELENGTH) (offset)
	PUSH	{R1, R3}	// Push {offset, color}
	ADD	R4, #8		// R4 += 8
	BAL	num_4_sym_loop	// (Loop)

end_num_4_sym:
	LDR	R0, =NUM_4_STACK  // R0 -> NUM_4_STACK
	STR	R4, [R0, #0]	// size = R4
	STR	SP, [R0, #4]	// location = SP

	// Get 3 symbol

prep_num_3_sym:
	LDR	R0, =NUM_3_IMG	// R0 -> NUM_3_IMG
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1 (R0 = open(...))
	LDR	R1, =NUM_3_FILED // R1 -> NUM_3_FILED
	STR	R0, [R1]	// NUM_3_FILED = R0
	MOV	R4, #0		// R4 = 0 (Later: size)

num_3_sym_loop:
	LDR	R0, =NUM_3_FILED  // R0 -> NUM_3_FILED
	LDR	R0, [R0]	// R0 = NUM_3_FILED
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #12		// R2 = 12 (bytes to read)
	BL	read		// Parameters: R0--R2
	CMP	R0, #0		// R0 ? 0
	BEQ	end_num_3_sym	// (Break)
	LDR	R0, =POSCOLOR	// R0 -> POSCOLOR
	LDR	R1, [R0, #0]	// R1 = x
	LDR	R2, [R0, #4]	// R2 = y
	LDR	R3, [R0, #8]	// R3 = color
	LDR	R0, =LINELENGTH	// R0 -> LINELENGTH
	LDR	R0, [R0]	// R0 = LINELENGTH
	MUL	R2, R2, R0	// R2 = y * LINELENGTH
	LSL	R1, R1, #2	// R1 = x * 4
	ADD	R1, R1, R2	// R1 = (x * 4) + (y * LINELENGTH) (offset)
	PUSH	{R1, R3}	// Push {offset, color}
	ADD	R4, #8		// R4 += 8
	BAL	num_3_sym_loop	// (Loop)

end_num_3_sym:
	LDR	R0, =NUM_3_STACK  // R0 -> NUM_3_STACK
	STR	R4, [R0, #0]	// size = R4
	STR	SP, [R0, #4]	// location = SP

	// Get 2 symbol

prep_num_2_sym:
	LDR	R0, =NUM_2_IMG	// R0 -> NUM_2_IMG
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1 (R0 = open(...))
	LDR	R1, =NUM_2_FILED // R1 -> NUM_2_FILED
	STR	R0, [R1]	// NUM_2_FILED = R0
	MOV	R4, #0		// R4 = 0 (Later: size)

num_2_sym_loop:
	LDR	R0, =NUM_2_FILED  // R0 -> NUM_2_FILED
	LDR	R0, [R0]	// R0 = NUM_2_FILED
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #12		// R2 = 12 (bytes to read)
	BL	read		// Parameters: R0--R2
	CMP	R0, #0		// R0 ? 0
	BEQ	end_num_2_sym	// (Break)
	LDR	R0, =POSCOLOR	// R0 -> POSCOLOR
	LDR	R1, [R0, #0]	// R1 = x
	LDR	R2, [R0, #4]	// R2 = y
	LDR	R3, [R0, #8]	// R3 = color
	LDR	R0, =LINELENGTH	// R0 -> LINELENGTH
	LDR	R0, [R0]	// R0 = LINELENGTH
	MUL	R2, R2, R0	// R2 = y * LINELENGTH
	LSL	R1, R1, #2	// R1 = x * 4
	ADD	R1, R1, R2	// R1 = (x * 4) + (y * LINELENGTH) (offset)
	PUSH	{R1, R3}	// Push {offset, color}
	ADD	R4, #8		// R4 += 8
	BAL	num_2_sym_loop	// (Loop)

end_num_2_sym:
	LDR	R0, =NUM_2_STACK  // R0 -> NUM_2_STACK
	STR	R4, [R0, #0]	// size = R4
	STR	SP, [R0, #4]	// location = SP

	// Get 1 symbol

prep_num_1_sym:
	LDR	R0, =NUM_1_IMG	// R0 -> NUM_1_IMG
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1 (R0 = open(...))
	LDR	R1, =NUM_1_FILED // R1 -> NUM_1_FILED
	STR	R0, [R1]	// NUM_1_FILED = R0
	MOV	R4, #0		// R4 = 0 (Later: size)

num_1_sym_loop:
	LDR	R0, =NUM_1_FILED  // R0 -> NUM_1_FILED
	LDR	R0, [R0]	// R0 = NUM_1_FILED
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #12		// R2 = 12 (bytes to read)
	BL	read		// Parameters: R0--R2
	CMP	R0, #0		// R0 ? 0
	BEQ	end_num_1_sym	// (Break)
	LDR	R0, =POSCOLOR	// R0 -> POSCOLOR
	LDR	R1, [R0, #0]	// R1 = x
	LDR	R2, [R0, #4]	// R2 = y
	LDR	R3, [R0, #8]	// R3 = color
	LDR	R0, =LINELENGTH	// R0 -> LINELENGTH
	LDR	R0, [R0]	// R0 = LINELENGTH
	MUL	R2, R2, R0	// R2 = y * LINELENGTH
	LSL	R1, R1, #2	// R1 = x * 4
	ADD	R1, R1, R2	// R1 = (x * 4) + (y * LINELENGTH) (offset)
	PUSH	{R1, R3}	// Push {offset, color}
	ADD	R4, #8		// R4 += 8
	BAL	num_1_sym_loop	// (Loop)

end_num_1_sym:
	LDR	R0, =NUM_1_STACK  // R0 -> NUM_1_STACK
	STR	R4, [R0, #0]	// size = R4
	STR	SP, [R0, #4]	// location = SP

	// Get 0 symbol

prep_num_0_sym:
	LDR	R0, =NUM_0_IMG	// R0 -> NUM_0_IMG
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1 (R0 = open(...))
	LDR	R1, =NUM_0_FILED // R1 -> NUM_0_FILED
	STR	R0, [R1]	// NUM_0_FILED = R0
	MOV	R4, #0		// R4 = 0 (Later: size)

num_0_sym_loop:
	LDR	R0, =NUM_0_FILED  // R0 -> NUM_0_FILED
	LDR	R0, [R0]	// R0 = NUM_0_FILED
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #12		// R2 = 12 (bytes to read)
	BL	read		// Parameters: R0--R2
	CMP	R0, #0		// R0 ? 0
	BEQ	end_num_0_sym	// (Break)
	LDR	R0, =POSCOLOR	// R0 -> POSCOLOR
	LDR	R1, [R0, #0]	// R1 = x
	LDR	R2, [R0, #4]	// R2 = y
	LDR	R3, [R0, #8]	// R3 = color
	LDR	R0, =LINELENGTH	// R0 -> LINELENGTH
	LDR	R0, [R0]	// R0 = LINELENGTH
	MUL	R2, R2, R0	// R2 = y * LINELENGTH
	LSL	R1, R1, #2	// R1 = x * 4
	ADD	R1, R1, R2	// R1 = (x * 4) + (y * LINELENGTH) (offset)
	PUSH	{R1, R3}	// Push {offset, color}
	ADD	R4, #8		// R4 += 8
	BAL	num_0_sym_loop	// (Loop)

end_num_0_sym:
	LDR	R0, =NUM_0_STACK  // R0 -> NUM_0_STACK
	STR	R4, [R0, #0]	// size = R4
	STR	SP, [R0, #4]	// location = SP

	// Get A symbol

prep_a_sym:
	LDR	R0, =A_IMG	// R0 -> A_IMG
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1 (R0 = open(...))
	LDR	R1, =A_FILED	// R1 -> A_FILED
	STR	R0, [R1]	// A_FILED = R0
	MOV	R4, #0		// R4 = 0 (Later: size)

a_sym_loop:
	LDR	R0, =A_FILED	// R0 -> A_FILED
	LDR	R0, [R0]	// R0 = A_FILED
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #12		// R2 = 12 (bytes to read)
	BL	read		// Parameters: R0--R2
	CMP	R0, #0		// R0 ? 0
	BEQ	end_a_sym	// (Break)
	LDR	R0, =POSCOLOR	// R0 -> POSCOLOR
	LDR	R1, [R0, #0]	// R1 = x
	LDR	R2, [R0, #4]	// R2 = y
	LDR	R3, [R0, #8]	// R3 = color
	LDR	R0, =LINELENGTH	// R0 -> LINELENGTH
	LDR	R0, [R0]	// R0 = LINELENGTH
	MUL	R2, R2, R0	// R2 = y * LINELENGTH
	LSL	R1, R1, #2	// R1 = x * 4
	ADD	R1, R1, R2	// R1 = (x * 4) + (y * LINELENGTH) (offset)
	PUSH	{R1, R3}	// Push {offset, color}
	ADD	R4, #8		// R4 += 8
	BAL	a_sym_loop	// (Loop)

end_a_sym:
	LDR	R0, =A_STACK	// R0 -> A_STACK
	STR	R4, [R0, #0]	// size = R4
	STR	SP, [R0, #4]	// location = SP

	// Get B symbol

prep_b_sym:
	LDR	R0, =B_IMG	// R0 -> B_IMG
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1 (R0 = open(...))
	LDR	R1, =B_FILED	// R1 -> B_FILED
	STR	R0, [R1]	// LEFT_FILED = R0
	MOV	R4, #0		// R4 = 0 (Later: size)

b_sym_loop:
	LDR	R0, =B_FILED	// R0 -> B_FILED
	LDR	R0, [R0]	// R0 = B_FILED
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #12		// R2 = 12 (bytes to read)
	BL	read		// Parameters: R0--R2
	CMP	R0, #0		// R0 ? 0
	BEQ	end_b_sym	// (Break)
	LDR	R0, =POSCOLOR	// R0 -> POSCOLOR
	LDR	R1, [R0, #0]	// R1 = x
	LDR	R2, [R0, #4]	// R2 = y
	LDR	R3, [R0, #8]	// R3 = color
	LDR	R0, =LINELENGTH	// R0 -> LINELENGTH
	LDR	R0, [R0]	// R0 = LINELENGTH
	MUL	R2, R2, R0	// R2 = y * LINELENGTH
	LSL	R1, R1, #2	// R1 = x * 4
	ADD	R1, R1, R2	// R1 = (x * 4) + (y * LINELENGTH) (offset)
	PUSH	{R1, R3}	// Push {offset, color}
	ADD	R4, #8		// R4 += 8
	BAL	b_sym_loop	// (Loop)

end_b_sym:
	LDR	R0, =B_STACK	// R0 -> B_STACK
	STR	R4, [R0, #0]	// size = R4
	STR	SP, [R0, #4]	// location = SP

	//Get up symbol
	
prep_up_sym:
	LDR	R0, =UP_IMG	// R0 -> UP_IMG
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1 (R0 = open(...))
	LDR	R1, =UP_FILED	// R1 -> UP_FILED
	STR	R0, [R1]	// UP_FILED = R0
	MOV	R4, #0		// R4 = 0 (Later: size)

up_sym_loop:
	LDR	R0, =UP_FILED	// R0 -> UP_FILED
	LDR	R0, [R0]	// R0 = UP_FILED
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #12		// R2 = 12 (bytes to read)
	BL	read		// Parameters: R0--R2
	CMP	R0, #0		// R0 ? 0
	BEQ	end_up_sym	// (Break)
	LDR	R0, =POSCOLOR	// R0 -> POSCOLOR
	LDR	R1, [R0, #0]	// R1 = x
	LDR	R2, [R0, #4]	// R2 = y
	LDR	R3, [R0, #8]	// R3 = color
	LDR	R0, =LINELENGTH	// R0 -> LINELENGTH
	LDR	R0, [R0]	// R0 = LINELENGTH
	MUL	R2, R2, R0	// R2 = y * LINELENGTH
	LSL	R1, R1, #2	// R1 = x * 4
	ADD	R1, R1, R2	// R1 = (x * 4) + (y * LINELENGTH) (offset)
	PUSH	{R1, R3}	// Push {offset, color}
	ADD	R4, #8		// R4 += 8
	BAL	up_sym_loop	// (Loop)

end_up_sym:
	LDR	R0, =UP_STACK	// R0 -> UP_STACK
	STR	R4, [R0, #0]	// size = R4
	STR	SP, [R0, #4]	// location = SP

	// Get down symbol
	
prep_down_sym:
	LDR	R0, =DOWN_IMG	// R0 -> DOWN_IMG
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1 (R0 = open(...))
	LDR	R1, =DOWN_FILED	// R1 -> DOWN_FILED
	STR	R0, [R1]	// DOWN_FILED = R0
	MOV	R4, #0		// R4 = 0 (Later: size)

down_sym_loop:
	LDR	R0, =DOWN_FILED	// R0 -> DOWN_FILED
	LDR	R0, [R0]	// R0 = DOWN_FILED
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #12		// R2 = 12 (bytes to read)
	BL	read		// Parameters: R0--R2
	CMP	R0, #0		// R0 ? 0
	BEQ	end_down_sym	// (Break)
	LDR	R0, =POSCOLOR	// R0 -> POSCOLOR
	LDR	R1, [R0, #0]	// R1 = x
	LDR	R2, [R0, #4]	// R2 = y
	LDR	R3, [R0, #8]	// R3 = color
	LDR	R0, =LINELENGTH	// R0 -> LINELENGTH
	LDR	R0, [R0]	// R0 = LINELENGTH
	MUL	R2, R2, R0	// R2 = y * LINELENGTH
	LSL	R1, R1, #2	// R1 = x * 4
	ADD	R1, R1, R2	// R1 = (x * 4) + (y * LINELENGTH) (offset)
	PUSH	{R1, R3}	// Push {offset, color}
	ADD	R4, #8		// R4 += 8
	BAL	down_sym_loop	// (Loop)

end_down_sym:
	LDR	R0, =DOWN_STACK	// R0 -> DOWN_STACK
	STR	R4, [R0, #0]	// size = R4
	STR	SP, [R0, #4]	// location = SP

	// Get left symbol

prep_left_sym:
	LDR	R0, =LEFT_IMG	// R0 -> LEFT_IMG
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1 (R0 = open(...))
	LDR	R1, =LEFT_FILED	// R1 -> LEFT_FILED
	STR	R0, [R1]	// LEFT_FILED = R0
	MOV	R4, #0		// R4 = 0 (Later: size)

left_sym_loop:
	LDR	R0, =LEFT_FILED	// R0 -> LEFT_FILED
	LDR	R0, [R0]	// R0 = LEFT_FILED
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #12		// R2 = 12 (bytes to read)
	BL	read		// Parameters: R0--R2
	CMP	R0, #0		// R0 ? 0
	BEQ	end_left_sym	// (Break)
	LDR	R0, =POSCOLOR	// R0 -> POSCOLOR
	LDR	R1, [R0, #0]	// R1 = x
	LDR	R2, [R0, #4]	// R2 = y
	LDR	R3, [R0, #8]	// R3 = color
	LDR	R0, =LINELENGTH	// R0 -> LINELENGTH
	LDR	R0, [R0]	// R0 = LINELENGTH
	MUL	R2, R2, R0	// R2 = y * LINELENGTH
	LSL	R1, R1, #2	// R1 = x * 4
	ADD	R1, R1, R2	// R1 = (x * 4) + (y * LINELENGTH) (offset)
	PUSH	{R1, R3}	// Push {offset, color}
	ADD	R4, #8		// R4 += 8
	BAL	left_sym_loop	// (Loop)

end_left_sym:
	LDR	R0, =LEFT_STACK	// R0 -> LEFT_STACK
	STR	R4, [R0, #0]	// size = R4
	STR	SP, [R0, #4]	// location = SP

	// Get right symbol

prep_right_sym:
	LDR	R0, =RIGHT_IMG	// R0 -> RIGHT_IMG
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1 (R0 = open(...))
	LDR	R1, =RIGHT_FILED  // R1 -> RIGHT_FILED
	STR	R0, [R1]	// RIGHT_FILED = R0
	MOV	R4, #0		// R4 = 0 (Later: size)

right_sym_loop:
	LDR	R0, =RIGHT_FILED  // R0 -> RIGHT_FILED
	LDR	R0, [R0]	// R0 = RIGHT_FILED
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #12		// R2 = 12 (bytes to read)
	BL	read		// Parameters: R0--R2
	CMP	R0, #0		// R0 ? 0
	BEQ	end_right_sym	// (Break)
	LDR	R0, =POSCOLOR	// R0 -> POSCOLOR
	LDR	R1, [R0, #0]	// R1 = x
	LDR	R2, [R0, #4]	// R2 = y
	LDR	R3, [R0, #8]	// R3 = color
	LDR	R0, =LINELENGTH	// R0 -> LINELENGTH
	LDR	R0, [R0]	// R0 = LINELENGTH
	MUL	R2, R2, R0	// R2 = y * LINELENGTH
	LSL	R1, R1, #2	// R1 = x * 4
	ADD	R1, R1, R2	// R1 = (x * 4) + (y * LINELENGTH) (offset)
	PUSH	{R1, R3}	// Push {offset, color}
	ADD	R4, #8		// R4 += 8
	BAL	right_sym_loop	// (Loop)

end_right_sym:
	LDR	R0, =RIGHT_STACK  // R0 -> RIGHT_STACK
	STR	R4, [R0, #0]	// size = R4
	STR	SP, [R0, #4]	// location = SP

	// After all the symbols are loaded

after_loading_sym:
	MOV	FP, SP		// Set link
	BL	set_screen	// Parameters: None

	// Game

game:
	LDR	R0, =SCORE	// R0 -> SCORE
	LDR	R1, [R0]	// R1 = SCORE
	ADD	R1, #1		// R1 += 1
	STR	R1, [R0]	// SCORE = (incremented)
	MOV	R0, #STOP	// R0 = milliseconds
	BL	delay		// Parameters: R0
	LDR	R0, =COUNTER	// R0 -> COUNTER
	LDR	R1, [R0]	// R1 = COUNTER
	ADD	R1, #STOP	// R1 += STOP
	STR	R1, [R0]	// COUNTER = (incremented)
	BL	inc_counter	// Parameters: (None)

new_symbol:
	BL	clock		// Parameters: (None)
	LDR	R1, =6		// R1 = 6
	BL	divide		// Parameters: R0--R1
	LSL	R1, #3		// Remainder *= 8
	LDR	R2, =TEMP	// R2 -> TEMP
	STR	R1, [R2, #0]	// TEMP[0] = A_STACK offset
	
new_x:
	BL	clock		// Parameters: (None)
	LDR	R1, =X_RES	// R1 -> X_RES
	LDR	R1, [R1]	// R1 = X_RES
	SUB	R1, #64		// R1 -= 64 (Width of sprite)
	BL	divide		// Parameters: R0--R1
	LDR	R2, =TEMP	// R2 -> TEMP
	STR	R1, [R2, #4]	// TEMP[4] = x

new_y:
	BL	clock		// Parameters: (None)
	LDR	R1, =Y_RES	// R1 -> Y_RES
	LDR	R1, [R1]	// R1 = Y_RES
	SUB	R1, #64		// R1 -= 64 (Height of sprite)
	BL	divide		// Parameters: R0--R1
	LDR	R2, =TEMP	// R2 -> TEMP
	STR	R1, [R2, #8]	// TEMP[8] = y

put_together:
	LDR	R2, =TEMP	// R2 -> TEMP
	LDR	R1, [R2, #8]	// R1 = y
	LDR	R0, [R2, #4]	// R0 = x
	BL	set_offset	// Parameters: R0--R1
	LDR	R2, =TEMP	// R2 -> TEMP
	LDR	R1, [R2, #0]	// R1 = A_STACK offset
	LDR	R0, =A_STACK	// R0 -> A_STACK
	ADD	R0, R1		// R0 -> (SYMBOL)_STACK
	BL	prep_symbol	// Parameters: R0--R1
	BL	set_screen	// Parameters: (None)
	
	// Input loop

input:
	BL	inc_counter	// Parameters: (None)
	LDR	R0, =JOYSTICK	// R0 -> JOYSTICK
	LDR	R0, [R0]	// R0 = JOYSTICK
	BL	readNesJoystick	// Parameters: R0; R0 = buttons pressed
	CMP	R0, #A		// A pressed?
	BEQ	a_press		// Parameters: None
	CMP	R0, #B		// B pressed?
	BEQ	b_press		// Parameters: None
	CMP	R0, #SELECT	// SELECT pressed?
	BEQ	select_held	// Parameters: None
	CMP	R0, #START	// START pressed?
	BEQ	start_held	// Parameters: None
	CMP	R0, #UP		// UP pressed?
	BEQ	up_press	// Parameters: None
	CMP	R0, #DOWN	// DOWN pressed?
	BEQ	down_press	// Parameters: None
	CMP	R0, #LEFT	// LEFT pressed?
	BEQ	left_press	// Parameters: None
	CMP	R0, #RIGHT	// RIGHT pressed?
	BEQ	right_press	// Parameters: None
	BAL	input		// (Loop)

	/* (No parameters) */
inc_counter:
	PUSH	{LR}		// Save
	MOV	R0, #1		// R0 = milliseconds
	BL	delay		// Parameters: R0
	LDR	R0, =COUNTER	// R0 -> COUNTER
	LDR	R1, [R0]	// R1 = COUNTER
	ADD	R1, #1		// R1 += 1
	CMP	R1, #TIME	// R1 ? TIME
	MOVGE	R1, #0		// R1 = 0
	STR	R1, [R0]	// COUNTER = (incremented)
	CMP	R1, #0		// R1 ? 0
	LDR	R2, =SEC	// R2 -> SEC
	LDR	R3, [R2]	// R3 = SEC
	ADDEQ	R3, #1		// R3 += 1
	STR	R3, [R2]	// SEC = (incremented)
	CMP	R3, #CEASE	// R3 ? CEASE
	BEQ	done		// (Terminate)
	POP	{PC}		// Fetch

	/* (No parameters) */
a_press:
	BL	inc_counter	// Parameters: (None)
	BL	set_screen	// Parameters: (None)
	LDR	R0, =TEMP	// R0 -> TEMP
	LDR	R1, [R0, #0]	// R1 = TEMP[0]
	LSR	R1, #3		// R1 /= 8
	CMP	R1, #_A		// R1 ? _A
	BEQ	bottom_game	// ((Big loop))
	
a_held:
	BL	inc_counter	// Parameters: (None)
	LDR	R0, =JOYSTICK	// R0 -> JOYSTICK
	LDR	R0, [R0]	// R0 = JOYSTICK
	BL	readNesJoystick	// Parameters: R0; R0 = buttons pressed
	CMP	R0, #A		// A pressed?
	BGE	a_held		// (Loop)
	BAL	input		// (Go back)

	/* (No parameters) */
b_press:
	BL	inc_counter	// Parameters: (None)
	BL	set_screen	// Parameters: (None)
	LDR	R0, =TEMP	// R0 -> TEMP
	LDR	R1, [R0, #0]	// R1 = TEMP[0]
	LSR	R1, #3		// R1 /= 8
	CMP	R1, #_B		// R1 ? _B
	BEQ	bottom_game	// ((Big loop))

b_held:
	BL	inc_counter	// Parameters: (None)
	LDR	R0, =JOYSTICK	// R0 -> JOYSTICK
	LDR	R0, [R0]	// R0 = JOYSTICK
	BL	readNesJoystick	// Parameters: R0; R0 = buttons pressed
	CMP	R0, #B		// B pressed?
	BGE	b_held		// (Loop)	
	BAL	input		// (Go back)

	/* (No parameters) */
select_held:
	BL	inc_counter	// Parameters: (None)
	LDR	R0, =JOYSTICK	// R0 -> JOYSTICK
	LDR	R0, [R0]	// R0 = JOYSTICK
	BL	readNesJoystick	// Parameters: R0; R0 = buttons pressed
	CMP	R0, #SELECT	// SELECT pressed?
	BGE	select_held	// (Loop)
	BAL	input		// (Go back)

	/* (No parameters) */
start_held:
	BL	inc_counter	// Parameters: (None)
	LDR	R0, =JOYSTICK	// R0 -> JOYSTICK
	LDR	R0, [R0]	// R0 = JOYSTICK
	BL	readNesJoystick	// Parameters: R0; R0 = buttons pressed
	CMP	R0, #START	// START pressed?
	BGE	start_held	// (Loop)
	BAL	input		// (Go back)

	/* (No parameters) */
up_press:
	BL	inc_counter	// Parameters: (None)
	BL	set_screen	// Parameters: (None)
	LDR	R0, =TEMP	// R0 -> TEMP
	LDR	R1, [R0, #0]	// R1 = TEMP[0]
	LSR	R1, #3		// R1 /= 8
	CMP	R1, #_UP	// R1 ? _UP
	BEQ	bottom_game	// ((Big loop))
	
up_held:
	BL	inc_counter	// Parameters: (None)
	LDR	R0, =JOYSTICK	// R0 -> JOYSTICK
	LDR	R0, [R0]	// R0 = JOYSTICK
	BL	readNesJoystick	// Parameters: R0; R0 = buttons pressed
	CMP	R0, #UP		// UP pressed?
	BGE	up_held		// (Loop)
	BAL	input		// (Go back)

	/* (No parameters) */
down_press:
	BL	inc_counter	// Parameters: (None)
	BL	set_screen	// Parameters: (None)
	LDR	R0, =TEMP	// R0 -> TEMP
	LDR	R1, [R0, #0]	// R1 = TEMP[0]
	LSR	R1, #3		// R1 /= 8
	CMP	R1, #_DOWN	// R1 ? _DOWN
	BEQ	bottom_game	// ((Big loop))

down_held:
	BL	inc_counter	// Parameters: (None)
	LDR	R0, =JOYSTICK	// R0 -> JOYSTICK
	LDR	R0, [R0]	// R0 = JOYSTICK
	BL	readNesJoystick	// Parameters: R0; R0 = buttons pressed
	CMP	R0, #DOWN	// DOWN pressed?
	BGE	down_held	// (Loop)
	BAL	input		// (Go back)
	
	/* (No parameters) */
left_press:
	BL	inc_counter	// Parameters: (None)
	BL	set_screen	// Parameters: (None)
	LDR	R0, =TEMP	// R0 -> TEMP
	LDR	R1, [R0, #0]	// R1 = TEMP[0]
	LSR	R1, #3		// R1 /= 8
	CMP	R1, #_LEFT	// R1 ? _LEFT
	BEQ	bottom_game	// ((Big loop))

left_held:
	BL	inc_counter	// Parameters: (None)
	LDR	R0, =JOYSTICK	// R0 -> JOYSTICK
	LDR	R0, [R0]	// R0 = JOYSTICK
	BL	readNesJoystick	// Parameters: R0; R0 = buttons pressed
	CMP	R0, #LEFT	// LEFT pressed?
	BGE	left_held	// (Loop)
	BAL	input		// (Go back)

	/* (No parameters) */
right_press:
	BL	inc_counter	// Parameters: (None)
	BL	set_screen	// Parameters: (None)
	LDR	R0, =TEMP	// R0 -> TEMP
	LDR	R1, [R0, #0]	// R1 = TEMP[0]
	LSR	R1, #3		// R1 /= 8
	CMP	R1, #_RIGHT	// R1 ? _RIGHT
	BEQ	bottom_game

right_held:
	BL	inc_counter	// Parameters: (None)
	LDR	R0, =JOYSTICK	// R0 -> JOYSTICK
	LDR	R0, [R0]	// R0 = JOYSTICK
	BL	readNesJoystick	// Parameters: R0; R0 = buttons pressed
	CMP	R0, #RIGHT	// RIGHT pressed?
	BGE	right_held	// (Loop)
	BAL	input		// (Go back)

	/* (Get ready for big loop) */
bottom_game:
	LDR	R0, =NUM_9_STACK  // R0 -> NUM_9_STACK
	LDR	R1, =SEC	// R1 -> SEC
	LDR	R1, [R1]	// R1 = SEC
	LSL	R1, #3		// R1 *= 8
	ADD	R0, R1		// R0 = (SYMBOL)_STACK
	BL	prep_symbol	// Parameters: R0
	BL	set_screen	// Parameters: (None)
	BAL	game		// ((Big loop))

	/* R0 -> (SYMBOL)_STACK */
prep_symbol:
	PUSH	{R4-R5}		// Save R4-R5
	LDR	R1, =BUFFER	// @ R1 -> BUFFER
	LDR	R2, =OFFSET	// R2 -> OFFSET
	LDR	R2, [R2]	// @ R2 = OFFSET
	LDR	R3, [R0, #0]	// @ R3 = size

symbol_loop:
	SUBS	R3, #8		// size -= 8 ==> set flags
	BMI	end_symbol	// (Break)
	LDR	SP, [R0, #4]	// SP = location
	LDRD	R4, [SP, R3]	// R4,R5 = offset,color
	ADD	R4, R4, R2	// R4 = offset + OFFSET (new offset)
	STR	R5, [R1, R4]	// BUFFER[new offset] = color
	BAL	symbol_loop	// (Loop)

end_symbol:	
	POP	{R4-R5}		// Fetch R4-R5
	MOV	SP, FP		// Restore link
	MOV	PC, LR		// (Go back)

	/* (No parameters) */
set_screen:
	PUSH	{LR}		// Save
	LDR	R0, =BUFFER	// R0 -> BUFFER
	LDR	R1, =fbp	// R1 -> fbp
	LDR	R1, [R1]	// R1 = mapped fbp
	LDR	R2, =SCREENSIZE	// R2 -> SCREENSIZE
	LDR	R2, [R2]	// R2 = SCREENSIZE
	BL	put_screen	// Parameters: R0--R2
	POP	{PC}		// Fetch

	/* R0 = x, R1 = y */
set_offset:
	PUSH	{LR}		// Save
	LDR	R2, =POS	// R2 -> POS
	STR	R0, [R2, #0]	// POS.x = x
	STR	R1, [R2, #1]	// POS.y = y
	LDR	R2, =LINELENGTH	// R2 -> LINELENGTH
	LDR	R2, [R2]	// R2 = LINELENGTH
	LSL	R0, #2		// R0 = x * 4
	MUL	R1, R1, R2	// R1 = y * LINELENGTH
	ADD	R0, R0, R1	// R0 = (x * 4) + (y * LINELENGTH) (offset)
	LDR	R1, =OFFSET	// R1 -> OFFSET
	STR	R0, [R1]	// OFFSET = offset
	POP	{PC}		// Fetch

	/* R0 = dx, R1 = dy */
adj_offset:
	PUSH	{R4, LR}	// Save
	LDR	R2, =POS	// R2 -> POS
	LDR	R3, [R2, #0]	// R3 = POS.x
	LDR	R4, [R2, #4]	// R4 = POS.y
	ADD	R3, R0		// POS.x += dx
	ADD	R4, R1		// POS.y += dy
	STR	R3, [R2, #0]	// POS.x = R3
	STR	R4, [R2, #4]	// POS.y = R4
	LDR	R2, =LINELENGTH	// R2 -> LINELENGTH
	LDR	R2, [R2]	// R2 = LINELENGTH
	LSL	R0, #2		// R0 = x * 4
	MUL	R1, R1, R2	// R1 = y * LINELENGTH
	ADD	R0, R0, R1	// R0 = (x * 4) + (y * LINELENGTH) (offset)
	LDR	R1, =OFFSET	// R1 -> OFFSET
	LDR	R2, [R1]	// R2 = OFFSET
	ADD	R2, R0		// offset += OFFSET
	STR	R2, [R1]	// OFFSET = offset
	POP	{R4, PC}	// Fetch

	/* R0 = n, R1 = d */
divide:
	PUSH	{R0-R1}		// Save
	MOV	R2, #0		// R2 = 0 (Quotient)
	MOV	R3, #1		// R3 = 1 (Accumulator)

div_loop_1:
	CMP	R1, R0		// n ? d
	MOVLS	R1, R1, LSL #1	// d *= 2
	MOVLS	R3, R3, LSL #1	// R3 *= 2
	BLS	div_loop_1	// (Loop)

div_loop_2:
	CMP	R0, R1		// d ? n
	SUBCS	R0, R0, R1	// n -= d
	ADDCS	R2, R2, R3	// R2 += R3
	MOVS	R3, R3, LSR #1	// R3 /= 2
	MOVCC	R1, R1, LSR #1	// d /= 2
	BCC	div_loop_2	// (Loop)

end_divide:
	POP	{R0-R1}		// Fetch
	MUL	R1, R1, R2	// R1 = d * Quotient
	SUB	R1, R0, R1	// R1 = Remainder
	MOV	R0, R2		// R0 = Quotient
	MOV	PC, LR

	/* (No parameters) */
done:
	LDR	R0, =fbp	// R0 -> fbp
	LDR	R1, =SCREENSIZE	// R1 -> screen size
	LDR	R1, [R1]	// R1 = screen size
	BL	munmap		// Parameters: R0--R1
	LDR	R0, =FB_FILED	// R0 -> FB_FILED
	LDR	R0, [R0]	// R0 = FB_FILED
	BL	close		// Parameters: R0
	LDR	R0, =UP_FILED	// R0 -> UP_FILED
	LDR	R0, [R0]	// R0 = UP_FILED
	BL	close		// Parameters: R0
	LDR	R0, =DOWN_FILED	// R0 -> DOWN_FILED
	LDR	R0, [R0]	// R0 = DOWN_FILED
	BL	close		// Parameters: R0
	LDR	R0, =LEFT_FILED	// R0 -> LEFT_FILED
	LDR	R0, [R0]	// R0 = LEFT_FILED
	BL	close		// Parameters: R0
	LDR	R0, =RIGHT_FILED  // R0 -> RIGHT_FILED
	LDR	R0, [R0]	// R0 = RIGHT_FILED
	BL	close		// Parameters: R0
	LDR	R0, =B_FILED	// R0 -> B_FILED
	LDR	R0, [R0]	// R0 = B_FILED
	BL	close		// Parameters: R0
	LDR	R0, =A_FILED	// R0 -> A_FILED
	LDR	R0, [R0]	// R0 = A_FILED
	BL	close		// Parameters: R0
	LDR	R0, =NUM_9_FILED  // R0 -> NUM_9_FILED
	LDR	R0, [R0]	// R0 = NUM_9_FILED
	BL	close		// Parameters: R0
	LDR	R0, =NUM_8_FILED  // R0 -> NUM_8_FILED
	LDR	R0, [R0]	// R0 = NUM_8_FILED
	BL	close		// Parameters: R0
	LDR	R0, =NUM_7_FILED  // R0 -> NUM_7_FILED
	LDR	R0, [R0]	// R0 = NUM_7_FILED
	BL	close		// Parameters: R0
	LDR	R0, =NUM_6_FILED  // R0 -> NUM_6_FILED
	LDR	R0, [R0]	// R0 = NUM_6_FILED
	BL	close		// Parameters: R0
	LDR	R0, =NUM_5_FILED  // R0 -> NUM_5_FILED
	LDR	R0, [R0]	// R0 = NUM_5_FILED
	BL	close		// Parameters: R0
	LDR	R0, =NUM_4_FILED  // R0 -> NUM_4_FILED
	LDR	R0, [R0]	// R0 = NUM_4_FILED
	BL	close		// Parameters: R0
	LDR	R0, =NUM_3_FILED  // R0 -> NUM_3_FILED
	LDR	R0, [R0]	// R0 = NUM_3_FILED
	BL	close		// Parameters: R0
	LDR	R0, =NUM_2_FILED  // R0 -> NUM_2_FILED
	LDR	R0, [R0]	// R0 = NUM_2_FILED
	BL	close		// Parameters: R0
	LDR	R0, =NUM_1_FILED  // R0 -> NUM_1_FILED
	LDR	R0, [R0]	// R0 = NUM_1_FILED
	BL	close		// Parameters: R0
	LDR	R0, =NUM_0_FILED  // R0 -> NUM_0_FILED
	LDR	R0, [R0]	// R0 = NUM_0_FILED
	BL	close		// Parameters: R0
	MOV	R0, #0		// R0 = 0 (return code)
	BLAL	exit		// Terminate the program

	.bss
	
BUFFER:
	.skip	0x7E9000

	.data
	
JOYSTICK:
	.word	0
	
FB_FILED:
	.word	0
POSCOLOR:
	.skip	12
SCREENSIZE:
	.word	0
LINELENGTH:
	.word	0
X_RES:
	.word	0
Y_RES:
	.word	0
	
OFFSET:
	.word	0
POS:
	.word	0
	.word	0
TEMP:
	.word	0
	.word	0
	.word	0

A_FILED:
	.word	0
B_FILED:
	.word	0
UP_FILED:
	.word	0
DOWN_FILED:
	.word	0
LEFT_FILED:
	.word	0
RIGHT_FILED:
	.word	0
NUM_9_FILED:
	.word	0
NUM_8_FILED:
	.word	0
NUM_7_FILED:
	.word	0
NUM_6_FILED:
	.word	0
NUM_5_FILED:
	.word	0
NUM_4_FILED:
	.word	0
NUM_3_FILED:
	.word	0
NUM_2_FILED:
	.word	0
NUM_1_FILED:
	.word	0
NUM_0_FILED:
	.word	0
	
/* Stack variables: +0 = size, +4 = location */

A_STACK:
	.word	0
	.word	0
B_STACK:
	.word	0
	.word	0
UP_STACK:
	.word	0
	.word	0
DOWN_STACK:
	.word	0
	.word	0
LEFT_STACK:
	.word	0
	.word	0
RIGHT_STACK:
	.word	0
	.word	0
NUM_9_STACK:
	.word	0
	.word	0
NUM_8_STACK:
	.word	0
	.word	0
NUM_7_STACK:
	.word	0
	.word	0
NUM_6_STACK:
	.word	0
	.word	0
NUM_5_STACK:
	.word	0
	.word	0
NUM_4_STACK:
	.word	0
	.word	0
NUM_3_STACK:
	.word	0
	.word	0
NUM_2_STACK:
	.word	0
	.word	0
NUM_1_STACK:
	.word	0
	.word	0
NUM_0_STACK:
	.word	0
	.word	0
	
COUNTER:
	.word	0
SEC:
	.word	0
SCORE:
	.word	-1
	
FRAMEBUF:
	.ascii	"/dev/fb0\000"
A_IMG:
	.ascii	"/home/pi/Desktop/a.bin\000"
B_IMG:
	.ascii	"/home/pi/Desktop/b.bin\000"
UP_IMG:
	.ascii	"/home/pi/Desktop/up.bin\000"
DOWN_IMG:
	.ascii	"/home/pi/Desktop/down.bin\000"
LEFT_IMG:
	.ascii	"/home/pi/Desktop/left.bin\000"
RIGHT_IMG:
	.ascii	"/home/pi/Desktop/right.bin\000"
NUM_9_IMG:
	.ascii	"/home/pi/Desktop/9.bin\000"
NUM_8_IMG:
	.ascii	"/home/pi/Desktop/8.bin\000"
NUM_7_IMG:
	.ascii	"/home/pi/Desktop/7.bin\000"
NUM_6_IMG:
	.ascii	"/home/pi/Desktop/6.bin\000"
NUM_5_IMG:
	.ascii	"/home/pi/Desktop/5.bin\000"
NUM_4_IMG:
	.ascii	"/home/pi/Desktop/4.bin\000"
NUM_3_IMG:
	.ascii	"/home/pi/Desktop/3.bin\000"
NUM_2_IMG:
	.ascii	"/home/pi/Desktop/2.bin\000"
NUM_1_IMG:
	.ascii	"/home/pi/Desktop/1.bin\000"
NUM_0_IMG:
	.ascii	"/home/pi/Desktop/0.bin\000"
