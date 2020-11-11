----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/11/2020 12:08:19 PM
-- Design Name: 
-- Module Name: fifo - Behavioral
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

entity fifo is
  port ( 
    clk : in std_logic;
    rst : in std_logic;
    fifo_en : in std_logic;
    data_in : in std_logic_vector(15 downto 0);
    col_o : out std_logic_vector(1 downto 0);
    hitmiss_o : out std_logic);
end fifo;

architecture Behavioral of fifo is
  type fifo_type is array (0 to 4) of std_logic_vector(15 downto 0);
  signal fifo : fifo_type ;
  signal fifo_ptr : integer; 
  signal all_tags_diff : std_logic;
begin

    process(clk)
    begin
     if(clk'event and clk = '1') then
        if(rst = '1') then
            for i in 0 to 4 loop
                fifo(i) <= (others => '0');
            end loop;
            col_o <= "00";
            hitmiss_o <= '0';
            fifo_ptr <= 0;
        else
            if(fifo_en = '1') then
                if(fifo_ptr = 4) then
                    fifo_ptr <= 0;
                else
                    fifo_ptr <= fifo_ptr+1;
                end if;
                fifo(0) <= data_in;
                for i in 1 to 4 loop
                   fifo(i) <= fifo(i-1);
                end loop;
            end if;          
        end if;
     end if;
     
    end process;
    
--    process(fifo) 
--    begin
--      if((fifo(0) /=  fifo(1)) or (fifo(0) /= fifo(2)) or (fifo(0) /= fifo(3)) or (fifo(0) /= fifo(4)) or (fifo(1) /= fifo(2)) or (fifo(1) /= fifo(3)) or (fifo(1) /= fifo(4)) or (fifo(2) /= fifo(3)) or (fifo(2) /= fifo(4)) or (fifo(3) /= fifo(4))) then
--        all_tags_diff <= '1';
--      else
--        all_tags_diff <= '0';
--      end if;
--    end process;
    
--    hitmiss_o <= '0' when all_tags_diff = '1' else '0';

end Behavioral;
