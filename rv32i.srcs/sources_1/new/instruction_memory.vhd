library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity instruction_memory is
  port (addr  : in  std_logic_vector(9 downto 0);
        instr : out std_logic_vector(31 downto 0));
end entity;

architecture Behavioral of instruction_memory is
  type rom_type is array (0 to 255) of std_logic_vector(31 downto 0);
 signal instr_mem : rom_type := (
   0 => x"00000093",  -- addi x1, x0, 0    : count = 0
   1 => x"00000313",  -- addi x6, x0, 0    : mem_addr = 0
   2 => x"01f00393",  -- addi x7, x0, 5    : limite = 5 primos
   3 => x"00100413",  -- addi x8, x0, 1    : x8 = 1
   4 => x"00200113",  -- addi x2, x0, 2    : n = 2
   5 => x"0470d863",  -- bge  x1, x7, end       (count>=limite?)
   6 => x"00100293",  -- addi x5, x0, 1    : is_prime = 1
   7 => x"00200193",  -- addi x3, x0, 2    : d = 2
   8 => x"0221d463",  -- bge  x3, x2, check     (d>=n?)
   9 => x"00010233",  -- add  x4, x2, x0   : temp = n
  10 => x"00324663",  -- blt  x4, x3, afterdiv  (temp<d?)
  11 => x"40320233",  -- sub  x4, x4, x3   : temp -= d
  12 => x"fe000ce3",  -- beq  x0, x0, divloop   (loop resta)
  13 => x"00021663",  -- bne  x4, x0, notdiv    (temp!=0?)
  14 => x"00000293",  -- addi x5, x0, 0    : is_prime = 0
  15 => x"00000663",  -- beq  x0, x0, check     (break)
  16 => x"00118193",  -- addi x3, x3, 1    : d += 1
  17 => x"fc000ee3",  -- beq  x0, x0, mid       (loop divisores)
  18 => x"00028a63",  -- beq  x5, x0, nextn     (is_prime==0?)
  19 => x"000104b3",  -- add  x9, x2, x0   : x9 = n
  20 => x"00232023",  -- sw   x2, 0(x6)    : mem[mem_addr] = n
  21 => x"00430313",  -- addi x6, x6, 4    : mem_addr += 4
  22 => x"00108093",  -- addi x1, x1, 1    : count += 1
  23 => x"00110113",  -- addi x2, x2, 1    : n += 1
  24 => x"fa000ae3",  -- beq  x0, x0, outer     (loop candidatos)
  25 => x"00000063",  -- beq  x0, x0, end       : HALT (loop infinito)
  others => x"00000013"
);
begin

  instr <= instr_mem(to_integer(unsigned(addr(9 downto 2))));

end architecture;
