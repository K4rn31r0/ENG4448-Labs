--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:16:49 04/21/2026
-- Design Name:   
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY hex_to_sseg_test IS
END hex_to_sseg_test;
 
ARCHITECTURE behavior OF hex_to_sseg_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT hex_to_sseg
    PORT(
         input : IN  std_logic_vector(3 downto 0);
         output : OUT  std_logic_vector(6 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal input : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal output : std_logic_vector(6 downto 0);

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: hex_to_sseg PORT MAP (
          input => input,
          output => output
        );

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		
		for i in 0 to 15 loop
			input <= std_logic_vector(to_unsigned(i, input'length));
			wait for 50 ns;
		end loop;
		
      wait;
   end process;

END;
