LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY lcd_init_tb IS
END lcd_init_tb;
 
ARCHITECTURE behavior OF lcd_init_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT lcd_init
    PORT(
         DATA_INIT : OUT  std_logic_vector(3 downto 0);
         LCD_E_INIT : OUT  std_logic;
         LCD_RS_INIT : OUT  std_logic;
         LCD_RW_INIT : OUT  std_logic;
         LCD_INIT_DONE : OUT  std_logic;
         RST : IN  std_logic;
         CLK : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal RST : std_logic := '0';
   signal CLK : std_logic := '0';

 	--Outputs
   signal DATA_INIT : std_logic_vector(3 downto 0);
   signal LCD_E_INIT : std_logic;
   signal LCD_RS_INIT : std_logic;
   signal LCD_RW_INIT : std_logic;
   signal LCD_INIT_DONE : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 20 ns;	-- 50 MHz
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: lcd_init PORT MAP (
          DATA_INIT => DATA_INIT,
          LCD_E_INIT => LCD_E_INIT,
          LCD_RS_INIT => LCD_RS_INIT,
          LCD_RW_INIT => LCD_RW_INIT,
          LCD_INIT_DONE => LCD_INIT_DONE,
          RST => RST,
          CLK => CLK
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		RST <= '1'; wait for 100 ns;	
	
		RST <= '0'; wait for 20 ms;
		
      assert false report "END" severity failure;
   end process;

END;
