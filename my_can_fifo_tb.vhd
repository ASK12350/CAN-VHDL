--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:25:37 08/25/2020
-- Design Name:   
-- Module Name:   D:/temp/my_can/my_can_fifo_tb.vhd
-- Project Name:  my_can
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: my_can_fifo
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY my_can_fifo_tb IS
END my_can_fifo_tb;
 
ARCHITECTURE behavior OF my_can_fifo_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT my_can_fifo
    PORT(
         wr_clk : IN  std_logic;
         rd_clk : IN  std_logic;
         rst : IN  std_logic;
         data_in : IN  std_logic_vector(7 downto 0);
         wr_en : IN  std_logic;
         rd_en : IN  std_logic;
         data_out : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal wr_clk : std_logic := '0';
   signal rd_clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal data_in : std_logic_vector(7 downto 0) := (others => '0');
   signal wr_en : std_logic := '0';
   signal rd_en : std_logic := '0';

 	--Outputs
   signal fifo_empty : std_logic;
   signal fifo_full : std_logic;
   signal data_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant wr_clk_period : time := 10 ns;
   constant rd_clk_period : time := 15 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: my_can_fifo PORT MAP (
          wr_clk => wr_clk,
          rd_clk => rd_clk,
          rst => rst,
          data_in => data_in,
          wr_en => wr_en,
          rd_en => rd_en,
          data_out => data_out
        );

   -- Clock process definitions
   wr_clk_process :process
   begin
		wr_clk <= '0';
		wait for wr_clk_period/2;
		wr_clk <= '1';
		wait for wr_clk_period/2;
   end process;
 
   rd_clk_process :process
   begin
		rd_clk <= '0';
		wait for rd_clk_period/2;
		rd_clk <= '1';
		wait for rd_clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      rst<='1';
      wait for 1000 ns;	
      rst<='0';
      wait for 100 ns;
		wr_en <='1';
		data_in <="10110110";
		wait for 10 ns;
		data_in <="11110000";
		wait for 10 ns;
		data_in <="00110011";
		wait for 10 ns;
		data_in <="00100011";
		wait for 10 ns;
		data_in <="10110011";
		wait for 10 ns;
		data_in <="00100001";
		wait for 10 ns;
		data_in <="10110010";
		wait for 10 ns;
		data_in <="00100011";
		wait for 10 ns;
		data_in <="00101011";
		wait for 10 ns;
		data_in <="00111011";
		wait for 10 ns;
		data_in <="10110111";
		wait for 10 ns;
		data_in <="00010101";
		wait for 10 ns;
		data_in <="00110000";
		wait for 10 ns;
		data_in <="00110010";
		wait for 10 ns;
		data_in <="00110001";
		wait for 10 ns;
		data_in <="00010011";
		wait for 10 ns;
		data_in <="00101011";
		wait for 10 ns;
		data_in <="00111011";
		wait for 10 ns;
		data_in <="00110111";
		wait for 10 ns;
		data_in <="00111011";
		wait for 10 ns;
		data_in <="00100011";
		wait for 10 ns;
		data_in <="10110011";
		wait for 10 ns;
		data_in <="01110011";
		wait for 10 ns;
		data_in <="00111011";
		wait for 10 ns;
		data_in <="00110111";
		wait for 10 ns;
		data_in <="10110011";
		wait for 10 ns;
		data_in <="01110011";
		wait for 10 ns;
		data_in <="00111011";
		wait for 10 ns;
		data_in <="00100011";
		wait for 10 ns;
		data_in <="00110011";
		wait for 10 ns;
		data_in <="00110011";
		wait for 10 ns;
		data_in <="00110011";
		wait for 10 ns;
		data_in <="00110011";
		wait for 10 ns;
		data_in <="00110011";
		wait for 10 ns;
		data_in <="00110011";
		wait for 10 ns;
		data_in <="00110011";
		wait for 10 ns;
		data_in <="00110011";
		wait for 10 ns;
		data_in <="00110011";
		wait for 10 ns;
		data_in <="00000011";
		wait for 10 ns;
		data_in <="00111011";
		wait for 10 ns;
		data_in <="00100011";
		wait for 10 ns;
		data_in <="00111011";
		wait for 10 ns;
		data_in <="00110011";
		wait for 10 ns;
		data_in <="00110011";
		wait for 10 ns;
		data_in <="00110011";
		wait for 10 ns;
		data_in <="00110011";
		wait for 10 ns;
		data_in <="01010011";
		wait for 10 ns;
		data_in <="10110011";
		wait for 10 ns;
		data_in <="00010011";
		wait for 10 ns;
		data_in <="00100011";
		wait for 10 ns;
		data_in <="00000000";
		wr_en <='0';
      -- insert stimulus here 
      wait;
   end process;
  
   lol : process
	begin
	 wait for 1200 ns;
	  rd_en <='1';
	 wait for 45 ns;
     rd_en <='0';
	 wait;
  end process;
  
END;
