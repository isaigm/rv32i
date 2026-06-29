library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity data_memory is
  port (clk        : in  std_logic;
        byte_en    : in  std_logic_vector(3 downto 0); -- ← era mem_write
        addr       : in  std_logic_vector(9 downto 0);
        write_data : in  std_logic_vector(31 downto 0);
        read_data  : out std_logic_vector(31 downto 0));
end entity;

architecture Behavioral of data_memory is
  type ram_type is array (0 to 255) of std_logic_vector(31 downto 0);
  signal data_mem : ram_type := (others => (others => '0'));
begin
  process (clk)
    variable idx : integer;
  begin
    if rising_edge(clk) then
      idx := to_integer(unsigned(addr(9 downto 2)));
      if byte_en(0) = '1' then
        data_mem(idx)(7 downto 0) <= write_data(7 downto 0);
      end if;
      if byte_en(1) = '1' then
        data_mem(idx)(15 downto 8) <= write_data(15 downto 8);
      end if;
      if byte_en(2) = '1' then
        data_mem(idx)(23 downto 16) <= write_data(23 downto 16);
      end if;
      if byte_en(3) = '1' then
        data_mem(idx)(31 downto 24) <= write_data(31 downto 24);
      end if;
    end if;
  end process;

  read_data <= data_mem(to_integer(unsigned(addr(9 downto 2))));
end architecture;
