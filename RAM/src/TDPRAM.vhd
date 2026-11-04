library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.math_real.all;

entity TDPRAM is
  generic (
    --! Tamaño de los datos.
    G_WIDTH : integer := 8;
    --! Profundidad de la RAM.
    G_DEPTH : integer := 32
  );
  port (
    --! Reset de la RAM. Activo a nivel bajo.
    RST_N_I : in std_logic;
    --! Habilitación de la RAM. Activo a nivel alto.
    EN_I : in std_logic;

    -- Puerto A
    --! Reloj de entrada A de la RAM.
    CLK_A_I : in std_logic;
    --! Habilitación de la escritura en el puerto A de la RAM. Activo a nivel alto.
    WE_A_I : in std_logic;
    --! Dirección de escritura en el puerto A de la RAM.
    ADDR_A_I : in std_logic_vector(integer(ceil(log2(real(G_DEPTH)))) - 1 downto 0);
    --! Dato de escritura en el puerto A de la RAM.
    DATA_WRITE_A_I : in std_logic_vector(G_WIDTH - 1 downto 0);
    --! Dato de lectura en el puerto A de la RAM.
    DATA_READ_A_O : out std_logic_vector(G_WIDTH - 1 downto 0);

    -- Puerto B
    --! Reloj de entrada B de la RAM.
    CLK_B_I : in std_logic;
    --! Habilitación de la escritura en el puerto B de la RAM. Activo a nivel alto.
    WE_B_I : in std_logic;
    --! Dirección de escritura en el puerto B de la RAM.
    ADDR_B_I : in std_logic_vector(integer(ceil(log2(real(G_DEPTH)))) - 1 downto 0);
    --! Dato de escritura en el puerto B de la RAM.
    DATA_WRITE_B_I : in std_logic_vector(G_WIDTH - 1 downto 0);
    --! Dato de lectura en el puerto B de la RAM.
    DATA_READ_B_O : out std_logic_vector(G_WIDTH - 1 downto 0)
  );
end TDPRAM;

architecture Behavioral of TDPRAM is
  --! Generación de la RAM.
  type t_ram is array (0 to G_DEPTH - 1) of std_logic_vector(G_WIDTH - 1 downto 0);
  --! Memoria de la RAM.
  signal r_mem : t_ram;

begin

  --! Gestión del puerto A.
  PUERTO_A : process (CLK_A_I)
  begin
    if rising_edge(CLK_A_I) then
      if WE_A_I = '1' then
        r_mem(to_integer(unsigned(ADDR_A_I))) <= DATA_WRITE_A_I;
      end if;

      DATA_READ_A_O <= r_mem(to_integer(unsigned(ADDR_A_I)));
    end if;
  end process;

  --! Gestión del puerto B.
  PUERTO_B : process (CLK_B_I)
  begin
    if rising_edge(CLK_B_I) then
      if WE_B_I = '1' then
        r_mem(to_integer(unsigned(ADDR_B_I))) <= DATA_WRITE_B_I;
      end if;

      DATA_READ_B_O <= r_mem(to_integer(unsigned(ADDR_B_I)));
    end if;
  end process;

end Behavioral;
