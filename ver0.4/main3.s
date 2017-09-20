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
	.file	"main3.c"

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
	ldr	r3, .L2		// r3 = finfo
	ldr	r3, [r3, #44]	// r3 = finfo.line_length
	ldr	r2, [fp, #-20]	// r2 = y
	mul	r2, r2, r3	// r2 = y * finfo.line_length
	ldr	r3, [fp, #-16]	// r3 = x
	add	r3, r2, r3	// r3 = x + (r2 = y * finfo.line_length)
	str	r3, [fp, #-8]	// fp[-8] = pix_offset
	ldr	r3, .L2+4	// r3 = fbp
	ldr	r2, [r3]	// r2 = r3
	ldr	r3, [fp, #-8]	// r3 = pix_offset
	add	r3, r2, r3	// fbp + pix_offset
	ldr	r2, [fp, #-24]	// Load r2 into c
	uxtb	r2, r2		// Extend r2 to 32-bit
	strb	r2, [r3]	// c = fbp[pix_offset]
	nop			// Padding, I guess?
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
	ldr	r2, [r3, #4]
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
	str	r0, [fp, #-176]	// (fp - 176) = fbfd
	str	r1, [fp, #-180]	// (fp - 180) = screensize
	mov	r3, #0
	str	r3, [fp, #-8]	// (fp - 8) = r3 = #0
	mov	r3, #0		// Redundant?
	str	r3, [fp, #-12]	// (fp - 12) = r3 = #0
	mov	r1, #2		// Opcode for reading/writing is 2
	ldr	r0, .L13	// r0 = .L13+0 = .LC0 = "/dev/fb0"
	bl	open		// syscall 5
	str	r0, [fp, #-8]	// (fp - 8) = r0 = open("/dev/fb0")
	ldr	r2, .L13+4	// r3 = .L13+4 = vinfo
	mov	r1, #17920
	ldr	r0, [fp, #-8]	// r0 = (fp - 8) = open("/dev/fb0") (Redundant?)
	bl	ioctl		// syscall 54
	ldr	r2, .L13+4	// r2 = .L13+4 = vinfo
	sub	r3, fp, #172
	mov	r1, r2
	mov	r2, #160
	mov	r0, r3
	bl	memcpy		// syscall ???
	ldr	r3, .L13+4	// r3 = .L13+4 = vinfo
	mov	r2, #8
	str	r2, [r3, #24]
	ldr	r2, .L13+4	// r2 = .L13+4 = vinfo
	ldr	r1, .L13+8	// r1 = .L13+8 = 17921
	ldr	r0, [fp, #-8]
	bl	ioctl		// syscall 54
	ldr	r2, .L13+12	// r2 = .L13+12 = finfo
	ldr	r1, .L13+16	// r1 = .L13+16 = 17922
	ldr	r0, [fp, #-8]
	bl	ioctl		// syscall 54
	ldr	r3, .L13+4	// r3 = .L13+4 = vinfo
	ldr	r3, [r3]	// Not sure why this is here
	ldr	r2, .L13+4	// r2 = .L13+4 = vinfo
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
	bl	mmap		// syscall 90
	mov	r2, r0
	ldr	r3, .L13+20	// r3 = .L13+20 = fbp
	str	r2, [r3]	// Redundant?
	bl	draw
	mov	r0, #5
	bl	sleep		// syscall 162?
	ldr	r3, .L13+20	// r3 = .L13+20 = fbp
	ldr	r3, [r3]
	ldr	r2, [fp, #-12]
	mov	r1, r2
	mov	r0, r3
	bl	munmap		// syscall 91
	sub	r3, fp, #172
	mov	r2, r3
	ldr	r1, .L13+8	// r1 = .L13+8 = 17921
	ldr	r0, [fp, #-8]
	bl	ioctl
	ldr	r0, [fp, #-8]
	bl	close		// syscall 6
	mov	r3, #0
	mov	r0, r3		// Could just `mov r0, #0` and delete above line
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
.L14:
	.align	2
.L13:
	.word	.LC0
	.word	vinfo
	.word	17921
	.word	finfo
	.word	17922
	.word	fbp
	.size	main, .-main
	.ident	"GCC: (Raspbian 6.3.0-18+rpi1) 6.3.0 20170516"
	.section	.note.GNU-stack,"",%progbits
