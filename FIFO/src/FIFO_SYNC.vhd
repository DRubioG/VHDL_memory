library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity FIFO_SYNC is
  generic (
    G_WIDTH : integer := 8;
    G_DEPTH : integer := 32
  );
  port (
    CLK_I   : in std_logic;
    RST_N_I : in std_logic;
    EN_I    : in std_logic;
    DATA_I  : in std_logic_vector(G_WIDTH - 1 downto 0);
    READ_I  : in std_logic;
    DATA_O  : out std_logic_vector(G_WIDTH - 1 downto 0);
    WRITE_I : in std_logic;
    EMPTY_O : out std_logic;
    FULL_O  : out std_logic
  );
end entity FIFO_SYNC;

architecture rtl of FIFO_SYNC is

  type t_mem is array (0 to G_DEPTH-1) of std_logic_vector(7 downto 0);

  signal r_mem : t_mem;

  signal r_wr_ptr : integer range 0 to G_DEPTH;
  signal r_rd_ptr : integer range 0 to G_DEPTH;
  signal r_count  : integer range 0 to G_DEPTH;

  

begin
  process (CLK_I)
  begin
    if rising_edge(CLK_I) then

      if RST_N_I = '0' then

        r_wr_ptr   <= 0;
        r_rd_ptr   <= 0;
        r_count    <= 0;
        DATA_O <= (others => '0');

      elsif EN_I = '1' then
        if WRITE_I = '1' and r_count < G_DEPTH then
          r_mem(r_wr_ptr) <= DATA_I;
          r_wr_ptr      <= (r_wr_ptr + 1) mod G_DEPTH;
        end if;

        if READ_I = '1' and r_count > 0 then
          DATA_O <= r_mem(r_rd_ptr);
          r_rd_ptr   <= (r_rd_ptr + 1) mod G_DEPTH;
        end if;

        if WRITE_I = '1' and r_count < G_DEPTH and not (READ_I = '1' and r_count > 0) then
          r_count <= r_count + 1;
        elsif READ_I = '1' and r_count > 0 and not (WRITE_I = '1' and r_count < G_DEPTH) then
          r_count <= r_count - 1;
        end if;

      end if;
    end if;
  end process;

  EMPTY_O <= '1' when r_count = 0 else
    '0';
  FULL_O <= '1' when r_count = G_DEPTH else
    '0';

end architecture;