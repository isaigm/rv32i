library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity store_unit is
  port (funct3    : in  std_logic_vector(2 downto 0);
        addr      : in  std_logic_vector(1 downto 0);
        rs2_data  : in  std_logic_vector(31 downto 0);
        store_out : out std_logic_vector(31 downto 0);
        byte_en   : out std_logic_vector(3 downto 0));
end entity;

architecture Behavioral of store_unit is
begin
  process (funct3, addr, rs2_data)
  begin
    store_out <= (others => '0');
    byte_en <= "0000";
    case funct3 is
      when "000" => -- sb
        case addr is
          when "00" =>
            store_out(7 downto 0) <= rs2_data(7 downto 0);
            byte_en <= "0001";
          when "01" =>
            store_out(15 downto 8) <= rs2_data(7 downto 0);
            byte_en <= "0010";
          when "10" =>
            store_out(23 downto 16) <= rs2_data(7 downto 0);
            byte_en <= "0100";
          when others =>
            store_out(31 downto 24) <= rs2_data(7 downto 0);
            byte_en <= "1000";
        end case;
      when "001" => -- sh
        if addr(1) = '0' then
          store_out(15 downto 0) <= rs2_data(15 downto 0);
          byte_en <= "0011";
        else
          store_out(31 downto 16) <= rs2_data(15 downto 0);
          byte_en <= "1100";
        end if;
      when others => -- sw
        store_out <= rs2_data;
        byte_en <= "1111";
    end case;
  end process;
end architecture;
