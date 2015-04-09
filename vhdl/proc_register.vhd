-----------------------------------------------------------
-- implements register + clock domain crossing
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.procedures.all;

entity proc_register is
port(
-- unsynced
    depth               : out std_logic_vector(15 downto 0); -- registered on rst
    rec_rxeqmix         : out t_cfg_array(1 downto 0);       -- async
    rec_enable          : out std_logic_vector(1 downto 0);  -- async
    rec_polarity        : out std_logic_vector(1 downto 0);
    rec_descramble      : out std_logic_vector(1 downto 0);
    avg_width           : out std_logic_vector(1 downto 0);  -- registered on start
    core_L              : out std_logic_vector(11 downto 0); -- registered on start
    core_n              : out std_logic_vector(4 downto 0);  -- registered on start
    core_scale_sch      : out std_logic_vector(11 downto 0); -- registered on start
    core_scale_schi     : out std_logic_vector(11 downto 0); -- registered on start
    core_scale_cmul     : out std_logic_vector(1 downto 0);  -- registered on start
    core_iq             : out std_logic;                     -- registered on start
    core_circular       : out std_logic;                     -- registered on start
    tx_frame_offset     : out std_logic_vector(15 downto 0); -- registered on resync, rst
    rec_rst             : out std_logic;
    rec_input_select    : out std_logic_vector(0 downto 0);
    rec_input_select_changed : out std_logic;


-- ============ SAMPLE_CLK =============
-- pulse
    trig_rst            : out std_logic;
    trig_arm            : out std_logic;
    trig_int            : out std_logic;
    avg_rst             : out std_logic;
    tx_rst              : out std_logic;
    tx_deskew           : out std_logic;
    tx_dc_balance       : out std_logic;
    tx_toggle_buf       : out std_logic;
    tx_resync           : out std_logic;
    tx_ovfl_ack         : out std_logic;

-- flag
    mem_req             : out std_logic;
    tx_sat              : out std_logic;

-- value
    trig_type           : out std_logic;
    tx_shift            : out std_logic_vector(1 downto 0);
    tx_muli             : out std_logic_vector(15 downto 0);
    tx_mulq             : out std_logic_vector(15 downto 0);


-- ============ CORE_CLK =============
-- pulse
    core_rst            : out std_logic;
    core_start          : out std_logic;
-- flag
-- value

-- ============ CPU_CLK =============

-- flag
    rec_data_valid      : in  std_logic_vector(1 downto 0);
    rec_stream_valid    : in  std_logic;
    trig_armed          : in  std_logic;
    avg_active          : in  std_logic;
    avg_err             : in  std_logic;
    core_ov_fft         : in  std_logic;
    core_ov_ifft        : in  std_logic;
    core_ov_cmul        : in  std_logic;
    core_busy           : in  std_logic;
    tx_busy             : in  std_logic;
    mem_ack             : in  std_logic;
    tx_ovfl             : in  std_logic;

-- pulse (intr)
    trig_trigd          : in  std_logic;
    avg_done            : in  std_logic;
    core_done           : in  std_logic;
    tx_toggled          : in  std_logic;

-- clocks
    sample_clk          : in  std_logic;
    core_clk            : in  std_logic;


-- CPU Interface

    fpga2bus_intr       : out std_logic_vector(15 downto 0);
    fpga2bus_error      : out std_logic;
    fpga2bus_wrack      : out std_logic;
    fpga2bus_rdack      : out std_logic;
    fpga2bus_data       : out std_logic_vector(31 downto 0);
    bus2fpga_wrce       : in  std_logic_vector(5 downto 0);
    bus2fpga_rdce       : in  std_logic_vector(5 downto 0);
    bus2fpga_be         : in  std_logic_vector(3 downto 0);
    bus2fpga_data       : in  std_logic_vector(31 downto 0);
    bus2fpga_reset      : in  std_logic;
    bus2fpga_clk        : in  std_logic
);
end proc_register;

