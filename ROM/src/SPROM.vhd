library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.math_real.all;

entity SPROM is
  generic (
    --! Tamaño de los datos.
    G_WIDTH : integer := 8;
    --! Profundidad de la ROM.
    G_DEPTH : integer := 16
  );
  port (
    --! Reloj de entrada de la ROM.
    CLK_I : in std_logic;
    --! Reset de la ROM. Activo a nivel bajo.
    RST_N_I : in std_logic;
    --! Habilitación de la ROM. Activo a nivel alto.
    EN_I : in std_logic;
    --! Dirección de lectura de la ROM.
    ADDR_I : in std_logic_vector(integer(ceil(log2(real(G_DEPTH)))) - 1 downto 0);
    --! Dato leído de la ROM.
    DATA_O : out std_logic_vector(G_WIDTH - 1 downto 0)
  );
end SPROM;

architecture Behavioral of SPROM is

  --! Generación de la memoria.
  type t_rom is array (0 to G_DEPTH - 1) of std_logic_vector(G_WIDTH - 1 downto 0);
  --! Memoria ROM.
  constant r_mem : t_rom := (
  0  => "00000001",
  1  => "00000010",
  2  => "00100011",
  3  => "01000100",
  4  => "00000101",
  5  => "01000110",
  6  => "00000111",
  7  => "00101000",
  8  => "01101001",
  9  => "00001010",
  10 => "00001011",
  11 => "00001100",
  12 => "00001101",
  13 => "00001110",
  14 => "00001111",
  15 => "11111111"
  );

begin

  --! Este process lee el valor de la memoria.
  LECTURA : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        DATA_O <= (others => '0');
      elsif EN_I = '1' then
        DATA_O <= r_mem(to_integer(unsigned(ADDR_I)));
      end if;
    end if;
  end process;

end Behavioral;
