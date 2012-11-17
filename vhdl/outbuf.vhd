-----------------------------------------------------------
-- Output buffer
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.procedures.all;

entity outbuf is
port(
    clk                 : in  std_logic;
    rst                 : in  std_logic;
    frame_clk           : in  std_logic;

-- signals for selectio oserdes transmitter
    txn                 : out std_logic_vector(7 downto 0);
    txp                 : out std_logic_vector(7 downto 0);
    txclkn              : out std_logic;
    txclkp              : out std_logic;

-- settings
    depth               : in  std_logic_vector(15 downto 0);
    tx_deskew           : in  std_logic;
    dc_balance          : in  std_logic;
    muli                : in  std_logic_vector(15 downto 0);
    mulq                : in  std_logic_vector(15 downto 0);
    toggle_buf          : in  std_logic;
    toggled             : out std_logic;
    frame_offset        : in  std_logic_vector(15 downto 0);
    resync              : in  std_logic;
	busy				: out std_logic;

-- mem
    mem_clk             : in  std_logic;
    mem_dini            : in  std_logic_vector(31 downto 0);
    mem_addri           : in  std_logic_vector(15 downto 0);
    mem_wei             : in  std_logic_vector(3 downto 0);
    mem_douti           : out std_logic_vector(31 downto 0);
    mem_addra           : in  std_logic_vector(15 downto 0);
    mem_douta           : out std_logic_vector(31 downto 0)
);
end outbuf;

architecture Structural of outbuf is
    signal depth_r           : std_logic_vector(15 downto 0);
    signal frame_addr        : std_logic_vector(15 downto 0);
    signal do_sync           : std_logic;
    signal active            : std_logic;
    signal active_r          : std_logic;
    signal do_toggle         : std_logic;

    signal dout0             : std_logic_vector(31 downto 0);
    signal dout1             : std_logic_vector(31 downto 0);
    signal dout              : std_logic_vector(31 downto 0);
    signal mem_addr0         : std_logic_vector(15 downto 0);
    signal mem_addr1         : std_logic_vector(15 downto 0);
    signal mem_we0           : std_logic_vector(31 downto 0);
    signal mem_we1           : std_logic_vector(31 downto 0);
    signal mem_out0          : std_logic_vector(31 downto 0);
    signal mem_out1          : std_logic_vector(31 downto 0);

    signal e1                : std_logic_vector(23 downto 0);
    signal e2                : std_logic_vector(23 downto 0);

    signal i                 : std_logic_vector(15 downto 0);
    signal q                 : std_logic_vector(15 downto 0);

    signal c_re              : signed(15 downto 0);
    signal c_im              : signed(15 downto 0);

begin

    depth_r_proc: process(clk, rst, depth)
    begin
        if rising_edge(clk) then
            if rst = '1' or resync = '1' then
                depth_r <= depth - 1;
            end if;
        end if;
    end process depth_r_proc;

    do_sync_process: process(clk, rst, resync, frame_clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or resync = '1' then
                do_sync <= '1';
            elsif frame_clk = '1' and do_sync = '1' then
                do_sync <= '0';
            end if;
        end if;
    end process do_sync_process;

    frame_addr_process: process(clk, depth_r, rst, do_sync, frame_offset, frame_addr)
    begin
        if rising_edge(clk) then
            if frame_addr = depth_r or rst = '1' then
                frame_addr <= (others => '0');
            elsif frame_clk = '1' and do_sync = '1' then
                frame_addr <= frame_offset;
            else
                frame_addr <= frame_addr + 1;
            end if;
        end if;
    end process frame_addr_process;

    active_process: process(clk, rst, toggle_buf, do_toggle, frame_addr, depth_r)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                do_toggle <= '0';
                active <= '0';
            elsif toggle_buf = '1' then
                do_toggle <= '1';
            elsif do_toggle = '1' and frame_addr = depth_r then
                active <= not active;
                do_toggle <= '0';
            end if;
        end if;
    end process active_process;

	busy <= do_toggle;

    active_r_process: process(clk, rst, active)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                active_r <= '0';
            else
                active_r <= active;
            end if;
        end if;
    end process active_r_process;

    toggled <= active xor active_r;

--    outbuf_mem_0: entity work.ram48xi
--    generic map(
--        WIDTH               => 32,
--        DOA_REG             => 1,
--        DOB_REG             => 1
--    )
--    port map (
--        clka                => clk,
--        dina                => "00000000000000000000000000000000",
--        addra               => frame_addr,
--        wea                 => "00000000000000000000000000000000",
--        douta               => dout0,
--        clkb                => mem_clk,
--        dinb                => mem_dini,
--        addrb               => mem_addr0,
--        web                 => mem_we0,
--        doutb               => mem_out0
--    );
    outbuf_mem_1: entity work.ram48xi
    generic map(
        WIDTH               => 32,
        DOA_REG             => 1,
        DOB_REG             => 1
    )
    port map (
        clka                => clk,
        dina                => "00000000000000000000000000000000",
        addra               => frame_addr,
        wea                 => "00000000000000000000000000000000",
        douta               => dout1,
        clkb                => mem_clk,
        dinb                => mem_dini,
        addrb               => mem_addr1,
        web                 => mem_we1,
        doutb               => mem_out1
    );
    
    mem_addr0 <= mem_addra when active = '0' else
                 mem_addri;
    mem_addr1 <= mem_addra when active = '1' else
                 mem_addri;
    we_gen: for i in 0 to 3 generate
    begin
        mem_we0((i+1)*8-1 downto i*8) <= (others => mem_wei(i)) when active = '1' else
            (others => '0');
        mem_we1((i+1)*8-1 downto i*8) <= (others => mem_wei(i)) when active = '0' else
            (others => '0');
    end generate;

    mem_douti <= mem_out0 when active = '1' else
                 mem_out1;
    mem_douta <= mem_out1 when active = '1' else
                 mem_out0;

    dout_p: process(clk, dout0, dout1, active, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                dout <= (others => '0');
            else
                if active = '1' then
                    dout <= dout1;
                else
                    dout <= dout0;
                end if;
            end if;
        end if;
    end process dout_p;

    i <= std_logic_vector(c_re);
    q <= std_logic_vector(c_im);

    cmul_i: entity work.cmul
    port map(
        clk          => clk,
        a_re         => signed(dout(15 downto 0)),
        a_im         => signed(dout(31 downto 16)),
        b_re         => signed(muli),
        b_im         => signed(mulq),
        c_re         => c_re,
        c_im         => c_im
    );
    
    e2(0) <= '1'; --VALID
    e2(1) <= '1'; --ENABLE
    e2(2) <= '0'; --Marker_1
    e2(3) <= '0'; --reserved
    e2(7 downto 4) <= "0000";
    e2(23 downto 8) <= i; -- TODO : q?
    e1(0) <= '0'; --TRIGGER1
    e1(1) <= '0'; --TRIGGER2
    e1(2) <= '0'; --Marker_2
    e1(3) <= '0'; --reserved
    e1(7 downto 4) <= "0000";
    e1(23 downto 8) <= q; -- TODO : i?

    transmitter_i: entity work.transmitter
    port map(
        clk                 => clk,
        rst                 => rst,
        e1                  => e1,
        e2                  => e2,
        txn                 => txn,
        txp                 => txp,
        txclkn              => txclkn,
        txclkp              => txclkp,
        deskew              => tx_deskew,
        dc_balance          => dc_balance
    );

end Structural;

