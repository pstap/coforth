# coforth.s
# coffee forth

# Useful links
# qemu riscv memory map https://github.com/qemu/qemu/blob/master/hw/riscv/virt.c
# NS16550A Datasheet    https://datasheetspdf.com/pdf-file/605590/NationalSemiconductor/NS16550A/1

# riscv32 calling conventions
# Register Name(s)      Usage
# x0/zero               Always holds 0
# ra                    the return address
# sp                    the address of the boundary of the stack
# t0-t6                 temporary values that do not persist after function calls
# s0-s11                values that persist after function calls
# a0-a1                 first two arguments to the function or the return values
# a2-a7                 any remaining arguments

# coforth constants
.equ TOS, s0            # this register always stores the top of the data stack
.equ RS,  s11           # this register stores the top of the return stack

# uart registers
.equ UART0, 0x10000000

# outer interpreter
.global _start	
_start: 
  la    a0, hello       # print welcome messagen
  call  print_cstr
  
1:                      # ECHO LOOP:
  call  getchar         # get a char
  beq   a0, zero, 1b    # loop back if we didn't get a char
  call  putchar
  la    a0, nl
  call  print_cstr
  j     1b              # loop back

forever:
  wfi
  j     forever

# output procedures
print_cstr: 
  # a0 <- cstr address, used as char ptr
  # NOTE: putchar is inlined here
  li    t0, UART0               # t0 <- UART output addr
1:                              # LOOP:
  lb    t1, 0(a0)               # t1 <- current char
  beq   t1, zero, 2f            # return if we see null char
  sb    t1, 0(t0)               # output current char
  addi  a0, a0, 1               # increment char ptr
  j     1b
2:                              # RET:
  ret

putchar:  
  # a0 <- char to output to UART
  li    t0, UART0               # t0 <- UART output addr
  sb    a0, 0(t0)               # write low byte of t0 to UART
  ret

# TODO: replace magic numbers with constants
getchar:  
  li    t0, UART0               # to <- UART addr
  lbu   t1, 0x5(t0)             # t1 <- line status
  andi  t1, t1, 0x1             # lowest bit indicates if char is available
  addi  a0, zero, 0             # store 0 in return register
  beqz  t1, 1f                  # return early if no char is ready
  lbu   a0, (t0)                # load byte from UART0
1:                              # RET:
  ret
  
.section .data

hello:
  .asciz "hello from coffee forth!\r\n"

eop:  
  .asciz "jumping to infinite loop\r\n"

msg:  
  .asciz "got: "

nl: 
  .asciz "\r\n"
