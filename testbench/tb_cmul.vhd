library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.NUMERIC_STD.ALL;
library std;
        use std.textio.all;
library work;
use work.all;

entity tb_cmul is
end tb_cmul;

architecture behav of tb_cmul is
    signal clk     : std_logic := '0';
    signal a_re    : signed(15 downto 0) := "0000000000000000";
    signal a_im    : signed(15 downto 0) := "0000000000000000";
    signal b_re    : signed(15 downto 0) := "0000000000000000";
    signal b_im    : signed(15 downto 0) := "0000000000000000";
    signal c_re    : signed(15 downto 0) := "0000000000000000";
    signal c_im    : signed(15 downto 0) := "0000000000000000";

    signal cnt     : signed(15 downto 0) := "0000000000000000";

begin
    
    process
    begin
        clk <= '1', '0' after 5 ns;
        wait for 10 ns;
    end process;

    process
    begin
        wait for 10 ns;
        a_re <= X"7FFF";
        wait for 10 ns;
        b_re <= X"7FFF";
        wait for 10 ns;
        a_im <= X"7FFF";
        wait for 10 ns;
        a_re <= X"8000";
        wait for 10 ns;
        a_im <= X"8000";
        wait for 10 ns;
        b_re <= X"8000";
        wait for 10 ns;
        a_re <= X"8000";
        a_im <= X"8000";
        b_re <= X"8000";
        b_im <= X"8000";
        wait for 10 ns;
        a_re <= X"7FFF";
        a_im <= X"7FFF";
        b_re <= X"7FFF";
        b_im <= X"7FFF";
        wait for 100 ns;
        assert false report "done" severity failure;
        wait;
    end process;

    cmul_i: entity work.cmul
    port map(
        clk  => clk,
        a_re => a_re,
        a_im => a_im,
        b_re => b_re,
        b_im => b_im,
        c_re => c_re,
        c_im => c_im
    );

    
end behav;