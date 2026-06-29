.section .text.init
.globl _start
_start:
    li sp, 0x3fc        # inicializar stack pointer (cima de la data memory)
    call main           # llamar a main (esto es jal)
loop:
    j loop              # main retornó: bucle infinito (halt)
