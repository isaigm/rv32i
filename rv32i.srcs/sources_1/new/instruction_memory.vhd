library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity instruction_memory is
  port (addr  : in  std_logic_vector(9 downto 0);
        instr : out std_logic_vector(31 downto 0));
end entity;

architecture Behavioral of instruction_memory is
  type rom_type is array (0 to 255) of std_logic_vector(31 downto 0);
  signal instr_mem : rom_type := (x"123450b7",            -- addi x1, x0, 5      (x1 = 0 + 5  = 5)
                                  x"00000297",            -- addi x2, x0, 10     (x2 = 0 + 10 = 10)
                                 
                                  others => x"00000013"); -- nop
begin
  instr <= instr_mem(to_integer(unsigned(addr(9 downto 2))));

end architecture;
