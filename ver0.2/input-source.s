	.arch armv6
	.eabi_attribute 28, 1
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 6
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.file	"input.c"
	.section	.rodata
	.align	2
.LC0:
	.ascii	"Hello, World!\000"
	.align	2
.LC1:
	.ascii	"Cannot open display\012\000"
	.text
	.align	2
	.global	main
	.syntax unified
	.arm
	.fpu vfp
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 112
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, fp, lr}
	add	fp, sp, #8
	sub	sp, sp, #140
	ldr	r3, .L10
	str	r3, [fp, #-16]
	mov	r0, #0		// display = XOpenDisplay(NULL);
	bl	XOpenDisplay
	str	r0, [fp, #-20]
	ldr	r3, [fp, #-20]
	cmp	r3, #0		// if (display == NULL);
	bne	.L2
	ldr	r3, .L10+4
	ldr	r3, [r3]
	mov	r2, #20
	mov	r1, #1
	ldr	r0, .L10+8
	bl	fwrite
	mov	r0, #1
	bl	exit
.L2:
	ldr	r3, [fp, #-20]
	ldr	r3, [r3, #132]
	str	r3, [fp, #-24]
	ldr	r3, [fp, #-20]
	ldr	r1, [r3, #140]
	ldr	r2, [fp, #-24]
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	lsl	r3, r3, #4
	add	r3, r1, r3
	ldr	ip, [r3, #8]
	ldr	r3, [fp, #-20]
	ldr	r1, [r3, #140]
	ldr	r2, [fp, #-24]
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	lsl	r3, r3, #4
	add	r3, r1, r3
	ldr	r1, [r3, #56]
	ldr	r3, [fp, #-20]
	ldr	r0, [r3, #140]
	ldr	r2, [fp, #-24]
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	lsl	r3, r3, #4
	add	r3, r0, r3
	ldr	r3, [r3, #52]
	str	r3, [sp, #16]
	str	r1, [sp, #12]
	mov	r3, #1
	str	r3, [sp, #8]
	mov	r3, #200
	str	r3, [sp, #4]
	mov	r3, #200
	str	r3, [sp]
	mov	r3, #10
	mov	r2, #10
	mov	r1, ip
	ldr	r0, [fp, #-20]
	bl	XCreateSimpleWindow
	str	r0, [fp, #-28]
	ldr	r2, .L10+12
	ldr	r1, [fp, #-28]
	ldr	r0, [fp, #-20]
	bl	XSelectInput
	ldr	r1, [fp, #-28]
	ldr	r0, [fp, #-20]
	bl	XMapWindow
.L6:
	sub	r3, fp, #124
	mov	r1, r3
	ldr	r0, [fp, #-20]
	bl	XNextEvent
	ldr	r3, [fp, #-124]
	cmp	r3, #12
	bne	.L3
	ldr	r3, [fp, #-20]
	ldr	r1, [r3, #140]
	ldr	r2, [fp, #-24]
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	lsl	r3, r3, #4
	add	r3, r1, r3
	ldr	r2, [r3, #44]
	mov	r3, #10
	str	r3, [sp, #8]
	mov	r3, #10
	str	r3, [sp, #4]
	mov	r3, #20
	str	r3, [sp]
	mov	r3, #20
	ldr	r1, [fp, #-28]
	ldr	r0, [fp, #-20]
	bl	XFillRectangle
	ldr	r3, [fp, #-20]
	ldr	r1, [r3, #140]
	ldr	r2, [fp, #-24]
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	lsl	r3, r3, #4
	add	r3, r1, r3
	ldr	r4, [r3, #44]
	ldr	r0, [fp, #-16]
	bl	strlen
	mov	r3, r0
	str	r3, [sp, #8]
	ldr	r3, [fp, #-16]
	str	r3, [sp, #4]
	mov	r3, #50
	str	r3, [sp]
	mov	r3, #50
	mov	r2, r4
	ldr	r1, [fp, #-28]
	ldr	r0, [fp, #-20]
	bl	XDrawString
.L3:
	ldr	r3, [fp, #-124]
	cmp	r3, #2
	beq	.L9
	b	.L6
.L9:
	nop
	ldr	r0, [fp, #-20]
	bl	XCloseDisplay
	mov	r3, #0
	mov	r0, r3
	sub	sp, fp, #8
	@ sp needed
	pop	{r4, fp, pc}
.L11:
	.align	2
.L10:
	.word	.LC0
	.word	stderr
	.word	.LC1
	.word	32769
	.size	main, .-main
	.ident	"GCC: (Raspbian 6.3.0-18+rpi1) 6.3.0 20170516"
	.section	.note.GNU-stack,"",%progbits
