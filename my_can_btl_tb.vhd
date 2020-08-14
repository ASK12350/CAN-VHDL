

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY my_can_btl_tb IS
END my_can_btl_tb;
 
ARCHITECTURE behavior OF my_can_btl_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT  my_can_btl
    PORT(
         rx           : IN  std_logic;
			tx_in        : IN  std_logic;
			transmitter  : IN  std_logic;
         clk          : IN  std_logic;
         rst          : IN  std_logic;
         reset_mode   : IN  std_logic;
         sam          : IN  std_logic;
         sjw          : IN  std_logic_vector(1 downto 0);
         brp          : IN  std_logic_vector(5 downto 0);
         prop_seg     : IN  std_logic_vector(2 downto 0);
         pseg1        : IN  std_logic_vector(2 downto 0);
         pseg2        : IN  std_logic_vector(2 downto 0);
			    tx_out       : OUT  std_logic;
             clock_en     : OUT  std_logic;
             sample_point : OUT  std_logic;
             sampled_bit  : OUT  std_logic;
             hard_sync    : OUT  std_logic
        );
    END COMPONENT;
    

   SIGNAL bus_level : std_logic;

             --MODULE 1--
   --Inputs
	signal tx_in_1     : std_logic := '1';
	signal t_1         : std_logic :='0';
   signal clk_1       : std_logic := '0';
   signal rst         : std_logic := '1';
   signal reset_mode  : std_logic := '0';
   signal sam_1       : std_logic := '0';
   signal sjw_1       : std_logic_vector(1 downto 0) := "11";
   signal brp_1       : std_logic_vector(5 downto 0) := "000100";   -- 1Tq=2*5*clk_period=2*5*10=100 ns;
   signal prop_seg_1  : std_logic_vector(2 downto 0) := "101";
   signal pseg1_1     : std_logic_vector(2 downto 0) := "011";   --nominal bit time=sync+prop+pseg1+pseg2=1+6+4+4=15Tqs=1500ns
   signal pseg2_1     : std_logic_vector(2 downto 0) := "011";
	signal count_1     : integer range 0 to 50:=0;
	signal cnt         : integer range 0 to 4000:=0;

 	--Outputs
	signal tx_out_1       : std_logic;
   signal clock_en_1     : std_logic;
   signal sample_point_1 : std_logic;
   signal sampled_bit_1  : std_logic;
   signal hard_sync_1    : std_logic;
	
	
            --MODULE 2--	
	
	--Inputs
	signal tx_in_2    : std_logic := '1';
   signal t_2        : std_logic:='0';
	signal clk_2      : std_logic:= '0';
   signal sam_2      : std_logic := '1';
   signal sjw_2      : std_logic_vector(1 downto 0) := "11";
   signal brp_2      : std_logic_vector(5 downto 0) := "000100";   -- 1Tq=2*clk_period=2*5*10.2=102 ns;
   signal prop_seg_2 : std_logic_vector(2 downto 0) := "101";
   signal pseg1_2    : std_logic_vector(2 downto 0) := "011";   --nominal bit time=sync+prop+pseg1+pseg2=1+6+4+4=15Tqs=1530ns
   signal pseg2_2    : std_logic_vector(2 downto 0) := "011";
   signal count_2    : integer range 0 to 50:=0;
	
 	--Outputs
	signal tx_out_2        : std_logic;
   signal clock_en_2      : std_logic;
   signal sample_point_2  : std_logic;
   signal sampled_bit_2   : std_logic;
   signal hard_sync_2     : std_logic;
	
	
	
	          --MODULE 3--
	
		--Inputs
	signal tx_in_3    : std_logic := '1';
   signal t_3        : std_logic:='0';
   signal sam_3      : std_logic := '0';
	signal clk_3      : std_logic := '0';
   signal sjw_3      : std_logic_vector(1 downto 0) := "11";
   signal brp_3      : std_logic_vector(5 downto 0) := "000100";   -- 1Tq=2*5*clk_period=10*9.8=98 ns;
   signal prop_seg_3 : std_logic_vector(2 downto 0) := "101";
   signal pseg1_3    : std_logic_vector(2 downto 0) := "011";   --nominal bit time=sync+prop+pseg1+pseg2=1+6+4+4=15Tqs=1470ns
   signal pseg2_3    : std_logic_vector(2 downto 0) := "011";
   signal count_3    : integer range 0 to 50:=0;
	
 	--Outputs
	signal tx_out_3       : std_logic;
   signal clock_en_3     : std_logic;
   signal sample_point_3 : std_logic;
   signal sampled_bit_3  : std_logic;
   signal hard_sync_3    : std_logic;

   -- Clock period definitions
   constant clk_period_1 : time := 10 ns;   --frequency =  100MHz
	constant clk_period_2 : time := 10.1 ns; --frequency =   99MHz  --delta(f)<=sjw/(20*nbt)=4/(20*15)=4/300=0.013=1.3%
	constant clk_period_3 : time :=  9.9 ns; --frequency =  101MHz
 
