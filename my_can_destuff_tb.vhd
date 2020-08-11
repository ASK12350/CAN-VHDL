--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:04:41 08/02/2020
-- Design Name:   
-- Module Name:   D:/temp/del/my_can_destuff_tb.vhd
-- Project Name:  del
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: my_can_destuff
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY my_can_destuff_tb IS
END my_can_destuff_tb;
 
ARCHITECTURE behavior OF my_can_destuff_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT my_can_destuff
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         rx : IN  std_logic;
         sample_point : IN  std_logic;
         wr : OUT  std_logic;
         data : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal rx : std_logic := '0';
   signal sample_point : std_logic := '0';

 	--Outputs
   signal wr : std_logic;
   signal data : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: my_can_destuff PORT MAP (
          clk => clk,
          rst => rst,
          rx => rx,
          sample_point => sample_point,
          wr => wr,
          data => data
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   rst_proc: process
   begin		
       rst <='1';
		 wait for 100 ns;
		 rst <='0';
		 wait;
   end process;
	
	rx_proc: process
   begin		
       rx <='1'; 
      wait for 100 ns;	
       rx<='0';
      wait for 100 ns;
       rx<='1';
      wait for 200 ns;
       rx<='0';
      wait for 150 ns;
       rx<='1';
      wait for 250 ns;
       rx<='0';
      wait for 250 ns;
       rx<='1';
      wait for 150 ns;
       rx<='0';
      wait for 50 ns;
       rx<='1'; 
		wait for 200 ns;
		 rx<='0';
		wait for 150 ns;
		 rx <='1';
		wait for 100 ns;
		 rx <='0';
		wait for 100 ns;
		 rx <='1';
		wait for 50 ns;
		 rx <='0';
		wait for 250 ns;
		 rx <='1';
		wait for 50 ns;
       rx <='0';
      wait for 50 ns;
       rx <='1';
      wait for 200 ns;
       rx <='0';
      wait for 150 ns;
       rx <='1';
      wait for 250 ns;
       rx <='0';
      wait for 200 ns;
       rx <='1';		 
      wait;		 
   end process;
   
  s_proc : process
   begin
	  sample_point <='1';
	  wait for 10 ns;
	  sample_point <='0';
	  wait for 40 ns;
	  end process;
END;
