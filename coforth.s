# coforth.s
# coffee forth

# Useful links
# qemu riscv memory map https://github.com/qemu/qemu/blob/master/hw/riscv/virt.c

# coforth constants
.equ TOS, s0            # this register always stores the top of the data stack
.equ RS,  s11           # this register stores the top of the return stack

# outer interpreter
.global _start	
_start: 
  li    sp, 0x88000000          # initialize sp, NOTE: specific to qemu virt machine
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

