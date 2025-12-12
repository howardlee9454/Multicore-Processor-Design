#----------------------------------------------------------
# RISC-V Assembly
#----------------------------------------------------------
#--------------------------------------

    li x2, 0xFFFC  
    addi t0, x0, 5
    addi t3, x0, 6

    push t0
    push t3

    pop t1
    pop t2

    li x10, 0
    li x11, 0
    beq t1, x0, done
    beq t2, x0, done

multiply:
    add x10, x10, t1
    addi x11, x11, 1
    beq x11, t2, done
    j multiply
done:
    push x10
    halt

    