architecture Structural of proc_register is

    type reg is array(5 downto 0) of std_logic_vector(31 downto 0);
    signal slv_reg                  : reg;

    signal rec_input_select_i       : std_logic_vector(0 downto 0);
    signal rec_input_select_r       : std_logic_vector(0 downto 0);
    signal rec_input_select_changed_i : std_logic;
    signal rec_input_select_changed_r : std_logic;
    signal rec_input_select_changed_r1 : std_logic;
    signal rec_input_select_changed_r2 : std_logic;

    signal trig_arm_value           : std_logic;
    signal trig_int_value           : std_logic;
    signal trig_rst_value           : std_logic;

    signal avg_rst_value            : std_logic;

    signal core_start_value         : std_logic;
    signal core_rst_value           : std_logic;

    signal tx_muli_wr               : std_logic;
    signal tx_mulq_wr               : std_logic;
    signal tx_shift_wr              : std_logic;

    signal tx_deskew_value          : std_logic;
    signal tx_toggle_value          : std_logic;
    signal tx_resync_value          : std_logic;
    signal tx_rst_value             : std_logic;
    signal tx_ovfl_synced           : std_logic;
    signal tx_ovfl_ack_unsynced     : std_logic;

    signal mem_req_r                : std_logic;

    signal busy                     : std_logic_vector(13 downto 0);

    signal trig_trigd_synced        : std_logic;
    signal avg_done_synced          : std_logic;
    signal core_done_synced         : std_logic;
    signal tx_toggled_synced        : std_logic;
begin

