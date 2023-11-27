# coforth.s
# coffee forth

# Useful links
# qemu riscv memory map https://github.com/qemu/qemu/blob/master/hw/riscv/virt.c

# coforth macros
# this register is the program counter
#define PC s9

# this register stores the top of the data stack
#define TOS s10

# this register points to the data stack
#define DS sp

# this register stores the top of the return stack
#define TOR ra

# this register points to the return stack
#define RS s11

.section .text


# outer interpreter
.global _start	
_start: 
  la    sp, __stack_start       # initialize sp, NOTE: specific to qemu virt machine
  la    a0, hello               # print welcome message
  call  print_cstr
  
  la    PC, program             # load the program into PC
  lw    t0, 0(PC)
  addi  RS, RS, -4              # allocate space for RA
  jalr  t0                      # jump into program
RETURN_TO_MAIN: 
  la    a0, e_main
  call  print_cstr
  mv    a0, TOS                 # copy top of stack
  call  print_word

forever:
  wfi
  j     forever

# TODO: direct threaded with shared NEXT
# NOTE: shared NEXT is bad for the branch predictor
# NOTE: would prefer indirect threading
NEXT:
  la    a0, e_plus
  call  print_cstr
  la    a0, e_next
  call  print_cstr  
  addi  PC, PC, 4               # increment PC TODO: word size may not actually be 4
  lw    t0, 0(PC)               # t0 := word
  jr    t0                      # jump to word

# TODO: shared exit
EXIT:
  la    a0, e_exit
  call  print_cstr
  la    a0, RETURN_TO_MAIN
  call  print_word
  j     RETURN_TO_MAIN
  

# forth words
plus:                           # (n n -- n)
  lw    t0, 0(DS)               # load word from data stack (POP)
  addi  DS, DS, 4               # pop off stack
  add   TOS, TOS, t0            # add loaded word to t0
  j     NEXT                    # go to next instruction

dup:                            # (x -- x x)
  la    a0, e_dup
  call  print_cstr
  addi  DS, DS, -4              # allocate space on stack to push to
  sw    TOS, 0(DS)              # store value to top of data stack (PUSH)
  add   TOS, TOS, t0            # add loaded word to t0
  mv    a0, ra
  call  print_word
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

e_plus: .asciz "ENTERED PLUS\r\n"
e_dup:  .asciz "ENTERED DUP\r\n"
e_next: .asciz "ENTERED NEXT\r\n"
e_exit: .asciz "EXIT, returning to: "
e_main: .asciz "ENTERED MAIN\r\n"

program:
  .word dup
  .word plus
  .word EXIT
