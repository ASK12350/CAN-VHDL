
LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY my_can_bsp IS
    PORT(
	     clk          : IN std_logic;
		  rst          : IN std_logic;
		  hard_sync    : IN std_logic;
		  sample_point : IN std_logic;
		  sampled_bit  : IN std_logic;
		  sampled_bit_q: IN std_logic;
		  id_ok        : IN std_logic;
		  txfifo_empty : IN std_logic;
		  rxfifo_full  : IN std_logic;
		  data_in      : IN std_logic_vector(7 DOWNTO 0);
		    tx         : OUT std_logic;
			 transmitter: OUT std_logic;
			 transmitting: OUT std_logic;
		    ide_out    : OUT std_logic;
			 acf_en     : OUT std_logic;
			 go_error   : OUT std_logic;
			 msg_end    : OUT std_logic;
			 id         : OUT std_logic_vector(28 DOWNTO 0) ;
		    reset_mode : OUT std_logic;
			 fifo_wr_en : OUT std_logic;
			 fifo_rd_en : OUT std_logic;
		       data_out    : OUT std_logic_vector(7 DOWNTO 0));
END my_can_bsp;

ARCHITECTURE behavioral OF my_can_bsp IS

COMPONENT my_can_crc 
       port(
		    clk     : IN std_logic;
			 clr     : IN std_logic;
			 enable  : IN std_logic;
			 data    : IN std_logic;
			 crc_out : OUT std_logic_vector(14 DOWNTO 0));
			 
end COMPONENT; 

--go_rx_state
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
--SIGNAL go_rx_presof : std_logic;
SIGNAL go_rx_sof    : std_logic;

--go_errror
SIGNAL go_stuff_error : std_logic;
SIGNAL go_crc_error   : std_logic;
SIGNAL go_form_error  : std_logic;

--rx_state
SIGNAl rx_idle      : std_logic;
SIGNAL rx_inter     : std_logic;
--SIGNAL rx_presof    : std_logic;
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

--state values
SIGNAL id1          : std_logic_vector(10 DOWNTO 0);
SIGNAL id2          : std_logic_vector(17 DOWNTO 0);
SIGNAL rtr1         : std_logic;                      --srr in case of extended frame
SIGNAL ide          : std_logic;
SIGNAL rtr2         : std_logic;                      --rtr in case of extended frame
SIGNAL rb0          : std_logic;                      
SIGNAL rb1          : std_logic;
SIGNAL dlc          : std_logic_vector(3 DOWNTO 0):=(others=>'0');
SIGNAL data_temp    : std_logic_vector(7 DOWNTO 0);
SIGNAL crc          : std_logic_vector(14 DOWNTO 0);
SIGNAL crc_de       : std_logic;
SIGNAL ack          : std_logic;
SIGNAL ack_de       : std_logic;

--writing into temporary storage
TYPE msg_array IS ARRAY(0 TO 12) OF std_logic_vector(7 DOWNTO 0);
SIGNAL msg_rx_buffer   : msg_array;
SIGNAL msg_tx_buffer   : msg_array;
SIGNAL wr           : std_logic;
SIGNAL i            : integer range  0 to 12;
--destuff
SIGNAL destuff      : std_logic;
SIGNAL destuff_en   : std_logic;
SIGNAL destuff_cnt  : integer range 0 to 5;

SIGNAL dlc_int      : integer range 0 to 63;
SIGNAL cnt          : integer range 0 to 63;

--crc
SIGNAL crc_enable    : std_logic;
SIGNAL crc_en        : std_logic;
SIGNAL crc_clr       : std_logic;
SIGNAL crc_temp      : std_logic_vector(14 DOWNTO 0);

--fifo
SIGNAL wr_fifo      : std_logic;
SIGNAL cs_fifo      : std_logic;
SIGNAL fifo_wr_en_temp : std_logic;
SIGNAL fifo_rd_en_temp : std_logic;
SIGNAL wr_cnt       : integer range 0 TO 12 ;
SIGNAL msg_len      : integer range 0 TO 12 ;

