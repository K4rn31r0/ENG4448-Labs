--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:22:15 04/21/2026
-- Design Name:   
-- Module Name:   C:/users/pedrocunha/Documents/PUC/ENG4448/ENG4448-Labs/source/Lab04/mux_2to1_test.vhd
-- Project Name:  Lab04
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: mux_2to1
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY mux_2to1_test IS
END mux_2to1_test;
 
ARCHITECTURE behavior OF mux_2to1_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT mux_2to1
    PORT(
         in0 : IN  std_logic_vector(3 downto 0);
         in1 : IN  std_logic_vector(3 downto 0);
         outp : OUT  std_logic_vector(3 downto 0);
         sel : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal in0 : std_logic_vector(3 downto 0) := (others => '0');
   signal in1 : std_logic_vector(3 downto 0) := (others => '0');
   signal sel : std_logic := '0';

 	--Outputs
   signal outp : std_logic_vector(3 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: mux_2to1 PORT MAP (
          in0 => in0,
          in1 => in1,
          outp => outp,
          sel => sel
        );
 
   -- Stimulus process
   stim_proc: process
   begin		
		-- hold reset state for 100 ns
      wait for 100 ns;
		
		in0 <= "1010";
		in1 <= "0101";
		
		wait for 100 ns;
		
		sel <= '1';
		
      wait;
   end process;

END;
