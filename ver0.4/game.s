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
	str	fp, [sp, #-4]!	// [sp-4] = fp; fp is modified
	add	fp, sp, #0	// fp = sp + 0
	sub	sp, sp, #28	// sp = sp - 28
	str	r0, [fp, #-16]	// [fp-16] = r0 = x
	str	r1, [fp, #-20]	// [fp-20] = r1 = y
	str	r2, [fp, #-24]	// [fp-24] = r2 = c
	ldr	r3, .L2		// r3 = [.L2+0] = finfo
	ldr	r3, [r3, #44]	// r3 = [r3+44] = finfo.line_length
	ldr	r2, [fp, #-20]	// r2 = [fp-20] = y
	mul	r2, r2, r3	// r2 = r2 * r3 = y * finfo.line_length
	ldr	r3, [fp, #-16]	// r3 = [fp-16] = x
	add	r3, r2, r3	// r3 = r2 + r3 = y * finfo.line_length + x
	str	r3, [fp, #-8]	// [fp-8] = r3 = y * finfo.line_length + x = pix_offset
	ldr	r3, .L2+4	// r3 = [.L2+4] = fbp
	ldr	r2, [r3]	// r2 = r3 = fbp
	ldr	r3, [fp, #-8]	// r3 = [fp-8] = pix_offset
	add	r3, r2, r3	// r3 = r2 + r3 = fbp + pix_offset
	ldr	r2, [fp, #-24]	// r2 = [fp-24] = c
	uxtb	r2, r2		// Extend r2 byte to unsigned 32-bit number
	strb	r2, [r3]	// r3 = fbp = r2 = c
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
	add	fp, sp, #4	// fp = sp + 4
	sub	sp, sp, #184	// sp = sp - 184
	str	r0, [fp, #-176]	// [fp-176] = r0 = 0 (fpfd?)
	str	r1, [fp, #-180]	// [fp-180] = r0 = 0 (orig_vinfo?)
	mov	r3, #0		// r3 = 0 (screensize?)
	str	r3, [fp, #-8]	// [fp-8] = r3 = 0
	mov	r3, #0		// (Redundant)
	str	r3, [fp, #-12]	// [fp-12] = r3 = 0
	mov	r1, #2		// r1 = 2 (Opcode for reading & writing = 2)
	ldr	r0, .L6		// r0 = [.L6+0] = [.LC0+0] = "/dev/fb0\000"
	bl	open		// syscall 5
	str	r0, [fp, #-8]	// [fp-8] = r0 = "/dev/fb0\000"
	ldr	r2, .L6+4	// r2 = [.L6+4] = vinfo
	mov	r1, #17920	// r1 = 17920 (Opcode for FBIOGET_VSCREENINFO)
	ldr	r0, [fp, #-8]	// r0 = [fp-8] = "/dev/fb0\000"
	bl	ioctl		// syscall 54
	ldr	r2, .L6+4	// (Redundant)
	sub	r3, fp, #172	// r3 = [fp = -8] - 172 = [fp-180] = orig_vinfo
	mov	r1, r2		// r1 = r2 = [.L6+4] = vinfo
	mov	r2, #160	// r2 = 160 (size of fb_var_screeninfo in bytes)
	mov	r0, r3		// r0 = r3 = [fp-180] = orig_vinfo
	bl	memcpy		// syscall ??? (create manual memcpy)
	ldr	r3, .L6+4	// r3 = [.L6+4] = vinfo
	mov	r2, #8		// r2 = 8
	str	r2, [r3, #24]	// [r3+24] = vinfo.bits_per_pixel = r2 = 8
	ldr	r2, .L6+4	// r2 = [.L6+4] = vinfo
	ldr	r1, .L6+8	// r1 = [.L6+8] = 17921 (Opcode for FBIOPUT_VSCREENINFO)
	ldr	r0, [fp, #-8]	// r0 = [fp-8] = "/dev/fb0\000"
	bl	ioctl		// syscall 54
	ldr	r2, .L6+12	// r2 = [.L6+12] = finfo
	ldr	r1, .L6+16	// r1 = [.L6+16] = 17922 (Opcode for FBIOGET_FSCREENINFO)
	ldr	r0, [fp, #-8]	// (Redundant)
	bl	ioctl		// syscall 54
	ldr	r3, .L6+4	// r3 = [.L6+4] = vinfo
	ldr	r3, [r3]	// r3 = vinfo.xres
	ldr	r2, .L6+4	// r2 = [.L6+4] = vinfo
	ldr	r2, [r2, #4]	// r2 = vinfo.yres
	mul	r3, r2, r3	// r3 = r2 * r3 = vinfo.xres * vinfo.yres = screensize
	str	r3, [fp, #-12]	// [fp-12] = r3 = screensize
	ldr	r1, [fp, #-12]	// r1 = [fp-12] = screensize
	mov	r3, #0		// r3 = 0
	str	r3, [sp, #4]	// [sp+4] = r3 = 0
	ldr	r3, [fp, #-8]	// r3 = [fp-8] = "/dev/fb0\000"
	str	r3, [sp]	// [sp+0] = r3 = "/dev/fb0\000"
	mov	r3, #1		// r3 = 1 (Opcode for MAP_SHARED)
	mov	r2, #3		// r2 = 3 (Opcode for PROT_READ | PROT_WRITE)
	mov	r0, #0		// r0 = 0
	bl	mmap		// syscall 90 (First 4 parameters = r0 -- r3; Last 2 parameters = [sp+0] -- [sp+4])
	mov	r2, r0		// r2 = r0 = (char*)mmap
	ldr	r3, .L6+20	// r3 = [.L6+20] = fbp
	str	r2, [r3]	// r3 = fbp = r2 = (char*)mmap
	ldr	r3, .L6+4	// r3 = [.L6+4] = vinfo
	ldr	r3, [r3]	// r3 = vinfo.xres
	lsr	r3, r3, #1	// r3 = r3 / 2 = vinfo.xres / 2
	mov	r0, r3		// r0 = r3 = vinfo.xres / 2
	ldr	r3, .L6+4	// r3 = [.L6+4] = vinfo
	ldr	r3, [r3, #4]	// r3 = vinfo.yres
	lsr	r3, r3, #1	// r3 = r3 / 2 = vinfo.yres / 2
	mov	r2, #5		// r2 = 5 (color between 0 -- 15, inclusive)
	mov	r1, r3		// r1 = r3 = vinfo.yres / 2
	bl	put_pixel	// Paramaters = r0 -- r2
	mov	r0, #5		// r0 = 5 (number of seconds)
	bl	sleep		// syscall 162?
	ldr	r3, .L6+20	// r3 = [.L6+20] = fbp
	ldr	r3, [r3]	// (Redundant)
	ldr	r2, [fp, #-12]	// r2 = [fp-12] = screensize
	mov	r1, r2		// r1 = r2 (Could just `ldr r1, .L6+20`)
	mov	r0, r3		// r0 = r3 (Could just `ldr r0, [fp, #-12]`)
	bl	munmap		// syscall 91
	sub	r3, fp, #172	// r3 = [fp = ...] - 172 = [fp-180] = orig_vinfo
	mov	r2, r3		// r2 = r3 (Could just `sub r2, fp, #172`)
	ldr	r1, .L6+8	// r1 = [.L6+8] = 17921 (Opcode for FPIOPUT_VSCREENINFO)
	ldr	r0, [fp, #-8]	// r0 = [fp-8] = "/dev/fb0\000"
	bl	ioctl		// syscall 54
	ldr	r0, [fp, #-8]	// (Redundant)
	bl	close		// syscall 6
	mov	r3, #0		// r3 = 0
	mov	r0, r3		// r0 = r3 = 0 (Could just 'mov r0, #0`)
	sub	sp, fp, #4	// sp = [fp-4]
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
