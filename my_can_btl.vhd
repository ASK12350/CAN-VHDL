
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY my_can_btl IS
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
		         sample_point      : OUT std_logic;
					sampled_bit       : OUT std_logic;
					hard_sync         : OUT std_logic); 
					
END my_can_btl;

ARCHITECTURE behavioral OF my_can_btl IS


FUNCTION conv(b:boolean) return std_logic IS
BEGIN
  IF  b THEN 
   RETURN ('1');
  ELSE
   RETURN ('0');
  END IF;
END ;

SIGNAL rx_q     : std_logic;
SIGNAL rx_edge  : std_logic;
SIGNAL clk_en   : std_logic;
SIGNAL rx_idle  : std_logic;
SIGNAL s_reg    : std_logic_vector(2 DOWNTO 0);
SIGNAL hard_sync_temp : std_logic;
SIGNAL rx_q_q : std_logic;
SIGNAL cnt : integer range 0 to 127;
SIGNAL cnt2 : integer range 0 to 20;
SIGNAL delaye: integer range 0 to 5; 
SIGNAL delayl: integer range 0 to 5;
SIGNAL sampled_bit_temp : std_logic;
SIGNAL go_sync  : std_logic;
SIGNAL go_tseg1 : std_logic;
SIGNAL go_tseg2 : std_logic;
SIGNAL rx_sync : std_logic;
SIGNAL rx_tseg1 : std_logic;
SIGNAL rx_tseg2 : std_logic;
BEGIN 

go_sync <=clk_en and rx_tseg2 and conv(cnt2=to_integer(unsigned(tseg2))) and conv(delaye=0);
go_tseg1 <=hard_sync_temp or (clk_en and rx_sync) or(clk_en and rx_tseg2 and conv(delaye/=0) and conv(cnt2>=to_integer(unsigned(tseg2))-delaye));
go_tseg2 <=clk_en and rx_tseg1 and conv(cnt2=to_integer(unsigned(tseg1))+delayl); 

sampled_bit <=sampled_bit_temp;
hard_sync <= hard_sync_temp;
rx_edge <= NOT(rx_q) AND rx_q_q ;
tx_out <=tx_in or (not(transmitter));
 
PROCESS(clk)
BEGIN
IF(rising_edge(clk)) THEN
 rx_q <= rx ;
END IF;
END PROCESS;

PROCESS(clk)
BEGIN
IF(rising_edge(clk))THEN
 rx_q_q <= rx_q;
END IF;
END PROCESS;

--Hard_synchronization

 Hard_syn:PROCESS(clk,rst)
BEGIN
 IF(rst='1') THEN
  hard_sync_temp <= '0';
  rx_idle <= '1';
 ELSIF(rising_edge(clk)) THEN          
   IF(reset_mode='1') THEN
    hard_sync_temp <='0';
    rx_idle <= '1';
   ELSIF((rx_edge and rx_idle) ='1') THEN
    hard_sync_temp <='1';
    rx_idle <= '0';
   ELSE
    hard_sync_temp <='0';
   END IF;
 END IF;
END PROCESS Hard_syn;

--Brp clock generation

proc_brp:PROCESS(clk,rst)
 BEGIN
  IF(rst='1') THEN
   cnt        <=  0  ;
  ELSIF(rising_edge(clk)) THEN 
    IF(cnt >= (to_integer(unsigned(brp & '0')))+1) THEN
     cnt   <= 0;
    ELSIF(hard_sync_temp='1') THEN
	  cnt <= 0;
	 ELSE
     cnt   <= cnt+1;
    END IF;
  END IF;
 END PROCESS proc_brp;
 
 PROCESS(clk,rst)
 BEGIN
   IF(rst='1') THEN
	 cnt2 <=0;
	ELSIF(rising_edge(clk)) THEN
	  IF((go_sync or go_tseg1 or go_tseg2)='1') THEN
	   cnt2<=0;
	  ELSIF(clk_en='1') THEN
	   cnt2<=cnt2+1;
	  END IF;
	END IF;
