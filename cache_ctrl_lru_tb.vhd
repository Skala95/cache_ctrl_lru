----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2020 07:21:01 PM
-- Design Name: 
-- Module Name: cache_ctrl_lru_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cache_ctrl_lru_tb is
--  Port ( );
end cache_ctrl_lru_tb;

architecture Behavioral of cache_ctrl_lru_tb is
    component cache_ctrl_lru is
       port(clk : in std_logic;
            rst : in std_logic;
            index: in std_logic_vector(9 downto 0);
            tag: in std_logic_vector(15 downto 0);
            it_valid : in std_logic;
            hm_ready: in std_logic;
            it_ready: out std_logic;
            hm_valid: out std_logic;
            hit_miss: out std_logic;
            col: out std_logic_vector(1 downto 0));
   end component;

    signal clk_s : std_logic := '0';
    signal rst_s : std_logic := '0';
    signal index_s : std_logic_vector(9 downto 0) := (others => '0');
    signal tag_s : std_logic_vector(15 downto 0) := (others => '0');
    signal it_valid_s : std_logic := '0';
    signal it_ready_s : std_logic := '0';
    signal hm_ready_s : std_logic := '0';
    signal hm_valid_s : std_logic := '0';
    signal hit_miss_s : std_logic := '0';
    signal col_s : std_logic_vector(1 downto 0) := (others => '0');
begin
    
    duv: cache_ctrl_lru
    port map( clk => clk_s,
              rst => rst_s,
              index => index_s,
              tag => tag_s,
              it_valid => it_valid_s,
              it_ready => it_ready_s,
              hm_ready => hm_ready_s,
              hm_valid => hm_valid_s,
              hit_miss => hit_miss_s,
              col => col_s);

    clk_gen : process is
    begin
        clk_s <= not clk_s;--'0', '1' after 10 ns;
        wait for 1000 ns;
    end process;
    
    uut_gen: process is
    begin
        rst_s <= '1';
        wait for 1000 ns;
        rst_s <= '0';
        wait until falling_edge(rst_s);
        wait until falling_edge(clk_s);
        it_valid_s <= '1';
        tag_s <= x"0001";
        index_s <= "0000000000";
        wait until falling_edge(clk_s);
        it_valid_s <= '0';
        hm_ready_s <= '1';
        for i in 1 to 5 loop
            wait until falling_edge(clk_s);
        end loop;
        it_valid_s <= '1';
        tag_s <= x"0002";
        for i in 1 to 5 loop
            wait until falling_edge(clk_s);
        end loop;
        it_valid_s <= '0';
        tag_s <= x"0002";
        for i in 1 to 5 loop
            wait until falling_edge(clk_s);
        end loop;
        tag_s <= x"0003";
        for i in 1 to 5 loop
            wait until falling_edge(clk_s);
        end loop;
        tag_s <= x"0004";
        wait until falling_edge(clk_s);
        tag_s <= x"0001";
        wait until falling_edge(clk_s);
        tag_s <= x"FFFF";
        wait;
    end process;
end Behavioral;
