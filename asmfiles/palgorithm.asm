

#----------------------------------------------------------
# Core 1 Init
#----------------------------------------------------------
  org 0x0000    
  li      sp, 0xFFFC    # core 1 stack
  jal     mainc1        # core 1 main program
  halt

#----------------------------------------------------------
# Shared Lock Functions
#----------------------------------------------------------
# pass in an address to lock function in argument register 0
# returns when lock is available
lock:
acquire:
  lr.w    t0, (a0)              # load lock location
  bne     t0, zero, acquire     # wait on lock to be open
  li      t1, 1
  sc.w    t2, t1, (a0)
  bne     t2, zero, lock        # if sc.w failed, retry (In case of SC failure, rd gets written 1 (!= 0))
  ret

# pass in an address to unlock function in argument register 0
# returns after freeing lock
unlock:
  sw      zero, 0(a0)           # exclusive writer safe to clear the lock
  ret

  

#----------------------------------------------------------
# Core 1 Main
#----------------------------------------------------------
# main function does something ugly but demonstrates beautifully
mainc1:

  #Generate seed
  li a2, 0x1 //a2 holds seed value

  

  generate_loop:
    #Generate crc

    jal crc32 //now a0 holds random number
    or s1, zero, a0 //moving a0 to s1 since a0 will be used for lockte crc
    
    
    
    #Lock
    push ra         

    ori     a0, zero, lock_var    # move lock to argument register
    jal     lock                  # try to acquire the lock
    
    # ----------------------- #
    # critical code segment:
    
    # Compute stack[s_ptr*4] and store it in there
    
    ori t2, zero, s_ptr //t2 holds 308
    lw t0, 0(t2) //t0 holds 800 - first iteration
    sw s1, 0(t0) //s1 holds crc, stores it in Mem[s_ptr]
    
    # update s_ptr = s_ptr - 4 
    li t4, 4
    sub t5, t0, t4 
    sw t5, 0(t2)
    or s3, zero, t5
    

    # ----------------------- #

    ori     a0, zero, lock_var    # move lock to argument register
    jal     unlock                # release the lock
    pop ra        
  
    # Update seed to random[N-1] ,  then go back to crc generation if terminate condition not met
    or a2, zero, s1 //update seed
    li t2,256
    ori t3, zero, produce_count //t3 holds 30C
    lw t0, 0(t3) //t0 holds 0 - first iteration
    addi t0, t0, 1 //produce_count increment by 1
    sw t0, 0(t3)

    beq t0, t2, generate_terminate //compare produce count and 256, terminate program if it's equal
    j generate_loop
  generate_terminate:
      halt


  halt  

#----------------------------------------------------------
# Core 2 Init
#----------------------------------------------------------
  org 0x0200               
  li      sp, 0x7FFC            # core 2 stack
  jal     mainc2                # core 2 main program
  halt
#----------------------------------------------------------
# Core 2 Main
#----------------------------------------------------------
# main function does something ugly but demonstrates beautifully
mainc2:
    #s0:sum, will turn to average at the end, s1:min, s2:max
    ori   s0, zero, 0        
    li   s1, 0x0000FFFF  # s1 = 00000FFF
    
    ori   s2, zero, 0
    #Critical section must perform:
    # 1, Check if stack is empty, if it is, terminate program
    # 2, Pop Stack
    # 3, Update stack pointer after pop

    consume_start:
      # producer count must be > 0 to run loop
      ori t3, zero, produce_count //t3 holds 30C
      lw t0, 0(t3) //t0 holds 0 - first iteration
      beq t0,zero,consume_start
      consume_loop:

        ori t2, zero, s_ptr
        lw s4, 0(t2)
        li t0, 0x800
        beq s4, t0, consume_loop

        push ra
        ori     a0, zero, lock_var    # move lock to argument register
        jal     lock                  # try to acquire the lock
        
        # ----------------------- #
        # critical code segment:
        ori t2, zero, s_ptr //t2 holds the address of s_ptr
        
        lw t0, 0(t2) // Now t0 holds s_ptr
        or x20, t0, zero 

        addi t0, t0, 4 //add 4 to access crc
        lw t1 ,0(t0)//now t1 holds Stack[s_ptr + 4] - random 32 bits value from producer
        or s3, zero, t1 //s3 holds the current random number - debug from here, seems like t1 is not holding correct value -> t0 is wrong
        li t4, 0
        sw t4, 0(t0)//save zero to Stack[s_ptr+4]
        sw t0,0(t2)//store s_ptr+4 as new s_ptr
        # ----------------------- #

        ori   a0, zero, lock_var    # move lock to argument register
        jal   unlock                # release the lock
        pop ra

        #Perform Calculation: min, max, average
        li t1, 0x0000FFFF
        and s3,s3, t1//only take lower 16 bits - now t1 is the random number we want to use
       
        add s0, s0, s3 //update sum
        #a2, a3 are arguments for min and max calculations
        //min
        or a2, zero, s1
        or a3, zero, s3
        jal min
        or s1, zero, a0
        //max
        or a2, zero, s2
        or a3, zero, s3
        jal max
        or s2, zero, a0
        li t2,256//# of iterations
        ori t3, zero, consume_count //t3 holds 30C
        lw t0, 0(t3) //t0 holds 0 - first iteration
        addi t0, t0, 1 //consume_count increment by 1
        sw t0, 0(t3)
    
        beq t0, t2, consume_done //compare consume count and 256, terminate program if it's equal
        j consume_loop
    
    consume_done:
        #calculate average and terminate
        srli s0, s0, 8 //divide the sum by 256 to get average
        halt