-- x  rec_enable(0)                    1 0
-- x  rec_polarity(0)                  1 1
-- x  rec_descramble(0)                1 2
-- x  rec_rxeqmix(0)(0)                0 3
-- x  rec_rxeqmix(0)(1)                0 4
-- r  rec_data_valid(0)   bus2fpga_clk 0 5
-- 0  0                                0 6
-- 0  0                                0 7
-- x  rec_enable(1)                    1 0
-- x  rec_polarity(1)                  1 1
-- x  rec_descramble(1)                1 2
-- x  rec_rxeqmix(0)(1)                0 3
-- x  rec_rxeqmix(1)(1)                0 4
-- r  rec_data_valid(1)   bus2fpga_clk 0 5
-- 0  0                                0 6
-- 0  0                                0 7
-- 0  0                                0 0
-- 0  0                                0 1
-- 0  0                                0 2
-- 0  0                                0 3
-- 0  0                                0 4
-- 0  0                                0 5
-- 0  0                                0 6
-- 0  0                                0 7
-- x  rec_input_select(0)              0 0
-- 0  0                                0 1
-- r  rec_stream_valid    bus2fpga_clk 0 2
-- 0  0                                0 3
-- 0  0                                0 4
-- 0  0                                0 5
-- 0  0                                0 6
-- t  rec_rst                          0 7
-------------------------------------------------------------------------------
-- x  depth(0)                         0 0
-- x  depth(1)                         0 1
-- x  depth(2)                         0 2
-- x  depth(3)                         0 3
-- x  depth(4)                         0 4
-- x  depth(5)                         0 5
-- x  depth(6)                         0 6
-- x  depth(7)                         0 7
-- x  depth(8)                         0 0
-- x  depth(9)                         0 1
-- x  depth(10)                        0 2
-- x  depth(11)                        0 3
-- x  depth(12)                        0 4
-- x  depth(13)                        0 5
-- x  depth(14)                        0 6
-- x  depth(15)                        0 7
-- x  trig_type           sample_clk   0 0
-- 0                                   0 1
-- t  trig_arm            sample_clk   0 2  r  trig_armed          bus2fpga_clk 
-- t  trig_int            sample_clk   0 3
-- 0  0                                0 4
-- 0  0                                0 5
-- 0  0                                0 6
-- t  rst                 sample_clk   0 7
-- x  avg_width(0)                     0 0
-- x  avg_width(1)                     0 1
-- r  avg_active                       0 2
-- r  avg_err                          0 3
-- 0  0                                0 4
-- 0  0                                0 5
-- 0  0                                0 6
-- t  rst                 sample_clk   0 7
-------------------------------------------------------------------------------
-- x  core_scale_sch(0)                0 0
-- x  core_scale_sch(1)                1 1
-- x  core_scale_sch(2)                0 2
-- x  core_scale_sch(3)                1 3
-- x  core_scale_sch(4)                0 4
-- x  core_scale_sch(5)                1 5
-- x  core_scale_sch(6)                0 6
-- x  core_scale_sch(7)                1 7
-- x  core_scale_sch(8)                0 0
-- x  core_scale_sch(9)                1 1
-- x  core_scale_sch(10)               1 2
-- x  core_scale_sch(11)               0 3
-- 0  0                                0 4
-- 0  0                                0 5
-- 0  0                                0 6
-- 0  0                                0 7
-- x  core_scale_schi(0)               0 0
-- x  core_scale_schi(1)               1 1
-- x  core_scale_schi(2)               0 2
-- x  core_scale_schi(3)               1 3
-- x  core_scale_schi(4)               0 4
-- x  core_scale_schi(5)               1 5
-- x  core_scale_schi(6)               0 6
-- x  core_scale_schi(7)               1 7
-- x  core_scale_schi(8)               0 0
-- x  core_scale_schi(9)               1 1
-- x  core_scale_schi(10)              1 2
-- x  core_scale_schi(11)              0 3
-- 0  0                                0 4
-- 0  0                                0 5
-- 0  0                                0 6
-- 0  0                                0 7
-------------------------------------------------------------------------------
-- x  core_L(0)                        0 0
-- x  core_L(1)                        0 1
-- x  core_L(2)                        0 2
-- x  core_L(3)                        0 3
-- x  core_L(4)                        0 4
-- x  core_L(5)                        0 5
-- x  core_L(6)                        0 6
-- x  core_L(7)                        0 7
-- x  core_L(8)                        0 0
-- x  core_L(9)                        0 1
-- x  core_L(10)                       0 2
-- x  core_L(11)                       0 3
-- 0  0                                0 4
-- 0  0                                0 5
-- x  core_scale_cmul(0)               0 6
-- x  core_scale_cmul(1)               0 7
-- x  core_n(0)                        1 0
-- x  core_n(1)                        1 1
-- x  core_n(2)                        0 2
-- x  core_n(3)                        0 3
-- x  core_n(4)                        0 4
-- 0  0                                0 5
-- 0  0                                0 6
-- 0  0                                0 7
-- x  core_iq                          0 0
-- t  core_start          core_clk     0 1  r  core_busy           bus2fpga_clk
-- r  core_ov_fft         bus2fpga_clk 0 2
-- r  core_ov_ifft        bus2fpga_clk 0 3
-- r  core_ov_cmul        bus2fpga_clk 0 4
-- x  core_circular                    0 5
-- 0  0                                0 6
-- t  core_rst            core_clk     0 7
-------------------------------------------------------------------------------
-- x  tx_muli(0)          sample_clk   0 0
-- x  tx_muli(1)          sample_clk   0 1
-- x  tx_muli(2)          sample_clk   0 2
-- x  tx_muli(3)          sample_clk   0 3
-- x  tx_muli(4)          sample_clk   0 4
-- x  tx_muli(5)          sample_clk   0 5
-- x  tx_muli(6)          sample_clk   0 6
-- x  tx_muli(7)          sample_clk   0 7
-- x  tx_muli(8)          sample_clk   0 0
-- x  tx_muli(9)          sample_clk   0 1
-- x  tx_muli(10)         sample_clk   0 2
-- x  tx_muli(11)         sample_clk   0 3
-- x  tx_muli(12)         sample_clk   0 4
-- x  tx_muli(13)         sample_clk   0 5
-- x  tx_muli(14)         sample_clk   0 6
-- x  tx_muli(15)         sample_clk   0 7
-- x  tx_mulq(0)          sample_clk   0 0
-- x  tx_mulq(1)          sample_clk   0 1
-- x  tx_mulq(2)          sample_clk   0 2
-- x  tx_mulq(3)          sample_clk   0 3
-- x  tx_mulq(4)          sample_clk   0 4
-- x  tx_mulq(5)          sample_clk   0 5
-- x  tx_mulq(6)          sample_clk   0 6
-- x  tx_mulq(7)          sample_clk   0 7
-- x  tx_mulq(8)          sample_clk   0 0
-- x  tx_mulq(9)          sample_clk   0 1
-- x  tx_mulq(10)         sample_clk   0 2
-- x  tx_mulq(11)         sample_clk   0 3
-- x  tx_mulq(12)         sample_clk   0 4
-- x  tx_mulq(13)         sample_clk   0 5
-- x  tx_mulq(14)         sample_clk   0 6
-- x  tx_mulq(15)         sample_clk   0 7
-------------------------------------------------------------------------------
-- x  tx_frame_offset(0)               0 0
-- x  tx_frame_offset(1)               0 1
-- x  tx_frame_offset(2)               0 2
-- x  tx_frame_offset(3)               0 3
-- x  tx_frame_offset(4)               0 4
-- x  tx_frame_offset(5)               0 5
-- x  tx_frame_offset(6)               0 6
-- x  tx_frame_offset(7)               0 7
-- x  tx_frame_offset(8)               0 0
-- x  tx_frame_offset(9)               0 1
-- x  tx_frame_offset(10)              0 2
-- x  tx_frame_offset(11)              0 3
-- x  tx_frame_offset(12)              0 4
-- x  tx_frame_offset(13)              0 5
-- x  tx_frame_offset(14)              0 6
-- x  tx_frame_offset(15)              0 7
-- t  tx_deskew           sample_clk   0 0
-- x  tx_dc_balance       sample_clk   0 1
-- t  tx_toggle                        0 2  r  tx_busy             bus2fpga_clk 
-- t  tx_resync                        0 3
-- 0  0                                0 4
-- 0  0                                0 5
-- 0  0                                0 6
-- t  tx_rst              sample_clk   0 7
-- w  mem_req                          0 0  r  mem_ack
-- 0  0                                0 1
-- 0  0                                0 2
-- 0  0                                0 3
-- x  tx_sat              sample_clk   1 4
-- w  tx_ovfl             sample_clk   0 5  r  tx_ovfl             bus2fpga_clk
-- x  tx_shift(0)         sample_clk   0 6
-- x  tx_shift(1)         sample_clk   0 7
    
    reciever_gen: for i in 0 to 1 generate
        signal recv_reg          : std_logic_vector(4 downto 0);
        signal rec_data_valid_s  : std_logic;
    begin
        rec_enable(i)   <= recv_reg(0);
        rec_polarity(i) <= recv_reg(1);
        rec_descramble(i) <= recv_reg(2);
        rec_rxeqmix(i)  <= recv_reg(4 downto 3);

        rec_data_valid_i: entity work.flag
        generic map(
            name        => "rec_data_valid" & integer'image(i)
        )
        port map(
            flag_in      => rec_data_valid(i),
            flag_out     => rec_data_valid_s,
            clk          => bus2fpga_clk
        );

        rec_gtx_write_proc: process(bus2fpga_clk, bus2fpga_reset, bus2fpga_wrce) is
        begin
            if rising_edge(bus2fpga_clk) then
                if bus2fpga_reset = '1' then
                    recv_reg <= "00111";
                else
                    if bus2fpga_wrce = "100000" and bus2fpga_be(i) = '1' then
                        recv_reg <= bus2fpga_data((i+1)*8-4 downto i*8);
                    end if;
                end if;
            end if;
        end process rec_gtx_write_proc;
        slv_reg(0)((i+1)*8-1 downto i*8) <= "00" & rec_data_valid_s & recv_reg;
    end generate;

    rec_input_select_i <= slv_reg(0)(24 downto 24);
    rec_input_select <= rec_input_select_i;

    rec_input_select_changed_i <= or_many(rec_input_select_i xor rec_input_select_r);

    rec_input_select_changed_p: process(bus2fpga_clk)
    begin
        if rising_edge(bus2fpga_clk) then
            rec_input_select_r <= rec_input_select_i;
            rec_input_select_changed_r <= rec_input_select_changed_i;
            rec_input_select_changed_r1 <= rec_input_select_changed_r;
            rec_input_select_changed_r2 <= rec_input_select_changed_r1;
        end if;
    end process rec_input_select_changed_p;

    rec_input_select_changed <= or_many(rec_input_select_changed_i & rec_input_select_changed_r & rec_input_select_changed_r1 & rec_input_select_changed_r2);
    
    sync_rec_stream_valid: entity work.flag
    generic map(
        name        => "rec_stream_valid"
    )
    port map(
        flag_in     => rec_stream_valid,
        flag_out    => slv_reg(0)(26),
        clk         => bus2fpga_clk
    );
    rec_rst <= bus2fpga_data(31) when bus2fpga_wrce = "100000" and bus2fpga_be(3) = '1' else
               '1' when bus2fpga_reset = '1' else
               '0';
    slv_reg(0)(23 downto 16) <= "00000000";
    slv_reg(0)(25) <= '0';
    slv_reg(0)(31 downto 27) <= "00000";
    write_proc0: process(bus2fpga_clk, bus2fpga_reset, bus2fpga_wrce) is
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                slv_reg(0)(24 downto 24) <= "0";
            else
                if bus2fpga_wrce = "100000" and bus2fpga_be(3) = '1' then
                    slv_reg(0)(24 downto 24) <= bus2fpga_data(24 downto 24);
                end if;
            end if;
        end if;
    end process write_proc0;
