library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.math_real.all;

entity SDPRAM is
  generic (
    --! Tamaño de los datos.
    G_WIDTH : integer := 8;
    --! Profundidad de la RAM.
    G_DEPTH : integer := 32
  );
  port (
    --! Reloj de entrada de la RAM.
    CLK_I : in std_logic;
    --! Reset de la RAM. Activo a nivel bajo.
    RST_N_I : in std_logic;
    --! Habilitación de la RAM. Activo a nivel alto.
    EN_I : in std_logic;

    -- Puerto Escritura
    --! Habilitación de escritura por el puerto A. Activo a nivel alto.
    WE_I : in std_logic;
    --! Dirección de escritura en la RAM.
    ADDR_WRITE_I : in std_logic_vector(integer(ceil(log2(real(G_DEPTH)))) - 1 downto 0);
    --! Dato a escribir en la RAM.
    DATA_WRITE_I : in std_logic_vector(G_WIDTH - 1 downto 0);

    -- Puerto Lectura
    --! Dirección de lectura en la RAM.
    ADDR_READ_I : in std_logic_vector(integer(ceil(log2(real(G_DEPTH)))) - 1 downto 0);
    --! Dato leído de la RAM.
    DATA_READ_O : out std_logic_vector(G_WIDTH - 1 downto 0)
  );
end SDPRAM;

architecture Behavioral of SDPRAM is

  --! Generación de la memoria de la RAM.
  type t_ram is array (0 to G_DEPTH - 1) of std_logic_vector(G_WIDTH - 1 downto 0);
  --! Memoria de la RAM.
  signal r_mem : t_ram;

begin

  --! Proceso de escritura en la RAM.
  WRITE_PROCESS : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        r_mem <= (others => (others => '0'));
      elsif EN_I = '1' then
        if WE_I = '1' then
          r_mem(to_integer(unsigned(ADDR_WRITE_I))) <= DATA_WRITE_I;
        end if;
      end if;
    end if;
  end process;

  --! Lectura de la RAM.
  DATA_OUTPUT : DATA_READ_O <= r_mem(to_integer(unsigned(ADDR_READ_I)));

end Behavioral;
