	.data
/* Dimensions and color */
.equ WIDTH,		1920
.equ HEIGHT,	1080
.equ BIT_DEPTH,	32

/* Framebuffer structure and info */
.align 4
Framebuffer:
	.int 640    // +0x00: Physical width
	.int 480    // +0x04: Physical height
	.int 640    // +0x08: Virtual width
	.int 480    // +0x0C: Virtual height
	.int 0      // +0x10: Pitch
	.int 32     // +0x14: Bit depth
	.int 0      // +0x18: X
	.int 0      // +0x1C: Y
	.int 0      // +0x20: GPU Address
	.int 0      // +0x24: GPU Size
.align 2

	.text
	.global FramebufferSetup
FramebufferSetup:
	STMFD	SP!, {LR}

	/* Request framebuffer config */
	LDR		R0, =0x1
	LDR		R1, =Framebuffer	// R1 points to Framebuffer
	ADD		R1, R1, #0x40000000	// Special GPU signal
	LDR		R2, =WIDTH			// Get WIDTH before storing it
	STR		R2, [R1, #0x00]
	STR		R2, [R1, #0x08]
	LDR		R2, =HEIGHT			// Get HEIGHT before storing it
	STR		R2,	[R1, #0x04]
	STR		R2, [R1, #0x0C]
	LDR		R2, =BIT_DEPTH		// Get BIT_DEPTH before storing it
	STR		R2, [R1, #0x14]
	BL		MailboxWrite
	BL		MailboxRead

	LDMFD	SP!, {PC}
