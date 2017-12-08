	.fpu neon

	.global	fbp
	.bss
	.align	2
	.type	fbp, %object
	.size	fbp, 4
fbp:
	.space	4
	
	.comm	vinfo,160,4
	.comm	finfo,68,4
	.comm	t_start,8,4
	.comm	t_end,8,4
	.comm	t_save,8,4

	.text

	.equ FLOOR, 700
	.EQU ACCEL, 0
	.equ GRAVITY, 1

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
	LSL	R1, R1, #2	// R1 = vinfo.xres * 4 = line length
	LDR	R2, =LINELENGTH	// R2 -> LINELENGTH
	STR	R1, [R2]	// LINELENGTH = line length
	LDR	R2, [R0, #4]	// R2 = vinfo.yres
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

open_image:
	LDR	R0, =IMAGEFILE	// R0 -> IMAGEFILE
	MOV	R1, #2		// R1 = 2 (Opcode for O_RDWR)
	BL	open		// Parameters: R0--R1
	LDR	R1, =IMG_FILED	// R1 -> IMG_FILED
	STR	R0, [R1]	// IMG_FILED = open("/home/pi/Desktop/image.bin\000")
	MOV	R4, #0		// R4 = 0 (track size of stack)

image_loop:
	LDR	R0, =IMG_FILED	// R0 -> IMG_FILED
	LDR	R0, [R0]	// R0 = IMG_FILED
	LDR	R1, =POSCOLOR	// R1 -> POSCOLOR
	MOV	R2, #12		// R2 = 12 (bytes to read)
	BL	read		// Parameters: R0--R2
	CMP	R0, #0		// R0 ? 0
	BEQ	set_stack	// (Break)
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
	BAL	image_loop	// (Loop)

set_stack:
	LDR	R0, =STACKSIZE	// R0 -> STACKSIZE
	STR	R4, [R0]	// STACKSIZE = R4
	MOV	FP, SP		// Set dynamic link

start_coords:
	LDR	R0, =DELTA	// R0 -> DELTA
	LDR	R1, =LINELENGTH	// R1 -> LINELENGTH
	LDR	R1, [R1]	// R1 = LINELENGTH
	LDRD	R2, [R0]	// R2,R3 = dx,dy
	LSL	R2, R2, #2	// R2 = dx * 4
	MUL	R3, R3, R1	// R3 = dy * LINELENGTH
	ADD	R2, R2, R3	// R2 = (dx * 4) + (dy * LINELENGTH) (dOffset)
	LDR	R0, =OFFSET	// R0 -> OFFSET
	STR	R2, [R0]	// OFFSET = R2
	LDR	R0, =STACKSIZE	// R0 -> STACKSIZE
	LDR	R0, [R0]	// @ R0 = STACKSIZE
	LDR	R1, =OFFSET	// R1 -> OFFSET
	LDR	R1, [r1]	// @ R1 = OFFSET
	
coords_loop:
	SUBS	R0, #8		// R0 -= 8
	BMI	end_coords	// (Break)
	LDR	R2, [FP, R0]	// R2 = offset
	ADD	R2, R2, R1	// R2 = offset + OFFSET
	STR	R2, [FP, R0]	// offset = R2
	BAL	coords_loop	// (Loop)

end_coords:
	LDR	R0, =DELTA	// R0 -> DELTA
	LDR	R1, =POS	// R1 -> POS
	LDRD	R2, [R0]	// R2,R3 = dx,dy
	STRD	R2, [R1]	// POS = dx,dy

init_delta:
	LDR	R0, =DELTA	// R0 -> DELTA
	LDR	R2, =20		// R2 = dx
	LDR	R3, =-30	// R3 = dy
	STRD	R2, [R0]	// DELTA = dx,dy

/* LOOP STARTS HERE */

big_loop:
	LDR	R0, =2		// R0 = 2 (Opcode for CLOCK_MONOTONIC)
	LDR	R1, =t_start	// R1 -> t_start
	BL	clock_gettime	// Parameters: R0--R1
	LDR	R0, =POS	// R0 -> POS
	LDR	R1, [R0, #4]	// R1 = POS.y
	CMP	R1, #FLOOR	// POS.y ? FLOOR
	BGE	done		// (Break)
	LDR	R0, =DELTA	// R0 -> DELTA
	LDR	R1, [R0, #4]	// R1 = dy
	ADD	R1, #GRAVITY	// dy += GRAVITY
	STR	R1, [R0, #4]	// DELTA+4 = new dy

prep_check:
	LDR	R0, =DELTA	// R0 -> DELTA
	LDR	R1, [R0, #0]	// @ R1 = dx
	LDR	R2, [R0, #4]	// @ R2 = dy
	LDR	R0, =IMG_DIMS	// R0 -> IMG_DIMES
	LDR	R3, [R0, #0]	// @ R3 = width
	LDR	R4, [R0, #4]	// @ R4 = height
	LDR	R0, =POS	// R0 -> POS
	LDR	R5, [R0, #0]	// @ R5 = x
	LDR	R6, [R0, #4] 	// @ R6 = y
	LDR	R7, =COLLISION	// @ R7 -> COLLISION

check_dx:
	CMP	R1, #0		// dx ? 0
	BEQ	check_dy	// dx == 0
	BGT	right_loop	// dx > 0
	BLT	left_loop	// dx < 0

right_loop:
	NOP

left_loop:
	NOP

check_dy:
	CMP	R2, #0		// dy ? 0
	BEQ	adj_coords	// dy == 0
	BLT	up_loop		// dy < 0
	BGT	down_loop	// dy > 0

up_loop:
	NOP

down_loop:
	NOP

adj_coords:
	LDR	R0, =DELTA	// R0 -> DELTA
	LDR	R1, =LINELENGTH	// R1 -> LINELENGTH
	LDR	R1, [R1]	// R1 = LINELENGTH
	LDRD	R2, [R0]	// R2,R3 = dx,dy
	LDR	R0, =POS	// R0 -> POS
	LDRD	R4, [R0]	// R4,R5 = x,y
	ADD	R4, R2		// R4 = x + dx
	ADD	R5, R3		// R5 = y + dy
	STRD	R4, [R0]	// POS = new x,y
	LSL	R2, R2, #2	// R2 = dx * 4
	MUL	R3, R3, R1	// R3 = dy * LINELENGTH
	ADD	R2, R2, R3	// R2 = (dx * 4) + (dy * LINELENGTH) (dOffset)
	LDR	R0, =OFFSET	// R0 -> OFFSET
	STR	R2, [R0]	// OFFSET = R2

prep_stack:
	LDR	R0, =STACKSIZE	// R0 -> STACKSIZE
	LDR	R0, [R0]	// @ R0 = STACKSIZE
	LDR	R1, =OFFSET	// R1 -> OFFSET
	LDR	R1, [r1]	// @ R1 = OFFSET
	LDR	R2, =BUFFER	// @ R2 -> BUFFER
	LDR	R3, =0		// @ R3 = 0

stack_loop:
	SUBS	R0, #8		// R0 -= 8
	BMI	prep_buffer	// (Break)
	LDRD	R4, [FP, R0]	// R4,R5 = offset,color
	STR	R3, [R2, R4]	// BUFFER[offset] = 0
	ADD	R4, R4, R1	// R4 = offset + OFFSET
	STRD	R4, [FP, R0]	// offset,color = R4,R5
	STR	R5, [R2, R4]	// BUFFER[offset] = color
	BAL	stack_loop	// (Loop)

prep_buffer:
	LDR	R0, =STACKSIZE	// R0 -> STACKSIZE
	LDR	R0, [R0]	// @ R0 = STACKSIZE
	LDR	R1, =BUFFER	// @ R1 = BUFFER

buffer_loop:
	SUBS	R0, #8		// R0 -= 8
	BMI	set_screen	// (Break)
	LDRD	R2, [FP, R0]	// R2,R3 = offset,color
	STR	R3, [R1, R2]	// BUFFER[offset] = color
	BAL	buffer_loop	// (Loop)
	
set_screen:
	LDR	R0, =BUFFER	// R0 -> BUFFER
	LDR	R1, =fbp	// R1 -> fbp
	LDR	R1, [R1]	// R1 = fbp
	LDR	R2, =SCREENSIZE	// R2 -> SCREENSIZE
	LDR	R2, [R2]	// R2 = SCREENSIZE
	BL	put_screen	// Parameters: R0--R2

wait_here:
	LDR	R0, =2		// R0 = 2 (Opcode for CLOCK_MONOTONIC)
	LDR	R1, =t_end	// R1 -> t_end
	BL	clock_gettime	// Parameters: R0--R1
	LDR	R0, =t_end	// R0 -> t_end
	LDR	R0, [R0, #4]	// R0 = t_end.nanoseconds
	LDR	R1, =t_start	// R1 -> t_start
	LDR	R1, [R1, #4]	// R1 = t_start.nanoseconds
	SUB	R0, R0, R1	// R0 = elapsed
	LDR	R2, =FPS_NANOS	// R2 -> FPS_NANOS
	LDR	R2, [R2]	// R2 = FPS_NANOS
	SUB	R1, R2, R0	// R1 = FPS_NANOS - elapsed
	LDR	R0, =t_save	// R0 -> t_save
	STR	R1, [R0, #4]	// t_save.nsec = R1
	LDR	R1, =0		// R1 = 0
	BL	nanosleep	// Parameters: R0--R1

big_reset:
	BAL	big_loop	// (LOOP)

done:
	LDR	R0, =fbp	// R0 -> fbp
	LDR	R1, =SCREENSIZE	// R1 -> screen size
	LDR	R1, [R1]	// R1 = screen size
	BL	munmap		// Parameters: R0--R1
	LDR	R0, =FB_FILED	// R0 -> FB_FILED
	LDR	R0, [R0]	// R0 = FB_FILED
	BL	close		// Parameters: R0
	LDR	R0, =IMG_FILED	// R0 -> IMG_FILED
	LDR	R0, [R0]	// R0 = IMG_FILED
	BL	close		// Parameters: R0
	LDR	R0, =COLL_FILED	// R0 -> COLL_FILED
	LDR	R0, [R0]	// R0 = COLL_FILED
	BL	close		// Parameters: R0
	MOV	R0, #0		// R0 = 0 (return code)
	BLAL	exit		// Terminate the program

	.bss
BUFFER:
	.skip	0x7E9000
COLLISION:
	.skip	0x7E9000

	.data
FPS_NANOS:
	.word	16666660
FB_FILED:
	.word	0
IMG_FILED:
	.word	0
COLL_FILED:
	.word	0
POSCOLOR:
	.skip	12
SIZE:
	.skip	4
SCREENSIZE:
	.word	0
LINELENGTH:
	.word	0
STACKSIZE:
	.word	0
DELTA:
	.word	0
	.word	0
POS:
	.word	200
	.word	FLOOR-1
OFFSET:
	.word	0
COLLPOS:
	.word	400
	.word	400
IMG_DIMS:
	.word	256
	.word	256
	
FRAMEBUF:
	.ascii	"/dev/fb0\000"
IMAGEFILE:
	.ascii	"/home/pi/Desktop/image.bin\000"
COLLFILE:
	.ascii	"/home/pi/Desktop/collider.bin\000"

/* NOTES
	*/