-------------------------------------------------------------------------------
    depth <= slv_reg(1)(15 downto 0);

    sync_trig_type: entity work.flag
    generic map(
        name        => "trig_type"
    )
    port map(
        flag_in    => slv_reg(1)(16),
        flag_out   => trig_type,
        clk        => sample_clk
    );
    trig_arm_value <= bus2fpga_data(18) when bus2fpga_wrce = "010000" and bus2fpga_be(2) = '1' else
                      '0';
    sync_trig_arm: entity work.toggle
    generic map(
        name        => "trig_arm"
    )
    port map(
        toggle_in   => trig_arm_value,
        toggle_out  => trig_arm,
        busy        => busy(0),
        clk_from    => bus2fpga_clk,
        clk_to      => sample_clk
    );
    trig_int_value  <= bus2fpga_data(19) when bus2fpga_wrce = "010000" and bus2fpga_be(2) = '1' else
                       '0';
    sync_trig_int: entity work.toggle
    generic map(
        name        => "trig_int"
    )
    port map(
        toggle_in   => trig_int_value,
        toggle_out  => trig_int,
        busy        => busy(1),
        clk_from    => bus2fpga_clk,
        clk_to      => sample_clk
    );
    trig_rst_value  <= bus2fpga_data(23) when bus2fpga_wrce = "010000" and bus2fpga_be(2) = '1' else
                       '1' when bus2fpga_reset = '1' else
                       '0';
    sync_trig_rst: entity work.toggle
    generic map(
        name        => "trig_rst"
    )
    port map(
        toggle_in   => trig_rst_value,
        toggle_out  => trig_rst,
        busy        => busy(2),
        clk_from    => bus2fpga_clk,
        clk_to      => sample_clk
    );
    
    avg_width <= slv_reg(1)(25 downto 24);
    avg_rst_value  <= bus2fpga_data(31) when bus2fpga_wrce = "010000" and bus2fpga_be(3) = '1' else
                       '1' when bus2fpga_reset = '1' else
                       '0';
    sync_avg_rst: entity work.toggle
    generic map(
        name        => "avg_rst"
    )
    port map(
        toggle_in   => avg_rst_value,
        toggle_out  => avg_rst,
        busy        => busy(3),
        clk_from    => bus2fpga_clk,
        clk_to      => sample_clk
    );
    
    write_proc1: process(bus2fpga_clk)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                slv_reg(1)(17 downto 0) <= (others => '0');
                slv_reg(1)(25 downto 24) <= (others => '0');
            else
                if bus2fpga_wrce = "010000" then
                    if bus2fpga_be(0) = '1' then
                        slv_reg(1)(7 downto 0) <= bus2fpga_data(7 downto 0);
                    end if;
                    if bus2fpga_be(1) = '1' then
                        slv_reg(1)(15 downto 8) <= bus2fpga_data(15 downto 8);
                    end if;
                    if bus2fpga_be(2) = '1' then
                        slv_reg(1)(17 downto 16) <= bus2fpga_data(17 downto 16);
                    end if;
                    if bus2fpga_be(3) = '1' then
                        slv_reg(1)(25 downto 24) <= bus2fpga_data(25 downto 24);
                    end if;
                end if;
            end if;
        end if;
    end process write_proc1;

    sync_trig_armed: entity work.flag
    generic map(
        name        => "trig_armed"
    )
    port map(
        flag_in     => trig_armed,
        flag_out    => slv_reg(1)(18),
        clk         => bus2fpga_clk
    );
    sync_avg_active: entity work.flag
    generic map(
        name        => "avg_active"
    )
    port map(
        flag_in     => avg_active,
        flag_out    => slv_reg(1)(26),
        clk         => bus2fpga_clk
    );
    sync_avg_err: entity work.flag
    generic map(
        name        => "avg_err"
    )
    port map(
        flag_in     => avg_err,
        flag_out    => slv_reg(1)(27),
        clk         => bus2fpga_clk
    );
    slv_reg(1)(23 downto 19) <= (others => '0');
    slv_reg(1)(31 downto 28) <= (others => '0');
