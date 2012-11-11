library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.all;

entity overlap_add is
port(
    clk          : in std_logic;
    rst          : in std_logic;

    start        : in std_logic;
    nfft         : in std_logic_vector(4 downto 0);
    scale_sch    : in std_logic_vector(11 downto 0);
    scale_schi   : in std_logic_vector(11 downto 0);
    L            : in std_logic_vector(11 downto 0);
    Nx           : in std_logic_vector(15 downto 0);
    iq           : in std_logic;

    wave_index   : in std_logic_vector(3 downto 0);
    x_in         : in std_logic_vector(15 downto 0);
    x_index      : out std_logic_vector(15 downto 0);

    y_re_in      : in std_logic_vector(15 downto 0);
    y_im_in      : in std_logic_vector(15 downto 0);
    y_re_out     : out std_logic_vector(15 downto 0);
    y_im_out     : out std_logic_vector(15 downto 0);
    y_index      : out std_logic_vector(15 downto 0);
    y_we         : out std_logic;

    h_re_in      : in std_logic_vector(15 downto 0);
    h_im_in      : in std_logic_vector(15 downto 0);
    h_index      : out std_logic_vector(11 downto 0);

    ovfl_fft     : out std_logic;
    ovfl_ifft    : out std_logic;

    busy         : out std_logic;
    done         : out std_logic
);
end overlap_add;

architecture Structural of overlap_add is
    component fft
  port (
    sclr : in STD_LOGIC := 'X'; 
    fwd_inv_we : in STD_LOGIC := 'X'; 
    rfd : out STD_LOGIC; 
    start : in STD_LOGIC := 'X'; 
    fwd_inv : in STD_LOGIC := 'X'; 
    dv : out STD_LOGIC; 
    nfft_we : in STD_LOGIC := 'X'; 
    scale_sch_we : in STD_LOGIC := 'X'; 
    done : out STD_LOGIC; 
    clk : in STD_LOGIC := 'X'; 
    busy : out STD_LOGIC; 
    edone : out STD_LOGIC; 
    ovflo : out STD_LOGIC; 
    scale_sch : in STD_LOGIC_VECTOR ( 11 downto 0 ); 
    xn_re : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
    xk_im : out STD_LOGIC_VECTOR ( 15 downto 0 ); 
    xn_index : out STD_LOGIC_VECTOR ( 11 downto 0 ); 
    nfft : in STD_LOGIC_VECTOR ( 4 downto 0 ); 
    xk_re : out STD_LOGIC_VECTOR ( 15 downto 0 ); 
    xn_im : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
    xk_index : out STD_LOGIC_VECTOR ( 11 downto 0 ) 
  );
end component;
    type fsm_type is (INACTIVE, PREPARE, START_FFT_IFFT, WAIT_COMPLETE, COMPLETE);
    signal state : fsm_type;
    signal prepare_we   : std_logic;
    signal NH           : std_logic_vector(15 downto 0);
    signal NH_i         : std_logic_vector(15 downto 0);
    signal L_i          : std_logic_vector(11 downto 0);
    signal Nx_i         : std_logic_vector(15 downto 0);
    signal iq_i         : std_logic;
    signal scale_sch_i  : std_logic_vector(11 downto 0);
    signal scale_schi_i : std_logic_vector(11 downto 0);

    signal scratch_din  : std_logic_vector(31 downto 0);
	signal scratch_addr : std_logic_vector(11 downto 0);
	signal scratch_we   : std_logic;
	signal scratch_dout : std_logic_vector(31 downto 0);

	signal edone        : std_logic;
	signal dv           : std_logic;
	signal rfd          : std_logic;

    signal start_fftncmul : std_logic;
    signal fftncmul_done    : std_logic;
    signal ifftnadd_done   : std_logic;
    signal was_last     : std_logic;
    signal start_fft    : std_logic;
    signal start_ifft   : std_logic;
    signal start_transform : std_logic;
    signal scale_sch_fft : std_logic_vector(11 downto 0);
	signal ovflo    : std_logic;
    signal ifft_mem : std_logic;
    signal fft_mem : std_logic;
	signal xn_index   : std_logic_vector(11 downto 0);
	signal xk_index   : std_logic_vector(11 downto 0);
	signal xk_re      : std_logic_vector(15 downto 0);
	signal xk_im      : std_logic_vector(15 downto 0);
	signal xn_re      : std_logic_vector(15 downto 0);
	signal xn_im      : std_logic_vector(15 downto 0);
	signal fft_xn_re      : std_logic_vector(15 downto 0);
	signal fft_xn_im      : std_logic_vector(15 downto 0);
	signal ifft_xn_re      : std_logic_vector(15 downto 0);
	signal ifft_xn_im      : std_logic_vector(15 downto 0);
    signal fft_scratch_re   : std_logic_vector(15 downto 0);
    signal fft_scratch_im   : std_logic_vector(15 downto 0);
    signal fft_scratch_wr   : std_logic;
    signal fft_scratch_index : std_logic_vector(11 downto 0);
    signal ifft_scratch_re   : std_logic_vector(15 downto 0);
    signal ifft_scratch_im   : std_logic_vector(15 downto 0);
    signal ifft_scratch_wr   : std_logic;
    signal ifft_scratch_index : std_logic_vector(11 downto 0);
    signal fft_unload   :std_logic;
    signal ifft_unload :std_logic;
    signal start_1  : std_logic;
    signal start_2  : std_logic;
    signal start_3  : std_logic;
    signal start_4  : std_logic;
    signal start_5  : std_logic;

