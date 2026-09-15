OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)

SECTIONS
{
  . = KERNEL_ADDRESS;
  "!!!!OSBase" :
  {
    GetAll.o("!!!!OSBase")
    *(.text .text.*)
    *("C$$Code")
    *(.rodata .rodata.*)
  }
  PROVIDE(Image$$RO$$Limit = .);

  zzzzzzz 0xff000000 : AT(LOADADDR("!!!!OSBase") + SIZEOF("!!!!OSBase"))
  {
    *(zzzzzzz)
    *(.data .data.*)
  }
  PROVIDE(Image$$RW$$Base = ADDR(zzzzzzz));
  PROVIDE(Image$$ZI$$Base = .);

  .bss (NOLOAD) :
  {
    *(.bss .bss.*)
    *(COMMON)
  }
  PROVIDE(Image$$ZI$$Limit = .);

  /DISCARD/ :
  {
    *(.comment)
    *(.ARM.attributes)
  }
}
