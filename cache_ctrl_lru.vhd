library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cache_ctrl_lru is
  Port (clk : in std_logic;
        rst : in std_logic;
        index: in std_logic_vector(9 downto 0);
        tag: in std_logic_vector(15 downto 0);
        it_valid : in std_logic;
        hm_ready: in std_logic;
        it_ready: out std_logic;
        hm_valid: out std_logic;
        hit_miss: out std_logic;
        col: out std_logic_vector(1 downto 0)         
   );
end cache_ctrl_lru;

architecture Behavioral of cache_ctrl_lru is
    type state is (idle,receiving ,checking ,done);
    signal state_next, state_reg : state ;
    type t_sets is array(0 to 1023) of std_logic_vector(63 downto 0);
    signal sets: t_sets;
    signal s_tags: std_logic_vector(63 downto 0);
    type t_lru is array(0 to 1023,0 to 3) of std_logic_vector(3 downto 0);
    type t_full is array(0 to 1023) of std_logic;
    signal lru : t_lru;
    signal s_hit0_reg, s_hit1_reg, s_hit2_reg, s_hit3_reg,  s_hit0_next, s_hit1_next, s_hit2_next, s_hit3_next : std_logic := '0';
    signal receive_reg, receive_next : std_logic := '0';
    signal full : t_full;
    signal tag_reg,tag_next : std_logic_vector(15 downto 0);
    signal s_col_reg, s_col_next : std_logic_vector(1 downto 0);
    signal done_reg, done_next : std_logic := '0';
   -- signal it_ready_reg, it_ready_next : std_logic := '0';
