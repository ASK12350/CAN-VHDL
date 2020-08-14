--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:14:06 08/10/2020
-- Design Name:   
-- Module Name:   D:/temp/del/my_can_registers_tb.vhd
-- Project Name:  del
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: my_can_registers
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
 
 
ENTITY my_can_registers_tb IS
END my_can_registers_tb;
 
ARCHITECTURE behavior OF my_can_registers_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT my_can_registers
    PORT(
         clk    : IN  std_logic;
         clr    : IN  std_logic;
         addr   : IN  std_logic_vector(3 downto 0);
			wr     : IN std_logic;
			cs     : IN std_logic;
         data_in  : IN  std_logic_vector(7 downto 0);
         data_out  : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk  : std_logic := '0';
   signal clr  : std_logic := '0';
   signal wr   : std_logic := '0';
   signal cs   : std_logic := '0';
   signal addr : std_logic_vector(3 downto 0) := (others => '0');

	--BiDirs
   signal data_in : std_logic_vector(7 downto 0);
   signal data_out : std_logic_vector(7 DOWNTO 0);
   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: my_can_registers PORT MAP (
          clk    => clk,
          clr    => clr,
          wr     => wr,
          cs     => cs,
          addr   => addr,
          data_in => data_in,
			 data_out=>data_out
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
   stim_proc: process
   begin		
      clr<='1';
      wait for 1000 ns;	
      clr<='0';
		wait for 100 ns;
		cs <='1';
		wait for 700 ns;
		cs <='0';
      wait;
   end process;

   s :PROCESS
	 begin
	 wait for 1100 ns;
	  wr  <='0';
	  wait for 50 ns;
	   wr <='1';
	  wait for 600 ns;
	   wr <='0';
	  wait for 250 ns;
     end process;
	  
	  l : PROCESS
	  begin
	  wait for 1200 ns;
	  addr <="0001";
	  wait for 50 ns;
	  addr <="0010";
	  wait for 50 ns;
	  addr <="0011";
	  wait for 50 ns;
	  addr <="0100";
	  wait for 50 ns;
     addr <="0101";
	  wait for 50 ns;
	  addr <="0110";
	  wait for 50 ns;
	  addr <="0111";
	  wait for 50 ns;
	  addr <="1000";
	  wait for 50 ns;
	  addr <="1001";
	  wait for 50 ns;
	  addr <="1010";
	  wait for 50 ns;
	  addr <="1011";
	  wait for 50 ns;
	  addr <="1100";
	  wait for 50 ns;
	  addr <="1101";
	  wait ;
	  end process;
	  
	  d : process
	  begin
	   wait for 1150 ns;
		data_in <="11001100";
		wait for 50 ns;
		data_in <="11000011";
		wait for 50 ns;
		data_in <="00111000";
		wait for 50 ns;
		data_in <="11110000";
		wait for 50 ns;
		data_in <="01111110";
		wait for 50 ns;
		data_in <="11110000";
		wait for 50 ns;
		data_in <="01111110";
		wait for 50 ns;
		data_in <="11110000";
		wait for 50 ns;
		data_in <="01111110";
		wait for 50 ns;
		data_in <="11110000";
		wait for 50 ns;
		data_in <="01111110";
		wait for 50 ns;
		data_in <="11110000";
		wait for 50 ns;
		data_in <="01111110";
		wait;
		end process;
END; 
