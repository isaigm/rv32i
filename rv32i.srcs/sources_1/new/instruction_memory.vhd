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
    0 => x"3fc00113", 1 => x"04c000ef", 2 => x"0000006f", 3 => x"fe010113",
    4 => x"00812e23", 5 => x"02010413", 6 => x"fe042623", 7 => x"0100006f",
    8 => x"fec42783", 9 => x"00178793", 10 => x"fef42623", 11 => x"fec42703",
    12 => x"007a17b7", 13 => x"1ff78793", 14 => x"fee7d4e3", 15 => x"00000013",
    16 => x"00000013", 17 => x"01c12403", 18 => x"02010113", 19 => x"00008067",
    20 => x"ff010113", 21 => x"00112623", 22 => x"00812423", 23 => x"01010413",
    24 => x"000017b7", 25 => x"00010737", 26 => x"fff70713", 27 => x"00e7a023",
    28 => x"f9dff0ef", 29 => x"000017b7", 30 => x"0007a023", 31 => x"f91ff0ef",
    32 => x"fe1ff06f",
    others => x"00000013"
  );
begin

  instr <= instr_mem(to_integer(unsigned(addr(9 downto 2))));

end architecture;
