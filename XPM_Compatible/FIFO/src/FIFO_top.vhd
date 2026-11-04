library ieee;
use ieee.std_logic_1164.all;

entity top is
  generic (
    --! Tamaño de los datos del FIFO.
    G_WIDTH : integer := 8;
    --! Profundidad del FIFO.
    G_DEPTH : integer := 32;
    --! Indicador si el FIFO es sincrono o asíncrono.
    --! Opciones:
    --! "SYNC": síncrono.
    --! "ASYNC": asíncrono.
    G_FIFO_TYPE : string := "SYNC";
    --! Indicador si el FIFO a utilizar es propio de XILINX.
    --! Opciones:
    --! "XILINX": Utilizar la macro de Xilinx.
    --! "NONE": No utilizar la macro de Xilinx.
    G_USE_XILINX : string := "NONE"
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

architecture rtl of top is

begin

  --! En caso de querer utilizar la macro de Xilinx, se genera
  --! solo la macro de Xilinx.
  GEN_XILINX : if G_USE_XILINX = "XILINX" generate

    --! Instanciación del FIFO de Xilinx.
    FIFO_Xilinx_inst : entity work.FIFO_Xilinx
      generic map(
        G_WIDTH     => G_WIDTH,
        G_DEPTH     => G_DEPTH,
        G_FIFO_TYPE => G_FIFO_TYPE
      )
      port map
      (
        CLK_SYNC_I  => CLK_SYNC_I,
        CLK_WRITE_I => CLK_WRITE_I,
        CLK_READ_I  => CLK_READ_I,
        RST_N_I     => RST_N_I,
        EN_I        => EN_I,
        WRITE_I     => WRITE_I,
        DATA_I      => DATA_I,
        READ_I      => READ_I,
        DATA_O      => DATA_O,
        EMPTY_O     => EMPTY_O,
        FULL_O      => FULL_O
      );

  else
    generate

      --! Intanciación del FIFO genérico.
      FIFO_inst : entity work.FIFO
        generic map(
          G_WIDTH     => G_WIDTH,
          G_DEPTH     => G_DEPTH,
          G_FIFO_TYPE => G_FIFO_TYPE
        )
        port map
        (
          CLK_SYNC_I  => CLK_SYNC_I,
          CLK_WRITE_I => CLK_WRITE_I,
          CLK_READ_I  => CLK_READ_I,
          RST_N_I     => RST_N_I,
          EN_I        => EN_I,
          WRITE_I     => WRITE_I,
          DATA_I      => DATA_I,
          READ_I      => READ_I,
          DATA_O      => DATA_O,
          EMPTY_O     => EMPTY_O,
          FULL_O      => FULL_O
        );

    end generate;

  end architecture;