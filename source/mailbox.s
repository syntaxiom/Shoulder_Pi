	.data
/* Mailbox Ports (Addresses) */
.equ BASE,		0x2000B880
.equ READ,		0x2000B880
.equ POLL,		0x2000B890
.equ SENDER,	0x2000B894
.equ STATUS,	0x2000B898
.equ CONFIG,	0x2000B89C
.equ WRITE,		0x2000B8A0

	.text
	.global MailboxWrite
/* Writes data to the mailbox (send)
	R0 = Channel	(Input)
	R1 = Data		(Input) */
MailboxWrite:
	STMFD	SP!, {R1 - R4}	// Push R --R4 onto stack
	LDR		R2, =BASE		// R2 points to mailbox BASE address
	EOR		R4, R4, R4		// Nullify R4

WaitingToWrite:
	/* Timeout */
	ADD		R4, R4, #1
	TST		R4, #0x80000	// If b19 is 1, then MailboxWrite timed out
	BNE		DoneWriting

	/* Is it ready? */
	LDR		R3, [R2, #0x18]	// R3 points to mailbox STATUS address
	TST		R3, #0x80000000	// b31 must be 0 before proceeding
	BNE		WaitingToWrite

	/* Send message */
	ORR		R1, R0, R1		// Invert R1 with R0
	STR		R1, [R2, #0x20]	// Store R1 contents into mailbox WRITE address

DoneWriting:
	LDMFD	SP!, {R1 - R4}	// Pop R1--R4 off the stack
	MOV		PC, LR

	.global MailboxRead
/* Reads data from the mailbox (receives)
	R0 = Channel		(Input)
	R1 = Return data	(Clobber) */
MailboxRead:
	STMFD	SP!, {R2 - R4}	// Push R2--R4 onto stack
	LDR		R2, =BASE		// R2 points to mailbox BASE address
	EOR		R4, R4, R4		// Nullify R4

WaitingToRead:
	/* Timeout */
	ADD		R4, R4, #1
	TST		R4, #0x80000	// If b19 is 1, then MailboxRead timed out
	BNE		DoneReading

	/* Is it ready? */
	LDR		R3, [R2, #0x18]	// R3 points to mailbox STATUS address
	TST		R3, #0x40000000	// b30 must be 0 before proceeding
	BNE		WaitingToRead

	/* Receive message */
	LDR		R3, [R2, #0x00]	// R3 points to mailbox READ address (same as BASE address)

	/* Is the channel correct? */
	AND		R1, R3, #0x0F	// b0--b3 must be 0 before proceeding
	TEQ		R0, R1
	BNE		WaitingToRead

	/* Extract data */
	BIC		R1, R3, #0xF	// R1 = R3 AND NOT 0xF

DoneReading:
	LDMFD	SP!, {R2 - R4}
	MOV		PC, LR
