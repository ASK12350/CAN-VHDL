----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:06:27 08/11/2020 
-- Design Name: 
-- Module Name:    my_can_fifo - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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


entity my_can_fifo is
           PORT(
			     clk      : IN std_logic;
				  rst      : IN std_logic;
				  wr       : IN std_logic;
				  addr     : IN std_logic_vector(5 DOWNTO 0);
				  cs       : IN std_logic;
				  data_in  : IN std_logic_vector(7 DOWNTO 0);
				       data_out : OUT std_logic(7 DOWNTO 0));
				  
end my_can_fifo;

architecture Behavioral of my_can_fifo is

begin


end Behavioral;

