LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY my_can_bsp IS
    PORT(
	     clk          : IN std_logic;
		  rst          : IN std_logic;
		  clk_en       : IN std_logic;
		  hard_sync    : IN std_logic;
		  sample_point : IN std_logic;
		  sampled_bit  : IN std_logic;
		  sampled_bit_q: IN std_logic;
		    reset_mode : OUT std_logic;
		       data    : OUT std_logic_vector(7 DOWNTO 0));
END my_can_bsp;

ARCHITECTURE behavioral OF my_can_bsp IS

SIGNAL go_rx_id1    : std_logic;
SIGNAL go_rx_id2    : std_logic;
SIGNAL go_rx_rtr1   : std_logic;
SIGNAL go_rx_ide    : std_logic;
SIGNAL go_rx_rtr2   : std_logic;
SIGNAL go_rx_rb0    : std_logic;
SIGNAL go_rx_rb1    : std_logic;
SIGNAL go_rx_dlc    : std_logic;
SIGNAL go_rx_data   : std_logic;
SIGNAL go_rx_crc    : std_logic;
SIGNAL go_rx_crc_de : std_logic;
SIGNAL go_rx_ack    : std_logic;
SIGNAL go_rx_ack_de : std_logic;
SIGNAL go_rx_eof    : std_logic;
SIGNAL go_rx_idle   : std_logic;
SIGNAL go_rx_inter  : std_logic;
SIGNAL go_rx_error  : std_logic;
SIGNAL go_rx_presof : std_logic;
SIGNAL go_rx_sof    : std_logic;
SIGNAl rx_idle      : std_logic;
SIGNAL rx_inter     : std_logic;
SIGNAL rx_error     : std_logic;
SIGNAL rx_presof    : std_logic;
SIGNAL rx_sof       : std_logic;
SIGNAL rx_id1       : std_logic;
SIGNAL rx_id2       : std_logic;
SIGNAL rx_rtr1      : std_logic;
SIGNAL rx_ide       : std_logic;
SIGNAL rx_rtr2      : std_logic;
SIGNAL rx_rb0       : std_logic;
SIGNAL rx_rb1       : std_logic;
SIGNAL rx_dlc       : std_logic;
SIGNAL rx_data      : std_logic;
SIGNAL rx_crc       : std_logic;
SIGNAL rx_crc_de    : std_logic;
SIGNAL rx_ack       : std_logic;
SIGNAL rx_ack_de    : std_logic;
SIGNAL rx_eof       : std_logic;
SIGNAL id1          : std_logic_vector(10 DOWNTO 0);
SIGNAL id2          : std_logic_vector(17 DOWNTO 0);
SIGNAL rtr1         : std_logic;
SIGNAL ide          : std_logic;
SIGNAL rtr2         : std_logic;
SIGNAL rb0          : std_logic;
SIGNAL rb1          : std_logic;
SIGNAL dlc          : std_logic_vector(3 DOWNTO 0);
SIGNAL data_temp    : std_logic_vector(7 DOWNTO 0);
SIGNAL crc          : std_logic_vector(14 DOWNTO 0);
SIGNAL crc_de       : std_logic;
SIGNAL ack          : std_logic;
SIGNAL ack_de       : std_logic;
SIGNAL destuff_cnt  : integer range 0 to 5;
SIGNAL destuff      : std_logic;
SIGNAL cnt : integer range 0 to 20;
--SIGNAL sample_point_q : std_logic;

FUNCTION conv(b: boolean) return std_logic IS
BEGIN
  IF b THEN
   return('1');
  ELSE
   return ('0'); 
  END IF;
END ;

FUNCTION orv(s:std_logic_vector(3 DOWNTO 0)) return std_logic IS
VARIABLE temp : std_logic:='0';
BEGIN 
  FOR i IN 0 TO 2 LOOP
   temp:=temp or s(i);
  END LOOP;
  IF(temp='1') THEN
   return ('1'); 
  ELSE
   return ('0');
  END IF;
END;

BEGIN

data <=data_temp;
 
