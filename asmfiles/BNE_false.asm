#----------------------------------------------------------
# RISC-V Assembly
#----------------------------------------------------------
#--------------------------------------

    li x2, 0xFFFC  
    addi t0, x0, 6
    addi t3, x0, 6

    bne t0, t3, done
    addi t1, x0, 1
    push t1 # push this to stack
    halt

done:
    push t0
    halt
