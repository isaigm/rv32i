library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity tb_datapath is
  -- un testbench NO tiene puertos: es el "mundo exterior"
end entity;

architecture sim of tb_datapath is
  -- señales locales para conectar al DUT (Device Under Test)
  signal clk    : std_logic := '0';
  signal rst    : std_logic := '1';   -- arranca en reset
  signal pc_out : std_logic_vector(31 downto 0);
  signal LED:   std_logic_vector(15 downto 0);
  constant CLK_PERIOD : time := 10 ns;
begin

  -- instancia de tu diseño (el DUT)
  dut: entity work.datapath_top
    port map (
      clk    => clk,
      rst    => rst,
      LED => LED
    );

  -- generación del reloj: oscila para siempre
  clk_process: process
  begin
    clk <= '0';
    wait for CLK_PERIOD / 2;
    clk <= '1';
    wait for CLK_PERIOD / 2;
  end process;

  -- estímulo: maneja el reset y luego deja correr
  stim_process: process
  begin
    rst <= '1';                  -- mantener reset al inicio
    wait for 2 * CLK_PERIOD ;      -- HUECO 1: cuánto tiempo en reset
    rst <= '0';                  -- soltar el reset → el PC empieza a avanzar
    wait for 20 * CLK_PERIOD ;      -- HUECO 2: dejar correr un rato
    wait;                        -- detener el estímulo (la simulación sigue)
  end process;

end architecture;