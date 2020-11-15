------------------------------------------------------------------------------------
---- Company: 
---- Engineer: 
---- 
---- Create Date: 04/19/2020 06:15:16 PM
---- Design Name: 
---- Module Name: cache_ctrl_lru_tb - Behavioral
---- Project Name: 
---- Target Devices: 
---- Tool Versions: 
---- Description: 
---- 
---- Dependencies: 
---- 
---- Revision:
---- Revision 0.01 - File Created
---- Additional Comments:
---- 
------------------------------------------------------------------------------------


--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
----use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx leaf cells in this code.
----library UNISIM;
----use UNISIM.VComponents.all;

--entity cache_ctrl_lru_tb is
----  Port ( );
--end cache_ctrl_lru_tb;

--architecture Behavioral of cache_ctrl_lru_tb is
--    component cache_ctrl_lru is
--       port(clk : in std_logic;
--            rst : in std_logic;
--            index: in std_logic_vector(9 downto 0);
--            tag: in std_logic_vector(15 downto 0);
--            it_valid : in std_logic;
--            hm_ready: in std_logic;
--            it_ready: out std_logic;
--            hm_valid: out std_logic;
--            hit_miss: out std_logic;
--            col: out std_logic_vector(1 downto 0));
--   end component;

--    signal clk_s : std_logic := '0';
--    signal rst_s : std_logic := '0';
--    signal index_s : std_logic_vector(9 downto 0) := (others => '0');
--    signal tag_s : std_logic_vector(15 downto 0) := (others => '0');
--    signal it_valid_s : std_logic := '0';
--    signal it_ready_s : std_logic := '0';
--    signal hm_ready_s : std_logic := '0';
--    signal hm_valid_s : std_logic := '0';
--    signal hit_miss_s : std_logic := '0';
--    signal col_s : std_logic_vector(1 downto 0) := (others => '0');
--begin
    
--    duv: cache_ctrl_lru
--    port map( clk => clk_s,
--              rst => rst_s,
--              index => index_s,
--              tag => tag_s,
--              it_valid => it_valid_s,
--              it_ready => it_ready_s,
--              hm_ready => hm_ready_s,
--              hm_valid => hm_valid_s,
--              hit_miss => hit_miss_s,
--              col => col_s);

--    clk_gen : process is
--    begin
--        clk_s <= not clk_s;--'0', '1' after 10 ns;
--        wait for 10 ns;
--    end process;
    
--    uut_gen: process is
--    begin
--        rst_s <= '1';
--        wait for 100 ns;
--        rst_s <= '0';
--        index_s <= "0000000000";        
--        wait until falling_edge(rst_s);
--        wait until falling_edge(clk_s);
--        it_valid_s <= '1';
--        tag_s <= x"0009";
--        wait until falling_edge(clk_s);
--        it_valid_s <= '0';
----        wait until hm_valid_s = '1';
----        wait until falling_edge(clk_s);
----        hm_ready_s <= '1';
----        wait until falling_edge(clk_s);
----        hm_ready_s <= '0';
----        --tag_s <= x"FFFF";
--        wait;
--    end process;
--end Behavioral;    
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cache_ctrl_lru_tb is
--  Port ( );
end cache_ctrl_lru_tb;

architecture Behavioral of cache_ctrl_lru_tb is
    component cache_ctrl_lru is
       generic(SET_SIZE : natural := 1024;
      	TAG_SIZE : natural := 4--16   
      		  );
       port(clk : in std_logic;
            rst : in std_logic;
            index: in std_logic_vector(9 downto 0);
            tag: in std_logic_vector((TAG_SIZE - 1) downto 0);
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
    signal tag_s : std_logic_vector(3 downto 0) := (others => '0');
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
        index_s <= "0000000000";
        it_valid_s <= '1';
        tag_s <= "0000";
        wait until falling_edge(rst_s);
        wait until falling_edge(clk_s);
        for i in 0 to 10 loop
            it_valid_s <= '1';
            tag_s <= "0000";
            --index_s <= std_logic_vector(unsigned(index_s)+1);
            wait until falling_edge(clk_s);
            wait until falling_edge(clk_s);
            it_valid_s <= '0';
            wait until hm_valid_s = '1';
            wait until falling_edge(clk_s);
            hm_ready_s <= '1';
            wait until falling_edge(clk_s);
            hm_ready_s <= '0';
            for i in 1 to 5 loop
                wait until falling_edge(clk_s);
            end loop;
        end loop;
        for i in 0 to 10 loop 
            it_valid_s <= '1';
            tag_s <= std_logic_vector(unsigned(tag_s)+1);
            --index_s <= std_logic_vector(unsigned(index_s)+1);
            wait until falling_edge(clk_s);
            wait until falling_edge(clk_s);
            it_valid_s <= '0';
            wait until hm_valid_s = '1';
            wait until falling_edge(clk_s);
            hm_ready_s <= '1';
            wait until falling_edge(clk_s);
            hm_ready_s <= '0';
            for i in 1 to 5 loop
                wait until falling_edge(clk_s);
            end loop;
        end loop;
        it_valid_s <= '1';
        tag_s <= "1010";
        for i in 1 to 5 loop
            wait until falling_edge(clk_s);
        end loop;
        it_valid_s <= '0';
        wait until hm_valid_s = '1';
        wait until falling_edge(clk_s);
        hm_ready_s <= '1';
        wait until falling_edge(clk_s);
        hm_ready_s <= '0';
        for i in 1 to 5 loop
            wait until falling_edge(clk_s);
        end loop;
        it_valid_s <= '1';
        tag_s <= "1001";
        wait until falling_edge(clk_s);
        wait until falling_edge(clk_s);
        it_valid_s <= '0';
        wait until hm_valid_s = '1';
        wait until falling_edge(clk_s);
        hm_ready_s <= '1';
        wait until falling_edge(clk_s);
        hm_ready_s <= '0';
        --tag_s <= x"FFFF";
        wait;
    end process;
end Behavioral;