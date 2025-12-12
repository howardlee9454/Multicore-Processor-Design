org 0x000

li t0, 0x400
li t1, 1
sw t1, 0(t0) // I to M
lw t2, 0(t0) // Stay M
NOP //M to S
NOP 
NOP 
NOP 
lw t1, 0(t0) //Stay S
NOP 
NOP 
NOP 
NOP 
NOP //S to I

halt






org 0x200

li t0, 0x400
li t1, 2
NOP //I to I
NOP //Stay I
NOP 
NOP 
lw t2, 0(t0) //I to S
NOP //Stay S
NOP
NOP 
NOP 
NOP
sw t1, 0(t0) //S to M


halt
