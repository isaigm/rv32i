library IEEE;
  use IEEE.STD_LOGIC_1164.all;

  use IEEE.NUMERIC_STD.all;

entity register_file is
  port (clk      : in  std_logic;
        we       : in  std_logic;
        rs1_addr : in  std_logic_vector(4 downto 0);
        rs2_addr : in  std_logic_vector(4 downto 0);
        rd_addr  : in  std_logic_vector(4 downto 0);
        rd_data  : in  std_logic_vector(31 downto 0);
        rs1_data : out std_logic_vector(31 downto 0);
        rs2_data : out std_logic_vector(31 downto 0));
end entity;

architecture Behavioral of register_file is
  type mem is array (0 to 31) of std_logic_vector(31 downto 0);
  signal registers : mem := (others => (others => '0'));
begin
  process (clk)
  begin
    if rising_edge(clk) then
      if we = '1' then
        if unsigned(rd_addr) /= 0 then
          registers(to_integer(unsigned(rd_addr))) <= rd_data;

        end if;
      end if;
    end if;

  end process;
  rs1_data <= registers(to_integer(unsigned(rs1_addr))) when unsigned(rs1_addr) /= 0 else
              (others => '0');
  rs2_data <= registers(to_integer(unsigned(rs2_addr))) when unsigned(rs2_addr) /= 0 else
              (others => '0');
end architecture;
