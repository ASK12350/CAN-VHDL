----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:11:03 08/10/2020 
-- Design Name: 
-- Module Name:    my_can_crc - Behavioral 
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

entity my_can_crc is
       port(
		    clk     : IN std_logic;
			 clr     : IN std_logic;
			 enable  : IN std_logic;
			 data    : IN std_logic;
			 crc_out : OUT std_logic_vector(14 DOWNTO 0));
			 
end my_can_crc;

architecture Behavioral of my_can_crc is
SIGNAL crc_next : std_logic_vector(15 DOWNTO 0);
SIGNAL crc_temp : std_logic_vector(15 DOWNTO 0);
SIGNAL crc_bit_check : std_logic;

begin
 
crc_out  <= crc_temp(15 DOWNTO 1) ; 
crc_next <= crc_temp(14 DOWNTO 0) & '0';
crc_bit_check <=data xor crc_temp(15);

PROCESS(clk,clr)
BEGIN
  IF(clr ='1') THEN
   crc_temp <="1100010110011001";
  ELSIF(rising_edge(clk)) THEN
    IF(enable='1') THEN
	   IF(crc_bit_check='1') THEN
		 crc_temp <= crc_next xor "1000101100110010";
		ELSE
		 crc_temp <= crc_next;
		END IF;
	 END IF;
  END IF;
END PROCESS;


end Behavioral;

