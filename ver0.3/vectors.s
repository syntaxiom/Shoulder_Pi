.global _start
_start:
    mov sp,#0x8000
    bl notmain
hang: b hang

.global PUT32
PUT32:
    str r1,[r0]
    bx lr

.global GET32
GET32:
    ldr r0,[r0]
    bx lr

.global dummy
dummy:
    bx lr