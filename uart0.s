# NS16550A Datasheet    https://datasheetspdf.com/pdf-file/605590/NationalSemiconductor/NS16550A/1

.global print_cstr
.global putchar
.global getchar
.global key

# uart registers
.equ UART0, 0x10000000

# output procedures
print_cstr:                     # print_cstr: print a null terminated string to UART0
                                # a0 := ! cstr address, used as char ptr
  li    t0, UART0               # t0 := 0 UART output addr
1:                              # LOOP:
  lb    t1, 0(a0)               # t1 := ! current char
  beq   t1, zero, 2f            # return if we see null char
  sb    t1, 0(t0)               # output current char
  addi  a0, a0, 1               # increment char ptr
  j     1b
2:
  ret

putchar:                        # putchar: output a char to UART0
                                # a0 := 0 char to output to UART
  li    t0, UART0               # t0 := 0 UART output addr
  sb    a0, 0(t0)               # write low byte of t0 to UART
  ret

getchar:                        # getchar: get a single char from UART0.
                                # returns 0 if there's no char available
                                # TODO: replace magic numbers with constants
  li    t0, UART0               # to := 0 UART addr
  lbu   t1, 0x5(t0)             # t1 := ! line status
  andi  t1, t1, 0x1             # lowest bit indicates if char is available
  addi  a0, zero, 0             # store 0 in return register
  beqz  t1, 1f                  # return early if no char is ready
  lbu   a0, (t0)                # load byte from UART0
1:                              # RET:
  ret

key:                            # key: blocking version of getchar. spin until we get a character
  addi  sp, sp, -16             # alloc stack space for ra
  sw    ra, 0(sp)               # store ra
1:                              # LOOP:
  call  getchar                 # returns char in a0
  beqz  a0, 1b                  # loop back if we didn't get a character
  lw    ra, 0(sp)               # restore ra from stack
  addi  sp, sp, 16              # dealloc stack
  ret                           # RET: a0 holds the char


print_word:                     # print_word: prints word in a0 in hex
  addi  sp, sp, -32             # preamble:
  sw    s0,  0(sp)              
  sw    s1,  4(sp)
  sw    s2,  8(sp)
  sw    s3, 12(sp)
  sw    ra, 16(sp)
                                # body:
  mv    s0, a0                  # s0 := 0 original argument
  li    s1, 0xF0000000          # s1 := ! mask 
  la    s2, hextbl              # s2 := 0 hex table
  li    s3, 28                  # s3 := ! shift amount
1:
  and   a0, a0, s1              # apply mask to a0
  srl   a0, a0, s3              # shift over masked nibble to LSB
  add   a0, a0, s2              # get address of character in table
  lb    a0, 0(a0)               # a0 <- hextbl[a0]
  call  putchar                 # print out char
  beqz  s3, 2f                  # return if done
  srli  s1, s1, 4               # shift mask over
  addi  s3, s3, -4              # subtract 4 from shift amount
  mv    a0, s0                  # restore original number
  j     1b
2:                              # epilogue:
  lw    s0,  0(sp)              
  lw    s1,  4(sp)
  lw    s2,  8(sp)
  lw    s3, 12(sp)
  lw    ra, 16(sp)
  addi  sp, sp, 32
  ret

.section .data
hextbl:
  .ascii "0123456789ABCDEF"
