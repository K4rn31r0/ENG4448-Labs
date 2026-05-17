LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY lcd_write_tb IS
END lcd_write_tb;
 
ARCHITECTURE behavior OF lcd_write_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT lcd_write
    PORT(
         LCD_INIT_DONE : IN  std_logic;
         RST : IN  std_logic;
         CLK : IN  std_logic;
         DATA_OUT : OUT  std_logic_vector(3 downto 0);
         LCD_E : OUT  std_logic;
         LCD_RS : OUT  std_logic;
         LCD_RW : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal LCD_INIT_DONE : std_logic := '0';
   signal RST : std_logic := '0';
   signal CLK : std_logic := '0';

 	--Outputs
   signal DATA_OUT : std_logic_vector(3 downto 0);
   signal LCD_E : std_logic;
   signal LCD_RS : std_logic;
   signal LCD_RW : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: lcd_write PORT MAP (
          LCD_INIT_DONE => LCD_INIT_DONE,
          RST => RST,
          CLK => CLK,
          DATA_OUT => DATA_OUT,
          LCD_E => LCD_E,
          LCD_RS => LCD_RS,
          LCD_RW => LCD_RW
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
		RST <= '1';
      wait for 100 ns;	
		RST <= '0';
		wait for 40 ns;

      -- insert stimulus here 
		
		LCD_INIT_DONE <= '1';
		
		wait for 3.2 ms;
		
      assert false report "END" severity failure;
   
	end process;

END;
