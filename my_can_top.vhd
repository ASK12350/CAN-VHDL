----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:24:18 08/02/2020 
-- Design Name: 
-- Module Name:    my_can_top - Behavioral 
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

entity my_can_top is
    port(
	     clk  : in std_logic;
		  rst  : in std_logic;
		  rx   : in std_logic;
		  tx_in : in std_logic;
		  transmitter : in std_logic;
		  sample_point : out std_logic;
		  sampled_bit : out std_logic;
		  acc_fil          :IN std_logic_vector(28 DOWNTO 0);
        acc_mas          :IN std_logic_vector(28 DOWNTO 0);
		  data : Out std_logic_vector(7 downto 0);
		  tx_out : out std_logic);
		  
end my_can_top;

architecture Behavioral of my_can_top is

COMPONENT my_can_bsp 
    PORT(
	     clk          : IN std_logic;
		  rst          : IN std_logic;
		  clk_en       : IN std_logic;
		  hard_sync    : IN std_logic;
		  sample_point : IN std_logic;
		  sampled_bit  : IN std_logic;
		  sampled_bit_q: IN std_logic;
		  id_ok        : IN std_logic;
		    ide_out    : OUT std_logic;
		    id         : OUT std_logic_vector(28 DOWNTO 0);
			 acf_en     : OUT std_logic;
		    reset_mode : OUT std_logic;
		    data_out   : OUT std_logic_vector(7 DOWNTO 0));
END COMPONENT;

COMPONENT my_can_acf 
  PORT(
     clk               : IN std_logic;
	  rst               : IN std_logic;
	  enable            : IN std_logic;
	  acceptance_filter : IN std_logic_vector(28 DOWNTO 0);
	  acceptance_mask   : IN std_logic_vector(28 DOWNTO 0);
	  id                : IN std_logic_vector(28 DOWNTO 0);
	  ide               : IN std_logic;
	  id_ok             : OUT std_logic);
end COMPONENT;

COMPONENT my_can_btl 
     PORT(
	     rx              : IN std_logic; 
		  tx_in           : IN std_logic;
		  transmitter     : IN std_logic;
        clk             : IN std_logic; 
	     rst             : IN std_logic;
		  reset_mode      : IN std_logic;
		  sam					: IN std_logic;
	     sjw             : IN std_logic_vector(1 DOWNTO 0);
	     brp             : IN std_logic_vector(5 DOWNTO 0);
	     tseg1           : IN std_logic_vector(3 DOWNTO 0);
	     tseg2           : IN std_logic_vector(2 DOWNTO 0);
		         sampled_bit_q     : OUT std_logic;
		         tx_out            : OUT std_logic;
		         clock_en          : OUT std_logic;
		         sample_point      : OUT std_logic;
					sampled_bit       : OUT std_logic;
					hard_sync         : OUT std_logic); 
					
END COMPONENT;

SIGNAL clk_en_temp    : std_logic;
SIGNAL hard_sync_temp : std_logic;
SIGNAL sampled_bit_q_temp : std_logic;
SIGNAL sampled_bit_temp        : std_logic;
SIGNAL sample_point_temp : std_logic;
SIGNAL bit_error : std_logic;
SIGNAL reset_mode_temp  : std_logic;
SIGNAL  sam					: std_logic:='1';
SIGNAL  sjw             : std_logic_vector(1 DOWNTO 0):="11";
SIGNAL  brp             : std_logic_vector(5 DOWNTO 0):="000011";
SIGNAL  tseg1           : std_logic_vector(3 DOWNTO 0):="1000";
SIGNAL  tseg2           : std_logic_vector(2 DOWNTO 0):="011";
SIGNAL acf_en_temp      : std_logic;
SIGNAL id_temp          : std_logic_vector(28 DOWNTO 0);
SIGNAL ide_temp         : std_logic;
SIGNAL id_ok_temp       : std_logic;

begin

sample_point <=sample_point_temp;
sampled_bit <=sampled_bit_temp;

uubtl : my_can_btl PORT MAP ( clk => clk,
										rst => rst,
										rx  => rx,
										tx_in=>tx_in,
										transmitter=>transmitter,
										reset_mode=>reset_mode_temp,
										sam=>sam,
										sjw=>sjw,
										brp=>brp,
										tseg1=>tseg1,
										tseg2=>tseg2,
										tx_out=>tx_out,
										clock_en=>clk_en_temp,
										hard_sync=>hard_sync_temp,
										sampled_bit=>sampled_bit_temp,
										sampled_bit_q=>sampled_bit_q_temp,
										sample_point=>sample_point_temp);
	
uudestuff : my_can_bsp PORT MAP ( clk=>clk,
                                      rst=>rst,
												  sampled_bit=>sampled_bit_temp,
												  sampled_bit_q=>sampled_bit_q_temp,
												  hard_sync=>hard_sync_temp,
												  sample_point=>sample_point_temp,
												  ide_out=>ide_temp,
												  acf_en=>acf_en_temp,
												  id=>id_temp,
												  id_ok=>id_ok_temp,
												  clk_en=>clk_en_temp,
												  reset_mode =>reset_mode_temp,
												  data_out=>data);
						 
uuacf   : my_can_acf PORT MAP    (     clk=>clk,
                                			rst=>rst,
                                       enable=>acf_en_temp,
													acceptance_filter=>acc_fil,
													acceptance_mask =>acc_mas,
													id=>id_temp,
													ide=>ide_temp,
													id_ok=>id_ok_temp);
													


end Behavioral;