go_rx_presof <= hard_sync and (rx_idle or rx_inter);
go_rx_sof    <= (sample_point and rx_presof);
go_rx_id1    <= (sample_point and rx_sof);
go_rx_rtr1   <= (sample_point and rx_id1 and not(destuff))and conv(cnt=10);
go_rx_ide    <= (sample_point and rx_rtr1 and not(destuff));
go_rx_id2    <= (sample_point and rx_ide) and sampled_bit_q and not(destuff);
go_rx_rtr2   <= (sample_point and rx_id2) and not(destuff) and conv(cnt=17);
go_rx_rb0    <=  sample_point and ((not(sampled_bit_q) and rx_ide) or (ide and rx_rb1));
go_rx_rb1    <= (sample_point and rx_rtr2 and ide) and not(destuff); 
go_rx_dlc    <= (sample_point and rx_rb0) and not(destuff);
go_rx_data   <= (sample_point and rx_dlc) and conv(cnt=3) and not(destuff) and (orv(dlc) or sampled_bit_q);
go_rx_crc    <= ((sample_point and ((rx_data and conv(cnt=7)) or (rx_dlc and conv(cnt=3) and not(orv(dlc) or sampled_bit_q)))) and not(destuff)) ;
go_rx_crc_de <= (sample_point and rx_crc) and conv(cnt=14) and not(destuff);
go_rx_ack    <= (sample_point and rx_crc_de);
go_rx_ack_de <= (sample_point and rx_ack);
go_rx_eof    <= (sample_point and rx_ack_de);
go_rx_inter  <= (sample_point and rx_eof) and conv(cnt=6);
go_rx_idle   <= (sample_point and rx_inter) and conv(cnt=2);


--PROCESS(clk,rst)
--BEGIN
--  IF(rst='1') THEN 
--   sample_point_q<='0';
-- ELSIF(rising_edge(clk)) THEN
--   sample_point_q <=sample_point;
-- END IF;
--END PROCESS;
--
PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   cnt <=0;
  ELSIF(rising_edge(clk)) THEN
    IF((sample_point and not(destuff))='1') THEN
      IF((go_rx_id1 or go_rx_id2 or go_rx_dlc or go_rx_data or go_rx_crc or go_rx_eof or go_rx_inter or go_rx_idle)='1') THEN
       cnt <=0;		
      ELSE
       cnt <=cnt+1;
      END IF;
    END IF;		 
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_presof <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_presof='1') THEN
 	  rx_presof <='1';
	 ELSIF(go_rx_sof='1') THEN
	  rx_presof <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_sof <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_sof='1') THEN
 	  rx_sof <= '1';
	 ELSIF(go_rx_id1='1') THEN
	  rx_sof <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_id1 <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_id1='1') THEN
 	  rx_id1 <='1';
	 ELSIF(go_rx_rtr1='1') THEN
	  rx_id1 <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_rtr1 <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_rtr1='1') THEN
 	  rx_rtr1 <='1';
	 ELSIF(go_rx_ide='1') THEN
	  rx_rtr1 <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_ide <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_ide='1') THEN
 	  rx_ide <='1';
	 ELSIF((go_rx_rb0 or go_rx_id2)='1') THEN
	  rx_ide <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_id2 <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_id2='1') THEN
 	  rx_id2 <='1';
	 ELSIF(go_rx_rtr2='1') THEN
	  rx_id2 <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_rtr2 <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_rtr2='1') THEN
 	  rx_rtr2 <='1';
	 ELSIF(go_rx_rb1='1') THEN
	  rx_rtr2 <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_rb1 <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_rb1='1') THEN
 	  rx_rb1 <='1';
	 ELSIF(go_rx_rb0='1') THEN
	  rx_rb1 <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_rb0 <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_rb0='1') THEN
 	  rx_rb0 <='1';
	 ELSIF(go_rx_dlc='1') THEN
	  rx_rb0 <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_dlc <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_dlc='1') THEN
 	  rx_dlc <='1';
	 ELSIF((go_rx_data or go_rx_crc)='1') THEN
	  rx_dlc <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_data <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_data='1') THEN
 	  rx_data <='1';
	 ELSIF(go_rx_crc='1') THEN
	  rx_data <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_crc <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_crc='1') THEN
 	  rx_crc <='1';
	 ELSIF(go_rx_crc_de='1') THEN
	  rx_crc <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_crc_de <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_crc_de='1') THEN
 	  rx_crc_de <='1';
	 ELSIF(go_rx_ack='1') THEN
	  rx_crc_de <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_ack <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_ack='1') THEN
 	  rx_ack <='1';
	 ELSIF(go_rx_ack_de='1') THEN
	  rx_ack <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_ack_de <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_ack_de='1') THEN
 	  rx_ack_de <='1';
	 ELSIF(go_rx_eof='1') THEN
	  rx_ack_de <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_eof <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_eof='1') THEN
 	  rx_eof <='1';
	 ELSIF(go_rx_inter='1') THEN
	  rx_eof <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_inter <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_inter='1') THEN
 	  rx_inter <='1';
	 ELSIF(go_rx_idle='1') THEN
	  rx_inter <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_idle <='1';
	reset_mode <='1';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_idle='1') THEN
 	  rx_idle <='1';
	  reset_mode <='1';
	 ELSIF(go_rx_presof='1') THEN
	  rx_idle <='0';
	 ELSE
	  reset_mode <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst) 
