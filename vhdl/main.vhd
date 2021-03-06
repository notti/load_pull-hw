-----------------------------------------------------------
-- main
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.procedures.all;

entity main is
port(
	sys_clk				: in  std_logic;

-- signals for gtx transciever
    rx_refclk_n         : in  std_logic;
    rx_refclk_p         : in  std_logic;
    rx_rxn              : in  std_logic_vector(5 downto 0);
    rx_rxp              : in  std_logic_vector(5 downto 0);
    rx_txn              : out std_logic_vector(5 downto 0);
    rx_txp              : out std_logic_vector(5 downto 0);

-- overall settings
	depth				: in  std_logic_vector(15 downto 0);

-- auto mode
    auto_rst            : in  std_logic;
    auto_run            : in  std_logic;
    auto_single         : in  std_logic;
    auto_running        : out std_logic;
    auto_clr            : out std_logic;

-- control signals receiver
    rec_rst             : in  std_logic;
    rec_polarity        : in  std_logic_vector(1 downto 0);
    rec_descramble      : in  std_logic_vector(1 downto 0);
    rec_rxeqmix         : in  t_cfg_array(1 downto 0);
    rec_data_valid      : out std_logic_vector(1 downto 0);
    rec_enable          : in  std_logic_vector(1 downto 0);
    rec_input_select    : in  std_logic_vector(0 downto 0);
    rec_input_select_changed : in std_logic;
    rec_stream_valid    : out std_logic;

-- control signals trigger
    trig_rst            : in  std_logic;
    trig_arm            : in  std_logic;
    trig_ext            : in  std_logic;
    trig_int            : in  std_logic;
	trig_type		    : in  std_logic;
    trig_armed          : out std_logic;
    trig_trigd          : out std_logic;
	frame_clk			: out std_logic;

-- control signals average
    avg_rst             : in  std_logic;
    avg_width           : in  std_logic_vector(1 downto 0);
    avg_done            : out std_logic;
    avg_active          : out std_logic;
    avg_err             : out std_logic;

-- overlap_add
	core_rst			: in  std_logic;
	core_start          : in  std_logic;
	core_n              : in  std_logic_vector(4 downto 0);
	core_scale_sch      : in  std_logic_vector(11 downto 0);
	core_scale_schi     : in  std_logic_vector(11 downto 0);
	core_scale_cmul     : in  std_logic_vector(1 downto 0);
	core_L              : in  std_logic_vector(11 downto 0);
	core_iq             : in  std_logic;
    core_circular       : in std_logic;

	core_ov_fft         : out std_logic;
	core_ov_ifft        : out std_logic;
	core_ov_cmul        : out std_logic;

	core_busy           : out std_logic;
	core_done           : out std_logic;

-- signals for selectio oserdes transmitter
    tx_txn              : out std_logic_vector(7 downto 0);
    tx_txp              : out std_logic_vector(7 downto 0);
    tx_txclkn           : out std_logic;
    tx_txclkp           : out std_logic;

-- settings
	tx_rst				: in  std_logic;
    tx_deskew           : in  std_logic;
    tx_dc_balance       : in  std_logic;
    tx_muli             : in  std_logic_vector(15 downto 0);
    tx_muli_wr          : in  std_logic;
    tx_mulq             : in  std_logic_vector(15 downto 0);
    tx_mulq_wr          : in  std_logic;
    tx_toggle_buf       : in  std_logic;
    tx_toggled          : out std_logic;
    tx_frame_offset     : in  std_logic_vector(15 downto 0);
    tx_resync           : in  std_logic;
	tx_busy				: out std_logic;
    tx_ovfl             : out std_logic;
    tx_ovfl_ack         : in  std_logic;
    tx_sat              : in  std_logic;
    tx_shift            : in  std_logic_vector(3 downto 0);
    tx_shift_wr         : in  std_logic;

-- mem
	mem_dinia			: in  std_logic_vector(15 downto 0);
	mem_addria			: in  std_logic_vector(15 downto 0);
	mem_weaia			: in  std_logic_vector(1 downto 0);
	mem_doutia			: out std_logic_vector(15 downto 0);
    mem_enia            : in  std_logic;
	mem_dinib			: in  std_logic_vector(15 downto 0);
	mem_addrib			: in  std_logic_vector(15 downto 0);
	mem_weaib			: in  std_logic_vector(1 downto 0);
	mem_doutib			: out std_logic_vector(15 downto 0);
    mem_enib            : in  std_logic;

	mem_dinh			: in  std_logic_vector(31 downto 0);
	mem_addrh			: in  std_logic_vector(15 downto 0);
	mem_weh				: in  std_logic_vector(3 downto 0);
	mem_douth			: out std_logic_vector(31 downto 0);
    mem_enh             : in  std_logic;

	mem_dinoi			: in  std_logic_vector(31 downto 0);
	mem_addroi			: in  std_logic_vector(15 downto 0);
	mem_weoi			: in  std_logic_vector(3 downto 0);
	mem_doutoi			: out std_logic_vector(31 downto 0);
    mem_enoi            : in  std_logic;

	mem_addroa			: in  std_logic_vector(15 downto 0);
	mem_doutoa			: out std_logic_vector(31 downto 0);
    mem_enoa            : in  std_logic
);
end main;

