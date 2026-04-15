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

	signal rotary_q1 : STD_LOGIC := '0';
	signal rotary_q2 : STD_LOGIC := '0';
	signal delay_rotary_q1 : STD_LOGIC := '0';
	signal rotary_event : STD_LOGIC := '0';
	signal rotary_left : STD_LOGIC := '0';
	
	signal rot_c_sync_1   : STD_LOGIC := '0';
  signal rot_c_sync_2   : STD_LOGIC := '0';
  signal button_state   : STD_LOGIC := '0';
  signal button_event   : STD_LOGIC := '0';
  signal debounce_count : unsigned(19 downto 0) := (others => '0'); -- 20 bits para chegar a 500.000
	
	signal leds_reg : unsigned(7 downto 0) := "10000000";
	
begin

	rotary_filter: process(clk)
		variable rotary_in: STD_LOGIC_VECTOR(1 downto 0) := "00";
	begin
	
		if rising_edge(clk) then
			rotary_in := rot_b & rot_a;	-- concatenacao
			
			case rotary_in is
			
				when "00" => rotary_q1 <= '0'; rotary_q2 <= rotary_q2;
				when "01" => rotary_q1 <= rotary_q1; rotary_q2 <= '0';
				when "10" => rotary_q1 <= rotary_q1; rotary_q2 <= '1';
				when "11" => rotary_q1 <= '1'; rotary_q2 <= rotary_q2;
				when others => rotary_q1 <= rotary_q1; rotary_q2 <= rotary_q2;
				
			end case;
		end if;

	end process rotary_filter;
	
	direction: process(clk)
	begin
		if rising_edge(clk) then
			delay_rotary_q1 <= rotary_q1;
			
			-- Detecta a borda de subida de q1
			if (rotary_q1 = '1' and delay_rotary_q1 = '0') then
				rotary_event <= '1';
				rotary_left <= rotary_q2; 
			else
				rotary_event <= '0';
				rotary_left <= rotary_left;
			end if;
		end if;
	end process direction;
	
	button_debounce_proc : process(clk)
    begin
        if rising_edge(clk) then
            rot_c_sync_1 <= rot_c;
            rot_c_sync_2 <= rot_c_sync_1;
            
            button_event <= '0';
            
            if (rot_c_sync_2 = button_state) then
                debounce_count <= (others => '0');
            else
                debounce_count <= debounce_count + 1;
                
                if (debounce_count = 500000) then
                    button_state <= rot_c_sync_2;
                    debounce_count <= (others => '0');
                    
                    if (rot_c_sync_2 = '1') then
                        button_event <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process button_debounce_proc;
	
	output_proc: process(clk, reset)
	begin
	
		if (reset = '1') then
			leds_reg <= "10000000";
		elsif rising_edge(clk) then
		   if (button_event = '1') then
                leds_reg <= not leds_reg;
			elsif (rotary_event = '1') then 
			    if (rotary_left = '1') then
				    leds_reg <= leds_reg(6 downto 0) & leds_reg(7); -- Giro Esquerda
			    else
				    leds_reg <= leds_reg(0) & leds_reg(7 downto 1); -- Giro Direita
			    end if;
			end if;
		end if;
	
	end process output_proc;
	
	leds <= std_logic_vector(leds_reg);

end Behavioral;
