library ieee;
use ieee.std_logic_1164.all;

entity FIFO is
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
end entity FIFO;

architecture rtl of FIFO is
begin

  --! Este generate selecciona el tipo de FIFO a generar, si es síncrono o 
  --! es asíncrono.
  FIFO_TYPE_GEN : if G_FIFO_TYPE = "SYNC" generate

    --! Instanciación del FIFO síncrono.
    FIFO_SYNC_inst : entity work.FIFO_SYNC
      generic map(
        G_WIDTH   => G_WIDTH,
        G_DEPTH   => G_DEPTH
      )
      port map
      (
        CLK_I   => CLK_SYNC_I,
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

      --! Instanciación del FIFO asíncrono.
      FIFO_ASYNC_inst : entity work.FIFO_ASYNC
        generic map(
          G_WIDTH => G_WIDTH,
          G_DEPTH => G_DEPTH
        )
        port map
        (
          RST_N_I     => RST_N_I,
          EN_I        => EN_I,
          CLK_WRITE_I => CLK_WRITE_I,
          DATA_I      => DATA_I,
          WRITE_I     => WRITE_I,
          FULL_O      => FULL_O,
          CLK_READ_I  => CLK_READ_I,
          READ_I      => READ_I,
          DATA_O      => DATA_O,
          EMPTY_O     => EMPTY_O
        );

    end generate;

  end architecture;