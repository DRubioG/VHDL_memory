library ieee;
use ieee.std_logic_1164.all;

library xpm;
use xpm.vcomponents.all;

entity FIFO_Xilinx is
  generic (
    --! Tamaño de los datos del FIFO.
    G_WIDTH : integer := 8;
    --! Profundidad del FIFO.
    G_DEPTH : integer := 32;
    --! Indicador si el FIFO es sincrono o asíncrono.
    --! Opciones:
    --! "SYNC": síncrono.
    --! "ASYNC": asíncrono.
    G_FIFO_TYPE : string := "SYNC"
  );
  port (
    --! Reloj de entrada para el FIFO síncrono. Este puerto solo funciona
    --! cuando el G_FIFO_TYPE es "SYNC"".
    CLK_SYNC_I : in std_logic;
    --! Reloj para la escritura en el FIFO. Este puerto solo funciona cuando
    --! el G_FIFO_TYPE es "ASYNC".
    CLK_WRITE_I : in std_logic;
    --! Reloj para la lectura del FIFO. Este puerto solo funciona cuando
    --! el G_FIFO_TYPE es "ASYNC".
    CLK_READ_I : in std_logic;
    --! Reset del FIFO. Activo a nivel bajo.
    RST_N_I : in std_logic;
    --! Habilitación del FIFO. Activo a nivel alto.
    EN_I : in std_logic;
    --! Indicador de escritura en el FIFO. Activo a nivel alto.
    WRITE_I : in std_logic;
    --! Dato a escribir en el FIFO.
    DATA_I : in std_logic_vector(G_WIDTH - 1 downto 0);
    --! Indicador de lectura del FIFO. Activo a nivel alto.
    READ_I : in std_logic;
    --! Dato leído del FIFO.
    DATA_O : out std_logic_vector(G_WIDTH - 1 downto 0);
    --! Indicador de que el FIFO está vacío.  Activo a nivel alto.
    EMPTY_O : out std_logic;
    --! Indicador de que el FIFO está completo. Activo a nivel alto.
    FULL_O : out std_logic
  );
end entity;

architecture rtl of FIFO_Xilinx is

  --! Señal utilizada para negar el reset.
  signal s_rst : std_logic;

begin

  --! Negación del reset. Esto es debido a que los módulos de Xilinx utilizan un reset a nivel alto.
  RESET : s_rst <= not RST_N_I;

  --! Este generate selecciona el módulo XPM de Xilinx a utilizar dependiendo del tipo de FIFO.
  FIFO_TYPE_GEN : if G_FIFO_TYPE = "SYNC" generate

    --! Instanciación del FIFO síncrono.
    U_FIFO : xpm_fifo_sync
    generic map(
      FIFO_MEMORY_TYPE  => "auto",
      FIFO_WRITE_DEPTH  => G_DEPTH,
      WRITE_DATA_WIDTH  => G_WIDTH,
      READ_DATA_WIDTH   => G_WIDTH,
      READ_MODE         => "std",
      FIFO_READ_LATENCY => 0,
      USE_ADV_FEATURES  => "0000"
    )
    port map
    (
      sleep         => '0',
      rst           => s_rst,
      wr_clk        => CLK_SYNC_I,
      wr_en         => WRITE_I,
      din           => DATA_I,
      full          => FULL_O,
      rd_en         => READ_I,
      dout          => DATA_O,
      empty         => EMPTY_O,
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

      --! Instanciación del FIFO asíncrono.
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
        wr_clk        => CLK_WRITE_I,
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
        rd_clk        => CLK_READ_I,
        rd_rst_busy   => open,
        rd_en         => READ_I,
        dout          => DATA_O,
        data_valid    => open,
        empty         => EMPTY_O,
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