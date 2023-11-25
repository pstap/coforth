# coforth.s
# coffee forth

# Useful links
# qemu riscv memory map https://github.com/qemu/qemu/blob/master/hw/riscv/virt.c
# NS16550A Datasheet    https://datasheetspdf.com/pdf-file/605590/NationalSemiconductor/NS16550A/1

# coforth constants
.equ TOS, s0            # this register always stores the top of the data stack
.equ RS,  s11           # this register stores the top of the return stack

# uart registers
.equ UART0, 0x10000000

# outer interpreter
.global _start	
_start: 
  la    a0, hello               # print welcome message
  call  print_cstr
  li    sp, 0x3242
1:                              # ECHO LOOP:
  mv    a0, sp
  call  print_word
  call  key
  call  putchar
  la    a0, nl
  call  print_cstr
  j     1b                      # loop back

forever:
  wfi
  j     forever

# output procedures
print_cstr:                     # print_cstr: print a null terminated string to UART0
                                # a0 <- cstr address, used as char ptr
  li    t0, UART0               # t0 <- UART output addr
1:                              # LOOP:
  lb    t1, 0(a0)               # t1 <- current char
  beq   t1, zero, 2f            # return if we see null char
  sb    t1, 0(t0)               # output current char
  addi  a0, a0, 1               # increment char ptr
  j     1b
2:                              # RET:
  ret

putchar:                        # putchar: output a char to UART0
                                # a0 <- char to output to UART
  li    t6, UART0               # t6 <- UART output addr
  sb    a0, 0(t6)               # write low byte of t6 to UART
  ret

getchar:                        # getchar: get a single char from UART0.
                                # returns 0 if there's no char available
                                # TODO: replace magic numbers with constants
  li    t0, UART0               # to <- UART addr
  lbu   t1, 0x5(t0)             # t1 <- line status
  andi  t1, t1, 0x1             # lowest bit indicates if char is available
  addi  a0, zero, 0             # store 0 in return register
  beqz  t1, 1f                  # return early if no char is ready
  lbu   a0, (t0)                # load byte from UART0
1:                              # RET:
  ret

key:                            # key: blocking version of getchar. spin until we get a character
                                # TODO is stack usage broken?
  mv    t2, ra                  # store ra in t2 for now, we know getchar won't clobber it
1:                              # LOOP:
  call  getchar                 # returns char in a0
  beqz  a0, 1b                  # loop back if we didn't get a character
  mv    ra, t2                  # restore return address
  ret                           # RET: a0 holds the char


print_word:                     # print_word: prints word in a0 in hex
  mv    t4, ra                  # TODO: fix this horrible hack to work around the stack not working. putchar won't clobber t4
  mv    t0, a0                  # t0 <- ! original argument
  li    t1, 0xF0000000
  la    t2, hextbl              # t2 <- 0 hex table
  li    t3, 28                  # t3 <- ! shift amount
1:                              # LOOP:
  and   a0, a0, t1              # apply mask to a0
  srl   a0, a0, t3              # shift over masked nibble to LSB
  add   a0, a0, t2              # get address of character in table
  lb    a0, 0(a0)               # a0 <- hextbl[a0]
  call  putchar                 # print out char
  beqz  t3, 2f                  # jump to RET if done
  srli  t1, t1, 4               # shift mask over
  addi  t3, t3, -4              # subtract 4 from shift amount
  mv    a0, t0                  # restore original number
  j     1b
2:                              # RET:
  mv    ra, t4                  # restore the stack
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

dbg:  
  .asciz "DEBUG"

hextbl:
  .ascii "0123456789ABCDEF"
