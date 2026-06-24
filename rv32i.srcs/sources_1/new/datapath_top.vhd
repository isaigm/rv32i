library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.rv32i_pkg.all;
entity datapath_top is
  port (clk    : in  std_logic;
        rst    : in  std_logic;
        pc_out : out std_logic_vector(31 downto 0));
end entity;

architecture Behavioral of datapath_top is
  signal branch_taken  : std_logic;
  signal branch_target : std_logic_vector(31 downto 0);
  signal pc_plus_4     : std_logic_vector(31 downto 0);
  -- señales internas que conectan los bloques del fetch
  signal pc_current : std_logic_vector(31 downto 0); -- salida del PC
  signal next_pc    : std_logic_vector(31 downto 0); -- entrada del PC (pc+4)
  signal instr      : std_logic_vector(31 downto 0); -- salida de la imem

  -- campos extraídos de la instrucción
  signal opcode     : std_logic_vector(6 downto 0);
  signal funct3     : std_logic_vector(2 downto 0);
  signal funct7_bit : std_logic;
  signal rs1_addr   : std_logic_vector(4 downto 0);
  signal rs2_addr   : std_logic_vector(4 downto 0);
  signal rd_addr    : std_logic_vector(4 downto 0);

  -- señales de control (salen del control unit)
  signal reg_we     : std_logic;
  signal alu_op     : std_logic_vector(3 downto 0);
  signal alu_src    : std_logic;
  signal imm_sel    : std_logic_vector(2 downto 0);
  signal mem_read   : std_logic;
  signal mem_write  : std_logic;
  signal branch     : std_logic;
  signal jump       : std_logic;

  -- datos
  signal rs1_data   : std_logic_vector(31 downto 0);
  signal rs2_data   : std_logic_vector(31 downto 0);
  signal imm        : std_logic_vector(31 downto 0);
  signal alu_b      : std_logic_vector(31 downto 0); -- salida del MUX A
  signal alu_result : std_logic_vector(31 downto 0);
  signal zero_flag  : std_logic;
  signal wb_data    : std_logic_vector(31 downto 0); -- dato de writeback
  signal wb_sel     : std_logic_vector(2 downto 0);  -- dato de writeback

  signal mem_data : std_logic_vector(31 downto 0);
begin

  -- instancia del program counter
  pc_inst: entity work.program_counter
    port map (
      clk     => clk,
      rst     => rst,
      next_pc => next_pc,
      pc      => pc_current
    );

  imem_inst: entity work.instruction_memory
    port map (
      addr  => pc_current(9 downto 0),
      instr => instr
    );
  alu_b <= rs2_data when alu_src = '0' else
           imm;
  wb_data <= alu_result    when wb_sel = WB_ALU else
             mem_data      when wb_sel = WB_MEM else
             pc_plus_4     when wb_sel = WB_PC4 else
             imm           when wb_sel = WB_IMM else
             branch_target when wb_sel = WB_PCIMM else
             alu_result; -- fallback seguro
  branch_taken  <= branch and zero_flag;
  branch_target <= std_logic_vector(unsigned(pc_current) + unsigned(imm));
  pc_plus_4     <= std_logic_vector(unsigned(pc_current) + 4);
  next_pc       <= branch_target when (branch_taken = '1' or jump = '1') else
                   pc_plus_4;

  opcode     <= instr(6 downto 0);
  funct3     <= instr(14 downto 12);
  funct7_bit <= instr(30);
  rs1_addr   <= instr(19 downto 15);
  rs2_addr   <= instr(24 downto 20);
  rd_addr    <= instr(11 downto 7);

  pc_out <= pc_current;

  control_unit_inst: entity work.control_unit
    port map (
      opcode     => opcode,
      funct3     => funct3,
      funct7_bit => funct7_bit,
      reg_we     => reg_we,
      alu_op     => alu_op,
      alu_src    => alu_src,
      imm_sel    => imm_sel,
      wb_sel     => wb_sel,
      mem_read   => mem_read,
      mem_write  => mem_write,
      branch     => branch,
      jump       => jump
    );
  register_file_inst: entity work.register_file
    port map (
      clk      => clk,
      we       => reg_we,
      rs1_addr => rs1_addr,
      rs2_addr => rs2_addr,
      rd_addr  => rd_addr,
      rd_data  => wb_data,
      rs1_data => rs1_data,
      rs2_data => rs2_data
    );
  immediate_generator_inst: entity work.immediate_generator
    port map (
      instr   => instr,
      imm_sel => imm_sel,
      imm_out => imm
    );
  alu_inst: entity work.alu
    port map (
      a      => rs1_data,
      b      => alu_b,
      op     => alu_op,
      result => alu_result,
      zero   => zero_flag
    );

  data_memory_inst: entity work.data_memory
    port map (
      clk        => clk,
      mem_write  => mem_write,
      mem_read   => mem_read,
      addr       => alu_result(9 downto 0),
      write_data => rs2_data,
      read_data  => mem_data
    );
end architecture;
