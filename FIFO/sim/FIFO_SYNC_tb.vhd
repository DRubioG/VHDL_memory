
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_SYNC_tb is
end;

architecture bench of FIFO_SYNC_tb is
  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics
  constant G_WIDTH : integer := 8;
  constant G_DEPTH : integer := 32;
  -- Ports
  signal CLK_I   : std_logic := '0';
  signal RST_N_I : std_logic;
  signal EN_I    : std_logic;
  signal DATA_I  : std_logic_vector(G_WIDTH - 1 downto 0);
  signal READ_I  : std_logic;
  signal DATA_O  : std_logic_vector(G_WIDTH - 1 downto 0);
  signal WRITE_I : std_logic;
  signal EMPTY_O : std_logic;
  signal FULL_O  : std_logic;
  signal r_cont  : integer range 0 to 2 ** G_WIDTH := 0;
  signal s_block : std_logic;
begin

  FIFO_SYNC_inst : entity work.FIFO_SYNC
    generic map(
      G_WIDTH => G_WIDTH,
      G_DEPTH => G_DEPTH
    )
    port map
    (
      CLK_I   => CLK_I,
      RST_N_I => RST_N_I,
      EN_I    => EN_I,
      DATA_I  => DATA_I,
      READ_I  => READ_I,
      DATA_O  => DATA_O,
      WRITE_I => WRITE_I,
      EMPTY_O => EMPTY_O,
      FULL_O  => FULL_O
    );
  CLK_I   <= not CLK_I after clk_period/2;
  RST_N_I <= '0', '1' after 50 ns;
  EN_I    <= '1';

  process begin
    wait for 1 us;
    r_cont <= r_cont + 1;
    if r_cont >= G_DEPTH then
      r_cont <= 0;
    end if;
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
      wait for clk_period;
      READ_I <= '0';
      wait for 1 us;
    end loop;
    assert false report "Finish" severity failure;

  end process;
end;