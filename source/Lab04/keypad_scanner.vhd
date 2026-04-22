library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity keypad_scanner is
    Port ( 
			clk : in STD_LOGIC;
			rst : in STD_LOGIC;
			col : out  STD_LOGIC_VECTOR (3 downto 0);
         row : in  STD_LOGIC_VECTOR (3 downto 0)		
			);
end keypad_scanner;

architecture Behavioral of keypad_scanner is

	signal scan_tick : STD_LOGIC;
	
	type state_type is (SCAN_C1, SCAN_C2, SCAN_C3, SCAN_C4, WAIT_RELEASE);
	signal state : state_type := SCAN_C1;

begin

	-- reusando o refresher pro debounce(porque ele n deixa de ser um timer)
	timer_unit : entity work.sseg_refresher
		Generic map (N => 19)
		Port map (
			clk => clk,
			rst => rst,
			q => scan_tick
		);

end Behavioral;