begin

    process(clk) is
    begin
        if(clk'event and clk = '1') then
            if(rst = '1') then
                state_reg <= idle;
            else
                state_reg <= state_next;
            end if;
        end if;
    end process;
    
    process(state_reg, it_valid, hm_ready) is
    begin
        case state_reg is
            when idle =>
                if(it_valid = '1') then
                    state_next <= receiving;
                else 
                    state_next <= idle;
                end if;
            when receiving =>
                if(it_valid = '1') then
                    state_next <= checking;
                else 
                    state_next <= idle;
                end if;
            when checking =>
                state_next <= done;
            when done =>
                if(hm_ready = '1') then
                    state_next <= idle;
                else
                    state_next <= done;
                end if;   
        end case;
    end process;
    
    process(clk) is
    begin
        if(clk'event and clk = '1') then
            if(rst = '1') then
                --s_tags <= (others => '0');
                tag_reg <=  (others => '0');
                s_hit0_reg <= '0';
                s_hit1_reg <= '0';
                s_hit2_reg <= '0';
                s_hit3_reg <= '0';
                s_col_reg <= "00";
                receive_reg <= '0';
                done_reg <= '0';
                for i in 0 to 1023 loop
                    sets(i) <= (others => '0');                    
                    full(i) <= '0';
                    for j in 0 to 3 loop
                        lru(i,j) <= (others => '0');
                    end loop; 
                end loop;
            else
                s_hit0_reg <= s_hit0_next;
                s_hit1_reg <= s_hit1_next;
                s_hit2_reg <= s_hit2_next;
                s_hit3_reg <= s_hit3_next;
                s_col_reg <= s_col_next;
                receive_reg <= receive_next;
                done_reg <= done_next;       
                tag_reg <= tag_next;   
                --s_tags <= sets(to_integer(unsigned(index)));   --ovo predstavlja problem
            end if;
        end if;
    end process;
    
    process(state_reg, s_tags, s_hit0_reg, s_hit1_reg, s_hit2_reg, s_hit3_reg, s_col_reg, receive_reg, done_reg, it_valid, lru, full, sets,  index, tag, tag_reg) is
    begin
        s_hit0_next <= s_hit0_reg;
        s_hit1_next <= s_hit1_reg;
        s_hit2_next <= s_hit2_reg;
        s_hit3_next <= s_hit3_reg;
        s_col_next <= s_col_reg;
        receive_next <= receive_reg;
        done_next <= done_reg;
        tag_next <= tag_reg;
        case state_reg is
            when idle =>
                col<= "00"; 
                hit_miss <= '0'; 
                hm_valid <= '0';
                if(it_valid = '1') then
                    it_ready <= '1';
                else 
                    it_ready <= '0';
                end if;
            when receiving =>
                if(it_valid = '1') then
                    tag_next <= tag;
                    it_ready <= '0';
                    
                else
                    it_ready <= '0';
                end if;
             when checking =>
                if(tag_reg = sets(to_integer(unsigned(index)))(63 downto 48) ) then
                     s_hit0_next <= '1';
                     s_hit1_next <= '0';
                     s_hit2_next <= '0';
                     s_hit3_next <= '0';
                     s_col_next <= "00";
                     if (full(to_integer(unsigned(index))) = '1') then
                         lru(to_integer(unsigned(index)),0) <= x"0";
                         lru(to_integer(unsigned(index)),1) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),1))+1);
                         lru(to_integer(unsigned(index)),2) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),2))+1);
                         lru(to_integer(unsigned(index)),3) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),3))+1);
                     end if;
                     done_next <= '1'; 
                 elsif (tag_reg = sets(to_integer(unsigned(index)))(47 downto 32)) then
                     s_hit0_next <= '0';
                     s_hit1_next <= '1';
                     s_hit2_next <= '0';
                     s_hit3_next <= '0';
                     s_col_next <= "01";
                     if (full(to_integer(unsigned(index))) = '1') then
                         lru(to_integer(unsigned(index)),0) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),0))+1);
                         lru(to_integer(unsigned(index)),1) <= x"0";
                         lru(to_integer(unsigned(index)),2) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),2))+1);
                         lru(to_integer(unsigned(index)),3) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),3))+1);
                     end if;
                     done_next <= '1'; 
                 elsif (tag_reg = sets(to_integer(unsigned(index)))(31 downto 16)) then
                     s_hit0_next <= '0';
                     s_hit1_next <= '0';
                     s_hit2_next <= '1';
                     s_hit3_next <= '0';
                     s_col_next <= "10";
                     if (full(to_integer(unsigned(index))) = '1') then
                         lru(to_integer(unsigned(index)),0) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),0))+1);
                         lru(to_integer(unsigned(index)),1) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),1))+1);
                         lru(to_integer(unsigned(index)),2) <= x"0";
                         lru(to_integer(unsigned(index)),3) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),3))+1);
                     end if;
                     done_next <= '1'; 
                 elsif (tag_reg = sets(to_integer(unsigned(index)))(15 downto 0)) then
                     s_hit0_next <= '0';
                     s_hit1_next <= '0';
                     s_hit2_next <= '0';
                     s_hit3_next <= '1';
                     s_col_next <= "11";
                     if (full(to_integer(unsigned(index))) = '1') then
                         lru(to_integer(unsigned(index)),0) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),0))+1);
                         lru(to_integer(unsigned(index)),1) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),1))+1);
                         lru(to_integer(unsigned(index)),2) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),2))+1);
                         lru(to_integer(unsigned(index)),3) <= x"0";
                     end if;
                     done_next <= '1'; 
                 else
                     s_col_next <= "00";
                     s_hit0_next <= '0';
                     s_hit1_next <= '0';
                     s_hit2_next <= '0';
                     s_hit3_next <= '0';
                     if(lru(to_integer(unsigned(index)),0) = x"0" and full(to_integer(unsigned(index))) = '0') then
                        sets(to_integer(unsigned(index)))(63 downto 48) <= tag_reg;
                        lru(to_integer(unsigned(index)),0) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),0))+1);
                     elsif(lru(to_integer(unsigned(index)),1) = x"0" and full(to_integer(unsigned(index))) = '0') then
                        sets(to_integer(unsigned(index)))(47 downto 32) <= tag_reg;
                        lru(to_integer(unsigned(index)),1) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),1))+1);
                     elsif(lru(to_integer(unsigned(index)),2) = x"0" and full(to_integer(unsigned(index))) = '0') then
                        sets(to_integer(unsigned(index)))(31 downto 16) <= tag_reg;
                        lru(to_integer(unsigned(index)),2) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),2))+1); 
                     elsif(lru(to_integer(unsigned(index)),3) = x"0" and full(to_integer(unsigned(index))) = '0') then
                        sets(to_integer(unsigned(index)))(15 downto 0) <= tag_reg;
                        lru(to_integer(unsigned(index)),3) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),3))+1);
                        full(to_integer(unsigned(index))) <= '1'; 
                     else
                         -- proverava se da li je prva kolona LRU, i ako jeste znaci prva kolona je LRU                  
                         if((unsigned(lru(to_integer(unsigned(index)),0)) >= unsigned(lru(to_integer(unsigned(index)),1))) and (unsigned(lru(to_integer(unsigned(index)),0)) >= unsigned(lru(to_integer(unsigned(index)),2))) and (unsigned(lru(to_integer(unsigned(index)),0)) >= unsigned(lru(to_integer(unsigned(index)),3)))) then
                             lru(to_integer(unsigned(index)),0) <= x"0";
                             lru(to_integer(unsigned(index)),1) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),1))+1);
                             lru(to_integer(unsigned(index)),2) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),2))+1);
                             lru(to_integer(unsigned(index)),3) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),3))+1);
                             sets(to_integer(unsigned(index)))(63 downto 48) <= tag_reg;
                          -- ako nije prva kolona LRU  
                         else
                             -- proverava da li je prva kolona LRU pre druge
                             if(unsigned(lru(to_integer(unsigned(index)),0)) >= unsigned(lru(to_integer(unsigned(index)),1))) then
                                 -- ako jeste, proverava da li je prva kolona LRU pre trece kolone, i ako jeste znaci da je cetvrta kolona LRU
                                 if(unsigned(lru(to_integer(unsigned(index)),0)) >= unsigned(lru(to_integer(unsigned(index)),2))) then
                                    lru(to_integer(unsigned(index)),0) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),0))+1);
                                    lru(to_integer(unsigned(index)),1) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),1))+1);
                                    lru(to_integer(unsigned(index)),2) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),2))+1);
                                    lru(to_integer(unsigned(index)),3) <= x"0";
                                    sets(to_integer(unsigned(index)))(15 downto 0) <= tag_reg; 
                                 -- ako nije prva kolona LRU pre trece 
                                 else 
                                     -- proverava se da li je treca kolona LRU pre cetvrte, ako je zadovoljena treca kolona je LRU
                                     if(unsigned(lru(to_integer(unsigned(index)),2)) >= unsigned(lru(to_integer(unsigned(index)),3))) then
                                        lru(to_integer(unsigned(index)),0) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),0))+1);
                                        lru(to_integer(unsigned(index)),1) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),1))+1);
                                        lru(to_integer(unsigned(index)),2) <= x"0";
                                        lru(to_integer(unsigned(index)),3) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),3))+1);
                                        sets(to_integer(unsigned(index)))(31 downto 16) <= tag_reg;
                                     -- ako nije cetvrta kolona je LRU
                                     else
                                        lru(to_integer(unsigned(index)),0) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),0))+1);
                                        lru(to_integer(unsigned(index)),1) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),1))+1);
                                        lru(to_integer(unsigned(index)),2) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),2))+1);
                                        lru(to_integer(unsigned(index)),3) <= x"0";
                                        sets(to_integer(unsigned(index)))(15 downto 0) <= tag_reg;
                                     end if;
                                 end if;
                             -- prva kolona nije LRU pre druge
                             else
                                 -- proverava da li je druga kolona LRU (prva nije sigurno), i ako jeste znaci da je druga kolona LRU
                                 if((unsigned(lru(to_integer(unsigned(index)),1)) >= unsigned(lru(to_integer(unsigned(index)),2))) and (unsigned(lru(to_integer(unsigned(index)),1)) >= unsigned(lru(to_integer(unsigned(index)),3)))) then 
                                    lru(to_integer(unsigned(index)),0) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),0))+1);
                                    lru(to_integer(unsigned(index)),1) <= x"0" ;
                                    lru(to_integer(unsigned(index)),2) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),2))+1);
                                    lru(to_integer(unsigned(index)),3) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),3))+1);
                                    sets(to_integer(unsigned(index)))(47 downto 32) <= tag_reg;
                                 --ako nije druga LRU
                                 else
                                     -- proverava da li je druga kolona LRU pre trece, i ako jeste znaci da je cetvrta kolona LRU
                                     if(unsigned(lru(to_integer(unsigned(index)),1)) >= unsigned(lru(to_integer(unsigned(index)),2))) then
                                         lru(to_integer(unsigned(index)),0) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),0))+1);
                                         lru(to_integer(unsigned(index)),1) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),1))+1);
                                         lru(to_integer(unsigned(index)),2) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),2))+1);
                                         lru(to_integer(unsigned(index)),3) <= x"0";
                                         sets(to_integer(unsigned(index)))(15 downto 0) <= tag_reg;
                                     -- druga kolona nije LRU pre trece
                                     else
                                         -- proverava da li je treca kolona LRU pre cetvrte, ako jeste znaci treca je LRU
                                         if(unsigned(lru(to_integer(unsigned(index)),2)) >= unsigned(lru(to_integer(unsigned(index)),3))) then
                                             lru(to_integer(unsigned(index)),0) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),0))+1);
                                             lru(to_integer(unsigned(index)),1) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),1))+1);
                                             lru(to_integer(unsigned(index)),2) <= x"0";
                                             lru(to_integer(unsigned(index)),3) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),3))+1);
                                             sets(to_integer(unsigned(index)))(31 downto 16) <= tag_reg;lru(to_integer(unsigned(index)),0) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),0))+1);
                                          -- ako nije, cetvrta je LRU
                                          else 
                                             lru(to_integer(unsigned(index)),0) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),0))+1);
                                             lru(to_integer(unsigned(index)),1) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),1))+1);
                                             lru(to_integer(unsigned(index)),2) <= std_logic_vector(unsigned(lru(to_integer(unsigned(index)),2))+1);
                                             lru(to_integer(unsigned(index)),3) <= x"0";
                                             sets(to_integer(unsigned(index)))(15 downto 0) <= tag_reg;
                                          end if;
                                     end if;
                                 end if;
                             end if;
                         end if;
                     end if;
                  end if;
            when done =>
                hm_valid <= '1';
                hit_miss <= s_hit0_reg or s_hit1_reg or s_hit2_reg or s_hit3_reg;
                col <= s_col_reg;                          
        end case;    
    end process;
 
    --s_tags <= sets(to_integer(unsigned(index))); --zasto ovo pravi problem
 
end Behavioral;
