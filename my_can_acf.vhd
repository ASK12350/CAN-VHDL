----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:43:20 08/09/2020 
-- Design Name: 
-- Module Name:    my_can_acf - Behavioral 
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

entity my_can_acf is
  PORT(
     clk               : IN std_logic;
	  rst               : IN std_logic;
	  enable            : IN std_logic;
	  acceptance_filter : IN std_logic_vector(28 DOWNTO 0);
	  acceptance_mask   : IN std_logic_vector(28 DOWNTO 0);
	  id                : IN std_logic_vector(28 DOWNTO 0);
	  ide               : IN std_logic;
	  id_ok             : OUT std_logic);
end my_can_acf;

architecture Behavioral of my_can_acf is
SIGNAL acc_mask : std_logic_vector(28 DOWNTO 0);
SIGNAL tempt : std_logic_vector(28 DOWNTO 0);
SIGNAL id_ok_temp : std_logic;

FUNCTION andv(s:std_logic_vector(28 DOWNTO 0)) RETURN std_logic IS
VARIABLE temp : std_logic:='1';
BEGIN
  FOR i IN 0 TO 28 LOOP
   temp :=temp and s(i);
  END LOOP;
  return temp;
END ;

begin
acc_mask <=acceptance_mask WHEN ide='1' ELSE
           "000000000000000000" & acceptance_mask(10 DOWNTO 0); 

tempt <=  (id xnor acceptance_filter) or (not(acc_mask));	

id_ok_temp <=andv(tempt);

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   id_ok <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(enable='1') THEN
     id_ok <=id_ok_temp;
	 ELSE
	  id_ok <='0';
    END IF;
  END IF;
END PROCESS;
end Behavioral;

