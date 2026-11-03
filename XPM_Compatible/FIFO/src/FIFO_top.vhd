library ieee;
use ieee.std_logic_1164.all;

entity top is
  generic (
    G_WIDTH     : integer := 8;
    G_DEPTH     : integer := 32;
    USE_XILINX  : string  := "NONE";
    G_FIFO_TYPE : string  := "SYNC"
  );
  port (
    CLKA_I  : in std_logic;
    CLKB_I  : in std_logic;
    RST_N_I : in std_logic;
    EN_I    : in std_logic;
    DATA_I  : in std_logic_vector(7 downto 0);
    WRITE_I : in std_logic;
    READ_I  : in std_logic;
    DATA_O  : out std_logic_vector(7 downto 0);
    EMPTY_O : out std_logic;
    FULL_O  : out std_logic
  );
end entity;

architecture rtl of top is

begin

  GEN_XILINX : if USE_XILINX = "XILINX" generate
    FIFO_Xilinx_inst : entity work.FIFO_Xilinx
      generic map(
        G_WIDTH     => G_WIDTH,
        G_DEPTH     => G_DEPTH,
        G_FIFO_TYPE => G_FIFO_TYPE
      )
      port map
      (
        CLK_I   => CLKA_I,
        RST_N_I => RST_N_I,
        DATA_I  => DATA_I,
        WRITE_I => WRITE_I,
        READ_I  => READ_I,
        DATA_O  => DATA_O,
        EMPTY_O => EMPTY_O,
        FULL_O  => FULL_O
      );

  else
    generate

      FIFO_inst : entity work.FIFO
        generic map(
          G_WIDTH     => G_WIDTH,
          G_DEPTH     => G_DEPTH,
          G_FIFO_TYPE => G_FIFO_TYPE
        )
        port map
        (
          CLKA_I  => CLKA_I,
          CLKB_I  => CLKB_I,
          RST_N_I => RST_N_I,
          EN_I    => EN_I,
          DATA_I  => DATA_I,
          READ_I  => READ_I,
          DATA_O  => DATA_O,
          WRITE_I => WRITE_I,
          EMPTY_O => EMPTY_O,
          FULL_O  => FULL_O
        );
    end generate;

  end architecture;