BEGIN
  IF((rst or rx_idle)='1') THEN
   id1 <= (others=>'0');
  ELSIF(rising_edge(clk)) THEN
    IF((rx_id1 and sample_point and not(destuff))='1') THEN
     id1 <=	id1(9 DOWNTO 0) & sampled_bit_q;
    END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst) 
BEGIN
  IF((rst or rx_idle)='1') THEN
   rtr1 <= '0';
  ELSIF(rising_edge(clk)) THEN
    IF((rx_rtr1 and sample_point and not(destuff))='1') THEN
     rtr1 <= sampled_bit_q;
    END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst) 
BEGIN
  IF((rst or rx_idle)='1') THEN
   ide <= '0';
  ELSIF(rising_edge(clk)) THEN
    IF((rx_ide and sample_point and not(destuff))='1') THEN
     ide <=	sampled_bit_q;
    END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst) 
BEGIN
  IF((rst or rx_idle)='1') THEN
   id2 <= (others=>'0');
  ELSIF(rising_edge(clk)) THEN
    IF((rx_id2 and sample_point and not(destuff))='1') THEN
     id2 <=	id2(16 DOWNTO 0) & sampled_bit_q;
    END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst) 
BEGIN
  IF((rst or rx_idle) ='1') THEN
   rtr2 <= '0';
  ELSIF(rising_edge(clk)) THEN
    IF((rx_rtr2 and sample_point and not(destuff))='1') THEN
     rtr2 <= sampled_bit_q;
    END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst) 
BEGIN
  IF((rst or rx_idle)='1') THEN
   rb1 <= '0';
  ELSIF(rising_edge(clk)) THEN
    IF((rx_rb1 and sample_point and not(destuff))='1') THEN
     rb1 <=	sampled_bit_q;
    END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst) 
BEGIN
  IF((rst or rx_idle)='1') THEN
   rb0 <= '0';
  ELSIF(rising_edge(clk)) THEN
    IF((rx_rb0 and sample_point and not(destuff))='1') THEN
     rb0 <=	sampled_bit_q;
    END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst) 
BEGIN
  IF((rst or rx_idle)='1') THEN
   dlc <= (others=>'0');
  ELSIF(rising_edge(clk)) THEN
    IF((rx_dlc and sample_point and not(destuff))='1') THEN
     dlc <=	dlc(2 DOWNTO 0) & sampled_bit_q;
    END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst) 
BEGIN
  IF((rst or rx_idle)='1') THEN
   data_temp <= (others=>'0');
  ELSIF(rising_edge(clk)) THEN
    IF((rx_data and sample_point and not(destuff))='1') THEN
     data_temp <= data_temp(6 DOWNTO 0) & sampled_bit_q;
    END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst) 
BEGIN
  IF((rst or rx_idle)='1') THEN
   crc <= (others=>'0');
  ELSIF(rising_edge(clk)) THEN
    IF((rx_crc and sample_point and not(destuff))='1') THEN
     crc <= crc(13 DOWNTO 0) & sampled_bit_q;
    END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst) 
BEGIN
  IF((rst or rx_idle)='1') THEN
   crc_de <= '0';
  ELSIF(rising_edge(clk)) THEN
    IF((rx_crc_de and sample_point)='1') THEN
     crc_de <= sampled_bit_q;
    END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst) 
BEGIN
  IF((rst or rx_idle)='1') THEN
   ack <= '0';
  ELSIF(rising_edge(clk)) THEN
    IF((rx_ack and sample_point )='1') THEN
     ack <= sampled_bit_q;
    END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst) 
BEGIN
  IF((rst or rx_idle)='1') THEN
   ack_de <= '0';
  ELSIF(rising_edge(clk)) THEN
    IF((rx_ack_de and sample_point)='1') THEN
     ack_de <= sampled_bit_q;
    END IF;
  END IF;
END PROCESS;


PROCESS(clk,rst)
BEGIN
  IF((rst or rx_idle)='1') THEN
   destuff_cnt <=0;
  ELSIF(rising_edge(clk)) THEN
    IF(sample_point='1') THEN
      IF((sampled_bit xnor sampled_bit_q)='1') THEN
	     IF(destuff_cnt=4) THEN
	      destuff_cnt<=0;
	     ELSE
	      destuff_cnt<=destuff_cnt+1;
	     END IF;
	   ELSE
		 destuff_cnt <=0;
		END IF;
    END IF;
  END IF;
END PROCESS;


PROCESS(clk,rst) 
BEGIN
  IF(rst='1') THEN
   destuff <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(sample_point='1') THEN
	   IF((rx_ack or rx_crc_de or rx_ack_de or rx_idle or rx_inter or rx_eof)='1') THEN
	    destuff <='0';
		ELSIF(destuff_cnt=4) THEN
		 destuff <='1';
		ELSE
		 destuff <='0';
		END IF;
	 END IF;
  END IF;
END PROCESS;



END behavioral; 