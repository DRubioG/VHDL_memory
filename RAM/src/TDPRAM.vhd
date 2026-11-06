library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.MATH_REAL.all;

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
    --! Habilitación del puerto A. Activo a nivel alto.
    EN_A_I : in std_logic;
    --! Habilitación del puerto B. Activo a nivel alto.
    EN_B_I : in std_logic;

    -- Puerto A
    --! Reloj de entrada del puerto A.
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
    --! Reloj de entrada del puerto B.
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

architecture syn of TDPRAM is
  --! Generación de la RAM.
  type t_ram is array (0 to G_DEPTH - 1) of std_logic_vector(G_WIDTH - 1 downto 0);
  --! Memoria de la RAM.
  shared variable r_mem : t_ram;
begin

  --! Este process se encarga del puerto A.
  PUERTO_A : process (CLK_A_I)
  begin
    if rising_edge(CLK_A_I) then
      if RST_N_I = '0' then
        DATA_READ_A_O <= (others => '0');
        r_mem := (others => (others => '0'));
      elsif EN_A_I = '1' then
        DATA_READ_A_O <= r_mem(to_integer(unsigned(ADDR_A_I)));
        if WE_A_I = '1' then
          r_mem(to_integer(unsigned(ADDR_A_I))) := DATA_WRITE_A_I;
        end if;
      end if;
    end if;
  end process;

  --! Este process se encarga de puerto B.
  PUERTO_B : process (CLK_B_I)
  begin
    if rising_edge(CLK_B_I) then
      if RST_N_I = '0' then
        DATA_READ_B_O <= (others => '0');
      elsif EN_B_I = '1' then
        DATA_READ_B_O <= r_mem(to_integer(unsigned(ADDR_B_I)));
        if WE_B_I = '1' then
          r_mem(to_integer(unsigned(ADDR_B_I))) := DATA_WRITE_B_I;
        end if;
      end if;
    end if;
  end process;

end syn;