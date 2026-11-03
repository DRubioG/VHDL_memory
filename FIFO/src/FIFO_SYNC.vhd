library ieee;
use ieee.std_logic_1164.all;

entity FIFO_SYNC is
  generic (
    --! Tamaño de los datos de entrada y saldia del FIFO.
    G_WIDTH : integer := 8;
    --! Profundidad de datos del FIFO.
    G_DEPTH : integer := 32
  );
  port (
    --! Reloj de entrada del FIFO.
    CLK_I : in std_logic;
    --! Reset de entrada del módulo. Activo a nivel bajo.
    RST_N_I : in std_logic;
    --! Habilitación del módulo. Activo a nivel alto.
    EN_I : in std_logic;
    --! Dato de entrada al FIFO.
    DATA_I : in std_logic_vector(G_WIDTH - 1 downto 0);
    --! Indicación de lectura de datos del FIFO. Activo a nivel alto.
    READ_I : in std_logic;
    --! Dato de salida del FIFO.
    DATA_O : out std_logic_vector(G_WIDTH - 1 downto 0);
    --! Indicación de escritura del FIFO. Activo a nivel alto.
    WRITE_I : in std_logic;
    --! Indicador de que el FIFO está vació. Activo a nivel alto.
    EMPTY_O : out std_logic;
    --! Indicador de que el FIFO está completo. Activo a nivel alto.
    FULL_O : out std_logic
  );
end entity FIFO_SYNC;

architecture rtl of FIFO_SYNC is
  --! Generador de la memoria del FIFO.
  type t_mem is array (0 to G_DEPTH - 1) of std_logic_vector(G_WIDTH - 1 downto 0);
  --! Memoria del FIFO.
  signal r_fifo_rom : t_mem;
  --! Dirección de escritura del FIFO.
  signal r_cont_write : integer range 0 to G_DEPTH - 1;
  --! Dirección de lectura del FIFO.
  signal r_cont_read : integer range 0 to G_DEPTH - 1;
  --! Dirección diferencia entre escritura y lectura.
  signal r_diff : integer range 0 to G_DEPTH;

begin

  --! Asignación del dato de salida para que siempre haya una dato en el puerto de salida 
  --! y no tener que mandar la orden de lectura para leer.
  DATO_SALIDA : DATA_O <= r_fifo_rom(r_cont_read);

  --! Este process controla el FIFO. Por eso tiene dos partes, una de lectura y
  --! otra de escritura.
  FIFO_PROCESS : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        r_cont_write <= 0;
        r_cont_read  <= 0;
        r_diff       <= 0;
        for i in 0 to G_DEPTH - 1 loop
          r_fifo_rom(i) <= (others => '0');
        end loop;

      elsif EN_I = '1' then

        -- Escritura
        if WRITE_I = '1' and r_diff < G_DEPTH then
          r_fifo_rom(r_cont_write) <= DATA_I;

          if r_cont_write = G_DEPTH - 1 then
            r_cont_write <= 0;
          else
            r_cont_write <= r_cont_write + 1;
          end if;

          r_diff <= r_diff + 1;
        end if;
        -- Lectura
        if READ_I = '1' and r_diff > 0 then

          if r_cont_read = G_DEPTH - 1 then
            r_cont_read <= 0;
          else
            r_cont_read <= r_cont_read + 1;
          end if;

          r_diff <= r_diff - 1;
        end if;
      end if;
    end if;
  end process;

  --! Esto genera la señal que indica que el FIFO está vacío.
  EMPTY_ASSIGN : EMPTY_O <= '1' when r_diff = 0 else
  '0';

  --! Esto genera la señal que indica que el FIFO está completo.
  FULL_ASSIGN : FULL_O <= '1' when r_diff = G_DEPTH else
  '0';

end architecture;