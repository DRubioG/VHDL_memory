library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.math_real.all;
library xpm;
use xpm.vcomponents.all;

entity SDPRAM_Xilinx is
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
end SDPRAM_Xilinx;

architecture Behavioral of SDPRAM_Xilinx is

  --! Reset del módulo.
  signal s_rst : std_logic;

begin
  --! Negación del reset.
  RESET : s_rst <= not RST_N_I;

  --! Instanciación del SPRAM.
  xpm_memory_sdpram_inst : xpm_memory_sdpram
  generic map(
    ADDR_WIDTH_A            => ADDR_WRITE_I'length,
    ADDR_WIDTH_B            => ADDR_READ_I'length,
    AUTO_SLEEP_TIME         => 0,
    BYTE_WRITE_WIDTH_A      => 32,
    CASCADE_HEIGHT          => 0,
    CLOCKING_MODE           => "common_clock",
    ECC_BIT_RANGE           => "7:0",
    ECC_MODE                => "no_ecc",
    ECC_TYPE                => "none",
    MEMORY_INIT_FILE        => "none",
    MEMORY_INIT_PARAM       => "0",
    MEMORY_OPTIMIZATION     => "true",
    MEMORY_PRIMITIVE        => "auto",
    MEMORY_SIZE             => G_DEPTH,
    MESSAGE_CONTROL         => 0,
    READ_DATA_WIDTH_B       => G_WIDTH,
    READ_LATENCY_B          => 0,
    READ_RESET_VALUE_B      => "0",
    RST_MODE_A              => "SYNC",
    RST_MODE_B              => "SYNC",
    SIM_ASSERT_CHK          => 0,
    USE_EMBEDDED_CONSTRAINT => 0,
    USE_MEM_INIT            => 1,
    USE_MEM_INIT_MMI        => 0,
    WAKEUP_TIME             => "disable_sleep",
    WRITE_DATA_WIDTH_A      => G_WIDTH,
    WRITE_MODE_B            => "no_change",
    WRITE_PROTECT           => 1
  )
  port map
  (
    sleep          => '0',
    clka           => CLK_I,
    ena            => EN_I,
    wea            => WE_I & WE_I,
    addra          => ADDR_WRITE_I,
    dina           => DATA_WRITE_I,
    injectsbiterra => '0',
    injectdbiterra => '0',
    clkb           => CLK_I,
    rstb           => s_rst,
    enb            => EN_I,
    regceb         => '0',
    addrb          => ADDR_READ_I,
    doutb          => DATA_READ_O,
    sbiterrb       => open,
    dbiterrb       => open
  );
end Behavioral;
