org 0x0000
li sp, 0xFFFC
li t0, 0x1000
lw t1, 0(t0)
addi t0, t0, 8
lw t1, 0(t0)
halt
