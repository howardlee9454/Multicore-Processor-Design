#----------------------------------------------------------
# RISC-V Assembly
#----------------------------------------------------------
#--------------------------------------
    
    li x2, 0xFFFC  
    li x12, 0xFFFC
    addi t0, x0, 5
    addi t3, x0, 6
    addi t1, x0, 3

    push t1
    push t0
    push t3
    li x10, 0

start:
    pop t1
    pop t2
    li x11, 0
    beq t1, x0, done
    beq t2, x0, done
multiply:
    add x10, x10, t1
    addi x11, x11, 1
    beq x11, t2, done
    j multiply

start2:
    pop t1
    li x11, 1
    beq x11, t1, done
    beq t1, x0, done
multiply3:
    add x10, x10, x13
    addi x11, x11, 1
    beq x11, t1, done
    j multiply3

done:
    add x13, x10, x0
    bne x2, x12, start2
    push x10
    halt