SIGNAL transmitter_temp : std_logic;
SIGNAL transmitting_temp: std_logic;
SIGNAL msg_tx_buffer_empty : std_logic;
SIGNAL remote_frame    : std_logic;

FUNCTION conv(b: boolean) return std_logic IS
BEGIN
  IF b THEN
   return('1');
  ELSE                                               --boolean to std_logic
   return ('0'); 
  END IF;
END ;

BEGIN

uucrc : my_can_crc PORT MAP    (    clk=>clk,
                                    clr=>crc_clr,
								            enable=>crc_enable,
							               data=>sampled_bit,
							            	crc_out=>crc_temp   );


fifo_wr_en_temp <=wr_fifo and cs_fifo and not(rxfifo_full);
fifo_rd_en_temp <=not(wr_fifo) and cs_fifo and not(txfifo_empty);
ide_out <=ide;
msg_len <=12 WHEN (not(remote_frame) and conv(dlc(3)='1')) ='1' ELSE
          to_integer(unsigned(dlc))+4 WHEN remote_frame='0' ELSE
          4;

--crc signals
crc_enable <= crc_en and sample_point and not(destuff);
crc_clr    <= rst or rx_idle;
 
--go_rx_signals 
go_rx_sof   <= hard_sync and (rx_idle or rx_inter);
--go_rx_sof      <= (sample_point and rx_presof);
go_rx_id1      <= (sample_point and rx_sof);
go_rx_rtr1     <= (sample_point and not(destuff)) and conv(cnt=10) and rx_id1;
go_rx_ide      <= (sample_point and not(destuff)) and rx_rtr1;
go_rx_id2      <= (sample_point and not(destuff)) and sampled_bit and rx_ide;
go_rx_rtr2     <= (sample_point and not(destuff)) and conv(cnt=17) and rx_id2;
go_rx_rb0      <= (sample_point and not(destuff)) and ((not(sampled_bit) and rx_ide) or (ide and rx_rb1));
go_rx_rb1      <= (sample_point and not(destuff)) and rx_rtr2 and ide; 
go_rx_dlc      <= (sample_point and not(destuff)) and rx_rb0;
go_rx_data     <= (sample_point and not(destuff)) and conv(cnt=3) and rx_dlc and not(remote_frame);
go_rx_crc      <= (sample_point and not(destuff)) and ((rx_data and conv(cnt=dlc_int)) or (rx_dlc and conv(cnt=3) and remote_frame)) ;
go_rx_crc_de   <= (sample_point and not(destuff)) and conv(cnt=14) and rx_crc;
go_rx_ack      <= (sample_point and not(destuff)) and rx_crc_de;
go_rx_ack_de   <= (sample_point and rx_ack);
go_rx_eof      <= (sample_point and rx_ack_de);
go_rx_inter    <= (sample_point and rx_eof) and conv(cnt=6);
go_rx_idle     <= (sample_point and rx_inter) and conv(cnt=2); 

--go_error signals
go_crc_error   <= go_rx_eof and not(conv(crc=crc_temp));
go_stuff_error <= sample_point and conv(destuff_cnt=4) and (sampled_bit xnor sampled_bit_q) and destuff_en ;
go_form_error <=  sample_point and not(destuff) and (rx_ack_de or rx_eof) and not(sampled_bit);
go_error <=go_form_error or go_stuff_error or go_crc_error;

remote_frame    <= ((not(ide) and rtr1) or (ide and rtr2));

destuff_en      <= not(rx_idle or rx_inter or rx_eof or rx_ack or rx_crc_de or rx_ack_de or rx_sof);

dlc_int         <= 63 WHEN dlc(3)='1' ELSE
                   to_integer(8*unsigned(dlc))-1;
						 
						 
--fifo_en
PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   fifo_wr_en <='0';
	fifo_rd_en <='0';
  ELSIF(rising_edge(clk)) THEN
   fifo_wr_en <=fifo_wr_en_temp;
   fifo_rd_en <=fifo_rd_en_temp;	
  END IF;
