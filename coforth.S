# coforth.s
# coffee forth

# Useful links
# qemu riscv memory map https://github.com/qemu/qemu/blob/master/hw/riscv/virt.c

# coforth macros
# this register is the program counter
#define PC s9

# this register always stores the top of the data stack
#define TOS s10

# this register stores points to the data stack
#define DS sp

# this register stores the top of the return stack
#define RS s11

.section .text


# outer interpreter
.global _start	
_start: 
  la    sp, __stack_start       # initialize sp, NOTE: specific to qemu virt machine
  la    a0, hello               # print welcome message
  call  print_cstr
1:                              # ECHO LOOP:
  call  key
  call  putchar
  la    a0, nl
  call  print_cstr
  j     1b

forever:
  wfi
  j     forever

# TODO: direct threaded with shared NEXT
# NOTE: shared NEXT is bad for the branch predictor
# NOTE: would prefer indirect threading
NEXT:
  addi  s9, s9, 4              # increment PC TODO: word size may not actually be 4
  lw    t0, 0(PC)               # t0 := word
  jr    t0                      # jump to word     

# TODO: shared exit
EXIT: 
  lw    t0, 0(RS)               # t0 := POP RS
  addi  RS, RS, -4
  jr    t0

# forth words
plus:                           # (n n -- n)
  lw    t0, 0(DS)               # load word from data stack (POP)
  addi  DS, DS, 4               # pop off stack
  add   TOS, TOS, t0            # add loaded word to t0
  j     NEXT                    # go to next instruction

dup:                            # (x -- x x)
  addi  DS, DS, -4              # allocate space on stack to push to
  sw    TOS, 0(DS)              # store value to top of data stack (PUSH)
  add   TOS, TOS, t0            # add loaded word to t0
  j     NEXT                    # go to next instruction


.section .data

hello:
  .asciz "hello from coffee forth!\r\n"

eop:  
  .asciz "jumping to infinite loop\r\n"

msg:  
  .asciz "got: "

nl: 
  .asciz "\r\n"

dbg:  
  .asciz "DEBUG"

program:
  .word dup
  .word plus
  .word EXIT
