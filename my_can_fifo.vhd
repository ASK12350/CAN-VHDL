----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:16:05 08/24/2020 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity my_can_fifo is
port(
     wr_clk      : IN std_logic;
     rd_clk      : IN std_logic;
	  rst         : IN std_logic;
	  data_in     : IN std_logic_vector(7 DOWNTO 0);
	  wr_en       : IN std_logic;
	  rd_en       : IN std_logic;
	  fifo_empty  : OUT std_logic;
	  fifo_full   : OUT std_logic;
	  data_out    : OUT std_logic_vector(7 DOWNTO 0));
end my_can_fifo;

architecture Behavioral of my_can_fifo is
TYPE memory IS ARRAY (0 TO 63) OF std_logic_vector(7 DOWNTO 0);
SIGNAL fifo : memory :=(others=>(others=>'0'));
SIGNAL data_cnt  : integer range 0 to 13;
SIGNAL wr_index  : integer range 0 to 63:=0;
SIGNAL rd_index  : integer range 0 to 63:=0;
SIGNAL fifo_cnt  : integer range 0 to 63:=0;
SIGNAL go_overload : std_logic;
SIGNAL fifo_empty_temp  : std_logic;
SIGNAL fifo_full_temp   : std_logic;

FUNCTION conv(b : boolean) return std_logic IS
BEGIN
 IF b THEN return '1'; ELSE return '0'; END IF;
END;

begin
fifo_full       <=fifo_full_temp;
fifo_empty      <=fifo_empty_temp;
fifo_empty_temp <= conv(fifo_cnt=0);
fifo_full_temp  <= conv(fifo_cnt=63);

PROCESS(wr_clk,rst)
BEGIN
  IF(rst='1') THEN
   fifo <=(others=>(others=>'0'));
  ELSIF(rising_edge(wr_clk)) THEN
    IF((wr_en and not(fifo_full_temp)) ='1') THEN
	   fifo(wr_index) <= data_in;
	 END IF;
  END IF;
END PROCESS;

PROCESS(wr_clk,rst)
BEGIN
  IF(rst='1') THEN
   wr_index <=0;
  ELSIF(rising_edge(wr_clk)) THEN
    IF((wr_en and not(fifo_full_temp))='1') THEN
	   IF(wr_index=63) THEN
		 wr_index <=0;
		ELSE
       wr_index <=wr_index+1;
		END IF;
    END IF;
  END IF;
END PROCESS;

PROCESS(rd_clk,rst)
BEGIN
  IF(rst='1') THEN
   rd_index <=0;
  ELSIF(rising_edge(rd_clk)) THEN
    IF((rd_en and not(fifo_empty_temp))='1') THEN
	   IF(rd_index=63) THEN
		 rd_index <=0;
		ELSE
		 rd_index <=rd_index+1;
	   END IF;
	 END IF;
  END IF;
END PROCESS;

PROCESS(rd_clk,rst)
BEGIN
  IF(rst='1') THEN
   data_out <=(others=>'0');
  ELSIF(rising_edge(rd_clk)) THEN
    IF((rd_en and not(fifo_empty_temp))='1') THEN
	  data_out <=fifo(rd_index);
	 END IF;
  END IF;
END PROCESS;

PROCESS(rd_clk,wr_clk,rst)
BEGIN
  IF(rst='1') THEN
   fifo_cnt <=0;
  ELSE
    IF(rising_edge(rd_clk)) THEN
	   IF((rd_en and not(fifo_empty_temp))='1') THEN
		 fifo_cnt <=fifo_cnt-1;
		END IF;
	 END IF;
    IF(rising_edge(wr_clk)) THEN
	   IF((wr_en and not(fifo_full_temp))='1') THEN
		 fifo_cnt <=fifo_cnt+1;
		END IF;
    END IF;
  END IF;
END PROCESS;
	

end Behavioral;

