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
	.file	"main.c"
	.global	fbp
	.bss
	.align	2
	.type	fbp, %object
	.size	fbp, 4
fbp:
	.space	4
	.comm	vinfo,160,4
	.comm	finfo,68,4
	.text
	.align	2

	.global	put_pixel
	.syntax unified
	.arm
	.fpu vfp
	.type	put_pixel, %function
put_pixel:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	sub	sp, sp, #28
	str	r0, [fp, #-16]	// (fp - 16) = x
	str	r1, [fp, #-20]	// (fp - 20) = y
	str	r2, [fp, #-24]	// (fp - 24) = c
	ldr	r3, .L2		// needed for C compilation
	ldr	r3, [r3, #44]	// r3 = finfo.line_length
	ldr	r2, [fp, #-20]	// r2 = y
	mul	r2, r2, r3	// r2 = y * finfo.line_length
	ldr	r3, [fp, #-16]	// r3 = x
	add	r3, r2, r3	// r3 = x + (r2 = y * finfo.line_length)
	str	r3, [fp, #-8]
	ldr	r3, .L2+4
	ldr	r2, [r3]
	ldr	r3, [fp, #-8]
	add	r3, r2, r3	// fbp + pix_offset
	ldr	r2, [fp, #-24]	// r2 = c
	uxtb	r2, r2		// Extends r2 (c) to 32-bit value
	strb	r2, [r3]
	nop			// Why is this here? Padding?
	add	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
.L3:
	.align	2
.L2:
	.word	finfo
	.word	fbp
	.size	put_pixel, .-put_pixel
	.global	__aeabi_uidiv
	.align	2

	.global	draw
	.syntax unified
	.arm
	.fpu vfp
	.type	draw, %function
draw:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	mov	r3, #0
	str	r3, [fp, #-12]
	b	.L5
.L8:
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L6
.L7:
	ldr	r3, [fp, #-8]
	lsl	r3, r3, #4
	mov	r2, r3
	ldr	r3, .L9
	ldr	r3, [r3]
	mov	r1, r3
	mov	r0, r2
	bl	__aeabi_uidiv
	mov	r3, r0
	str	r3, [fp, #-16]
	ldr	r2, [fp, #-16]
	ldr	r1, [fp, #-12]
	ldr	r0, [fp, #-8]
	bl	put_pixel	// Parameters for `put_pixel` are r2, r1, and r0
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L6:
	ldr	r3, .L9
	ldr	r2, [r3]
	ldr	r3, [fp, #-8]
	cmp	r2, r3
	bhi	.L7
	ldr	r3, [fp, #-12]
	add	r3, r3, #1
	str	r3, [fp, #-12]
.L5:
	ldr	r3, .L9
	ldr	r3, [r3, #4]
	lsr	r2, r3, #1
	ldr	r3, [fp, #-12]
	cmp	r2, r3
	bhi	.L8
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
.L10:
	.align	2
.L9:
	.word	vinfo
	.size	draw, .-draw
	.section	.rodata
	.align	2
.LC0:
	.ascii	"/dev/fb0\000"
	.align	2
.LC1:
	.ascii	"Error: cannot open framebuffer device.\000"
	.align	2
.LC2:
	.ascii	"The framebuffer device was opened successfully.\000"
	.align	2
.LC3:
	.ascii	"Error reading variable information.\000"
	.align	2
.LC4:
	.ascii	"Original %dx%d, %dbpp\012\000"
	.align	2
.LC5:
	.ascii	"Error setting variable information.\000"
	.align	2
.LC6:
	.ascii	"Error reading fixed information.\000"
	.align	2
.LC7:
	.ascii	"Failed to mmap.\000"
	.align	2
.LC8:
	.ascii	"Error re-setting variable information.\000"
	.text
	.align	2

	.global	main
	.syntax unified
	.arm
	.fpu vfp
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 176
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #184
	str	r0, [fp, #-176]
	str	r1, [fp, #-180]
	mov	r3, #0
	str	r3, [fp, #-8]
	mov	r3, #0
	str	r3, [fp, #-12]
	mov	r1, #2		// O_RDWR; opcode for reading and writing = 2
	ldr	r0, .L21	// "dev/fb0"
	bl	open		// Parameters for `open` are r1 and r0
	str	r0, [fp, #-8]
	ldr	r3, [fp, #-8]
	cmp	r3, #0
	bne	.L12
	ldr	r0, .L21+4
	bl	puts
	mov	r3, #1
	b	.L20
.L12:
	ldr	r0, .L21+8
	bl	puts
	ldr	r2, .L21+12
	mov	r1, #17920
	ldr	r0, [fp, #-8]
	bl	ioctl
	mov	r3, r0
	cmp	r3, #0
	beq	.L14
	ldr	r0, .L21+16
	bl	puts
.L14:
	ldr	r3, .L21+12
	ldr	r1, [r3]
	ldr	r3, .L21+12
	ldr	r2, [r3, #4]
	ldr	r3, .L21+12
	ldr	r3, [r3, #24]
	ldr	r0, .L21+20
	bl	printf
	ldr	r2, .L21+12
	sub	r3, fp, #172
	mov	r1, r2
	mov	r2, #160
	mov	r0, r3
	bl	memcpy
	ldr	r3, .L21+12
	mov	r2, #8
	str	r2, [r3, #24]
	ldr	r2, .L21+12
	ldr	r1, .L21+24
	ldr	r0, [fp, #-8]
	bl	ioctl
	mov	r3, r0
	cmp	r3, #0
	beq	.L15
	ldr	r0, .L21+28
	bl	puts
.L15:
	ldr	r2, .L21+32
	ldr	r1, .L21+36
	ldr	r0, [fp, #-8]
	bl	ioctl
	mov	r3, r0
	cmp	r3, #0
	beq	.L16
	ldr	r0, .L21+40
	bl	puts
.L16:
	ldr	r3, .L21+12
	ldr	r3, [r3]
	ldr	r2, .L21+12
	ldr	r2, [r2, #4]
	mul	r3, r2, r3
	str	r3, [fp, #-12]
	ldr	r1, [fp, #-12]
	mov	r3, #0
	str	r3, [sp, #4]
	ldr	r3, [fp, #-8]
	str	r3, [sp]
	mov	r3, #1
	mov	r2, #3
	mov	r0, #0
	bl	mmap
	mov	r2, r0
	ldr	r3, .L21+44
	str	r2, [r3]
	ldr	r3, .L21+44
	ldr	r3, [r3]
	cmn	r3, #1
	bne	.L17
	ldr	r0, .L21+48
	bl	puts
	b	.L18
.L17:
	bl	draw
	mov	r0, #5
	bl	sleep
.L18:
	ldr	r3, .L21+44
	ldr	r3, [r3]
	ldr	r2, [fp, #-12]
	mov	r1, r2
	mov	r0, r3
	bl	munmap
	sub	r3, fp, #172
	mov	r2, r3
	ldr	r1, .L21+24
	ldr	r0, [fp, #-8]
	bl	ioctl
	mov	r3, r0
	cmp	r3, #0
	beq	.L19
	ldr	r0, .L21+52
	bl	puts
.L19:
	ldr	r0, [fp, #-8]
	bl	close
	mov	r3, #0
.L20:
	mov	r0, r3
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
.L22:
	.align	2
.L21:
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	vinfo
	.word	.LC3
	.word	.LC4
	.word	17921
	.word	.LC5
	.word	finfo
	.word	17922
	.word	.LC6
	.word	fbp
	.word	.LC7
	.word	.LC8
	.size	main, .-main
	.ident	"GCC: (Raspbian 6.3.0-18+rpi1) 6.3.0 20170516"
	.section	.note.GNU-stack,"",%progbits
