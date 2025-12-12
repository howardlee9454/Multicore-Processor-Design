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
