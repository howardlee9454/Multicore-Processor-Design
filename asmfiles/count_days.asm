#----------------------------------------------------------
# RISC-V Assembly
#----------------------------------------------------------
#--------------------------------------


li x2, 0xFFFC  
    addi t0, x0, 3
    addi t2, x0, 9
    addi t3, x0, 2025

    push t0 # day 
    push t2 # month
    push t3 # year

    pop t0
    pop t2
    pop t1

    addi t2, t2, -1
    addi t0, t0, -2000

initialize:
    li x10, 0 
    li x11, 0
    li t3, 365
    beq t0, x0, next
multiply:
    add x10, x10, t0
    addi x11, x11, 1
    beq x11, t3, next
    j multiply
next:
    add t1, t1, x10
    li x10, 0 
    li x11, 0
    li t3, 30
    beq t2, x0, done
multiply2:
    add x10, x10, t2
    addi x11, x11, 1
    beq x11, t3, done
    j multiply2
done:
    add t1, t1, x10
    push t1
    halt