-------------------------------------------------------------------------------
    core_scale_sch  <= slv_reg(2)(11 downto 0);
    core_scale_schi <= slv_reg(2)(27 downto 16);
    
    write_proc2: process(bus2fpga_clk)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                slv_reg(2)(11 downto 0) <= "011010101010";
                slv_reg(2)(27 downto 16) <= "011010101010";
            else
                if bus2fpga_wrce = "001000" then
                    if bus2fpga_be(0) = '1' then
                        slv_reg(2)(7 downto 0) <= bus2fpga_data(7 downto 0);
                    end if;
                    if bus2fpga_be(1) = '1' then
                        slv_reg(2)(11 downto 8) <= bus2fpga_data(11 downto 8);
                    end if;
                    if bus2fpga_be(2) = '1' then
                        slv_reg(2)(23 downto 16) <= bus2fpga_data(23 downto 16);
                    end if;
                    if bus2fpga_be(3) = '1' then
                        slv_reg(2)(27 downto 24) <= bus2fpga_data(27 downto 24);
                    end if;
                end if;
            end if;
        end if;
    end process write_proc2;

    slv_reg(2)(15 downto 12) <= (others => '0');
    slv_reg(2)(31 downto 28) <= (others => '0');
-------------------------------------------------------------------------------
    core_L <= slv_reg(3)(11 downto 0);
    core_n <= slv_reg(3)(20 downto 16);
    core_scale_cmul <= slv_reg(3)(15 downto 14);
    core_iq <= slv_reg(3)(24);
    core_circular <= slv_reg(3)(29);

    core_start_value    <= bus2fpga_data(25) when bus2fpga_wrce = "000100" and bus2fpga_be(3) = '1' else
                           '0';
    sync_core_start: entity work.toggle
    generic map(
        name        => "core_start"
    )
    port map(
        toggle_in   => core_start_value,
        toggle_out  => core_start,
        busy        => busy(4),
        clk_from    => bus2fpga_clk,
        clk_to      => core_clk
    );

    core_rst_value  <= bus2fpga_data(31) when bus2fpga_wrce = "000100" and bus2fpga_be(3) = '1' else
                       '1' when bus2fpga_reset = '1' else
                       '0';
    sync_core_rst: entity work.toggle
    generic map(
        name        => "core_rst"
    )
    port map(
        toggle_in   => core_rst_value,
        toggle_out  => core_rst,
        busy        => busy(5),
        clk_from    => bus2fpga_clk,
        clk_to      => core_clk
    );

    write_proc3: process(bus2fpga_clk)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                slv_reg(3)(11 downto 0) <= (others => '0');
                slv_reg(3)(15 downto 14) <= (others => '0');
                slv_reg(3)(20 downto 16) <= "00011";
                slv_reg(3)(24) <= '0';
                slv_reg(3)(29) <= '0';
            else
                if bus2fpga_wrce = "000100" then
                    if bus2fpga_be(0) = '1' then
                        slv_reg(3)(7 downto 0) <= bus2fpga_data(7 downto 0);
                    end if;
                    if bus2fpga_be(1) = '1' then
                        slv_reg(3)(11 downto 8) <= bus2fpga_data(11 downto 8);
                        slv_reg(3)(15 downto 14) <= bus2fpga_data(15 downto 14);
                    end if;
                    if bus2fpga_be(2) = '1' then
                        slv_reg(3)(20 downto 16) <= bus2fpga_data(20 downto 16);
                    end if;
                    if bus2fpga_be(3) = '1' then
                        slv_reg(3)(24) <= bus2fpga_data(24);
                        slv_reg(3)(29) <= bus2fpga_data(29);
                    end if;
                end if;
            end if;
        end if;
    end process write_proc3;

    sync_core_busy: entity work.flag
    generic map(
        name        => "core_busy"
    )
    port map(
        flag_in     => core_busy,
        flag_out    => slv_reg(3)(25),
        clk         => bus2fpga_clk
    );
    sync_core_ov_fft: entity work.flag
    generic map(
        name        => "core_ov_fft"
    )
    port map(
        flag_in     => core_ov_fft,
        flag_out    => slv_reg(3)(26),
        clk         => bus2fpga_clk
    );
    sync_core_ov_ifft: entity work.flag
    generic map(
        name        => "core_ov_ifft"
    )
    port map(
        flag_in     => core_ov_ifft,
        flag_out    => slv_reg(3)(27),
        clk         => bus2fpga_clk
    );
    sync_core_ov_cmul: entity work.flag
    generic map(
        name        => "core_ov_cmul"
    )
    port map(
        flag_in     => core_ov_cmul,
        flag_out    => slv_reg(3)(28),
        clk         => bus2fpga_clk
    );

    slv_reg(3)(13 downto 12) <= (others => '0');
    slv_reg(3)(23 downto 21) <= (others => '0');
    slv_reg(3)(31 downto 30) <= (others => '0');
