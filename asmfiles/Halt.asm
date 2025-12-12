#----------------------------------------------------------
# RISC-V Assembly
#----------------------------------------------------------
#--------------------------------------

    li x2, 0xFFFC  
    addi t0, x0, 6
    addi t3, x0, 6

    halt
    # all values moving forward should not be on stack 
    li x2, 0xFFFC  
    addi t0, x0, 6
    addi t3, x0, 6
