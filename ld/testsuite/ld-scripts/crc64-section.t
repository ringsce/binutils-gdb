MEMORY {
  rom : ORIGIN = 0x000000, LENGTH = 0x4000
  ram : ORIGIN = 0x008000, LENGTH = 0x1000
}

_start = 0x000000;
SECTIONS
{
  . = 0x1000 + SIZEOF_HEADERS;
  .foo ALIGN (0x200) :

    {
      FILL(0xFF)
      header = .;
      INCLUDE "begin_tag.inc"

      expected = .;
      BYTE(0x6C);
      BYTE(0x40);
      BYTE(0xDF);
      BYTE(0x5F);
      BYTE(0x0B);
      BYTE(0x49);
      BYTE(0x73);
      BYTE(0x47);

      QUAD(0x0);

      crc64 = .;
      DIGEST "_CRC64#BE" "CRC64-ECMA" (ecc_start , ecc_end);
      QUAD(0x0);

      INCLUDE "end_tag.inc"

      ecc_start = .;
      ASCIZ "123456789"
      ecc_end = . - 1;
      . = ALIGN(0x10);

      entry = .;
      *(.foo)
      . = ALIGN(0x100);
      BYTE(1);
      INCLUDE "digest_table.inc"
    } > rom
  .text ALIGN (0x200) :
    {
      *(.text)
      QUAD(0x0)
    } > rom

  .data : AT (0x008000) { *(.data) } >ram /* NO default AT>rom */
  . = ALIGN(0x20);
  .bss : { *(.bss) } >ram /* NO default AT>rom */
  /DISCARD/ : { *(*) }
}
