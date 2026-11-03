library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity FIFO is
  generic (
    G_WIDTH     : integer := 8;
    G_DEPTH     : integer := 32;
    G_FIFO_TYPE : string  := "SYNC"
  );
  port (
    CLKA_I   : in std_logic;
    CLKB_I   : in std_logic;
    RST_N_I : in std_logic;
    EN_I    : in std_logic;
    DATA_I  : in std_logic_vector(G_WIDTH - 1 downto 0);
    READ_I  : in std_logic;
    DATA_O  : out std_logic_vector(G_WIDTH - 1 downto 0);
    WRITE_I : in std_logic;
    EMPTY_O : out std_logic;
    FULL_O  : out std_logic
  );
end entity FIFO;

architecture rtl of FIFO is
begin

  FIFO_TYPE_GEN : if G_FIFO_TYPE = "SYNC" generate

    FIFO_SYNC_inst : entity work.FIFO_SYNC
      generic map(
        G_WIDTH => G_WIDTH,
        G_DEPTH => G_DEPTH
      )
      port map
      (
        CLK_I   => CLKA_I,
        RST_N_I => RST_N_I,
        EN_I    => EN_I,
        DATA_I  => DATA_I,
        READ_I  => READ_I,
        DATA_O  => DATA_O,
        WRITE_I => WRITE_I,
        EMPTY_O => EMPTY_O,
        FULL_O  => FULL_O
      );

  elsif G_FIFO_TYPE = "ASYNC" generate

      FIFO_ASYNC_inst : entity work.FIFO_ASYNC
        generic map(
          G_DATA_WIDTH => G_WIDTH,
          G_FIFO_DEPTH => G_DEPTH
        )
        port map
        (
          RST_N_I     => RST_N_I,
          CLK_WRITE_I => CLKA_I,
          DATA_I      => DATA_I,
          WRITE_I     => WRITE_I,
          FULL_O      => FULL_O,
          CLK_READ_I  => CLKB_I,
          READ_I      => READ_I,
          DATA_O      => DATA_O,
          EMPTY_O     => EMPTY_O
        );

    end generate;

  end architecture;