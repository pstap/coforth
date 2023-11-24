# coforth.s
# coffee forth

# riscv32 calling conventions
# Register Name(s)      Usage
# x0/zero               Always holds 0
# ra                    the return address
# sp                    the address of the boundary of the stack
# t0-t6                 temporary values that do not persist after function calls
# s0-s11                values that persist after function calls
# a0-a1                 first two arguments to the function or the return values
# a2-a7                 any remaining arguments

.global _start

.equ UART_OUTPUT, 0x10000000
	
_start: 
  la    a0, hello
  call  print_cstr
  la    a0, eop
  call  print_cstr
  j     forever

forever:
  wfi
  j     forever


print_cstr: 
  # a0 <- cstr address, used as char ptr
  li    t0, UART_OUTPUT         # t0 <- UART output addr
1:                              # LOOP:
  lb    t1, 0(a0)               # t1 <- current char
  beq   t1, zero, 2f            # return if we see null char
  sb    t1, 0(t0)               # output current char
  addi  a0, a0, 1               # increment char ptr
  j     1b
2:                              # RET:
  ret
  
.section .data

hello:
  .asciz "hello from coffee forth!\n"

eop:  
  .asciz "jumping to infinite loop\n"

