library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.math_real.all;

entity SRAM is
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
    --! Habilitación de la escritura de la RAM. Activo a nivel alto.
    WE_I : in std_logic;
    --! Dirección de escritura/lectura de la RAM.
    ADDRESS_I : in std_logic_vector(integer(ceil(log2(real(G_DEPTH)))) - 1 downto 0);
    --! Dato de escritura en la RAM.
    DATA_I : in std_logic_vector(G_WIDTH - 1 downto 0);
    --! Dato leído de la RAM.
    DATA_O : out std_logic_vector(G_WIDTH - 1 downto 0)
  );
end SRAM;

architecture Behavioral of SRAM is

  --! Generación de la memoria RAM.
  type t_ram is array (0 to G_DEPTH - 1) of std_logic_vector(G_WIDTH - 1 downto 0);

  --! Registro de la RAM.
  signal r_mem : t_ram;

begin

  --! Escritura de los datos en la memoria RAM.
  WRITE_RAM : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        r_mem <= (others => (others => '0'));
      elsif EN_I = '1' then
        if WE_I = '1' then
          r_mem(to_integer(unsigned(ADDRESS_I))) <= DATA_I;
        end if;
      end if;
    end if;
  end process;

  --! El dato leído de la RAM.
  DATO_SALIDA : DATA_O <= r_mem(to_integer(unsigned(ADDRESS_I)));

end Behavioral;