architecture Structural of main is

    signal avg_done_i          : std_logic;

	signal core_mem_dinx	   : std_logic_vector(15 downto 0);
	signal core_mem_addrx	   : std_logic_vector(15 downto 0);
	signal mem_addria_i		   : std_logic_vector(15 downto 0);
	signal mem_weaia_i		   : std_logic_vector(1 downto 0);
	signal mem_doutia_i		   : std_logic_vector(15 downto 0);
	signal mem_weaib_i		   : std_logic_vector(1 downto 0);
	signal core_mem_diny	   : std_logic_vector(31 downto 0);
	signal core_mem_addry	   : std_logic_vector(15 downto 0);
	signal core_mem_douty	   : std_logic_vector(31 downto 0);
	signal core_mem_wey		   : std_logic;
	signal mem_dinoi_i		   : std_logic_vector(31 downto 0);
	signal mem_addroi_i		   : std_logic_vector(15 downto 0);
	signal mem_weoi_i		   : std_logic_vector(3 downto 0);
	signal mem_doutoi_i		   : std_logic_vector(31 downto 0);
    signal mem_enia_i          : std_logic;
    signal mem_enib_i          : std_logic;
    signal mem_enoi_i          : std_logic;
    signal mem_enoa_i          : std_logic;

    signal sample_clk_i        : std_logic;
    signal sample_rst          : std_logic;
	signal frame_clk_i		   : std_logic;
	signal wave_index		   : std_logic_vector(3 downto 0);
	signal avg_active_i		   : std_logic;
    signal avg_err_i           : std_logic;
	signal trig_arm_i		   : std_logic;
	signal trig_arm_if		   : std_logic;

	signal core_start_i		   : std_logic;
	signal core_busy_i		   : std_logic;
    signal core_done_i         : std_logic;
    signal core_ov_fft_i       : std_logic;
    signal core_ov_ifft_i      : std_logic;
    signal core_ov_cmul_i      : std_logic;

    signal tx_muli_synced      : std_logic_vector(15 downto 0);
    signal tx_mulq_synced      : std_logic_vector(15 downto 0);

    signal tx_deskew_synced    : std_logic;
    signal tx_dc_balance_synced: std_logic;
    signal tx_toggle_buf_synced: std_logic;
    signal tx_resync_synced    : std_logic;
    signal tx_sat_synced       : std_logic;
    signal tx_shift_synced     : std_logic_vector(3 downto 0);

	signal tx_rst_i			   : std_logic;
    signal tx_rst_gen          : std_logic;
	signal tx_toggle_buf_i	   : std_logic;
	signal tx_toggle_buf_if	   : std_logic;
	signal tx_busy_i		   : std_logic;
    signal tx_ovfl_unsynced    : std_logic;
    signal tx_ovfl_ack_synced  : std_logic;
    signal tx_toggled_unsynced : std_logic;
    signal tx_toggled_i        : std_logic;
    signal tx_busy_unsynced    : std_logic;

    signal mem_allowed         : std_logic;

    signal auto_rst_i          : std_logic;
    signal auto_arm            : std_logic;
    signal rec_stream_valid_i  : std_logic;
    signal auto_core_start     : std_logic;
    signal core_start_if       : std_logic;
    signal core_ov             : std_logic;
    signal auto_tx_toggle_buf  : std_logic;