END PROCESS;
 
 proc_brp2:PROCESS(clk)
 BEGIN
  IF(rising_edge(clk)) THEN
    IF(cnt >= (to_integer(unsigned(brp & '0')))+1) THEN
     clk_en  <= '1' ;
    ELSE
     clk_en  <= '0' ;
    END IF;
  END IF;
 END PROCESS proc_brp2;
 

 --Changing States 
PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_sync <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_sync='1') THEN
	  rx_sync <='1';
    ELSIF(go_tseg1='1') THEN
	  rx_sync <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_tseg1 <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_tseg1='1') THEN
	  rx_tseg1 <='1';
	 ELSIF(go_tseg2='1') THEN
	  rx_tseg1 <='0';
	 END IF;
  END IF;
END PROCESS;
  
PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   rx_tseg2 <='0';
  ELSIF(rising_edge(clk)) THEN
    IF(go_tseg2='1') THEN
     rx_tseg2 <='1'; 
    ELSIF((go_tseg1 or go_sync)='1') THEN  
	  rx_tseg2 <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst,rx_idle) 
BEGIN
  IF((rst or rx_idle)='1') THEN
   delayl <=0;
  ELSIF(rising_edge(clk)) THEN
    IF((rx_tseg1 and rx_edge)='1') THEN
	   IF(to_integer(unsigned(sjw))>=cnt2) THEN
	    delayl <=cnt2+1;
	   ELSE
	    delayl <= to_integer(unsigned(sjw))+1;
	   END IF;
	 ELSIF(go_tseg2='1') THEN
	  delayl <=0;
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst,rx_idle)
BEGIN
  IF((rst or rx_idle)='1') THEN
   delaye <=0;
  ELSIF(rising_edge(clk)) THEN
    IF((rx_tseg2 and rx_edge)='1') THEN
	   IF(to_integer(unsigned(sjw))+cnt2>=to_integer(unsigned(tseg2))) THEN
	    delaye <=to_integer(unsigned(tseg2))+1-cnt2;
	   ELSE
		 delaye <=to_integer(unsigned(sjw))+1;
		END IF;
	 ELSIF((go_sync or go_tseg1)='1') THEN
	  delaye <=0;
	 END IF;
  END IF;
END PROCESS;
	 
--Sampling

sample_t:PROCESS(clk,rst)
VARIABLE i:integer range 0 to 3 :=0;
BEGIN
 IF(rst='1') THEN 
  i:=0;
 ELSIF(rising_edge(clk)) THEN
  IF(clk_en='1') THEN
    IF(cnt2>=(to_integer(unsigned(tseg1))+delayl-2) and rx_tseg1='1') THEN
	  s_reg(i)<=rx_q;
	   IF(i=2) THEN
		 i:=0;
		ELSE
		 i:=i+1;
		END IF;
	 END IF;
  END IF;
 END IF;
END PROCESS;

sampling:PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   sampled_bit_temp<='1';
  ELSIF(rising_edge(clk)) THEN
    IF((clk_en and go_tseg2)='1') THEN
	   IF(sam='1') THEN
		 sampled_bit_temp <= ((s_reg(0) and s_reg(1)) or (s_reg(1) and s_reg(2)) or (s_reg(2) and s_reg(0)));
	   ELSE
	    sampled_bit_temp <=rx_q;
	   END IF;
    END IF;
  END IF;  
END PROCESS sampling;

--sample_point
PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   sample_point<='0';
  ELSIF(rising_edge(clk)) THEN
    IF((clk_en and go_tseg2)='1') THEN
	  sample_point <='1';
	 ELSE
	  sample_point <='0';
	 END IF;
  END IF;
END PROCESS;

PROCESS(clk,rst)
BEGIN
  IF(rst='1') THEN
   sampled_bit_q <='1';
  ELSIF(rising_edge(clk)) THEN
    IF((clk_en and go_tseg2)='1') THEN
       sampled_bit_q <=sampled_bit_temp;
	 END IF;
  END IF;
END PROCESS;

END behavioral;
 
