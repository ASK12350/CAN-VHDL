--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:58:08 08/02/2020
-- Design Name:   
-- Module Name:   D:/temp/del/my_can_top_tb.vhd
-- Project Name:  del
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: my_can_top
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
  
ENTITY my_can_top_tb IS
END my_can_top_tb;
 
ARCHITECTURE behavior OF my_can_top_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT my_can_top
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         rx : IN  std_logic;
         tx_in : IN  std_logic;
         transmitter : IN  std_logic;
			acc_fil : IN std_logic_vector(28 DOWNTO 0);
         acc_mas : IN std_logic_vector(28 DOWNTO 0);
			sample_point : out std_logic;
			sampled_bit : out std_logic;
			tx_out : out std_logic;
			data : OUT std_logic_vector(7 DOWNTO 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk_1 : std_logic := '0';
   signal rst : std_logic := '0';
   signal tx_in_1 : std_logic := '1';
   signal t_1 : std_logic := '0';
   SIGNAL acc_fil_1          : std_logic_vector(28 DOWNTO 0):="00000000000000000000000000111";
   SIGNAL acc_mas_1          : std_logic_vector(28 DOWNTO 0):="11110000000000000000000111111";
	signal data_1 : std_logic_vector(7 downto 0) ;

 	--Outputs
	signal sampled_bit_1: std_logic;
	signal sample_point_1 : std_logic;
	signal tx_out_1 : std_logic;
	
	
   --Inputs
   signal clk_2 : std_logic := '0';
   signal tx_in_2 : std_logic := '1';
   signal t_2 : std_logic := '0';
	SIGNAL acc_fil_2          : std_logic_vector(28 DOWNTO 0):="11111100000000000000011001100";
   SIGNAL acc_mas_2          : std_logic_vector(28 DOWNTO 0):="11111100000000000000011111000";
	signal data_2 : std_logic_vector(7 downto 0) ;

 	--Outputs
	signal sampled_bit_2: std_logic;
	signal sample_point_2 : std_logic;
	signal tx_out_2 : std_logic;

	
	
   --Inputs
   signal clk_3 : std_logic := '0';
   signal tx_in_3 : std_logic := '1';
   signal t_3 : std_logic := '0';
	SIGNAL acc_fil_3          : std_logic_vector(28 DOWNTO 0):="01000101011010001000110100101";
   SIGNAL acc_mas_3          : std_logic_vector(28 DOWNTO 0):="00000000000000000010000000000";
   signal data_3 : std_logic_vector(7 downto 0) ;

 	--Outputs
	signal sampled_bit_3 : std_logic;
	signal sample_point_3 : std_logic;
  	signal tx_out_3 : std_logic;

  
  SIGNAL bus_level : std_logic;
   -- Clock period definitions
   constant clk_period_1 : time := 10 ns;
   constant clk_period_2 : time := 10.1 ns;
   constant clk_period_3 : time := 9.9 ns;

BEGIN
 bus_level <= tx_out_1 WHEN (t_1 ='1') ELSE
              tx_out_2 WHEN (t_2 ='1') ELSE
				  tx_out_3 WHEN (t_3 ='1') ELSE
				  '1';
 
 
	-- Instantiate the Unit Under Test (UUT)
   uut: my_can_top PORT MAP (
          clk => clk_1,
          rst => rst,
          rx => bus_level,
          tx_in => tx_in_1,
          transmitter => t_1,
			 acc_fil=>acc_fil_1,
			 acc_mas=>acc_mas_1,
			 sample_point=>sample_point_1,
			 sampled_bit=>sampled_bit_1,
          tx_out => tx_out_1,
			 data=>data_1
        );
	 uus: my_can_top PORT MAP (
          clk => clk_2,
          rst => rst,
          rx => bus_level,
          tx_in => tx_in_2,
          transmitter => t_2,
			 acc_fil=>acc_fil_2,
			 acc_mas=>acc_mas_2,
			 sample_point=>sample_point_2,
			 sampled_bit=>sampled_bit_2,
          tx_out => tx_out_2,
			 data=>data_2
        );
	uuf: my_can_top PORT MAP (
          clk => clk_3,
          rst => rst,
          rx => bus_level,
          tx_in => tx_in_3,
          transmitter => t_3,
			 acc_fil=>acc_fil_3,
			 acc_mas=>acc_mas_3,
			 sample_point=>sample_point_3,
			 sampled_bit=>sampled_bit_3,
          tx_out => tx_out_3,
			 data=>data_3
        );



   -- Clock process definitions
   clk1_process :process
   begin
		clk_1 <= '0';
		wait for clk_period_1/2;
		clk_1 <= '1';
		wait for clk_period_1/2;
   end process;
	
	clk2_process :process
   begin
		clk_2 <= '0';
		wait for clk_period_2/2;
		clk_2 <= '1';
		wait for clk_period_2/2;
   end process;
	
	clk3_process :process
   begin
		clk_3 <= '0';
		wait for clk_period_3/2;
		clk_3 <= '1';
		wait for clk_period_3/2;
   end process;
 

   -- Stimulus process
   rst_proc: process
   begin		
      rst <='1';-- hold reset state for 100 ns.
      wait for 1000 ns;	
      rst <='0'; 
      wait;
   end process;

   transmit:process
	begin
	 wait for 1200 ns;
	  t_1 <='1';
    wait for 70000 ns;
	 wait for 5000 ns;
	 wait for 1000 ns;
	  t_1 <='0';
	  t_2 <='1';
	 wait for 75000 ns;
	 wait for 4500 ns;
	  t_2 <='0';
	  t_3 <='1';
	 wait for 64000 ns;
	  t_3 <='0';
	 wait for 10000 ns;
	  t_1 <='1';
	 wait for 155000 ns;
	  t_1 <='0';
    wait;
	 end process;
	 
	 tx:process
	 begin
	 tx_in_1 <='1';
	 wait for 1500 ns;
	  tx_in_1<='0';
    wait for 1100 ns;   --sof end
	   tx_in_1 <='0';    --ID1 start
	 wait for 1100 ns;    
       tx_in_1<='1';
      wait for 4400 ns;
       tx_in_1<='0';
      wait for 3300 ns;
       tx_in_1<='1';
      wait for 3300 ns; -- id1 end
		 tx_in_1 <='1';
		wait for 2200 ns; --srr and ide 
       tx_in_1<='0';
      wait for 5500 ns; --destuffs to 4 zeroes & ID2 starts
       tx_in_1<='1';                                            --ID1:-01111000111
      wait for 3300 ns; --destuffs to 2 zeroes                  --ID2:-000011011110001100
       tx_in_1<='0';
      wait for 1100 ns;
       tx_in_1<='1'; 
		wait for 4400 ns;
		 tx_in_1<='0';
		wait for 3300 ns;
		 tx_in_1 <='1';
		wait for 2200 ns;
		 tx_in_1 <='0';
		wait for 2200 ns; --ID2 ends
		 tx_in_1 <='1';   --rtr
		wait for 1100 ns; 
		 tx_in_1 <='0';
		wait for 5500 ns; --rb1 & rb0 & dlc(3 downto 1)          --RB1=RB0=0
		 tx_in_1 <='1';   --destuffs
		wait for 1100 ns;
       tx_in_1 <='0';
      wait for 1100 ns; --dlc(4)                               --dlc=0000 
       tx_in_1 <='1';   --crc starts
      wait for 1100 ns;                      --crc calculated is 101100001000110
        tx_in_1 <='0';
      wait for 1100 ns;
       tx_in_1 <='1';
      wait for 2200 ns;
       tx_in_1 <='0';
      wait for 4400 ns;
       tx_in_1 <='1';
      wait for 1100 ns;
       tx_in_1 <='0';
      wait for 3300 ns;
       tx_in_1 <='1';
      wait for 2200 ns;
       tx_in_1 <='0';
		wait for 1100 ns; --crc ends          --crc received is 101100001000110
		 tx_in_1 <='1';
      wait for 30000 ns; --crc_de,ack,ack_de,etc		 
      tx_in_2 <='1';
	 wait for 1500 ns;
	  tx_in_2<='0';       --sof
    wait for 1100 ns;    
       tx_in_2<='1';     --ID1 starts
      wait for 1100 ns; 
       tx_in_2<='0';
      wait for 2200 ns;                    
       tx_in_2<='1';
      wait for 2200 ns; 
       tx_in_2<='0';
      wait for 2200 ns;
       tx_in_2<='1';
      wait for 1100 ns;
       tx_in_2<='0';
      wait for 2200 ns;
       tx_in_2<='1'; 
		wait for 1100 ns;  --ID1 ends                          ID1:-10011001001
		 tx_in_2<='0';
		wait for 5500 ns; --rtr,ide,rn0 ,dlc(3 downto 2)       rtr=ide=rb0=0
		 tx_in_2 <='1';
		wait for 1100 ns; --destuffs                             
		 tx_in_2 <='0';
		wait for 2200 ns; --dlc(1 downto 0)                    dlc=0000
		 tx_in_2 <='0';   --crc starts            crc calculated is 010100101011010
		wait for 1100 ns; 
		 tx_in_2 <='1';
		wait for 1100 ns;
		 tx_in_2 <='0';
		wait for 1100 ns;
		 tx_in_2 <='1';
		wait for 1100 ns;
       tx_in_2 <='0';
      wait for 2200 ns;
       tx_in_2 <='1';
      wait for 1100 ns;
       tx_in_2 <='0';
		wait for 1100 ns;
       tx_in_2 <='1';
      wait for 1100 ns;
       tx_in_2 <='0';
		wait for 1100 ns;
       tx_in_2 <='1';
      wait for 2200 ns;
       tx_in_2 <='0';
		wait for 1100 ns;
       tx_in_2 <='1';
      wait for 1100 ns;
       tx_in_2 <='0';
		wait for 1100 ns; --crc ends               crc receivec is 010100101011010
		 tx_in_2 <='1';
      wait for 12300 ns; --crc_de,ack,ack_de etc
		 tx_in_3 <='1';
		wait for 11000 ns;
      tx_in_3<='0';
    wait for 2200 ns; --sof ,id(10)
       tx_in_3<='1';
      wait for 1100 ns; 
       tx_in_3<='0';
      wait for 5500 ns;
       tx_in_3<='1';
      wait for 2200 ns; --destuffs to 1bit
       tx_in_3<='0';
      wait for 5500 ns; --id1(2 downto 0),rtr,ide            ID1 is 01000001000
       tx_in_3<='1';                                           
      wait for 1100 ns; --destuffs                           rtr,ide,rb0=0 
       tx_in_3<='0';                                         
      wait for 4400 ns; --rb0, dlc(3 downto 1)             
       tx_in_3<='1'; 
		wait for 3300 ns; --dlc(0),data1(7 downto 6)           dlc=0001
		 tx_in_3<='0';
		wait for 1100 ns; 
		 tx_in_3 <='1';
		wait for 5500 ns;  --data ends                         data1=11011111
		 tx_in_3 <='0';    --destuffs
		wait for 1100 ns;                          --crc calculated is 100101000000111
		 tx_in_3 <='1';    --crc starts
		wait for 1100 ns;
		 tx_in_3 <='0';
		wait for 2200 ns;
		 tx_in_3 <='1';
		wait for 1100 ns;
		 tx_in_3 <='0';
		wait for 1100 ns;
       tx_in_3 <='1';
      wait for 1100 ns;
       tx_in_3 <='0';
      wait for 5500 ns;
       tx_in_3 <='1'; --destuffs
      wait for 1100 ns;
       tx_in_3 <='0';
      wait for 1100 ns;                           --crc received is 100101000000111
       tx_in_3 <='1';  --crc(2 downto 0) ,crc_de,ack etc
		wait for 28000 ns;                                 
		 tx_in_1 <='1';
		wait for 100 ns;
		 tx_in_1 <='0';
		wait for 2200 ns;  --sof,id(10) 
		 tx_in_1 <='1';
		wait for 3300 ns;  --
		 tx_in_1 <='0';
		wait for 1100 ns;
		 tx_in_1 <='1';
		wait for 2200 ns;
		 tx_in_1 <='0';
		wait for 1100 ns;
		 tx_in_1 <='1';
		wait for 2200 ns;
		 tx_in_1 <='0';
		wait for 1100 ns;    --id1 end        --ID1:-01110110110
		 tx_in_1 <='1';
		wait for 5500 ns;  --rtr,ide,ID2(17 downto 15)
		 tx_in_1 <='0';
		wait for 1100 ns; --destuffs          --srr=ide=1
		 tx_in_1 <='1';
		wait for 2200 ns; 
		 tx_in_1 <='0';
		wait for 1100 ns;
		 tx_in_1 <='1';
		wait for 3300 ns;
		 tx_in_1 <='0';
		wait for 3300 ns;
		 tx_in_1 <='1';
		wait for 2200 ns;
		 tx_in_1 <='0';
		wait for 1100 ns;
		 tx_in_1 <='1';
		wait for 3300 ns;   --id2 end         --ID2:-111110111000110111
		 tx_in_1 <='0';
		wait for 3300 ns;  --rtr,rb0,rb1,     --rtr=rb1=rb0=0
		 tx_in_1 <='1';
		wait for 1100 ns;
		 tx_in_1 <='0';
		wait for 3300 ns;  --dlc end             dlc=1000
		 tx_in_1 <='1';  --data starts
		wait for 1100 ns;
		 tx_in_1 <='0';
		wait for 1100 ns;
		 tx_in_1 <='1';
		wait for 4400 ns;
		 tx_in_1 <='0';
		wait for 4400 ns; --data1(1 downto 0),data2(7 downto 6)  --data1=10111100
		 tx_in_1 <='1';
		wait for 1100 ns;
		 tx_in_1 <='0';
		wait for 1100 ns;
		 tx_in_1 <='1';
		wait for 5500 ns; --data2(3 downto 0),data3(7)            --data2=00101111   
		 tx_in_1 <='0';
		wait for 5500 ns; --destuffs to 4 ones
		 tx_in_1 <='1';
		wait for 3300 ns; --destuffs to 3 zeroes
		 tx_in_1 <='0';
		wait for 1100 ns; --data3 end                             --data3=10000110
		 tx_in_1 <='1';
		wait for 1100 ns;
		 tx_in_1 <='0';
		wait for 1100 ns;
		 tx_in_1 <='1';
		wait for 2200 ns;
		 tx_in_1 <='0';
		wait for 1100 ns;
		 tx_in_1 <='1';
		wait for 1100 ns;
		 tx_in_1 <='0';
		wait for 1100 ns;
		 tx_in_1 <='1';
		wait for 1100 ns; --data4 end                             --data4=10110101
		 tx_in_1 <='0';
		wait for 1100 ns;
		 tx_in_1 <='1';
		wait for 2200 ns;
		 tx_in_1 <='0';
		wait for 1100 ns;
		 tx_in_1 <='1';
		wait for 1100 ns;
		 tx_in_1 <='0';
		wait for 1100 ns;
		 tx_in_1 <='1';
		wait for 3300 ns;--data5(1 downto 0),data6(7)             --data5=01101011
		 tx_in_1 <='0';
		wait for 1100 ns;
		 tx_in_1 <='1';
		wait for 2200 ns;
		 tx_in_1 <='0';
		wait for 2200 ns;
		 tx_in_1 <='1';
		wait for 2200 ns;  --data6                                --data6=10110011
		 tx_in_1 <='0';
		wait for 2200 ns;
		 tx_in_1 <='1';
		wait for 1100 ns;
		 tx_in_1 <='0';
		wait for 4400 ns;
		 tx_in_1 <='1';
		wait for 1100 ns;  --data7                                --data7=00100001
		 tx_in_1 <='0';
		wait for 5500 ns;
		 tx_in_1 <='1';
		wait for 2200 ns; --destuffs to 1 one
		 tx_in_1 <='0';
		wait for 1100 ns;
		 tx_in_1 <='1';
		wait for 1100 ns;                                         --data8=00000101
		 tx_in_1 <='1';  --crc starts
		wait for 4400 ns;                    --crc calculated is 111111011111110
		 tx_in_1 <='0';                 
		wait for 1100 ns; --destuffs
		 tx_in_1 <='1';
		wait for 2200 ns;
		 tx_in_1 <='0';
		wait for 1100 ns;
		 tx_in_1 <='1';
		wait for 5500 ns;
		 tx_in_1 <='1';  --changed
		wait for 1100 ns; --destuffs
		 tx_in_1 <='1';
		wait for 2200 ns;
		 tx_in_1 <='0';
		wait for 1100 ns;--crc ends           --crc received is 111111011111110
		 tx_in_1 <='1';
		wait for 2200 ns;--crc_de,ack,etc
		 tx_in_1 <='1';
      wait;		 
   end process;
	 
	 
	 
	 
END;
