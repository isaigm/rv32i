library ieee;
  use ieee.std_logic_1164.all;
  use work.rv32i_pkg.all;

entity control_unit is
  port (opcode     : in  std_logic_vector(6 downto 0);
        funct3     : in  std_logic_vector(2 downto 0);
        funct7_bit : in  std_logic;
        reg_we     : out std_logic;
        alu_op     : out std_logic_vector(3 downto 0);
        alu_src    : out std_logic;
        imm_sel    : out std_logic_vector(2 downto 0);
        wb_sel     : out std_logic_vector(2 downto 0);
        mem_read   : out std_logic;
        mem_write  : out std_logic;
        branch     : out std_logic;
        jalr       : out std_logic;
        jump       : out std_logic);
end entity;

architecture Behavioral of control_unit is
begin
  process (opcode, funct3, funct7_bit)
  begin
    wb_sel <= WB_ALU;
    reg_we <= '0';
    alu_op <= (others => '0');
    alu_src <= '0';
    imm_sel <= (others => '0');
    mem_read <= '0';
    mem_write <= '0';
    branch <= '0';
    jump <= '0';
    jalr <= '0';
    case opcode is
      when OPCODE_LOAD =>
        reg_we <= '1';
        alu_op <= ALU_SUM;
        alu_src <= '1';
        imm_sel <= IMM_I;
        mem_read <= '1';
        wb_sel <= WB_MEM;
      when OPCODE_STORE =>
        alu_op <= ALU_SUM;
        alu_src <= '1';
        imm_sel <= IMM_S;
        mem_write <= '1';
      when OPCODE_RTYPE =>
        reg_we <= '1';
        case funct3 is
          when "000" =>
            if funct7_bit = '1' then
              alu_op <= ALU_SUB;
            else
              alu_op <= ALU_SUM;
            end if;
          when "001" => alu_op <= ALU_LEFT_SHIFT;
          when "010" => alu_op <= ALU_SLT;
          when "011" => alu_op <= ALU_SLTU;
          when "100" => alu_op <= ALU_XOR;
          when "101" => if funct7_bit = '1' then
                          alu_op <= ALU_ARITH_RIGHT_SHIFT; -- 
                        else
                          alu_op <= ALU_RIGHT_SHIFT;
                        end if;
          when "110" => alu_op <= ALU_OR;
          when "111" => alu_op <= ALU_AND;
          when others => alu_op <= ALU_SUM;
        end case;
      when OPCODE_ITYPE =>
        reg_we <= '1';
        alu_src <= '1';
        imm_sel <= IMM_I;
        case funct3 is
          when "000" => alu_op <= ALU_SUM;
          when "001" => alu_op <= ALU_LEFT_SHIFT;
          when "010" => alu_op <= ALU_SLT;
          when "011" => alu_op <= ALU_SLTU;
          when "100" => alu_op <= ALU_XOR;
          when "101" =>
            if funct7_bit = '1' then
              alu_op <= ALU_ARITH_RIGHT_SHIFT;
            else
              alu_op <= ALU_RIGHT_SHIFT;
            end if;
          when "110" => alu_op <= ALU_OR;
          when "111" => alu_op <= ALU_AND;
          when others => alu_op <= ALU_SUM;
        end case;
      when OPCODE_BRANCH =>
        alu_op <= ALU_SUB;
        imm_sel <= IMM_B;
        branch <= '1';
      when OPCODE_JAL =>
        reg_we <= '1';
        imm_sel <= IMM_J;
        jump <= '1';
        wb_sel <= WB_PC4;
      when OPCODE_JALR =>
        reg_we <= '1';
        imm_sel <= IMM_I;
        alu_src <= '1';
        alu_op <= ALU_SUM;
        jump <= '1';
        jalr <= '1';
        wb_sel <= WB_PC4;
      when OPCODE_LUI =>
        reg_we <= '1';
        imm_sel <= IMM_U;
        wb_sel <= WB_IMM;
      when OPCODE_AUIPC =>
        reg_we <= '1';
        imm_sel <= IMM_U;
        wb_sel <= WB_PCIMM;

      when others => null;
    end case;
  end process;
end architecture;
