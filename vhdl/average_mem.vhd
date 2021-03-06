library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.all;

entity average_mem is
port(
    clk          : in std_logic;
    rst          : in std_logic;

    width        : in std_logic_vector(1 downto 0);
    depth        : in std_logic_vector(15 downto 0);
    trig         : in std_logic;
    done         : out std_logic;
    err			 : out std_logic;
    data         : in std_logic_vector(15 downto 0);
	data_valid	 : in std_logic;

    memclk       : in std_logic;
    sample_enable: in std_logic;
    dina         : in std_logic_vector(15 downto 0);
    addra        : in std_logic_vector(15 downto 0);
    wea          : in std_logic_vector(1 downto 0);
    ena          : in std_logic;
    douta        : out std_logic_vector(15 downto 0);
    dinb         : in std_logic_vector(15 downto 0);
    addrb        : in std_logic_vector(15 downto 0);
    web          : in std_logic_vector(1 downto 0);
    enb          : in std_logic;
    doutb        : out std_logic_vector(15 downto 0)
);
end average_mem;

architecture Structural of average_mem is
    type avg_state is (IDLE, FIRST, RUN, FINISHED, FAILED);
    signal state        : avg_state;
    signal next_state   : avg_state;

    signal dina_i       : std_logic_vector(18 downto 0);
    signal addra_i      : std_logic_vector(15 downto 0);
    signal wea_i        : std_logic_vector(18 downto 0);
    signal douta_i      : std_logic_vector(18 downto 0);
    signal dinb_i       : std_logic_vector(18 downto 0);
    signal addrb_i      : std_logic_vector(15 downto 0);
    signal web_i        : std_logic_vector(18 downto 0);
    signal doutb_i      : std_logic_vector(18 downto 0);
    signal ena_i        : std_logic_vector(18 downto 0);
    signal enb_i        : std_logic_vector(18 downto 0);

    signal cycle_cnt    : std_logic_vector(2 downto 0);
    signal frame_cnt    : std_logic_vector(15 downto 0);
    signal read_cnt     : std_logic_vector(15 downto 0);
    signal max          : std_logic_vector(15 downto 0);
    signal max_1        : std_logic_vector(15 downto 0);
    signal width_i      : std_logic_vector(1 downto 0);
    signal width_i2     : std_logic_vector(2 downto 0);

    signal wea_long     : std_logic_vector(15 downto 0);
    signal web_long     : std_logic_vector(15 downto 0);

    signal wea_shift    : std_logic_vector(18 downto 0);
    signal web_shift    : std_logic_vector(18 downto 0);

    signal data0        : signed(18 downto 0);
    signal dataadd      : signed(18 downto 0);