-------------------------------------------------------------------------------
    tx_muli_wr <= '1' when (bus2fpga_wrce = "000010" and (bus2fpga_be(0) = '1' or bus2fpga_be(1) = '1')) or bus2fpga_reset = '1' else
                  '0';
    sync_tx_muli: entity work.value
    generic map(
        name        => "tx_muli"
    )
    port map(
        value_in    => slv_reg(4)(15 downto 0),
        value_out   => tx_muli,
        value_wr    => tx_muli_wr,
        busy        => busy(6),
        clk_from    => bus2fpga_clk,
        clk_to      => sample_clk
    );
    tx_mulq_wr <= '1' when (bus2fpga_wrce = "000010" and (bus2fpga_be(2) = '1' or bus2fpga_be(3) = '1')) or bus2fpga_reset = '1' else
                  '0';
    sync_tx_mulq: entity work.value
    generic map(
        name        => "tx_mulq"
    )
    port map(
        value_in    => slv_reg(4)(31 downto 16),
        value_out   => tx_mulq,
        value_wr    => tx_mulq_wr,
        busy        => busy(7),
        clk_from    => bus2fpga_clk,
        clk_to      => sample_clk
    );

    write_proc4: process(bus2fpga_clk)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                slv_reg(4)(31 downto 0) <= (others => '0');
            else
                if bus2fpga_wrce = "000010" then
                    if bus2fpga_be(0) = '1' then
                        slv_reg(4)(7 downto 0) <= bus2fpga_data(7 downto 0);
                    end if;
                    if bus2fpga_be(1) = '1' then
                        slv_reg(4)(15 downto 8) <= bus2fpga_data(15 downto 8);
                    end if;
                    if bus2fpga_be(2) = '1' then
                        slv_reg(4)(23 downto 16) <= bus2fpga_data(23 downto 16);
                    end if;
                    if bus2fpga_be(3) = '1' then
                        slv_reg(4)(31 downto 24) <= bus2fpga_data(31 downto 24);
                    end if;
                end if;
            end if;
        end if;
    end process write_proc4;
