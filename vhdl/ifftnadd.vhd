library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

library work;
use work.all;

entity ifftnadd is
port(
    clk          : in  std_logic;
    rst          : in  std_logic;

    prepare      : in  std_logic;
    run          : in  std_logic;
    is_last      : in  std_logic;

    L            : in  std_logic_vector(11 downto 0);
    NH           : in  std_logic_vector(15 downto 0);
    Nx           : in  std_logic_vector(15 downto 0);

    xn_re        : out std_logic_vector(15 downto 0);
    xn_im        : out std_logic_vector(15 downto 0);
    xn_index     : in  std_logic_vector(11 downto 0);

    xk_re        : in  std_logic_vector(15 downto 0);
    xk_im        : in  std_logic_vector(15 downto 0);
    xk_index     : in  std_logic_vector(11 downto 0);

    scratch_re_in: in  std_logic_vector(15 downto 0);
    scratch_im_in: in  std_logic_vector(15 downto 0);
    scratch_re_out:out std_logic_vector(15 downto 0);
    scratch_im_out:out std_logic_vector(15 downto 0);
    scratch_wr   : out std_logic;
    scratch_index: out std_logic_vector(11 downto 0);

    y_index      : out std_logic_vector(15 downto 0);
    y_re_in      : in  std_logic_vector(15 downto 0);
    y_im_in      : in  std_logic_vector(15 downto 0);
    y_re_out     : out std_logic_vector(15 downto 0);
    y_im_out     : out std_logic_vector(15 downto 0);
    y_wr         : out std_logic;

    start_fft    : out std_logic;
    edone        : in  std_logic;
    dv           : in  std_logic;
    rfd          : in  std_logic;

    mem_busy     : out std_logic;
    ifft_unload  : out std_logic;
    done         : out std_logic
);
end ifftnadd;

architecture Structural of ifftnadd is
    --TODO CYCLIC insert
    type fft_fsm_type is (INACTIVE, LOAD_IFFT, LOAD_SCRATCH, WAIT_IFFT, UNLOAD, INCR, FINISHED);

    signal state : fft_fsm_type;
    signal block_cnt    : std_logic_vector(15 downto 0);
    signal addr_cnt     : std_logic_vector(11 downto 0);
    signal addr_cnt_1   : std_logic_vector(11 downto 0);
    signal addr_cnt_2   : std_logic_vector(11 downto 0);
    signal addr_cnt_3   : std_logic_vector(11 downto 0);
    signal xk_re_1      : std_logic_vector(15 downto 0);
    signal xk_re_2      : std_logic_vector(15 downto 0);
    signal xk_im_1      : std_logic_vector(15 downto 0);
    signal xk_im_2      : std_logic_vector(15 downto 0);
    signal addr_1       : std_logic_vector(15 downto 0);
    signal addr_2       : std_logic_vector(15 downto 0);
    signal addr         : std_logic_vector(15 downto 0);
    signal dv_1         : std_logic;
    signal dv_if        : std_logic;
    signal dv_if_1      : std_logic;
    signal dv_if_2      : std_logic;
    signal dv_2         : std_logic;
    signal dv_3         : std_logic;
    signal do_add       : std_logic;
    signal do_add_1     : std_logic;
    signal do_add_2     : std_logic;
    signal y_re         : std_logic_vector(15 downto 0);
    signal y_im         : std_logic_vector(15 downto 0);

begin

    fft_p1: process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= INACTIVE;
            else
                case state is
                    when INACTIVE  =>
                        if run = '1' then
                            state <= LOAD_IFFT;
                        else
                            state <= INACTIVE;
                        end if;
                    when LOAD_IFFT =>
                        if rfd = '0' then
                            state <= LOAD_SCRATCH;
                        else
                            state <= LOAD_IFFT;
                        end if;
                    when LOAD_SCRATCH =>
                        if addr_cnt = (NH - L + 2) then -- OK?
                            state <= WAIT_IFFT;
                        else
                            state <= LOAD_SCRATCH;
                        end if;
                    when WAIT_IFFT =>
                        if edone = '1' then
                            state <= UNLOAD;
                        else
                            state <= WAIT_IFFT;
                        end if;
                    when UNLOAD =>
                        if dv_3 = '0' then
                            state <= INCR;
                        else
                            state <= UNLOAD;
                        end if;
                    when INCR => state <= FINISHED;
                    when FINISHED => state <= INACTIVE;
                end case;
            end if;
        end if;
    end process fft_p1;

    block_cnt_impl: process(clk)
    begin
        if rising_edge(clk) then
            if state = INACTIVE and prepare = '1' then
                block_cnt <= (others => '0');
            elsif state = INCR then
                block_cnt <= block_cnt + L;
            end if;
        end if;
    end process;


