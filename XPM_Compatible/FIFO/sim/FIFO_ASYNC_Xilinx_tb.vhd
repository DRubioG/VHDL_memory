
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_ASYNC_Xilinx_tb is
end;

architecture bench of FIFO_ASYNC_Xilinx_tb is
  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics
  constant G_WIDTH : integer := 8;
  constant G_DEPTH : integer := 32;
  -- Ports
  signal RST_N_I     : std_logic;
  signal CLK_WRITE_I : std_logic := '0';
  signal DATA_I      : std_logic_vector(G_WIDTH - 1 downto 0);
  signal WRITE_I     : std_logic;
  signal FULL_O      : std_logic;
  signal CLK_READ_I  : std_logic := '0';
  signal READ_I      : std_logic;
  signal DATA_O      : std_logic_vector(G_WIDTH - 1 downto 0);
  signal EMPTY_O     : std_logic;
  signal r_cont      : integer := 0; 
  signal s_block     : std_logic;
begin

  FIFO_Xilinx_inst : entity work.FIFO_Xilinx
    generic map(
      G_WIDTH     => G_WIDTH,
      G_DEPTH     => G_DEPTH,
      G_FIFO_TYPE => "ASYNC"
    )
    port map
    (
      CLK_SYNC_I  => '0',
      CLK_WRITE_I => CLK_WRITE_I,
      CLK_READ_I  => CLK_READ_I,
      RST_N_I     => RST_N_I,
      EN_I        => '1',
      WRITE_I     => WRITE_I,
      DATA_I      => DATA_I,
      READ_I      => READ_I,
      DATA_O      => DATA_O,
      EMPTY_O     => EMPTY_O,
      FULL_O      => FULL_O
    );

  CLK_WRITE_I <= not CLK_WRITE_I after clk_period/2;
  CLK_READ_I  <= not CLK_READ_I after 3 * clk_period/2;
  RST_N_I     <= '0', '1' after 50 ns;
  process begin
    wait for 1 us;
    r_cont <= r_cont + 1;
    -- if r_cont >= G_DEPTH then
    --   r_cont <= 0;
    -- end if;
  end process;

  process begin
    DATA_I <= std_logic_vector(to_unsigned(r_cont, G_WIDTH));
    wait for 1 us;
  end process;

  process begin
    WRITE_I <= '0';
    wait for 1 us;
    if s_block = '0' then
      WRITE_I <= '1';
      wait for clk_period;
    end if;
  end process;

  process begin
    s_block <= '0';
    READ_I  <= '0';
    wait until FULL_O = '1';
    s_block <= '1';
    wait for 1 us;
    for i in 0 to G_DEPTH loop
      READ_I <= '1';
      wait for 3 * clk_period*32;
      READ_I <= '0';
      wait for 1 us;
    end loop;
    assert false report "Finish" severity failure;

  end process;
end;