#----------------------------------------------------------
# RISC-V Assembly
#----------------------------------------------------------
#REGISTERS
#ra $1 Return address
#sp $2 Stack pointer
#gp $3 Global pointer
#tp $4 Thread pointer
#t0-2 $5-7 temps
#s0/fp $8 Saved/frame pointer
#s1 $9 Saved register
#$a0-1 $10-11 Fn args/return values
#$a2-7 $12-17 Fn args
#$s2-11 $18-27 Saved registers
#$t3-6 $28-31 Temporaries

# USAGE random0 = crc(seed), random1 = crc(random0)
#       randomN = crc(randomN-1)
#------------------------------------------------------
# $a0 = crc32($a2)
crc32:
  lui $t1, 0x04C11
   ori $t1, $t1, 0x7B7
   addi $t1, $t1, 0x600
   or $t2, $0, $0
   ori $t3, $0, 32
 
l1:
  slt $t4, $t2, $t3
   beq $t4, $0, l2
 
  ori $t5, $0, 31
   srl $t4, $a2, $t5
   
   ori $t5, $0, 1
   sll $a2,$a2,$t5
   beq $t4, $0, l3
   xor $a2, $a2, $t1
 l3:
  addi $t2, $t2, 1
   j l1
l2:
  or $a0, $a2, $0
   jr $1


#----------------------------------------------------------
# RISC-V Assembly
#----------------------------------------------------------

# a2 = Numerator
# a3 = Denominator
# a0 = Quotient
# a1 = Remainder

#-divide(N=$a2,D=$a3) returns (Q=$a0,R=$a1)--------
divide:               # setup frame
  push  $1           # saved return address
   or    $a0, $0, $0   # Quotient v0=0
   or    $a1, $0, $a2  # Remainder t2=N=a0
   beq   $0, $a3, divrtn # test zero D
   slt   $t0, $a3, $0  # test neg D
   bne   $t0, $0, divdneg
   slt   $t0, $a2, $0  # test neg N
   bne   $t0, $0, divnneg
 divloop:
  slt   $t0, $a1, $a3 # while R >= D
   bne   $t0, $0, divrtn
   addi $a0, $a0, 1   # Q = Q + 1
   sub  $a1, $a1, $a3 # R = R - D
   j     divloop
divnneg:
  sub  $a2, $0, $a2  # negate N
   jal   divide        # call divide
  sub  $a0, $0, $a0  # negate Q
   beq   $a1, $0, divrtn
   addi $a0, $a0, -1  # return -Q-1
   j     divrtn
divdneg:
  sub  $a2, $0, $a3  # negate D
   jal   divide        # call divide
  sub  $a0, $0, $a0  # negate Q
 divrtn:
   pop $1
   jr  $1
#-divide--------------------------------------------


#----------------------------------------------------------
# RISC-V Assembly
#----------------------------------------------------------
# a2 = a
# a3 = b
# a0 = result

#-max (a2=a,a3=b) returns a0=max(a,b)--------------
max:
  push  $1
   or    $a0, $0, $a2
   slt   $t0, $a2, $a3
   beq   $t0, $0, maxrtn
   or    $a0, $0, $a3
 maxrtn:
   pop   $1
   jr    $1
 #--------------------------------------------------

#-min (a2=a,a3=b) returns a0=min(a,b)--------------
min:
  push  $1
   or    $a0, $0, $a2
   slt   $t0, $a3, $a2
   beq   $t0, $0, minrtn
   or    $a0, $0, $a3
 minrtn:
   pop   $1
   jr    $1
 #--------------------------------------------------


#----------------------------------------------------------
# Shared Data Segment
#----------------------------------------------------------
org 0x0500
lock_var:
  cfw 0x0     # lock starts unlocked, should end unlocked
res:
  cfw 0x0     # end result should be 3
s_ptr:
  cfw 0x800 
produce_count: //30C
  cfw 0x0
consume_count:
  cfw 0x0
