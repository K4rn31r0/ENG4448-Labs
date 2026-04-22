LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY shift_register_test IS
END shift_register_test;
 
ARCHITECTURE behavior OF shift_register_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT shift_register
    PORT(
         key_code : IN  std_logic_vector(3 downto 0);
         hex0 : OUT  std_logic_vector(3 downto 0);
         hex1 : OUT  std_logic_vector(3 downto 0);
         clk : IN  std_logic;
         key_pressed : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal key_code : std_logic_vector(3 downto 0) := (others => '0');
   signal clk : std_logic := '0';
   signal key_pressed : std_logic := '0';

 	--Outputs
   signal hex0 : std_logic_vector(3 downto 0);
   signal hex1 : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clk_period : time := 20 ns; 	-- 50 MHz clock
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: shift_register PORT MAP (
          key_code => key_code,
          hex0 => hex0,
          hex1 => hex1,
          clk => clk,
          key_pressed => key_pressed
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      key_pressed <= '1';
		key_code <= "0101";
		
		wait for clk_period*4;
		
		key_pressed <= '0';
		
		wait for clk_period*2;
		
		key_pressed <= '1';
		key_code <= "1110";
		
		wait for clk_period*4;
		
		key_pressed <= '0';
		
		wait for clk_period*2;
		
		key_pressed <= '1';
		key_code <= "0110";

      wait for clk_period*4;
		
		key_pressed <= '0';
		
		wait for clk_period*2;
		
		assert false report "END" severity failure;
		
   end process;

END;
