library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RotaryEncoder is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           rot_a : in  STD_LOGIC;
           rot_b : in  STD_LOGIC;
           rot_c : in  STD_LOGIC;
           leds : out  STD_LOGIC_VECTOR(7 downto 0)
			);
end RotaryEncoder;

architecture Behavioral of RotaryEncoder is
	
	type state_type is (
		s0, 
		e1, e2, e3,
		d1, d2, d3
	);
	signal pst, nst : state_type := s0; 
	signal rotary_q1 : STD_LOGIC := '0';
	signal rotary_q2 : STD_LOGIC := '0';
	
begin

--	rotary_filter: process(clk)
--		variable rotary_in: STD_LOGIC_VECTOR(1 downto 0) := "00";
--	begin
--	
--		if rising_edge(clk) then
--			rotary_in := rot_b & rot_a;	-- concatenacao
--			
--			case rotary_in is
--			
--				when "00" => rotary_q1 <= '0'; rotary_q2 <= rotary_q2;
--				when "01" => rotary_q1 <= rotary_q1; rotary_q2 <= '0';
--				when "10" => rotary_q1 <= rotary_q1; rotary_q2 <= '1';
--				when "11" => rotary_q1 <= '1'; rotary_q2 <= rotary_q2;
--				when others => null;
--				
--			end case;
--		end if;
--
--	end process rotary_filter;


	fsm_sync_proc : process(clk, reset)
	begin
	
		if (reset = '1') then 
			pst <= s0;
		elsif rising_edge(clk) then
			pst <= nst;
		end if;
		
	end process fsm_sync_proc;
	
	
	fsm_comb_proc : process(pst, rot_a, rot_b)
		variable ab : STD_LOGIC_VECTOR(1 downto 0) := "00";
	begin
		
		ab := rot_a & rot_b;
		nst <= pst;
		
		case pst is 	
			when s0 => 
				if (ab = "01") then
					nst <= e1;
				elsif (ab = "10") then
					nst <= d1;
				end if;
				
			when e1 =>
				if (ab = "11") then nst <= e2;
				elsif (ab = "00") then nst <= s0;
				end if;
				
			when e2 => 
				if (ab = "10") then nst <= e3;
				elsif (ab = "01") then nst <= e1;
				end if;
			
			when e3 =>
				if (ab = "00") then 
					nst <= s0; 	-- giro completo para a esquerda
				elsif  (ab = "11") then nst <= e2;
				end if;
			
			when d1 =>
				if (ab = "11") then nst <= d2;
				elsif (ab ="00") then nst <= s0;
				end if;
			
			when d2 =>
				if (ab = "01") then nst <= d3;
				elsif (ab = "10") then nst <= d1;
				end if;
			
			when d3 =>
				if (ab = "00") then
					nst <= s0;	-- giro completo para a direita
				elsif (ab = "11") then nst <= d2;
				end if;
				
			when others => 
				nst <= s0; 
			
		end case;
	
	end process fsm_comb_proc;

end Behavioral;