END PROCESS;  

--data into a temporary storage
PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   msg_rx_buffer<=(others=>(others=>'0'));
  ELSIF(rising_edge(clk)) THEN
   msg_rx_buffer(0)    <= id1(10 DOWNTO 3);
   msg_rx_buffer(1)    <= id1(2 DOWNTO 0) & ide & dlc;
   msg_rx_buffer(2)    <= remote_frame & "00000" & id2(17 DOWNTO 16);
   msg_rx_buffer(3)    <= id2(15 DOWNTO 8);
   msg_rx_buffer(4)    <= id2(7 DOWNTO 0);
    IF(wr='1') THEN
	  msg_rx_buffer(i)<=data_temp;
	 ELSIF(rx_idle='1') THEN
	  msg_rx_buffer<=(others=>(others=>'0'));
	 END IF;
  END IF;
END PROCESS;

--data counter
PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   i<=5;
  ELSIF(rising_edge(clk)) THEN
    IF(wr='1') THEN
 	  i<=i+1;
	 ELSIF(rx_idle='1') THEN
	  i<=5;
	 END IF;
  END IF;
END PROCESS;

--wr signal to store data in temp storage
PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   wr<='0';
  ELSIF(rising_edge(clk)) THEN
    IF((sample_point and rx_data  and not(destuff)) ='1') THEN 
	   IF(to_unsigned(cnt,6)(2 DOWNTO 0)="111") THEN
	    wr<='1';
	   END IF;
	 ELSE
	  wr<='0';	
	 END IF;
  END IF;
END PROCESS;
	   
--counting 
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


--rx state changing

--PROCESS(clk,rst)
--BEGIN
  --IF(rst='1') THEN
  -- rx_presof <='0';
  --ELSIF(rising_edge(clk)) THEN
  --  IF(go_rx_presof='1') THEN
  --  rx_presof <='1';
  -- ELSIF(go_rx_sof='1') THEN
  --  rx_presof <='0';
  -- END IF;
  --END IF;
--END PROCESS;

--sof
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

--standard ID
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

--rtr when IDE=0 else srr
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

--ide
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

--extended ID
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

--rtr when ide=1
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

--rb1
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

--rb0
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

--dlc
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

--data
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

--crc
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

--crc_de
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

--ack
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

--ack_de
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

--eof
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

--interframe
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

--idle
PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_idle<='1';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_idle='1') THEN
	  rx_idle <='1';
	 ELSIF(go_rx_sof='1') THEN
	  rx_idle<='0';
	 END IF;
  END IF;
END PROCESS;

--reset_mode

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
	reset_mode <='1';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_idle='1') THEN
	  reset_mode <='1';
	 ELSE
	  reset_mode <='0';
	 END IF;
  END IF;
END PROCESS;

--values to be stored or compared

--standard ID
PROCESS(clk,rst) 
BEGIN
  IF(rst='1') THEN
   id1 <= (others=>'1');
  ELSIF(rising_edge(clk)) THEN
    IF((rx_id1 and sample_point and not(destuff))='1') THEN
     id1 <=	id1(9 DOWNTO 0) & sampled_bit;
    ELSIF(rx_idle='1') THEN
	  id1 <= (others=>'1');
	 END IF;
  END IF;
END PROCESS;

--rtr when ide=0 else srr
PROCESS(clk,rst) 
BEGIN
  IF(rst='1') THEN
   rtr1 <= '1';
  ELSIF(rising_edge(clk)) THEN
    IF((rx_rtr1 and sample_point and not(destuff))='1') THEN
     rtr1 <= sampled_bit;
    ELSIF(rx_idle='1') THEN
	  rtr1 <='1';
	 END IF;
  END IF;
END PROCESS;

--ide
PROCESS(clk,rst) 
BEGIN
  IF(rst='1') THEN
   ide <= '1';
  ELSIF(rising_edge(clk)) THEN
    IF((rx_ide and sample_point and not(destuff))='1') THEN
     ide <=	sampled_bit;
    ELSIF(rx_idle='1') THEN
	  ide <='1';
	 END IF;
  END IF;
