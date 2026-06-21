LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--USE ieee.numeric_std.ALL;
 
ENTITY clk_gen_tb IS
END clk_gen_tb;
 
ARCHITECTURE behavior OF clk_gen_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT clk_gen
	GENERIC (
        DIVISOR : positive := 50_000_000
    );
    PORT(
         CLK50 : IN  std_logic;
         CLKOUT : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK50 : std_logic := '0';

 	--Outputs
   signal CLKOUT : std_logic;

   -- Clock period definitions
   constant CLK50_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: clk_gen 
   GENERIC MAP (
		DIVISOR => 8
   )
   PORT MAP (
          CLK50 => CLK50,
          CLKOUT => CLKOUT
        );

   -- Clock process definitions
   CLK50_process :process
   begin
		CLK50 <= '0';
		wait for CLK50_period/2;
		CLK50 <= '1';
		wait for CLK50_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      wait until rising_edge(clkout);
	  report "Primeira borda";
	  wait until falling_edge(clkout);
	  report "Segunda borda";
	  assert false report "END" severity failure;
   end process;

END;