begin

    width_i2 <= "001" when width_i = "01" else
                "011" when width_i = "10" else
                "111" when width_i = "11" else
                "000";

    status: process(clk)
    begin
        if rising_edge(clk) then
            if (state = IDLE and trig = '1') or rst = '1' then
                err <= '0';
            else
                if state = FAILED then
                    err <= '1';
                end if;
            end if;
        end if;
    end process status;

    done <= '1' when state = FINISHED or state = FAILED else
            '0';

    reg: process (clk, state, depth, width, trig)
    begin
        if rising_edge(clk) then
            if state = IDLE and trig = '1' then
                max <= depth - 1;
                max_1 <= depth - 3;
                width_i <= width;
            end if;
        end if;
    end process reg;

    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
            else
                state <= next_state;
            end if;
        end if;
    end process;

    fsm_b: process (state, trig, width_i, width_i2, frame_cnt, cycle_cnt, depth, width, data_valid, max, max_1)
    begin
        case state is
            when IDLE =>
                if trig = '1' then
                    next_state <= FIRST;
                else
                    next_state <= IDLE;
                end if;
            when FIRST =>
				if data_valid = '0' then
					next_state <= FAILED;
				elsif width_i = "00" and frame_cnt = max then
                    next_state <= FINISHED;
                elsif width_i /= "00" and frame_cnt = max_1 then
                    next_state <= RUN;
                else
                    next_state <= FIRST;
                end if;
            when RUN =>
				if data_valid = '0' then
					next_state <= FAILED;
                elsif cycle_cnt = width_i2 and frame_cnt = max then
                    next_state <= FINISHED;
                else
                    next_state <= RUN;
                end if;
            when FINISHED =>
                next_state <= IDLE;
			when FAILED =>
				next_state <= IDLE;
        end case;
    end process fsm_b;

    counter: process (clk)
    begin
        if rising_edge(clk) then
            if state = IDLE or frame_cnt = max then
                frame_cnt <= (others => '0');
            elsif state = FIRST or state = RUN then
                frame_cnt <= frame_cnt + 1;
            end if;
            if state = IDLE then
                cycle_cnt <= (others => '0');
            elsif frame_cnt = max then
                cycle_cnt <= cycle_cnt + 1;
            end if;
            if state = IDLE or read_cnt = max then
                read_cnt <= (others => '0');
            elsif state = RUN then
                read_cnt <= read_cnt + 1;
            end if;
        end if;
    end process counter;

    wea_long(7 downto 0) <= (others => wea(0));
    wea_long(15 downto 8) <= (others => wea(1));
    web_long(7 downto 0) <= (others => web(0));
    web_long(15 downto 8) <= (others => web(1));
    wea_shift <= ("00" & wea_long & "0") when width_i = "01" else
                 ("0" & wea_long & "00") when width_i = "10" else
                 (wea_long & "000") when width_i = "11" else
                 ("000" & wea_long);
    web_shift <= ("00" & web_long & "0") when width_i = "01" else
                 ("0" & web_long & "00") when width_i = "10" else
                 (web_long & "000") when width_i = "11" else
                 ("000" & web_long);

    addra_i <= addra when sample_enable = '0' else
               frame_cnt;
    addrb_i <= addrb when sample_enable = '0' else
               read_cnt;
    wea_i  <= wea_shift when sample_enable = '0' else
              (others => '1') when state = FIRST or state = RUN else
              (others => '0');
    web_i  <= web_shift when sample_enable = '0' else
              (others => '0');
    ena_i  <= (others => ena) when sample_enable = '0' else
              (others => '1') when state = FIRST or state = RUN else
              (others => '0');
    enb_i  <= (others => enb) when sample_enable = '0' else
              (others => '1') when state = FIRST or state = RUN else
              (others => '0');
    data0   <= resize(signed(data), 19);
    dataadd <= resize(signed(data), 19) + signed(doutb_i);
    dina_i <= std_logic_vector(data0) when sample_enable = '1' and cycle_cnt = "00" else
              std_logic_vector(dataadd) when sample_enable = '1' and cycle_cnt /= "00" else
              ("00" & dina & "0") when width_i = "01" else
              ("0" & dina & "00") when width_i = "10" else
              (dina & "000") when width_i = "11" else
              ("000" & dina);
    dinb_i <= ("00" & dinb & "0") when width_i = "01" else
              ("0" & dinb & "00") when width_i = "10" else
              (dinb & "000") when width_i = "11" else
              ("000" & dinb);
    douta <= douta_i(16 downto 1) when width_i = "01" else
             douta_i(17 downto 2) when width_i = "10" else
             douta_i(18 downto 3) when width_i = "11" else
             douta_i(15 downto 0);
    doutb <= doutb_i(16 downto 1) when width_i = "01" else
             doutb_i(17 downto 2) when width_i = "10" else
             doutb_i(18 downto 3) when width_i = "11" else
             doutb_i(15 downto 0);

    inbuf_mem_i: entity work.ram48xi
    generic map(
        WIDTH               => 19,
        DOA_REG             => 1,
        DOB_REG             => 1
    )
    port map (
        clka                => memclk,
        dina                => dina_i,
        addra               => addra_i,
        wea                 => wea_i,
        ena                 => ena_i,
        douta               => douta_i,
        clkb                => memclk,
        dinb                => dinb_i,
        addrb               => addrb_i,
        web                 => web_i,
        doutb               => doutb_i,
        enb                 => enb_i
    );

end Structural;

