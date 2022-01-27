library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library xpm;
use xpm.vcomponents.all;

entity faulty_fifo_behav is
    port (
        wr_clk      : in std_logic;
        rd_clk      : in std_logic;
        reset_i     : in std_logic;
        rd_en_i     : in std_logic;
        dout_o      : out std_logic_vector(63 downto 0);
        empty_o     : out std_logic;
        din_i       : in std_logic_vector(63 downto 0);
        wr_en_i     : in std_logic;
        wr_rst_busy : out std_logic;
        rd_rst_busy : out std_logic
        );
end entity faulty_fifo_behav;

architecture rtl of faulty_fifo_behav is

    signal wr_reset        : std_logic;
    signal fifo_valid      : std_logic;
    signal fifo_full       : std_logic;
    signal wr_en_reg       : std_logic;
    signal fifo_out_wr_clk : std_logic;

begin

    xpm_cdc_sync_rst_inst : xpm_cdc_sync_rst
        generic map (
            DEST_SYNC_FF   => 4,
            INIT           => 1,
            INIT_SYNC_FF   => 0,
            SIM_ASSERT_CHK => 0
        )
    port map (
        dest_rst => wr_reset,
        dest_clk => fifo_out_wr_clk,
        src_rst  => reset_i
    );

    my_fifo_out : xpm_fifo_async
        generic map (
            CDC_SYNC_STAGES     => 2,
            DOUT_RESET_VALUE    => "0",
            ECC_MODE            => "no_ecc",
            FIFO_MEMORY_TYPE    => "block",
            FIFO_READ_LATENCY   => 0,
            FIFO_WRITE_DEPTH    => 2048,
            FULL_RESET_VALUE    => 0,
            PROG_EMPTY_THRESH   => 3,
            PROG_FULL_THRESH    => 10,
            RD_DATA_COUNT_WIDTH => 11,
            READ_DATA_WIDTH     => 64,
            READ_MODE           => "fwft",
            RELATED_CLOCKS      => 0,
            USE_ADV_FEATURES    => "1000",
            WAKEUP_TIME         => 0,
            WRITE_DATA_WIDTH    => 64,
            WR_DATA_COUNT_WIDTH => 12
        )
        port map (
            rst           => wr_reset,
            wr_clk        => fifo_out_wr_clk,
            rd_clk        => rd_clk,
            din           => din_i,
            wr_en         => wr_en_reg,
            rd_en         => rd_en_i,
            dout          => dout_o,
            data_valid    => fifo_valid,
            full          => fifo_full,
            empty         => empty_o,
            rd_rst_busy   => wr_rst_busy,
            wr_rst_busy   => rd_rst_busy,
            sleep         => '0',
            injectsbiterr => '0',
            injectdbiterr => '0'
        );

        fifo_out_wr_clk <= wr_clk;
        process(fifo_out_wr_clk) -- works as expected
        -- process(wr_clk) -- not working
        begin
         if rising_edge(fifo_out_wr_clk) then -- works as expected
        --  if rising_edge(wr_clk) then -- not working
             wr_en_reg <= wr_en_i;
         end if;
        end process;


end architecture rtl;