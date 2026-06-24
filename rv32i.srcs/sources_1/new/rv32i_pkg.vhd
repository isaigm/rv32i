library IEEE;
  use IEEE.STD_LOGIC_1164.all;

package rv32i_pkg is
  constant ALU_SUM               : std_logic_vector(3 downto 0) := "0001";
  constant ALU_SUB               : std_logic_vector(3 downto 0) := "0010";
  constant ALU_AND               : std_logic_vector(3 downto 0) := "0011";
  constant ALU_OR                : std_logic_vector(3 downto 0) := "0100";
  constant ALU_XOR               : std_logic_vector(3 downto 0) := "0101";
  constant ALU_LEFT_SHIFT        : std_logic_vector(3 downto 0) := "0110";
  constant ALU_RIGHT_SHIFT       : std_logic_vector(3 downto 0) := "0111";
  constant ALU_ARITH_RIGHT_SHIFT : std_logic_vector(3 downto 0) := "1000";
  constant ALU_SLT               : std_logic_vector(3 downto 0) := "1001";
  constant ALU_SLTU              : std_logic_vector(3 downto 0) := "1011";

  constant IMM_I : std_logic_vector(2 downto 0) := "000";
  constant IMM_S : std_logic_vector(2 downto 0) := "001";
  constant IMM_U : std_logic_vector(2 downto 0) := "010";
  constant IMM_B : std_logic_vector(2 downto 0) := "011";
  constant IMM_J : std_logic_vector(2 downto 0) := "100";

  constant OPCODE_RTYPE  : std_logic_vector(6 downto 0) := "0110011";
  constant OPCODE_ITYPE  : std_logic_vector(6 downto 0) := "0010011";
  constant OPCODE_LOAD   : std_logic_vector(6 downto 0) := "0000011";
  constant OPCODE_STORE  : std_logic_vector(6 downto 0) := "0100011";
  constant OPCODE_BRANCH : std_logic_vector(6 downto 0) := "1100011";
  constant OPCODE_JAL    : std_logic_vector(6 downto 0) := "1101111";
  constant OPCODE_LUI    : std_logic_vector(6 downto 0) := "0110111";
  constant OPCODE_AUIPC  : std_logic_vector(6 downto 0) := "0010111";
  constant OPCODE_JALR   : std_logic_vector(6 downto 0) := "1100111";

  constant WB_ALU   : std_logic_vector(2 downto 0) := "000"; -- resultado de la ALU
  constant WB_MEM   : std_logic_vector(2 downto 0) := "001"; -- dato de memoria (loads)
  constant WB_PC4   : std_logic_vector(2 downto 0) := "010"; -- PC+4 (jal/jalr)
  constant WB_IMM   : std_logic_vector(2 downto 0) := "011"; -- inmediato (LUI)
  constant WB_PCIMM : std_logic_vector(2 downto 0) := "100"; -- PC+imm (AUIPC)
end package;
