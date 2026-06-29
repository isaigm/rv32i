library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.rv32i_pkg.all;

entity datapath_top is
  port (clk : in  std_logic;
        rst : in  std_logic;
        LED : out std_logic_vector(15 downto 0));
end entity;

architecture Behavioral of datapath_top is
  signal branch_taken  : std_logic;
  signal branch_target : std_logic_vector(31 downto 0);
  signal pc_plus_4     : std_logic_vector(31 downto 0);
  signal pc_current    : std_logic_vector(31 downto 0);
  signal next_pc       : std_logic_vector(31 downto 0);
  signal instr         : std_logic_vector(31 downto 0);

  signal opcode     : std_logic_vector(6 downto 0);
  signal funct3     : std_logic_vector(2 downto 0);
  signal funct7_bit : std_logic;
  signal rs1_addr   : std_logic_vector(4 downto 0);
  signal rs2_addr   : std_logic_vector(4 downto 0);
  signal rd_addr    : std_logic_vector(4 downto 0);

  signal reg_we  : std_logic;
  signal alu_op  : std_logic_vector(3 downto 0);
  signal alu_src : std_logic;
  signal imm_sel : std_logic_vector(2 downto 0);

  signal mem_write   : std_logic;
  signal branch      : std_logic;
  signal branch_cond : std_logic;
  signal jump        : std_logic;
  signal load_result : std_logic_vector(31 downto 0);
  signal rs1_data    : std_logic_vector(31 downto 0);
  signal rs2_data    : std_logic_vector(31 downto 0);
  signal imm         : std_logic_vector(31 downto 0);
  signal alu_b       : std_logic_vector(31 downto 0);
  signal alu_result  : std_logic_vector(31 downto 0);
  signal wb_data     : std_logic_vector(31 downto 0);
  signal wb_sel      : std_logic_vector(2 downto 0);
  signal jalr        : std_logic;
  signal jalr_target : std_logic_vector(31 downto 0);
  signal mem_data    : std_logic_vector(31 downto 0);
  signal store_out   : std_logic_vector(31 downto 0);
  signal byte_en     : std_logic_vector(3 downto 0);
  signal mem_byte_en : std_logic_vector(3 downto 0);
  signal led_reg     : std_logic_vector(15 downto 0) := (others => '0');
begin

  imem_inst: entity work.instruction_memory
    port map (
      addr  => pc_current(9 downto 0),
      instr => instr
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

  data_memory_inst: entity work.data_memory
    port map (
      clk        => clk,
      byte_en    => mem_byte_en,
      addr       => alu_result(9 downto 0),
      write_data => store_out,
      read_data  => mem_data
    );

  alu_inst: entity work.alu
    port map (
      a      => rs1_data,
      b      => alu_b,
      op     => alu_op,
      result => alu_result
    );

  branch_unit_inst: entity work.branch_unit
    port map (
      funct3 => funct3,
      rs1    => rs1_data,
      rs2    => rs2_data,
      take   => branch_cond
    );
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
      mem_write  => mem_write,
      branch     => branch,
      jalr       => jalr,
      jump       => jump
    );
  load_unit_inst: entity work.load_unit
    port map (
      funct3   => funct3,
      addr     => alu_result(1 downto 0),
      mem_data => mem_data,
      load_out => load_result
    );
  store_unit_inst: entity work.store_unit
    port map (
      funct3    => funct3,
      addr      => alu_result(1 downto 0),
      rs2_data  => rs2_data,
      store_out => store_out,
      byte_en   => byte_en
    );
  pc_inst: entity work.program_counter
    port map (
      clk     => clk,
      rst     => rst,
      next_pc => next_pc,
      pc      => pc_current
    );
  mem_byte_en <= byte_en when (mem_write = '1' and alu_result /= x"00001000") else "0000";

  alu_b <= rs2_data when alu_src = '0' else
           imm;
  wb_data <= alu_result    when wb_sel = WB_ALU else
             load_result   when wb_sel = WB_MEM else
             pc_plus_4     when wb_sel = WB_PC4 else
             imm           when wb_sel = WB_IMM else
             branch_target when wb_sel = WB_PCIMM else
             alu_result;
  jalr_target   <= alu_result(31 downto 1) & '0';
  branch_taken  <= branch and branch_cond;
  branch_target <= std_logic_vector(unsigned(pc_current) + unsigned(imm));
  pc_plus_4     <= std_logic_vector(unsigned(pc_current) + 4);

  next_pc <= jalr_target   when jalr = '1' else
             branch_target when (branch_taken = '1' or jump = '1') else
             pc_plus_4;
  opcode     <= instr(6 downto 0);
  funct3     <= instr(14 downto 12);
  funct7_bit <= instr(30);
  rs1_addr   <= instr(19 downto 15);
  rs2_addr   <= instr(24 downto 20);
  rd_addr    <= instr(11 downto 7);
 
  led_process: process (clk)
  begin
    if rising_edge(clk) then
      if mem_write = '1' and alu_result = x"00001000" then
        led_reg <= rs2_data(15 downto 0);
      end if;
    end if;
  end process;

  LED <= led_reg;

end architecture;
