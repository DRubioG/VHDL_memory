
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_ASYNC is
  generic (
    G_DATA_WIDTH : integer := 32;
    G_FIFO_DEPTH : integer := 1024
  );
  port (
    RST_N_I : in std_logic;

    -- Write domain
    CLK_WRITE_I : in std_logic;
    DATA_I      : in std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    WRITE_I     : in std_logic;
    FULL_O      : out std_logic;

    -- Read domain
    CLK_READ_I : in std_logic;
    READ_I     : in std_logic;
    DATA_O     : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    EMPTY_O    : out std_logic
  );
end entity;

architecture rtl of FIFO_ASYNC is

  -- FIFO memory
  type t_mem is array (0 to G_FIFO_DEPTH - 1) of std_logic_vector(G_DATA_WIDTH - 1 downto 0);

  signal r_mem : t_mem;

  -- Pointer width (one extra bit)
  function clog2(n : integer) return integer is
    variable v       : integer := n - 1;
    variable r       : integer := 0;
  begin
    while v > 0 loop
      r := r + 1;
      v := v/2;
    end loop;
    return r;
  end function;

  constant C_ADDR_WIDTH : integer := clog2(G_FIFO_DEPTH);
  constant C_PTR_WIDTH  : integer := C_ADDR_WIDTH + 1;

  -- Binary pointers
  signal r_wr_bin : unsigned(C_PTR_WIDTH - 1 downto 0);
  signal r_rd_bin : unsigned(C_PTR_WIDTH - 1 downto 0);

  -- Gray pointers
  signal r_wr_gray : unsigned(C_PTR_WIDTH - 1 downto 0);
  signal r_rd_gray : unsigned(C_PTR_WIDTH - 1 downto 0);

  -- Synchronized pointers
  signal r_rd_gray_sync1 : unsigned(C_PTR_WIDTH - 1 downto 0);
  signal r_rd_gray_sync2 : unsigned(C_PTR_WIDTH - 1 downto 0);

  signal r_wr_gray_sync1 : unsigned(C_PTR_WIDTH - 1 downto 0);
  signal r_wr_gray_sync2 : unsigned(C_PTR_WIDTH - 1 downto 0);

  -- Status
  signal s_full  : std_logic;
  signal s_empty : std_logic;

  signal r_DATA_O : std_logic_vector(G_DATA_WIDTH - 1 downto 0);

begin

  -- Full detection
  s_full <= '1' when r_wr_gray = (not r_rd_gray_sync2(C_PTR_WIDTH - 1 downto C_PTR_WIDTH - 2)) & r_rd_gray_sync2(C_PTR_WIDTH - 3 downto 0) else
    '0';

  -- Empty detection
  s_empty <= '1' when r_wr_gray_sync2 = r_rd_gray else
    '0';

  FULL_O  <= s_full;
  EMPTY_O <= s_empty;
  DATA_O  <= r_DATA_O;

  -- Write pointer and memory
  process (CLK_WRITE_I)
  begin
    if rising_edge(CLK_WRITE_I) then
      if RST_N_I = '0' then
        r_wr_bin  <= (others => '0');
        r_wr_gray <= (others => '0');
        r_mem     <= (others => (others => '0'));
      else
        if WRITE_I = '1' and s_full = '0' then
          r_mem(to_integer(r_wr_bin(C_ADDR_WIDTH - 1 downto 0))) <= DATA_I;
          r_wr_bin                                               <= r_wr_bin + 1;
          r_wr_gray                                              <= (r_wr_bin + 1) xor ((r_wr_bin + 1) srl 1);
        end if;
      end if;
    end if;
  end process;

  -- Read pointer
  process (CLK_READ_I)
  begin
    if rising_edge(CLK_READ_I) then
      if RST_N_I = '0' then
        r_rd_bin  <= (others => '0');
        r_rd_gray <= (others => '0');
        r_DATA_O  <= (others => '0');
      else
        if READ_I = '1' and s_empty = '0' then
          r_DATA_O  <= r_mem(to_integer(r_rd_bin(C_ADDR_WIDTH - 1 downto 0)));
          r_rd_bin  <= r_rd_bin + 1;
          r_rd_gray <= (r_rd_bin + 1) xor ((r_rd_bin + 1) srl 1);
        end if;
      end if;
    end if;
  end process;

  -- Synchronize read pointer into write domain
  process (CLK_WRITE_I)
  begin
    if rising_edge(CLK_WRITE_I) then
      if RST_N_I = '0' then
        r_rd_gray_sync1 <= (others => '0');
        r_rd_gray_sync2 <= (others => '0');
      else
        r_rd_gray_sync1 <= r_rd_gray;
        r_rd_gray_sync2 <= r_rd_gray_sync1;
      end if;
    end if;
  end process;

  -- Synchronize write pointer into read domain
  process (CLK_READ_I)
  begin
    if rising_edge(CLK_READ_I) then
      if RST_N_I = '0' then
        r_wr_gray_sync1 <= (others => '0');
        r_wr_gray_sync2 <= (others => '0');
      else
        r_wr_gray_sync1 <= r_wr_gray;
        r_wr_gray_sync2 <= r_wr_gray_sync1;
      end if;
    end if;
  end process;

end architecture;
