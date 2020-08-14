--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   07:42:43 08/06/2020
-- Design Name:   
-- Module Name:   D:/temp/del/my_can_bsp_tb.vhd
-- Project Name:  del
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: my_can_bsp
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
 
ENTITY my_can_bsp_tb IS
END my_can_bsp_tb;
 
ARCHITECTURE behavior OF my_can_bsp_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT my_can_bsp
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         clk_en : IN  std_logic;
         hard_sync : IN  std_logic;
         sample_point : IN  std_logic;
         sampled_bit : IN  std_logic;
			reset_mode  : OUT std_logic;
         data : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal clk_en : std_logic := '0';
   signal hard_sync : std_logic := '0';
   signal sample_point : std_logic := '0';
   signal sampled_bit : std_logic := '0';
	
 	--Outputs
   signal data : std_logic_vector(7 downto 0);
   signal reset_mode : std_logic := '0';

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: my_can_bsp PORT MAP (
          clk => clk,
          rst => rst,
          clk_en => clk_en,
          hard_sync => hard_sync,
          sample_point => sample_point,
          sampled_bit => sampled_bit,
          reset_mode => reset_mode,
          data => data
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   clk_en_process :process
   begin
		clk_en <= '0';
		wait for clk_period*9;
		clk_en <= '1';
		wait for clk_period;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