begin

    auto_rst_i <= auto_rst or core_rst or tx_rst;
    core_ov <= core_ov_fft_i or core_ov_ifft_i or core_ov_cmul_i;
    auto_clr <= auto_rst_i or core_ov;

    auto_inst: entity work.automatic
    port map(
        clk          => sys_clk,
        rst          => auto_rst_i,
        single       => auto_single,
        run          => auto_run,
        running      => auto_running,
        trig_arm     => auto_arm,
        avg_done     => avg_done_i,
        stream_valid => rec_stream_valid_i,
        core_start   => auto_core_start,
        core_ov      => core_ov,
        core_done    => core_done_i,
        tx_toggle    => auto_tx_toggle_buf,
        tx_toggled   => tx_toggled_i
    );
        

	-- mem access handling

    mem_allowed <= not or_many(avg_active_i & core_busy_i & tx_busy_i);

    mem_enia_i  <= mem_enia when mem_allowed = '1' else
                   core_busy_i;
    mem_enib_i  <= mem_enib when mem_allowed = '1' else
                   core_busy_i;
    mem_enoi_i  <= mem_enoi when mem_allowed = '1' else
                   core_busy_i;
    mem_enoa_i  <= mem_enoa when mem_allowed = '1' else
                   core_busy_i;

	core_mem_dinx <= mem_doutia_i;
	mem_doutia    <= mem_doutia_i;
	mem_weaia_i   <= mem_weaia when mem_allowed = '1' else
				     (others => '0');
	mem_addria_i  <= mem_addria when mem_allowed = '1' else
					 core_mem_addrx;
	mem_weaib_i   <= mem_weaib when mem_allowed = '1' else
				     (others => '0');

	core_mem_diny <= mem_doutoi_i;
	mem_dinoi_i   <= mem_dinoi when mem_allowed = '1' else
					 core_mem_douty;
	mem_addroi_i  <= mem_addroi when mem_allowed = '1' else
					 core_mem_addry;
	mem_weoi_i    <= mem_weoi when mem_allowed = '1' else
					 (others => core_mem_wey);
	mem_doutoi    <= mem_doutoi_i;
    
	-- entities

    trig_arm_i <= trig_arm when mem_allowed = '1' else
				  '0';
    trig_arm_if <= trig_arm_i or auto_arm;

	inbuf_inst: entity work.inbuf
	port map(
		sys_clk             => sys_clk,
		refclk_n            => rx_refclk_n,
		refclk_p            => rx_refclk_p,
		rxn                 => rx_rxn,
		rxp                 => rx_rxp,
		txn                 => rx_txn,
		txp                 => rx_txp,
		rec_rst             => rec_rst,
		rec_polarity        => rec_polarity,
		rec_descramble      => rec_descramble,
		rec_rxeqmix         => rec_rxeqmix,
		rec_data_valid      => rec_data_valid,
		rec_enable          => rec_enable,
		rec_input_select    => rec_input_select,
		rec_input_select_changed => rec_input_select_changed,
		rec_stream_valid    => rec_stream_valid_i,
		sample_clk          => sample_clk_i,
		sample_rst          => sample_rst,
		trig_rst            => trig_rst,
		trig_arm            => trig_arm_if,
		trig_ext            => trig_ext,
		trig_int            => trig_int,
		trig_type		    => trig_type,
		trig_armed          => trig_armed,
		trig_trigd          => trig_trigd,
		avg_rst             => avg_rst,
		avg_depth           => depth,
		avg_width           => avg_width,
		avg_done            => avg_done_i,
		avg_active          => avg_active_i,
		avg_err             => avg_err_i,
		frame_index         => open, -- don't we need this?
		frame_clk           => frame_clk_i,
		wave_index          => wave_index,
		mem_dina            => mem_dinia,
		mem_addra           => mem_addria_i,
		mem_wea             => mem_weaia_i,
		mem_douta           => mem_doutia_i,
        mem_ena             => mem_enia_i,
		mem_dinb            => mem_dinib,
		mem_addrb           => mem_addrib,
		mem_web             => mem_weaib_i,
		mem_doutb           => mem_doutib,
        mem_enb             => mem_enib_i
	);

    avg_done   <= avg_done_i;
    avg_err    <= avg_err_i;
	avg_active <= avg_active_i;
	frame_clk  <= frame_clk_i;
    rec_stream_valid <= rec_stream_valid_i;

    core_start_i <= core_start when mem_allowed = '1' else
					'0';
    core_start_if <= core_start_i or auto_core_start;

	core_inst: entity work.core
	port map(
		clk             => sys_clk,
		rst             => core_rst,

		core_start      => core_start_if,
		core_n          => core_n,
		core_scale_sch  => core_scale_sch,
		core_scale_schi => core_scale_schi,
		core_scale_cmul => core_scale_cmul,
		core_L          => core_L,
		core_depth      => depth,
		core_iq         => core_iq,
        core_circular   => core_circular,

		core_ov_fft     => core_ov_fft_i,
		core_ov_ifft    => core_ov_ifft_i,
		core_ov_cmul    => core_ov_cmul_i,

		core_busy       => core_busy_i,
		core_done       => core_done_i,

		wave_index      => wave_index,

		mem_dinx        => core_mem_dinx,
		mem_addrx       => core_mem_addrx,

		mem_diny        => core_mem_diny,
		mem_addry       => core_mem_addry,
		mem_douty       => core_mem_douty,
		mem_wey         => core_mem_wey,

		mem_dinh        => mem_dinh,
		mem_addrh       => mem_addrh,
		mem_weh         => mem_weh,
		mem_douth       => mem_douth,
        mem_enh         => mem_enh
	);

	core_ov_fft  <= core_ov_fft_i;
	core_ov_ifft <= core_ov_ifft_i;
	core_ov_cmul <= core_ov_cmul_i;
	core_busy    <= core_busy_i;
    core_done    <= core_done_i;

    tx_rst_generate: entity work.async_rst
    port map (
        clk => sample_clk_i,
        rst_in => tx_rst,
        rst_out => tx_rst_gen
    );
	tx_rst_i <= sample_rst or tx_rst_gen;
    tx_toggle_buf_i <= tx_toggle_buf when mem_allowed = '1' else
					   '0';
    tx_toggle_buf_if <= tx_toggle_buf_i or auto_tx_toggle_buf;

    tx_busy_gen: process(sys_clk)
    begin
        if rising_edge(sys_clk) then
            if tx_rst = '1' or tx_toggled_i = '1' then
                tx_busy_i <= '0';
            else
                if tx_toggle_buf_if = '1' then
                    tx_busy_i <= '1';
                end if;
            end if;
        end if;
    end process tx_busy_gen;

    sync_tx_muli: entity work.value
    port map(
        value_in    => tx_muli,
        value_out   => tx_muli_synced,
        value_wr    => tx_muli_wr,
        clk_from    => sys_clk,
        clk_to      => sample_clk_i
    );
    sync_tx_mulq: entity work.value
    port map(
        value_in    => tx_mulq,
        value_out   => tx_mulq_synced,
        value_wr    => tx_mulq_wr,
        clk_from    => sys_clk,
        clk_to      => sample_clk_i
    );

    sync_tx_deskew: entity work.toggle
    port map(
        toggle_in   => tx_deskew,
        toggle_out  => tx_deskew_synced,
        clk_from    => sys_clk,
        clk_to      => sample_clk_i
    );
    sync_tx_dc_balance: entity work.flag
    port map(
        flag_in     => tx_dc_balance,
        flag_out    => tx_dc_balance_synced,
        clk         => sample_clk_i
    );
    sync_tx_toggle: entity work.toggle
    port map(
        toggle_in   => tx_toggle_buf_if,
        toggle_out  => tx_toggle_buf_synced,
        clk_from    => sys_clk,
        clk_to      => sample_clk_i
    );
    sync_tx_resync: entity work.toggle
    port map(
        toggle_in   => tx_resync,
        toggle_out  => tx_resync_synced,
        clk_from    => sys_clk,
        clk_to      => sample_clk_i
    );
    sync_tx_sat: entity work.flag
    port map(
        flag_in     => tx_sat,
        flag_out    => tx_sat_synced,
        clk         => sample_clk_i
    );
    sync_tx_shift: entity work.value
    port map(
        value_in    => tx_shift,
        value_out   => tx_shift_synced,
        value_wr    => tx_shift_wr,
        clk_from    => sys_clk,
        clk_to      => sample_clk_i
    );

    sync_ovfl_ack: entity work.toggle
    port map(
        toggle_in   => tx_ovfl_ack,
        toggle_out  => tx_ovfl_ack_synced,
        clk_from    => sys_clk,
        clk_to      => sample_clk_i
    );

	outbuf_inst: entity work.outbuf
	port map(
		clk             => sample_clk_i,
		rst             => tx_rst_i,
		frame_clk       => frame_clk_i,

		txn             => tx_txn,
		txp             => tx_txp,
		txclkn          => tx_txclkn,
		txclkp          => tx_txclkp,

		depth           => depth,
		tx_deskew       => tx_deskew_synced,
		dc_balance      => tx_dc_balance_synced,
		muli            => tx_muli_synced,
		mulq            => tx_mulq_synced,
		toggle_buf      => tx_toggle_buf_synced,
		toggled         => tx_toggled_unsynced,
		frame_offset    => tx_frame_offset,
		resync          => tx_resync_synced,
		busy			=> tx_busy_unsynced,
        ovfl            => tx_ovfl_unsynced,
        ovfl_ack        => tx_ovfl_ack_synced,
        sat             => tx_sat_synced,
        shift           => tx_shift_synced,

		mem_clk         => sys_clk,
		mem_dini        => mem_dinoi_i,
		mem_addri       => mem_addroi_i,
		mem_wei         => mem_weoi_i,
		mem_douti       => mem_doutoi_i,
        mem_eni         => mem_enoi_i,
		mem_addra       => mem_addroa,
		mem_douta       => mem_doutoa,
        mem_ena         => mem_enoa_i
	);

    sync_tx_busy: entity work.flag
    port map(
        flag_in     => tx_busy_unsynced,
        flag_out    => tx_busy,
        clk         => sys_clk
    );

    sync_ovfl: entity work.flag
    port map(
        flag_in     => tx_ovfl_unsynced,
        flag_out    => tx_ovfl,
        clk         => sys_clk
    );

    sync_tx_toggled: entity work.toggle
    port map(
        toggle_in   => tx_toggled_unsynced,
        toggle_out  => tx_toggled_i,
        clk_from    => sample_clk_i,
        clk_to      => sys_clk
    );

    tx_toggled <= tx_toggled_i;

end Structural;

