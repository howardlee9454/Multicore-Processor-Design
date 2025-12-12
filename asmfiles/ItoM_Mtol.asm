org 0x000

li t0, 0x400
li t1, 1
sw t1, 0(t0) // I to M
NOP //M to I
NOP
NOP
NOP
NOP


halt







org 0x200

li t0, 0x400
li t1, 2
NOP //I to I
NOP
NOP
NOP
NOP
NOP
sw t1, 0(t0)//I to M


halt