END PROCESS;

--extended ID
PROCESS(clk,rst) 
BEGIN
  IF(rst='1') THEN
   id2 <= (others=>'0');
  ELSIF(rising_edge(clk)) THEN
    IF((rx_id2 and sample_point and not(destuff))='1') THEN
     id2 <=	id2(16 DOWNTO 0) & sampled_bit;
    ELSIF(rx_idle='1') THEN
	  id2 <= (others=> '0');
	 END IF;
  END IF;
END PROCESS;

--rtr when ide=1
PROCESS(clk,rst) 
BEGIN
  IF(rst ='1') THEN
   rtr2 <= '1';
  ELSIF(rising_edge(clk)) THEN
    IF((rx_rtr2 and sample_point and not(destuff))='1') THEN
     rtr2 <= sampled_bit;
    ELSIF(rx_idle='1') THEN
	  rtr2 <='1';
	 END IF;
  END IF;
END PROCESS;

--rb1
PROCESS(clk,rst) 
BEGIN
  IF(rst ='1') THEN
   rb1 <= '1';
  ELSIF(rising_edge(clk)) THEN
    IF((rx_rb1 and sample_point and not(destuff))='1') THEN
     rb1 <=	sampled_bit;
    ELSIF(rx_idle='1') THEN
	  rb1 <= '1';
	 END IF;
  END IF;
END PROCESS;

--rb0
PROCESS(clk,rst) 
BEGIN
  IF(rst='1') THEN
   rb0 <= '1';
  ELSIF(rising_edge(clk)) THEN
    IF((rx_rb0 and sample_point and not(destuff))='1') THEN
     rb0 <=	sampled_bit;
    ELSIF(rx_idle='1') THEN
	  rb0 <='1';
	 END IF;
  END IF;
END PROCESS;

--dlc
PROCESS(clk,rst) 
BEGIN
  IF(rst ='1') THEN
   dlc <= (others=>'1');
  ELSIF(rising_edge(clk)) THEN
    IF((rx_dlc and sample_point and not(destuff))='1') THEN
     dlc <=	dlc(2 DOWNTO 0) & sampled_bit;
    ELSIF(rx_idle='1') THEN
	  dlc <=(others=>'1');
	 END IF;
  END IF;
END PROCESS;

--data
PROCESS(clk,rst) 
BEGIN
  IF(rst='1') THEN
   data_temp <= (others=>'1');
  ELSIF(rising_edge(clk)) THEN
    IF((rx_data and sample_point and not(destuff))='1') THEN
     data_temp <= data_temp(6 DOWNTO 0) & sampled_bit;
    ELSIF(rx_idle='1') THEN 
	  data_temp <= (others=>'1');
	 END IF;
  END IF;
END PROCESS;

--crc
PROCESS(clk,rst) 
BEGIN
  IF(rst ='1') THEN
   crc <= (others=>'0');
  ELSIF(rising_edge(clk)) THEN
    IF((rx_crc and sample_point and not(destuff))='1') THEN
     crc <= crc(13 DOWNTO 0) & sampled_bit;
    ELSIF(rx_idle='1') THEN
	  crc <=(others=>'0');
	 END IF;
  END IF;
END PROCESS;

--crc_de
PROCESS(clk,rst) 
BEGIN
  IF(rst='1') THEN
   crc_de <= '1';
  ELSIF(rising_edge(clk)) THEN
    IF((rx_crc_de and sample_point and not(destuff))='1') THEN
     crc_de <= sampled_bit;
    ELSIF(rx_idle='1') THEN
	  crc_de <='1';
	 END IF;
  END IF;
END PROCESS;

--ack
PROCESS(clk,rst) 
BEGIN
  IF(rst='1') THEN
   ack <= '1';
  ELSIF(rising_edge(clk)) THEN
    IF((rx_ack and sample_point )='1') THEN
     ack <= sampled_bit;
    ELSIF(rx_idle='1') THEN
	  ack <='1';
	 END IF;
  END IF;
