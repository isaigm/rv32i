OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY {
    IMEM (rx)  : ORIGIN = 0x00000000, LENGTH = 1K
    DMEM (rw)  : ORIGIN = 0x00000400, LENGTH = 1K
}

SECTIONS {
    .text : {
        *(.text.init)      /* el _start va primero */
        *(.text*)          /* luego el resto del código */
    } > IMEM

    .data : { *(.data*) } > DMEM
    .bss  : { *(.bss*) }  > DMEM
}
