#----------------------------------------------------------
# RISC-V Assembly
#----------------------------------------------------------
#------------------------------------------------------------------
# Test llsc1
# Note: SW/SC should invalidate the link register if there is an
#       address match in the opposite core or in the same core.
#------------------------------------------------------------------

  org   0x0000
  lui $4, 0x2
  addi   $4, $4, 0xFC0
  ori   $10, $0, 0x80
  

  lw    $11, 0($10)
  addi   $11, $11, 0x01
  sw    $11, 0($10)
 
  lr.w    $11, ($10)
   addi   $11, $11, 0x01
   sc.w   $8, $11, ($10)
   sc.w   $8, $11, ($10)
  
  addi  $5, $10, 8
  lr.w    $11, ($5)
   addi   $11, $11, 0x01
   sw    $11, 8($10)
   sc.w  $8, $11, ($5)
   sw    $11, 8($10)
 
  halt      # that's all

  org   0x0200
  lui $4, 0x2
  addi   $4, $4, 0xFC0
  ori   $10, $0, 0x90
 
  lw    $11, 0($10)
   addi   $11, $11, 0x01
   sw    $11, 0($10)
 
  lr.w    $11, ($10)
   addi   $11, $11, 0x01
   sc.w   $8, $11, ($10)
   sc.w   $8, $11, ($10)
 
 addi $10, $10, 0x8
  lr.w    $11, ($10)
   addi   $11, $11, 0x01
   sw    $11, 0($10)
   sc.w  $8, $11, ($10)
   sw    $11, 0($10)
 
  halt      # that's all
