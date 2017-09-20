	.global _start
_start:
	MOV		R0, #42

_exit:
	MOV		R0, #0
	MOV		R7, #1
	SWI		0
