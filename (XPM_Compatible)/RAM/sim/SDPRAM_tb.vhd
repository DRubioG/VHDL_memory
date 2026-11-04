
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity SDPRAM_tb is
end;

architecture bench of SDPRAM_tb is
  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics
  constant G_WIDTH : integer := 8;
  constant G_DEPTH : integer := 32;
  -- Ports
  signal CLK_I        : std_logic := '0';
  signal RST_N_I      : std_logic;
  signal WE_I         : std_logic;
  signal ADDR_WRITE_I : std_logic_vector(integer(ceil(log2(real(G_DEPTH)))) - 1 downto 0);
  signal DATA_WRITE_I : std_logic_vector(G_WIDTH - 1 downto 0);
  signal ADDR_READ_I  : std_logic_vector(integer(ceil(log2(real(G_DEPTH)))) - 1 downto 0);
  signal DATA_READ_O  : std_logic_vector(G_WIDTH - 1 downto 0);
  signal r_cont       : integer := 0;
  signal s_block      : std_logic;
begin

  SDPRAM_inst : entity work.SDPRAM_Xilinx
    generic map(
      G_WIDTH => G_WIDTH,
      G_DEPTH => G_DEPTH
    )
    port map
    (
      CLK_I        => CLK_I,
      RST_N_I      => RST_N_I,
      EN_I         => '1',
      WE_I         => WE_I,
      ADDR_WRITE_I => ADDR_WRITE_I,
      DATA_WRITE_I => DATA_WRITE_I,
      ADDR_READ_I  => ADDR_READ_I,
      DATA_READ_O  => DATA_READ_O
    );
  CLK_I   <= not CLK_I after clk_period/2;
  RST_N_I <= '0', '1' after 50 ns;

  process begin
    r_cont <= r_cont + 1;
    if r_cont >= G_DEPTH then
      s_block <= '1';
    else
      s_block <= '0';
    end if;
    wait for 1 us;
  end process;

  process begin
    ADDR_WRITE_I <= std_logic_vector(to_unsigned(r_cont, ADDR_WRITE_I'length));
    DATA_WRITE_I <= std_logic_vector(to_unsigned(r_cont, DATA_WRITE_I'length));
    wait for 1 us;
  end process;

  process begin
    WE_I <= '0';
    wait for 1 us;
    if s_block = '0' then
      WE_I <= '1';
      wait for clk_period;
    end if;
  end process;
  process begin
    ADDR_READ_I <= std_logic_vector(to_unsigned(r_cont, ADDR_READ_I'length) + 2);

    wait for 1 us;
  end process;
end;