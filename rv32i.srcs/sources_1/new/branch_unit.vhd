library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity branch_unit is
  port (
        funct3 : in  std_logic_vector(2 downto 0);
        rs1    : in  std_logic_vector(31 downto 0);
        rs2    : in  std_logic_vector(31 downto 0);
        take   : out std_logic
  );
end entity;

architecture Behavioral of branch_unit is
begin
  process (funct3, rs1, rs2)
  begin
    take <= '0'; 
    
    case funct3 is
      when "000" => -- BEQ
        if rs1 = rs2 then
            take <= '1';
        end if;
      when "001" => -- BNE
        if rs1 /= rs2 then
            take <= '1';
        end if;
      when "100" => -- BLT
        if signed(rs1) < signed(rs2) then
            take <= '1';
        end if;
      when "101" => -- BGE
        if signed(rs1) >= signed(rs2) then
            take <= '1';
        end if;
      when "110" => -- BLTU
        if unsigned(rs1) < unsigned(rs2) then
            take <= '1';
        end if;
      when "111" => -- BGEU
        if unsigned(rs1) >= unsigned(rs2) then
            take <= '1';
        end if;
      when others =>
        null;
    end case;
  end process;
end architecture;