BEGIN
 bus_level <= tx_out_1 WHEN (t_1 ='1') ELSE
              tx_out_2 WHEN (t_2 ='1') ELSE
				  tx_out_3 WHEN (t_3 ='1') ELSE
				  '1';

 
	-- Instantiate the Unit Under Test (UUT)
   uut: my_can_btl PORT MAP (
          rx => bus_level,
			 tx_in => tx_in_1,
			 transmitter=>t_1,
          clk => clk_1,
          rst => rst,
          reset_mode => reset_mode,
          sam => sam_1,
          sjw => sjw_1,
          brp => brp_1,
          prop_seg => prop_seg_1,
          pseg1 => pseg1_1,
          pseg2 => pseg2_1,
			 tx_out =>tx_out_1,
          clock_en => clock_en_1,
          sample_point => sample_point_1,
          sampled_bit => sampled_bit_1,
          hard_sync => hard_sync_1
        );
		  
	  uus: my_can_btl PORT MAP (
          rx => bus_level,
			 tx_in => tx_in_2,
			 transmitter=>t_2,
          clk => clk_2,
          rst => rst,
          reset_mode => reset_mode,
          sam => sam_2,
          sjw => sjw_2,
          brp => brp_2,
          prop_seg => prop_seg_2,
          pseg1 => pseg1_2,
          pseg2 => pseg2_2,
			 tx_out =>tx_out_2,
          clock_en => clock_en_2,
          sample_point => sample_point_2,
          sampled_bit => sampled_bit_2,
          hard_sync => hard_sync_2
        );
	
      	
	   uuf: my_can_btl PORT MAP (
          rx => bus_level,
			 tx_in => tx_in_3,
			 transmitter=>t_3,
          clk => clk_3,
          rst => rst,
          reset_mode => reset_mode,
          sam => sam_3,
          sjw => sjw_3,
          brp => brp_3,
          prop_seg => prop_seg_3,
          pseg1 => pseg1_3,
          pseg2 => pseg2_3,
			 tx_out =>tx_out_3,
          clock_en => clock_en_3,
          sample_point => sample_point_3,
          sampled_bit => sampled_bit_3,
          hard_sync => hard_sync_3
        );

   -- Clock process definitions
	
	clk_1_process :process
   begin
		clk_1 <= '0';
		wait for clk_period_1/2;
		clk_1 <= '1';
		wait for clk_period_1/2;
   end process;
	
	clk_2_process:process
	begin
	  clk_2 <= '0';
	  wait for clk_period_2/2;
	  clk_2 <= '1';
	  wait for clk_period_2/2;
	end process;
	
	clk_3_process:process
	begin
	 clk_3 <= '0';
	 wait for clk_period_3/2;
	 clk_3 <= '1';
	 wait for clk_period_3/2;
	end process;
  
  
   rst_process :process(clk_2)
	variable t: integer range 0 to 1 :=0;
	begin
	 if(rising_edge(clk_2)) then
	  if(t=0) then
	   rst <= '1'; 
	   t:=t+1;
	  else
	   rst <= '0';
	  end if;
	 end if;
	 end process;
	 
   G_count:process(clock_en_2)
	 begin
	 if(rising_edge(clock_en_2)) then
	  if(cnt>=4000) then
	   cnt <=0;
	  else
   	cnt<=cnt+1;
	  end if;
	 end if;
	 end process;
	 
	  
	 transmit:process(cnt)
	 begin
	  if(cnt>=2 and cnt<=720) then
	   t_1 <='1';
		reset_mode<='0';
	  elsif(cnt>720 and cnt<=880) then
	   t_1 <='0';
		reset_mode<='1';
	  elsif(cnt>880 and cnt<=1600) then
	   reset_mode<='0';
		t_2 <='1';
	  elsif(cnt>1650 and cnt<=1700) then
	   t_2 <='0';
		reset_mode <='1';
	  elsif(cnt>1700 and cnt<=2450) then
	   reset_mode <='0';
		t_3 <='1';
	  else
	   t_3 <='0';
	  end if;
    end process;

	 
	cnt_1_proc:process(clock_en_1)
	variable i :integer range 0 to 15:=0;
	constant temp :integer:=14;
	begin
	if(rising_edge(clock_en_1)) then
	 if(i>=temp) then
	   if(t_1='1') THEN
		 count_1 <=count_1+1;
		else
		 count_1 <=0;
	   end if;
	  i:=0;
	 else
	  i:=i+1;
	 end if;
	end if;
  end process;
  
   cnt_2_proc:process(clock_en_2)
	variable j :integer range 0 to 15:=0;
	constant temp :integer:=14;
	begin
	if(rising_edge(clock_en_2)) then
	 if(j>=temp) then
	   if(t_2='1') then
	    count_2 <=count_2+1;
	   else
	    count_2 <=0;
	   end if;
	  j:=0;
	 else
	  j:=j+1;
	 end if;
	end if;
  end process;
  
   cnt_3_proc:process(clock_en_3)
	variable k :integer range 0 to 15:=0;
	constant temp :integer:=14;
	begin
	if(rising_edge(clock_en_3)) then
	 if(k>=temp) then
	   if(t_3='1') then		
	    count_3 <=count_3+1;
	   else
		 count_3 <=0;
		end if;
	  k:=0;
	 else
	  k:=k+1;
	 end if;
	end if;
  end process;
  
  tx_1_proc:process(clock_en_1)
  begin
   if(rising_edge(clock_en_1)) then
    if(count_1=2) then
	  tx_in_1 <= '0';
	 elsif(count_1=4) then 
	  tx_in_1 <= '1';
	 elsif(count_1=5) then
	  tx_in_1 <= '0';
	 elsif(count_1=8) then
	  tx_in_1 <= '1';
	 elsif(count_1=11) then
	  tx_in_1 <= '0';
	 elsif(count_1=14) then
	  tx_in_1 <= '1';
	 elsif(count_1=15) then
	  tx_in_1 <= '0';
	 elsif(count_1=18) then
	  tx_in_1 <= '1';
	 elsif(count_1=20) then
	  tx_in_1 <= '0';
	 elsif(count_1=23) then
	  tx_in_1 <= '1';
	 elsif(count_1=26) then
	  tx_in_1 <=  '0';
	 elsif(count_1=28) then
	  tx_in_1 <=  '1';
	 elsif(count_1=30) then
	  tx_in_1 <= '0';
	 elsif(count_1=34) then
	  tx_in_1 <= '1';
	 elsif(count_1=38) then
	  tx_in_1 <= '0';
	 elsif(count_1=40) then
	  tx_in_1 <= '1';
	 elsif(count_1=43) then
	  tx_in_1 <= '0';
	 elsif(count_1=45) then
	  tx_in_1 <= '1';
	 end if;
	end if;
  end process;
  
  tx_2_proc:process(clock_en_2)
  begin
   if(rising_edge(clock_en_2)) then
    if(count_2=2) then
	  tx_in_2 <= '0';
	 elsif(count_2=3) then 
	  tx_in_2 <= '1';
	 elsif(count_2=4) then
	  tx_in_2 <= '0';
	 elsif(count_2=6) then
	  tx_in_2 <= '1';
	 elsif(count_2=11) then
	  tx_in_2 <= '0';
	 elsif(count_2=12) then
	  tx_in_2 <= '1';
	 elsif(count_2=14) then
	  tx_in_2 <= '0';
	 elsif(count_2=17) then
	  tx_in_2 <= '1';
	 elsif(count_2=20) then
	  tx_in_2 <= '0';
	 elsif(count_2=21) then
	  tx_in_2 <= '1';
	 elsif(count_2=23) then
	  tx_in_2 <=  '0';
	 elsif(count_2=25) then
	  tx_in_2 <=  '1';
	 elsif(count_2=28) then
	  tx_in_2 <= '0';
	 elsif(count_2=33) then
	  tx_in_2 <= '1';
	 elsif(count_2=37) then
	  tx_in_2 <= '0';
	 elsif(count_2=42) then
	  tx_in_2 <= '1';
	 elsif(count_2=45) then
	  tx_in_2 <= '0';
	 elsif(count_2=47) then
	  tx_in_2 <= '1';
	 end if;
	end if;
  end process;
  
  tx_3_proc:process(clock_en_3)
  begin
   if(rising_edge(clock_en_3)) then
    if(count_3=4) then
	  tx_in_3 <= '0';
	 elsif(count_3=5) then 
	  tx_in_3 <= '1';
	 elsif(count_3=6) then
	  tx_in_3 <= '0';
	 elsif(count_3=8) then
	  tx_in_3 <= '1';
	 elsif(count_3=10) then
	  tx_in_3 <= '0';
	 elsif(count_3=12) then
	  tx_in_3 <= '1';
	 elsif(count_3=13) then
	  tx_in_3 <= '0';
	 elsif(count_3=16) then
	  tx_in_3 <= '1';
	 elsif(count_3=20) then
	  tx_in_3 <= '0';
	 elsif(count_3=21) then
	  tx_in_3 <= '1';
	 elsif(count_3=23) then
	  tx_in_3 <=  '0';
	 elsif(count_3=24) then
	  tx_in_3 <=  '1';
	 elsif(count_3=28) then
	  tx_in_3 <= '0';
	 elsif(count_3=31) then
	  tx_in_3 <= '1';
	 elsif(count_3=34) then
	  tx_in_3 <= '0';
	 elsif(count_3=35) then
	  tx_in_3 <= '1';
	 elsif(count_3=38) then
	  tx_in_3 <= '0';
	 elsif(count_3=43) then
	  tx_in_3 <= '1';
	 elsif(count_3=46) then
	  tx_in_3 <= '0';
	 elsif(count_3=50) then
	  tx_in_3 <= '1';
	 end if;
	end if;
  end process;
	

END;