-------------------------------------------------------------------------------
    tx_frame_offset <= slv_reg(5)(15 downto 0);

    tx_deskew_value <= bus2fpga_data(16) when bus2fpga_wrce = "000001" and bus2fpga_be(2) = '1' else
                       '0';
    sync_tx_deskew: entity work.toggle
    generic map(
        name        => "tx_deskew"
    )
    port map(
        toggle_in   => tx_deskew_value,
        toggle_out  => tx_deskew,
        busy        => busy(8),
        clk_from    => bus2fpga_clk,
        clk_to      => sample_clk
    );
    sync_tx_dc_balance: entity work.flag
    generic map(
        name        => "tx_dc_balance"
    )
    port map(
        flag_in     => slv_reg(5)(17),
        flag_out    => tx_dc_balance,
        clk         => sample_clk
    );
    tx_toggle_value <= bus2fpga_data(18) when bus2fpga_wrce = "000001" and bus2fpga_be(2) = '1' else
                       '0';
    sync_tx_toggle: entity work.toggle
    generic map(
        name        => "tx_toggle"
    )
    port map(
        toggle_in   => tx_toggle_value,
        toggle_out  => tx_toggle_buf,
        busy        => busy(9),
        clk_from    => bus2fpga_clk,
        clk_to      => sample_clk
    );
    tx_resync_value <= bus2fpga_data(19) when bus2fpga_wrce = "000001" and bus2fpga_be(2) = '1' else
                       '0';
    sync_tx_resync: entity work.toggle
    generic map(
        name        => "tx_resync"
    )
    port map(
        toggle_in   => tx_resync_value,
        toggle_out  => tx_resync,
        busy        => busy(10),
        clk_from    => bus2fpga_clk,
        clk_to      => sample_clk
    );
    tx_rst_value  <= bus2fpga_data(23) when bus2fpga_wrce = "000001" and bus2fpga_be(2) = '1' else
                     '1' when bus2fpga_reset = '1' else
                     '0';
    sync_tx_rst: entity work.toggle
    generic map(
        name        => "tx_rst"
    )
    port map(
        toggle_in   => tx_rst_value,
        toggle_out  => tx_rst,
        busy        => busy(11),
        clk_from    => bus2fpga_clk,
        clk_to      => sample_clk
    );

    mem_req <= mem_req_r;

    sync_tx_sat: entity work.flag
    generic map(
        name        => "tx_sat"
    )
    port map(
        flag_in     => slv_reg(5)(28),
        flag_out    => tx_sat,
        clk         => sample_clk
    );

    tx_shift_wr <= '1' when (bus2fpga_wrce = "000001" and bus2fpga_be(3) = '1') or bus2fpga_reset = '1' else
                  '0';
    sync_tx_shift: entity work.value
    generic map(
        name        => "tx_shift"
    )
    port map(
        value_in    => slv_reg(5)(31 downto 30),
        value_out   => tx_shift,
        value_wr    => tx_shift_wr,
        busy        => busy(12),
        clk_from    => bus2fpga_clk,
        clk_to      => sample_clk
    );

    write_proc5: process(bus2fpga_clk)
    begin
        if rising_edge(bus2fpga_clk) then
            if bus2fpga_reset = '1' then
                slv_reg(5)(15 downto 0) <= (others => '0');
                slv_reg(5)(17) <= '0';
                mem_req_r <= '0';
                slv_reg(5)(28) <= '1';
                slv_reg(5)(31 downto 30) <= (others => '0');
            else
                if bus2fpga_wrce = "000001" then
                    if bus2fpga_be(0) = '1' then
                        slv_reg(5)(7 downto 0) <= bus2fpga_data(7 downto 0);
                    end if;
                    if bus2fpga_be(1) = '1' then
                        slv_reg(5)(15 downto 8) <= bus2fpga_data(15 downto 8);
                    end if;
                    if bus2fpga_be(2) = '1' then
                        slv_reg(5)(17) <= bus2fpga_data(17);
                    end if;
                    if bus2fpga_be(3) = '1' then
                        mem_req_r      <= bus2fpga_data(24);
                        slv_reg(5)(28) <= bus2fpga_data(28);
                        slv_reg(5)(31 downto 30) <= bus2fpga_data(31 downto 30);
                    end if;
                end if;
            end if;
        end if;
    end process write_proc5;

    sync_tx_busy: entity work.flag
    generic map(
        name        => "tx_busy"
    )
    port map(
        flag_in     => tx_busy,
        flag_out    => slv_reg(5)(18),
        clk         => bus2fpga_clk
    );

    slv_reg(5)(24) <= mem_ack;

    sync_ovfl: entity work.flag
    generic map(
        name        => "ovfl"
    )
    port map(
        flag_in     => tx_ovfl,
        flag_out    => tx_ovfl_synced,
        clk         => bus2fpga_clk
    );

    tx_ovfl_ack_unsynced <= '1' when bus2fpga_wrce = "000001" and bus2fpga_be(3) = '1' and bus2fpga_data(29) = '0' else
                            '0';
    sync_ovfl_ack: entity work.toggle
    generic map(
        name        => "ovfl_ack"
    )
    port map(
        toggle_in   => tx_ovfl_ack_unsynced,
        toggle_out  => tx_ovfl_ack,
        busy        => busy(13),
        clk_from    => bus2fpga_clk,
        clk_to      => sample_clk
    );

    slv_reg(5)(16) <= '0';
    slv_reg(5)(23 downto 19) <= (others => '0');
    slv_reg(5)(27 downto 25) <= (others => '0');
    slv_reg(5)(29) <= tx_ovfl_synced;
