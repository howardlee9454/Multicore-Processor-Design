#----------------------------------------------------------
# RISC-V Assembly
#----------------------------------------------------------
#------------------------------------------
# Originally Test and Set example by Eric Villasenor
# Modified to be LL and SC example by Yue Du
# Modified for RISC-V by Zach Lagpacan
#------------------------------------------

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
  push    ra                    # save return address to main
  ori     a0, zero, lock_var    # move lock to argument register
  jal     lock                  # try to acquire the lock

  # ----------------------- #
  # critical code segment:
  ori     t2, zero, res
  lw      t0, 0(t2)
  addi    t1, t0, 2
  sw      t1, 0(t2)
  # ----------------------- #

  ori     a0, zero, lock_var    # move lock to argument register
  jal     unlock                # release the lock
  pop     ra                    # get return address
  ret

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
  push    ra                    # save return address
  ori     a0, zero, lock_var    # move lock to argument register
  jal     lock                  # try to acquire the lock

  # ----------------------- #
  # critical code segment:
  ori     t2, zero, res
  lw      t0, 0(t2)
  addi    t1, t0, 1
  sw      t1, 0(t2)
  # ----------------------- #

  ori   a0, zero, lock_var    # move lock to argument register
  jal   unlock                # release the lock
  pop   ra                    # get return address
  ret

#----------------------------------------------------------
# Shared Data Segment
#----------------------------------------------------------
org 0x0300
lock_var:
  cfw 0x0     # lock starts unlocked, should end unlocked
res:
  cfw 0x0     # end result should be 3
