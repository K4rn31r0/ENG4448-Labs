LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
 
ENTITY comp2bit_testbench IS
END comp2bit_testbench;
 
ARCHITECTURE behavior OF comp2bit_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Comp2bit
    PORT(
         a : IN  std_logic_vector(1 downto 0);
         b : IN  std_logic_vector(1 downto 0);
         z : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal a : std_logic_vector(1 downto 0) := (others => '0');
   signal b : std_logic_vector(1 downto 0) := (others => '0');

 	--Outputs
   signal z : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Comp2bit PORT MAP (
          a => a,
          b => b,
          z => z
        ); 

   -- Stimulus process
   stim_proc: process
   begin		
		for i_a in 0 to 3 loop
			for i_b in 0 to 3 loop
				a <= std_logic_vector(to_unsigned(i_a, 2));
				b <= std_logic_vector(to_unsigned(i_b, 2));
				wait for 50 ns;
			end loop;
		end loop;
      wait;
   end process;

END;