END PROCESS;

--ack_de
PROCESS(clk,rst) 
BEGIN
  IF(rst='1') THEN
   ack_de <= '1';
  ELSIF(rising_edge(clk)) THEN
    IF((rx_ack_de and sample_point)='1') THEN
     ack_de <= sampled_bit;
    ELSIF(rx_idle='1') THEN 
	  ack_de <='1';
	 END IF;
  END IF;
END PROCESS;

--destuff_count
PROCESS(clk,rst,rx_idle)
BEGIN
  IF((rst or rx_idle)='1') THEN
   destuff_cnt <=0;
  ELSIF(rising_edge(clk)) THEN
    IF((sample_point and destuff_en)='1') THEN
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

destuff <= sample_point and destuff_en and conv(destuff_cnt=4);
--destuff when 5 consecutive identical bits
--PROCESS(clk,rst) 
--BEGIN
--  IF(rst='1') THEN
--   destuff <='0';
--  ELSIF(rising_edge(clk)) THEN
--    IF(sample_point='1') THEN
--	   IF(destuff_en='0') THEN
--	    destuff <='0';
--		ELSIF(destuff_cnt=4) THEN
--		 destuff <='1';
--		ELSE
--		 destuff <='0';
--		END IF;
--	 END IF;
-- END IF;
--END PROCESS;

--crc_enable
PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   crc_en <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_sof='1') THEN
	  crc_en <='1';
	 ELSIF(go_rx_crc='1') THEN
	  crc_en <='0';
	 END IF;
  END IF;
END PROCESS;

--acceptance filter enable
PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   acf_en<='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_eof='1') THEN
	  acf_en<='1';
	 ELSIF(go_rx_inter='1') THEN
	  acf_en<='0';
	 END IF;
  END IF;
END PROCESS;

--ID for acceptance filter
PROCESS(clk,rst) 
BEGIN
  IF(rst='1') THEN
   id <=(others=>'0');
  ELSIF(rising_edge(clk)) THEN
    IF(go_rx_eof='1') THEN
	  id <=id2 & id1;
	 ELSIF(rx_idle='1') THEN
	  id <=(others=>'0');
	 END IF;
  END IF;
END PROCESS;

--cs for fifo
PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   cs_fifo <='0';
  ELSIF(rising_edge(clk)) THEN
    IF((go_rx_inter and id_ok)='1') THEN
	  cs_fifo <='1';
	 ELSIF(wr_cnt=msg_len) THEN
	  cs_fifo <='0';
	 END IF;
  END IF;
END PROCESS;

--write signal for fifo
PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   wr_fifo <='0';
  ELSIF(rising_edge(clk)) THEN
    IF((go_rx_inter and id_ok)='1') THEN
	  wr_fifo <='1';
	 ELSIF(wr_cnt=msg_len) THEN
	  wr_fifo <='0';
	 END IF;
  END IF;
END PROCESS;

--data counting for fifo
PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   wr_cnt <=0;
  ELSIF(rising_edge(clk)) THEN
    IF((cs_fifo and wr_fifo )='1') THEN
	   IF(wr_cnt=msg_len) THEN
		 wr_cnt <=0;
		ELSE
		 wr_cnt <=wr_cnt+1;
		END IF;
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   msg_end <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(wr_cnt=msg_len) THEN
	  msg_end <='1';
	 ELSE
	  msg_end <='0';
	 END IF;
  END IF;
END PROCESS;

--data sent into fifo 
PROCESS(clk,rst)
BEGIN 
  IF(rst='1') THEN
   data_out <= (others=>'0') ;
  ELSIF(rising_edge(clk)) THEN 
    IF((cs_fifo and wr_fifo)='1') THEN
	  data_out <=msg_rx_buffer(wr_cnt);
	 ELSE
	  data_out <=(others=>'0');
	 END IF;
  END IF;
END PROCESS; 


END behavioral; 
