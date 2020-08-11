----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:49:19 08/10/2020 
-- Design Name: 
-- Module Name:    my_can_registers - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;


entity my_can_registers is
           PORT(
			        clk       : IN std_logic;
					  clr       : IN std_logic;
					  wr        : IN std_logic;
					  cs        : IN std_logic;
					  int_i     : IN std_logic;
					  data_in   : IN std_logic_vector(7 DOWNTO 0);
					  addr      : IN std_logic_vector(6 DOWNTO 0);
					  rst               : OUT std_logic;
					  sam               : OUT std_logic;
					  acceptance_filter : OUT std_logic_vector(28 DOWNTO 0);
	              acceptance_mask   : OUT std_logic_vector(28 DOWNTO 0);
	              sjw      			  : OUT std_logic_vector(1 DOWNTO 0);
	              brp       		  : OUT std_logic_vector(5 DOWNTO 0);
	              tseg1     		  : OUT std_logic_vector(3 DOWNTO 0);
	              tseg2   			  : OUT std_logic_vector(2 DOWNTO 0);
					  data_out  		  : OUT std_logic_vector(7 DOWNTO 0));
					  
end my_can_registers;

architecture Behavioral of my_can_registers is

TYPE memory IS ARRAY(0 to 127) OF std_logic_vector(7 DOWNTO 0);
SIGNAL can_regs : memory;
begin
       
bus_timing_0 <= can_regs(1);
bus_timing_1 <= can_regs(2);
acc_mask_0   <= can_regs(3);
acc_mask_1   <= can_regs(4);
acc_mask_2   <= can_regs(5);
acc_mask_3   <= can_regs(6);
acc_filt_0   <= can_regs(7);
acc_filt_1   <= can_regs(8);
acc_filt_2   <= can_regs(9);
acc_filt_3   <= can_regs(10);

		 
PROCESS(clk,clr) 
BEGIN
  IF(clr='1') THEN
	can_regs<=(others=>(others=>'0'));
  ELSIF(rising_edge(clk)) THEN
    IF((cs and wr)='1') THEN
	  can_regs(to_integer(unsigned(addr)))<=data_in;
	 END IF ;
  END IF ;
END PROCESS;

PROCESS(clk,clr)
BEGIN
  If(clr='1') THEN
   data_out <= (others=>'0');
  ELSIF(rising_edge(clk)) THEN
    IF((cs and not(wr))='1') THEN
	  data_out<= can_regs(to_integer(unsigned(addr)));
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,clr)
BEGIN
  IF(clr='1') THEN
   rst<='1'; 
  ELSIF(rising_edge(clk)) THEN
    IF(int_i='1') THEN
	  rst <='0';
	 END IF;
  END IF;
END PROCESS;

sam   <= bus_timing_1(7);
tseg2 <= bus_timing_1(6 DOWNTO 4);
tseg1 <= bus_timing_1(3 DOWNTO 0);
sjw   <= bus_timing_0(7 DOWNTO 6);
brp   <= bus_timing_0(5 DOWNTO 0);

acceptance_filter <= acc_filt_0 & acc_filt_1 & acc_filt_2 & acc_filt_3(4 DOWNTO 0);
acceptance_mask   <= acc_mask_0 & acc_mask_1 & acc_mask_2 & acc_mask_3(4 DOWNTO 0); 

end Behavioral;