--=============================================================================
    slave_reg_read_proc: process(bus2fpga_rdce, slv_reg)
    begin
        case bus2fpga_rdce is
            when "100000" => fpga2bus_data <= slv_reg(0);
            when "010000" => fpga2bus_data <= slv_reg(1);
            when "001000" => fpga2bus_data <= slv_reg(2);
            when "000100" => fpga2bus_data <= slv_reg(3);
            when "000010" => fpga2bus_data <= slv_reg(4);
            when "000001" => fpga2bus_data <= slv_reg(5);
            when others => fpga2bus_data <= (others => '0');
        end case;
    end process slave_reg_read_proc;


    sync_trig_trigd: entity work.toggle
    generic map(
        name        => "trig_trigd"
    )
    port map(
        toggle_in   => trig_trigd,
        toggle_out  => trig_trigd_synced,
        busy        => open,
        clk_from    => sample_clk,
        clk_to      => bus2fpga_clk
    );
    sync_avg_done: entity work.flag
    generic map(
        name        => "avg_done"
    )
    port map(
        flag_in     => avg_done,
        flag_out    => avg_done_synced,
        clk         => bus2fpga_clk
    );
    sync_core_done: entity work.toggle
    generic map(
        name        => "core_done"
    )
    port map(
        toggle_in   => core_done,
        toggle_out  => core_done_synced,
        busy        => open,
        clk_from    => sample_clk,
        clk_to      => bus2fpga_clk
    );
    sync_tx_toggled: entity work.toggle
    generic map(
        name        => "tx_toggled"
    )
    port map(
        toggle_in   => tx_toggled,
        toggle_out  => tx_toggled_synced,
        busy        => open,
        clk_from    => sample_clk,
        clk_to      => bus2fpga_clk
    );

    fpga2bus_intr <= (
        0  => slv_reg(0)(5),
        1  => not slv_reg(0)(5),
        2  => slv_reg(0)(13),
        3  => not slv_reg(0)(13),
        4  => slv_reg(0)(26),
        5  => not slv_reg(0)(26),
        6  => trig_trigd_synced,
        7  => avg_done_synced,
        8  => core_done_synced,
        9  => tx_toggled_synced,
        10 => slv_reg(5)(29),
        others => '0');

    fpga2bus_rdack <= or_many(bus2fpga_rdce);
    fpga2bus_wrack <= or_many(bus2fpga_wrce) and not or_many(busy);
    fpga2bus_error <= '0';

end Structural;

