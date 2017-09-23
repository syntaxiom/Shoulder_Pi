	.global _start
_start:
	MOV	R0, #65

_exit:
	MOV	R7, #1
	SWI	0
