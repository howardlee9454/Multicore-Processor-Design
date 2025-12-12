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
