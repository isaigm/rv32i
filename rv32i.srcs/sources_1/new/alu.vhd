library ieee;
  use ieee.std_logic_1164.all;
  use IEEE.NUMERIC_STD.all;
  use work.rv32i_pkg.all;
entity alu is
  port (a      : in  std_logic_vector(31 downto 0);
        b      : in  std_logic_vector(31 downto 0);
        op     : in  std_logic_vector(3 downto 0);
        result : out std_logic_vector(31 downto 0);
        zero   : out std_logic);
end entity;

architecture Behavioral of alu is
 

begin
  process (a, b, op)
  begin
    case op is
      when ALU_SUM =>
        result <= std_logic_vector(unsigned(a) + unsigned(b));
      when ALU_SUB =>
        result <= std_logic_vector(unsigned(a) - unsigned(b));
      when ALU_AND =>
        result <= a and b;
      when ALU_OR =>
        result <= a or b;
      when ALU_XOR =>
        result <= a xor b;
      when ALU_LEFT_SHIFT =>
        result <= std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(b(4 downto 0)))));
      when ALU_RIGHT_SHIFT =>
        result <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(b(4 downto 0)))));
      when ALU_ARITH_RIGHT_SHIFT =>
        result <= std_logic_vector(shift_right(signed(a), to_integer(unsigned(b(4 downto 0)))));
      when ALU_SLT =>
        if signed(a) < signed(b) then
          result <= (0 => '1', others => '0');
        else
          result <= (others => '0');
        end if;
      when ALU_SLTU =>
        if unsigned(a) < unsigned(b) then
          result <= (0 => '1', others => '0');
        else
          result <= (others => '0');
        end if;
      when others =>
        result <= (others => '0');
    end case;
  end process;
  zero <= '1' when result = (result'range => '0') else '0';

end architecture;
