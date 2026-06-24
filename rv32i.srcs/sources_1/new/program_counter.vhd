library ieee;
  use ieee.std_logic_1164.all;

entity program_counter is
  port (clk     : in  std_logic;
        rst     : in  std_logic;
        next_pc : in  std_logic_vector(31 downto 0);  
        pc      : out std_logic_vector(31 downto 0));  
end entity;

architecture Behavioral of program_counter is
  signal pc_reg : std_logic_vector(31 downto 0) := (others => '0');
begin
  process (clk)
  begin
    if rising_edge(clk) then        
      if rst = '1' then
        pc_reg <= (others => '0');   
      else
        pc_reg <= next_pc;           
      end if;
    end if;
  end process;

  pc <= pc_reg;                    
end architecture;