--------------------------------------------------------------------------
-- FFT FILL aka ifft(scratch,Nf)
--------------------------------------------------------------------------

    start_fft <= '1' when state = INACTIVE and run = '1' else
                 '0';

    scratch_index <= addr_cnt_3 when state = LOAD_SCRATCH else
                     xn_index;
    --scratch: 2 read cycles; fft 3 -> delay by one
    xn_dly: process(clk)
    begin
        if rising_edge(clk) then
            xn_re <= scratch_re_in;
            xn_im <= scratch_im_in;
        end if;
    end process;

--------------------------------------------------------------------------
-- SCRATCH FILL with y(block_cnt:block_cnt+NH-L-1)
--------------------------------------------------------------------------
    addr_cnt_impl: process(clk)
    begin
        if rising_edge(clk) then
            if state /= LOAD_SCRATCH then
                addr_cnt <= (others => '0');
            else
                addr_cnt <= addr_cnt + 1;
            end if;
        end if;
    end process addr_cnt_impl;

    addr_cnt_dly: process(clk)
    begin
        if rising_edge(clk) then
            addr_cnt_1 <= addr_cnt;
            addr_cnt_2 <= addr_cnt_1;
            addr_cnt_3 <= addr_cnt_2;
        end if;
    end process addr_cnt_dly;

    addr <= addr_cnt + block_cnt when state = LOAD_SCRATCH else
            addr_2;

    y_index_dly: process(clk)
    begin
        if rising_edge(clk) then
            y_index <= addr_2;
        end if;
    end process y_index_dly;

    scratch_re_out <= y_re_in;
    scratch_im_out <= y_im_in;
    scratch_wr <= '1' when addr_cnt > 3 and state = LOAD_SCRATCH else -- OK?
                  '0';

--------------------------------------------------------------------------
-- UNLOAD aka y=scratch(0:Nf-L-1) + ifft()
--------------------------------------------------------------------------
    do_add <= '1' when xk_index < NH - L else
              '0';
    -- scratch 2 read cycles
    xk_dly: process(clk)
    begin
        if rising_edge(clk) then
            xk_re_1 <= xk_re;
            xk_re_2 <= xk_re_1;
            xk_im_1 <= xk_im;
            xk_im_2 <= xk_im_1;
            do_add_1 <= do_add;
            do_add_2 <= do_add_1;
        end if;
    end process xk_dly;

    y_re <= xk_re_2 + scratch_re_in when do_add_2 = '1' else
            xk_re_2;
    y_im <= xk_im_2 + scratch_im_in when do_add_2 = '1' else
            xk_im_2;

    y_re_dly: process(clk)
    begin
        if rising_edge(clk) then
            y_re_out <= y_re;
            y_im_out <= y_im;
        end if;
    end process;
    
    --y addr delay by 3 (2 cycle scratch + 1 cycle add)
    addr_dly: process(clk)
    begin
        if rising_edge(clk) then
            addr_1 <= block_cnt + xk_index;
            addr_2 <= addr_1;
        end if;
    end process addr_dly;

    --don't write values > Nx
    dv_if <= dv_1 when addr_1 < Nx else
             '0';

    dv_dly: process(clK)
    begin
        if rising_edge(clk) then
            dv_1 <= dv;
            dv_2 <= dv_1;
            dv_if_1 <= dv_if;
            dv_3 <= dv_2;
            dv_if_2 <= dv_if_1;
        end if;
    end process dv_dly;

    y_wr <= dv_if_2;

--------------------------------------------------------------------------
-- tell the rest of the world what we're doing
--------------------------------------------------------------------------

    mem_busy <= '1' when state = UNLOAD or state = LOAD_IFFT or state = LOAD_SCRATCH else
                '0';
    ifft_unload <= '1' when state = UNLOAD else
                   '0';
    done <= '1' when state = FINISHED else
            '0';

end Structural;
