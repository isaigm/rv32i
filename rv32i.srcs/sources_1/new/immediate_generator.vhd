library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.rv32i_pkg.all;
entity immediate_generator is
  port (instr   : in  std_logic_vector(31 downto 0);
        imm_sel : in  std_logic_vector(2 downto 0);
        imm_out : out std_logic_vector(31 downto 0));

end entity;

architecture Behavioral of immediate_generator is
 

begin
  process (instr, imm_sel)
  begin
    case imm_sel is
      when IMM_I =>
        imm_out(11 downto 0) <= instr(31 downto 20);
        imm_out(31 downto 12) <= (others => instr(31));
      when IMM_S =>
        imm_out(11 downto 5) <= instr(31 downto 25);
        imm_out(4 downto 0) <= instr(11 downto 7);
        imm_out(31 downto 12) <= (others => instr(31));
      when IMM_U =>
        imm_out(31 downto 12) <= instr(31 downto 12);
        imm_out(11 downto 0) <= (others => '0');
      when IMM_B =>
        imm_out(0) <= '0';
        imm_out(4 downto 1) <= instr(11 downto 8);
        imm_out(10 downto 5) <= instr(30 downto 25);
        imm_out(11) <= instr(7);
        imm_out(12) <= instr(31);
        imm_out(31 downto 13) <= (others => instr(31));
      when IMM_J =>
        imm_out(0) <= '0';
        imm_out(10 downto 1) <= instr(30 downto 21);
        imm_out(11) <= instr(20);
        imm_out(19 downto 12) <= instr(19 downto 12);
        imm_out(20) <= instr(31);
        imm_out(31 downto 21) <= (others => instr(31));
      when others => imm_out <= (others => '0');
    end case;
  end process;
end architecture;
