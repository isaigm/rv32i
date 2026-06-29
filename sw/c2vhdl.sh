#!/usr/bin/env bash
#
# c2vhdl.sh - Compila un programa C para RV32I y genera el VHDL de la instruction memory
#
# Uso:
#   ./c2vhdl.sh main.c [salida.vhd]
#
# Requiere: riscv64-unknown-elf-gcc, objcopy (toolchain RISC-V)
#           start.s y link.ld en el mismo directorio
#
# Si no pasas archivo de salida, imprime el VHDL en pantalla.

set -e  # abortar si algo falla

# ---- Configuración ----
GCC="riscv64-unknown-elf-gcc"
OBJCOPY="riscv64-unknown-elf-objcopy"
OBJDUMP="riscv64-unknown-elf-objdump"
ARCH="rv32i"
ABI="ilp32"
ROM_SIZE=256                       # número de palabras en tu instruction_memory
FILL='00000013'                    # relleno: nop (addi x0,x0,0)
ENTITY_NAME="instruction_memory"

# ---- Argumentos ----
CFILE="$1"
OUTFILE="$2"

if [ -z "$CFILE" ]; then
    echo "Uso: $0 <archivo.c> [salida.vhd]" >&2
    echo "  Si no das salida.vhd, imprime el VHDL en pantalla." >&2
    exit 1
fi

if [ ! -f "$CFILE" ]; then
    echo "Error: no existe el archivo '$CFILE'" >&2
    exit 1
fi

if [ ! -f "start.s" ] || [ ! -f "link.ld" ]; then
    echo "Error: faltan start.s y/o link.ld en el directorio actual" >&2
    exit 1
fi

# ---- Compilar ----
TMPDIR=$(mktemp -d)
ELF="$TMPDIR/program.elf"
BIN="$TMPDIR/program.bin"

echo ">> Compilando $CFILE para $ARCH..." >&2
$GCC -march=$ARCH -mabi=$ABI -nostdlib -nostartfiles \
     -T link.ld -o "$ELF" start.s "$CFILE"

# ---- Verificar que no haya instrucciones no soportadas ----
echo ">> Verificando instrucciones..." >&2
BAD=$($OBJDUMP -d "$ELF" | grep -oP '\t(mul|div|rem|fence|ecall|ebreak)[a-z.]*' | sort -u || true)
if [ -n "$BAD" ]; then
    echo "   ADVERTENCIA: el programa usa instrucciones que tu CPU quizás no soporta:" >&2
    echo "$BAD" | sed 's/^/     /' >&2
fi

# ---- Extraer binario ----
$OBJCOPY -O binary "$ELF" "$BIN"

# ---- Convertir a VHDL con Python ----
python3 - "$BIN" "$ROM_SIZE" "$FILL" "$ENTITY_NAME" "$OUTFILE" << 'PY_EOF'
import sys, struct

binfile   = sys.argv[1]
rom_size  = int(sys.argv[2])
fill      = sys.argv[3]
entity    = sys.argv[4]
outfile   = sys.argv[5] if len(sys.argv) > 5 and sys.argv[5] else None

# Leer el binario como palabras de 32 bits little-endian
with open(binfile, "rb") as f:
    data = f.read()

# Padear a múltiplo de 4
while len(data) % 4 != 0:
    data += b'\x00'

words = []
for i in range(0, len(data), 4):
    w = struct.unpack("<I", data[i:i+4])[0]
    words.append(f"{w:08x}")

if len(words) > rom_size:
    sys.stderr.write(f"ERROR: el programa tiene {len(words)} palabras pero la ROM solo tiene {rom_size}\n")
    sys.exit(1)

sys.stderr.write(f">> Programa: {len(words)} instrucciones (de {rom_size} disponibles)\n")

# Construir el cuerpo de la inicialización
lines = []
for i in range(0, len(words), 4):
    chunk = words[i:i+4]
    entries = "  ".join(f'{i+j} => x"{w}",' for j, w in enumerate(chunk))
    lines.append("    " + entries)

init_body = "\n".join(lines)

# El VHDL completo del módulo
vhdl = f'''library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity {entity} is
  port (addr  : in  std_logic_vector(9 downto 0);
        instr : out std_logic_vector(31 downto 0));
end entity;

architecture Behavioral of {entity} is
  type rom_type is array (0 to {rom_size-1}) of std_logic_vector(31 downto 0);
  signal instr_mem : rom_type := (
{init_body}
    others => x"{fill}"
  );
begin
  instr <= instr_mem(to_integer(unsigned(addr(9 downto 2))));
end architecture;
'''

if outfile:
    with open(outfile, "w") as f:
        f.write(vhdl)
    sys.stderr.write(f">> VHDL escrito en: {outfile}\n")
else:
    print(vhdl)
PY_EOF

# ---- Limpiar ----
rm -rf "$TMPDIR"
echo ">> Listo." >&2
