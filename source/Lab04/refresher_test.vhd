LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY refresher_test IS
END refresher_test;
 
ARCHITECTURE behavior OF refresher_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT sseg_refresher
    PORT(
         clk : IN  std_logic;
         clr : IN  std_logic;
         q : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal clr : std_logic := '0';

 	--Outputs
   signal q : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;	-- 50 MHz
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: sseg_refresher PORT MAP (
          clk => clk,
          clr => clr,
          q => q
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

	stim_proc : process
	begin 
		clr <= '1';
		wait for 100 ns;
		clr <= '0';
		wait;
	end process;
	
END;
