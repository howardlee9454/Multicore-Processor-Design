#----------------------------------------------------------
# RISC-V Assembly
#----------------------------------------------------------
# Multicore coherence test
# Each core stores to values that exist on the same block in the cache

# core 1
org 0x0000
  ori $5, $0, data1
   lui $6, 0xDEADB
   ori $6, $6, 0x7EF
   addi $7, $0, 7
   slli $7, $7, 8
   add $6, $6, $7
   sw  $6, 0($5)
   ori $5, $0, data4
   lui $6, 0xCAB1F
   ori $6, $6, 0x7ED
   add $6, $6, $7
   sw  $6, 0($5)
   halt

# core 2
org 0x0200
  ori $5, $0, data2
   lui $6, 0x89ABC
   ori $6, $6, 0x7EF
   addi $7, $0, 6
   slli $7, $7, 8
   add $6, $6, $7
   sw  $6, 0($5)
   ori $5, $0, data3
   lui $6, 0x01234
   ori $6, $6, 0x567
   sw  $6, 0($5)
   halt

org 0x0400
data1:
  cfw 0xBAD0BAD0
data2:
  cfw 0xBAD0BAD0
data3:
  cfw 0xBAD0BAD0
data4:
  cfw 0xBAD0BAD0
