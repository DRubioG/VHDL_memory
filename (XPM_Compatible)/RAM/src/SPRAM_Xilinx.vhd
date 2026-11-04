library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.math_real.all;
library xpm;
use xpm.vcomponents.all;

entity SPRAM_Xilinx is
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
end SPRAM_Xilinx;

architecture Behavioral of SPRAM_Xilinx is

  --! Reset del módulo.
  signal s_rst : std_logic;

begin
  --! Negación del reset.
  RESET : s_rst <= not RST_N_I;

  --! Instanciación del SPRAM.
  xpm_memory_spram_inst : xpm_memory_spram
  generic map(
    ADDR_WIDTH_A        => ADDRESS_I'length,
    AUTO_SLEEP_TIME     => 0,
    BYTE_WRITE_WIDTH_A  => G_WIDTH,
    CASCADE_HEIGHT      => 0,
    ECC_MODE            => "no_ecc",
    MEMORY_INIT_FILE    => "none",
    MEMORY_INIT_PARAM   => "0",
    MEMORY_OPTIMIZATION => "true",
    MEMORY_PRIMITIVE    => "auto",
    MEMORY_SIZE         => G_DEPTH,
    MESSAGE_CONTROL     => 0,
    READ_DATA_WIDTH_A   => G_WIDTH,
    READ_LATENCY_A      => 0,
    READ_RESET_VALUE_A  => "0",
    RST_MODE_A          => "SYNC",
    SIM_ASSERT_CHK      => 0,
    USE_MEM_INIT        => 1,
    USE_MEM_INIT_MMI    => 0,
    WAKEUP_TIME         => "disable_sleep",
    WRITE_DATA_WIDTH_A  => G_WIDTH,
    WRITE_MODE_A        => "read_first",
    WRITE_PROTECT       => 1
  )
  port map
  (
    sleep          => '0',
    clka           => CLK_I,
    rsta           => s_rst,
    ena            => EN_I,
    regcea         => '0',
    wea            => WE_I & WE_I,
    addra          => ADDRESS_I,
    dina           => DATA_I,
    injectsbiterra => '0',
    injectdbiterra => '0',
    douta          => DATA_O,
    sbiterra       => open,
    dbiterra       => open
  );

end Behavioral;
