library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.rv32i_pkg.all;

entity load_unit is
  port (funct3   : in  std_logic_vector(2 downto 0);
        addr     : in  std_logic_vector(1 downto 0);  -- 2 bits bajos de la dirección
        mem_data : in  std_logic_vector(31 downto 0); -- palabra leída de memoria
        load_out : out std_logic_vector(31 downto 0)); -- dato extendido para el registro
end entity;

architecture Behavioral of load_unit is
  signal byte_sel : std_logic_vector(7 downto 0);
  signal half_sel : std_logic_vector(15 downto 0);
begin
  -- Selecciona el BYTE correcto según los 2 bits bajos de la dirección
  byte_sel <= mem_data(7 downto 0)   when addr = "00" else
              mem_data(15 downto 8)  when addr = "01" else
              mem_data(23 downto 16) when addr = "10" else
              mem_data(31 downto 24);

  -- Selecciona el HALF-WORD correcto (alineado: addr(1) elige mitad baja o alta)
  half_sel <= mem_data(15 downto 0) when addr(1) = '0' else
              mem_data(31 downto 16);

  process (funct3, mem_data, byte_sel, half_sel)
  begin
    load_out <= (others => '0');
    case funct3 is
      when "000" =>  -- lb (byte con signo)
        load_out <= (31 downto 8 => byte_sel(7)) & byte_sel;
      when "001" =>  -- lh (half con signo)
        load_out <= (31 downto 16 => half_sel(15)) & half_sel;
      when "010" =>  -- lw (palabra completa)
        load_out <= mem_data;
      when "100" =>  -- lbu (byte sin signo)
        load_out <= (31 downto 8 => '0') & byte_sel;
      when "101" =>  -- lhu (half sin signo)
        load_out <= (31 downto 16 => '0') & half_sel;
      when others =>
        load_out <= mem_data;
    end case;
  end process;
end architecture;