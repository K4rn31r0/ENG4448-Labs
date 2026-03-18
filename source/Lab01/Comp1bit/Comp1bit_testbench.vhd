LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY Comp1bit_testbench IS
END Comp1bit_testbench;
 
ARCHITECTURE behavior OF Comp1bit_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Comp1bit
    PORT(
         a : IN  std_logic;
         b : IN  std_logic;
         z : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal a : std_logic := '0';
   signal b : std_logic := '0';

 	--Outputs
   signal z : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Comp1bit PORT MAP (
          a => a,
          b => b,
          z => z
        );
 
   -- Stimulus process
   stim_proc: process
   begin		
      a <= '0';
      b <= '0';
      wait for 50 ns;
      a <= '1';
      b <= '0';
      wait for 50 ns;	
      a <= '0';
      b <= '1';
      wait for 50 ns;	
      a <= '1';
      b <= '1';	
      wait;
   end process;

END;
