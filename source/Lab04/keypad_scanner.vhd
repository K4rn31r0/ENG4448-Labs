library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity keypad_scanner is
    Port ( 
			clk : in STD_LOGIC;
			rst : in STD_LOGIC;
			col : out  STD_LOGIC_VECTOR (3 downto 0);
         row : in  STD_LOGIC_VECTOR (3 downto 0);
			
			key_code : out STD_LOGIC_VECTOR (3 downto 0);
			key_pressed : out STD_LOGIC
			);
end keypad_scanner;

architecture Behavioral of keypad_scanner is

	signal scan_tick : STD_LOGIC;
	signal last_scan_tick : STD_LOGIC := '0';
   signal scan_enable : STD_LOGIC;
	
	type state_type is (SCAN_C1, SCAN_C2, SCAN_C3, SCAN_C4, WAIT_RELEASE);
	signal state : state_type := SCAN_C1;

begin

	-- reusando o refresher pro debounce(porque ele n deixa de ser um timer)
	timer_unit : entity work.sseg_refresher
		Generic map (N => 19)
		Port map (
			clk => clk,
			clr => rst,
			q => scan_tick
		);
	
	col <= "0111" when state = SCAN_C1 else
           "1011" when state = SCAN_C2 else
           "1101" when state = SCAN_C3 else
           "1110" when state = SCAN_C4 else
           "0000"; 
		
	keypad_fsm : process(clk)
	begin
		
		if rising_edge(clk) then
			last_scan_tick <= scan_tick;
			
			if rst = '1' then
				state <= SCAN_C1;
				key_code <= "0000";
				key_pressed <= '0';
				
			elsif (scan_tick = '1' and last_scan_tick = '0') then
			
				case state is
				
					when SCAN_C1 =>
						if row /= "1111" then
						
							if row = "0111" then
								key_code <= "0001";		-- 1
							elsif row = "1011" then
								key_code <= "0100";		-- 4
							elsif row = "1101" then
								key_code <= "0111";		-- 7
							elsif row = "1110" then
								key_code <= "0000";		-- 0
							end if;
							
							key_pressed <= '1';
							state <= WAIT_RELEASE;
						else 
							state <= SCAN_C2;
						end if;
					
					when SCAN_C2 =>
						if row /= "1111" then
						
							if row = "0111" then
								key_code <= "0010";		-- 2
							elsif row = "1011" then
								key_code <= "0101";		-- 5
							elsif row = "1101" then
								key_code <= "1000";		-- 8
							elsif row = "1110" then
								key_code <= "1111";		-- F
							end if;
							
							key_pressed <= '1';
							state <= WAIT_RELEASE;
						else 
							state <= SCAN_C3;
						end if;
						
					when SCAN_C3 =>
						if row /= "1111" then
						
							if row = "0111" then
								key_code <= "0011";		-- 3
							elsif row = "1011" then
								key_code <= "0110";		-- 6
							elsif row = "1101" then
								key_code <= "1001";		-- 9
							elsif row = "1110" then
								key_code <= "1110";		-- E
							end if;
							
							key_pressed <= '1';
							state <= WAIT_RELEASE;
						else 
							state <= SCAN_C4;
						end if;
						
					when SCAN_C4 =>
						if row /= "1111" then
						
							if row = "0111" then
								key_code <= "1010";		-- A
							elsif row = "1011" then
								key_code <= "1011";		-- B
							elsif row = "1101" then
								key_code <= "1100";		-- C
							elsif row = "1110" then
								key_code <= "1101";		-- D
							end if;
							
							key_pressed <= '1';
							state <= WAIT_RELEASE;
						else 
							state <= SCAN_C1;
						end if;
					
					when WAIT_RELEASE =>
					
						if row = "1111" then
							key_pressed <= '0';
							state <= SCAN_C1;
						end if;
						
				end case;
			end if;
		end if;
	
	end process keypad_fsm;

end Behavioral;

