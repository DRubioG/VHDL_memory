
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_ASYNC is
  generic (
    --! Tamaño de los datos del FIFO.
    G_WIDTH : integer := 8;
    --! Profundidad del FIFO.
    G_DEPTH : integer := 32
  );
  port (
    --! Reset del módulo. Activo a nivel bajo.
    RST_N_I : in std_logic;
    --! Habilitación del módulo. Activo a nivel alto.
    EN_I    : in std_logic;

    -- Dominio de escritura.
    --! Reloj de escritura en el FIFO.
    CLK_WRITE_I : in std_logic;
    --! Dato a escribir en el FIFO.
    DATA_I      : in std_logic_vector(G_WIDTH - 1 downto 0);
    --! Indicador de escritura en el FIFO. Activo a nivel alto.
    WRITE_I     : in std_logic;
    --! Indicador de que el FIFO está completo. Activo a nivel alto.
    FULL_O      : out std_logic;

    -- Dominio de lectura.
    --! Reloj de lectura del FIFO.
    CLK_READ_I : in std_logic;
    --! Dato leído del FIFO.
    DATA_O     : out std_logic_vector(G_WIDTH - 1 downto 0);
    --! Indicador de lectura del FIFO. Activo a nivel alto.
    READ_I     : in std_logic;
    --! Indicador de que el FIFO está vacío. Activo a nivel alto.
    EMPTY_O    : out std_logic
  );
end entity;

architecture rtl of FIFO_ASYNC is

  --! Generador de memoria.
  type t_mem is array (0 to G_DEPTH - 1) of std_logic_vector(G_WIDTH - 1 downto 0);
  --! Memoria del FIFO.
  signal r_mem : t_mem;

  --! Dirección de escritura del FIFO.
  signal r_cont_write : integer range 0 to G_DEPTH;
  --! Dirección de lectura del FIFO.
  signal r_cont_read : integer range 0 to G_DEPTH;

  --! Dirección diferencia entre escritura y lectura.
  signal r_diff : integer range 0 to G_DEPTH;

begin

  --! Escritura de los datos en el FIFO.
  ESCRITURA : process (CLK_WRITE_I)
  begin
    if rising_edge(CLK_WRITE_I) then
      if RST_N_I = '0' then
        r_cont_write <= 0;
        r_mem        <= (others => (others => '0'));
      elsif EN_I = '1' then
        if WRITE_I = '1' and r_cont_write < G_DEPTH then
          r_mem(r_cont_write) <= DATA_I;
          r_cont_write        <= r_cont_write + 1;
        end if;
      end if;
    end if;
  end process;

  --! Lectura de los datos del FIFO.
  LECTURA : process (CLK_READ_I)
  begin
    if rising_edge(CLK_READ_I) then
      if RST_N_I = '0' then
        r_cont_read <= 0;
        DATA_O      <= (others => '0');
      elsif EN_I = '1' then
        if READ_I = '1' and r_cont_read < G_DEPTH then
          DATA_O      <= r_mem(r_cont_read);
          r_cont_read <= r_cont_read + 1;
        end if;
      end if;
    end if;
  end process;

  --! Esto calcula cuál es a diferencia entre el indice de escritura y el indice de lectura.
  DIFERENCIA_INDICES : r_diff <= r_cont_write - r_cont_read;

  --! Esto genera la señal que indica que el FIFO está vacío.
  EMPTY_ASSIGN : EMPTY_O <= '1' when r_diff = 0 else
  '0';

  --! Esto genera la señal que indica que el FIFO está completo.
  FULL_ASSIGN : FULL_O <= '1' when r_diff = G_DEPTH else
  '0';

end architecture;
