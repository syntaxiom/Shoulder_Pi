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
	.file	"game.c"
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
	str	r0, [fp, #-16]
	str	r1, [fp, #-20]
	str	r2, [fp, #-24]
	ldr	r3, .L2
	ldr	r3, [r3, #44]
	ldr	r2, [fp, #-20]
	mul	r2, r2, r3
	ldr	r3, [fp, #-16]
	add	r3, r2, r3
	str	r3, [fp, #-8]
	ldr	r3, .L2+4
	ldr	r2, [r3]
	ldr	r3, [fp, #-8]
	add	r3, r2, r3
	ldr	r2, [fp, #-24]
	uxtb	r2, r2
	strb	r2, [r3]
	nop
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
	str	r0, [fp, #-176]
	str	r1, [fp, #-180]
	mov	r3, #0
	str	r3, [fp, #-8]
	mov	r3, #0
	str	r3, [fp, #-12]
	mov	r1, #2
	ldr	r0, .L6
	bl	open
	str	r0, [fp, #-8]
	ldr	r2, .L6+4
	mov	r1, #17920
	ldr	r0, [fp, #-8]
	bl	ioctl
	ldr	r2, .L6+4
	sub	r3, fp, #172
	mov	r1, r2
	mov	r2, #160
	mov	r0, r3
	bl	memcpy
	ldr	r3, .L6+4
	mov	r2, #8
	str	r2, [r3, #24]
	ldr	r2, .L6+4
	ldr	r1, .L6+8
	ldr	r0, [fp, #-8]
	bl	ioctl
	ldr	r2, .L6+12
	ldr	r1, .L6+16
	ldr	r0, [fp, #-8]
	bl	ioctl
	ldr	r3, .L6+4
	ldr	r3, [r3]
	ldr	r2, .L6+4
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
	ldr	r3, .L6+20
	str	r2, [r3]
	ldr	r3, .L6+4
	ldr	r3, [r3]
	lsr	r3, r3, #1
	mov	r0, r3
	ldr	r3, .L6+4
	ldr	r3, [r3, #4]
	lsr	r3, r3, #1
	mov	r2, #5
	mov	r1, r3
	bl	put_pixel
	mov	r0, #5
	bl	sleep
	ldr	r3, .L6+20
	ldr	r3, [r3]
	ldr	r2, [fp, #-12]
	mov	r1, r2
	mov	r0, r3
	bl	munmap
	sub	r3, fp, #172
	mov	r2, r3
	ldr	r1, .L6+8
	ldr	r0, [fp, #-8]
	bl	ioctl
	ldr	r0, [fp, #-8]
	bl	close
	mov	r3, #0
	mov	r0, r3
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
.L7:
	.align	2
.L6:
	.word	.LC0
	.word	vinfo
	.word	17921
	.word	finfo
	.word	17922
	.word	fbp
	.size	main, .-main
	.ident	"GCC: (Raspbian 6.3.0-18+rpi1) 6.3.0 20170516"
	.section	.note.GNU-stack,"",%progbits
