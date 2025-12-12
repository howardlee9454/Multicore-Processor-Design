#----------------------------------------------------------
# RISC-V Assembly
#----------------------------------------------------------
# Multicore coherence test
# stores 0xDEADBEEF to value

#core 1
org 0x0000
  ori $5, $0, word1
   lw  $6, 0($5)
   ori $7, $0, 16
   sll $6,$6,$7
   ori $29, $0, value
   ori $7, $0, flag
 
# wait for core 2 to finish
wait1:
  lw  $28, 0($7)
   beq $28, $0, wait1
 
# complete store
  lw  $5, 0($29)
   or  $5, $5, $6
   sw  $5, 0($29)
 
  halt

# core 2
org 0x0200
  ori $5, $0, word2
   lw  $6, 0($5)
   ori $7, $0, value
   sw  $6, 0($7)
 
# set flag
  ori $6, $0, flag
   ori $7, $0, 1
 
  sw  $7, 0($6)
   halt

org 0x0400
flag:
  cfw 0

org 0x0408
value:
  cfw 0

word1:
  cfw 0x0000DEAD
  cfw 0
word2:
  cfw 0x0000BEEF

