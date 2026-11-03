library ieee;
use ieee.std_logic_1164.all;

library xpm;
use xpm.vcomponents.all;

entity FIFO_Xilinx is
  generic (
    G_WIDTH     : integer := 8;
    G_DEPTH     : integer := 32;
    G_FIFO_TYPE : string  := "SYNC"
  );
  port (
    CLK_I   : in std_logic;
    RST_N_I : in std_logic;
    DATA_I  : in std_logic_vector(7 downto 0);
    WRITE_I : in std_logic;
    READ_I  : in std_logic;
    DATA_O  : out std_logic_vector(7 downto 0);
    EMPTY_O : out std_logic;
    FULL_O  : out std_logic
  );
end entity;

architecture rtl of FIFO_Xilinx is

  signal s_rst : std_logic;

begin

  s_rst <= not RST_N_I;

  FIFO_TYPE_GEN : if G_FIFO_TYPE = "SYNC" generate

    U_FIFO : xpm_fifo_sync
    generic map(
      FIFO_MEMORY_TYPE  => "auto",
      FIFO_WRITE_DEPTH  => G_DEPTH,
      WRITE_DATA_WIDTH  => G_WIDTH,
      READ_DATA_WIDTH   => G_WIDTH,
      READ_MODE         => "std",
      FIFO_READ_LATENCY => 1,
      USE_ADV_FEATURES  => "0000"
    )
    port map
    (
      sleep         => '0',
      rst           => s_rst,
      wr_clk        => CLK_I,
      wr_en         => WRITE_I,
      din           => DATA_I,
      full          => FULL_O,
      rd_en         => READ_I,
      dout          => DATA_O,
      empty         => EMPTY_I,
      data_valid    => open,
      overflow      => open,
      underflow     => open,
      wr_rst_busy   => open,
      rd_rst_busy   => open,
      almost_empty  => open,
      almost_full   => open,
      prog_empty    => open,
      prog_full     => open,
      rd_data_count => open,
      wr_data_count => open,
      injectsbiterr => '0',
      injectdbiterr => '0',
      sbiterr       => open,
      dbiterr       => open
    );

  elsif G_FIFO_TYPE = "ASYNC" generate

      xpm_fifo_async_inst : xpm_fifo_async
      generic map(
        CDC_SYNC_STAGES   => 2,
        FIFO_MEMORY_TYPE  => "auto",
        FIFO_READ_LATENCY => 1,
        FIFO_WRITE_DEPTH  => G_DEPTH,
        READ_DATA_WIDTH   => G_WIDTH,
        READ_MODE         => "std",
        WRITE_DATA_WIDTH  => G_WIDTH
      )
      port map
      (
        sleep         => '0',
        wr_clk        => wr_clk,
        rst           => s_rst,
        wr_rst_busy   => open,
        wr_en         => WRITE_I,
        din           => DATA_I,
        wr_ack        => open,
        full          => FULL_O,
        prog_full     => open,
        almost_full   => open,
        overflow      => open,
        wr_data_count => open,
        rd_clk        => rd_clk,
        rd_rst_busy   => rd_rst_busy,
        rd_en         => READ_I,
        dout          => DATA_O,
        data_valid    => open,
        empty         => EMPTY_I,
        prog_empty    => open,
        almost_empty  => open,
        underflow     => open,
        rd_data_count => open,
        injectsbiterr => '0',
        injectdbiterr => '0',
        sbiterr       => open,
        dbiterr       => open
      );

    end generate;
  end architecture;