SECTIONS
{
  PROVIDE(__uart0 = 0x10000000);
  PROVIDE(__stack_start = 0x88000000);
  . = 0x80000000;
  .text : { *(.text) }
  .data : { *(.data) }
  .bss  : { *(.bss) }
  PROVIDE(__data_start = .);
}