begin
    fsm_p1: process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= INACTIVE;
            else
                case state is
                    when INACTIVE  =>
                        if start = '1' then
                            state <= PREPARE;
                        else
                            state <= INACTIVE;
                        end if;
                    when PREPARE => state <= START_FFT_IFFT;
                    when START_FFT_IFFT => state <= WAIT_COMPLETE;
                    when WAIT_COMPLETE =>
                        if ifftnadd_done = '1' and was_last = '1' then
                            state <= COMPLETE;
                        else
                            state <= WAIT_COMPLETE;
                        end if;
                    when COMPLETE => state <= INACTIVE;
                end case;
            end if;
        end if;
    end process fsm_p1;

    fsm_p2: process(state)
    begin
        case state is
            when INACTIVE       => prepare_we <= '0'; busy <= '0'; done <= '0';
            when PREPARE        => prepare_we <= '1'; busy <= '1'; done <= '0';
            when START_FFT_IFFT => prepare_we <= '0'; busy <= '1'; done <= '0';
            when WAIT_COMPLETE  => prepare_we <= '0'; busy <= '1'; done <= '0';
            when COMPLETE       => prepare_we <= '0'; busy <= '0'; done <= '1';
        end case;
    end process fsm_p2;

    NH <= "0000000000001000" when nfft = "00011" else 
          "0000000000010000" when nfft = "00100" else 
          "0000000000100000" when nfft = "00101" else 
          "0000000001000000" when nfft = "00110" else 
          "0000000010000000" when nfft = "00111" else 
          "0000000100000000" when nfft = "01000" else 
          "0000001000000000" when nfft = "01001" else 
          "0000010000000000" when nfft = "01010" else 
          "0000100000000000" when nfft = "01011" else 
          "0001000000000000" when nfft = "01100" else 
          "0000000000000000";

    prepare_p: process(clk, state)
    begin
        if rising_edge(clk) then
            if state = PREPARE then
                L_i <= L;
                Nx_i <= Nx;
                NH_i <= NH;
                iq_i <= iq;
                scale_sch_i <= scale_sch;
                scale_schi_i <= scale_schi;
            end if;
        end if;
    end process prepare_p;

    start_dly: process(clk)
    begin
        if rising_edge(clk) then
            if state = START_FFT_IFFT then
                start_1 <= '1';
            else
                start_1 <= '0';
            end if;
            start_2 <= start_1;
            start_3 <= start_2;
            start_4 <= start_3;
            start_5 <= start_4;
        end if;
    end process start_dly;

    start_fftncmul <= '1' when start_5 = '1' or (ifftnadd_done = '1' and was_last = '0') else
                      '0';

    fftncmul_i: entity work.fftncmul
    port map(
        clk          => clk,
        rst          => rst,

        prepare      => prepare_we,
        run          => start_fftncmul,

        wave_index   => wave_index,
        L            => L_i,
        NH           => NH_i,
        Nx           => Nx_i,
        iq           => iq_i,

        xn_addr      => x_index,
        xn_in        => x_in,

        xn_re        => fft_xn_re,
        xn_im        => fft_xn_im,

        xk_re        => xk_re,
        xk_im        => xk_im,
        xk_index     => xk_index,

        H_re         => h_re_in,
        H_im         => h_im_in,
        H_index      => h_index,

        scratch_re   => fft_scratch_re,
        scratch_im   => fft_scratch_im,
        scratch_wr   => fft_scratch_wr,
        scratch_index=> fft_scratch_index,

        start_fft    => start_fft,
        edone        => edone,
        dv           => dv,

        mem_busy     => fft_mem,
        fft_unload   => fft_unload,
        done         => fftncmul_done,
        was_last     => was_last
    );

    ifftnadd_i: entity work.ifftnadd
    port map(
        clk          => clk,
        rst          => rst,

        prepare      => prepare_we,
        run          => fftncmul_done,
        is_last      => was_last,

        L            => L_i,
        NH           => NH_i,
        Nx           => Nx_i,

        xn_re        => ifft_xn_re,
        xn_im        => ifft_xn_im,
        xn_index     => xn_index,

        xk_re        => xk_re,
        xk_im        => xk_im,
        xk_index     => xk_index,

        scratch_re_in=> scratch_dout(15 downto 0),
        scratch_im_in=> scratch_dout(31 downto 16),
        scratch_re_out=> ifft_scratch_re,
        scratch_im_out=> ifft_scratch_im,
        scratch_wr   => ifft_scratch_wr,
        scratch_index=> ifft_scratch_index,

        y_index      => y_index,
        y_re_in      => y_re_in,
        y_im_in      => y_im_in,
        y_re_out     => y_re_out,
        y_im_out     => y_im_out,
        y_wr         => y_we,

        start_fft    => start_ifft,
        edone        => edone,
        dv           => dv,
        rfd          => rfd,

        mem_busy     => ifft_mem,
        ifft_unload  => ifft_unload,
        done         => ifftnadd_done
    );

    scratch_din <= fft_scratch_im & fft_scratch_re when fft_mem = '1' else
                   ifft_scratch_im & ifft_scratch_re;
    scratch_we <= fft_scratch_wr when fft_mem = '1' else
                  ifft_scratch_wr;
    scratch_addr <= fft_scratch_index when fft_mem = '1' else
                    ifft_scratch_index;

    scratch_i: entity work.ram4x32S
    generic map(
        DO_REG             => 1
    )
	port map (
		clka  => clk,
		dina  => scratch_din,
		addra => scratch_addr,
		wea   => scratch_we,
		douta => scratch_dout
    );

    xn_re <= fft_xn_re when fft_mem = '1' else
             ifft_xn_re;
    xn_im <= fft_xn_im when fft_mem = '1' else
             ifft_xn_im;
    start_transform <= start_fft or start_ifft; 
    scale_sch_fft <= scale_sch_i when start_fft = '1' else
                     scale_schi_i;

    ovfl_p: process(clk)
    begin
        if rising_edge(clk) then
            if state = PREPARE or rst = '1' then
                ovfl_fft <= '0';
                ovfl_ifft <= '0';
            elsif state = WAIT_COMPLETE then
                if ovflo = '1' then
                    if fft_unload = '1' then
                        ovfl_fft <= '1';
                    end if;
                    if ifft_unload = '1' then
                        ovfl_fft <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process ovfl_p;

    fft_inst: fft
    port map(
        sclr         => rst,
        fwd_inv_we   => start_transform,
        rfd          => rfd,
        start        => start_transform,
        fwd_inv      => start_fft,
        dv           => dv,
        nfft_we      => prepare_we,
        scale_sch_we => start_transform,
        done         => open,
        clk          => clk,
        busy         => open,
        edone        => edone,
        ovflo        => ovflo,
        scale_sch    => scale_sch_fft,
        xn_re        => xn_re,
        xk_im        => xk_im,
        xn_index     => xn_index,
        nfft         => nfft,
        xk_re        => xk_re,
        xn_im        => xn_im,
        xk_index     => xk_index
    );

end Structural;

