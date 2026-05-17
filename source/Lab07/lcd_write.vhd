library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.lcd_utils_pkg.ALL;

entity lcd_write is
    Port ( LCD_INIT_DONE : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           DATA_OUT : out  STD_LOGIC_VECTOR (3 downto 0);
           LCD_E : out  STD_LOGIC;
           LCD_RS : out  STD_LOGIC;
           LCD_RW : out  STD_LOGIC);
end lcd_write;

architecture Behavioral of lcd_write is

	constant CMD_ROM : initcmd_array_type := (
		x"28",			-- FUNCTION SET
		x"06",			-- ENTRY MODE SET
		x"0F",			-- DISPLAY ON
		x"01"				-- CLEAR DISPLAY
	);
	
	constant FIRST_LINE : char_array_type := (
		0 => x"44",		-- D
		1 => x"75",		-- u
		2 => x"72",		-- r
		3 => x"6D",		-- m
		4 => x"61", 	-- a
							-- 
		6 => x"62",		-- b
		7 => x"65",		-- e
		8 => x"6D",		-- m
		others => x"20"
	);
	
	constant SECOND_LINE: char_array_type := (
		0 => x"63",		-- c
		1 => x"65", 	-- e
		2 => x"64", 	-- d
		3 => x"6F",		-- o
		4 => x"2C",		-- ,
							--
		6 => x"4F",		-- O
		7 => x"4B",		-- K
		8 => x"3F",		-- ?
		others => x"20"
	);
	
	type master_fsm is (
		SEND_CONFIG,
		SEND_LINE1, 
		LINE_CHANGE,
		SEND_LINE2,
		DONE
	);
	
	type write_fsm is (
		IDLE, 
		UPPER_NIBBLE, UPPER_NIBBLE_E,
		WAIT_1U,
		LOWER_NIBBLE, LOWER_NIBBLE_E,
		WAIT_POST_BYTE
	);
	
	signal m_state	: master_fsm := SEND_CONFIG;
	signal write_state : write_fsm := IDLE;
	
	signal idx_cmd : integer range 0 to 3 := 0;		-- Qual comando da sequencia?
	signal idx_char : integer range 0 to 15 := 0;	-- Qual caractere da msg?
	
	signal byte_to_send : byte_t := (others => '0');
	signal counter : unsigned (19 downto 0) := (others => '0');
	signal setup_finished : STD_LOGIC := '0';
	 
begin		-- architecture

	process(CLK)
		variable time_up : boolean := false;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				write_state <= IDLE;
				m_state <= SEND_CONFIG;
				setup_finished <= '0';
				idx_cmd <= 0;
				idx_char <= 0;
			else 
				case write_state is
				
					when IDLE => 
						-- comecar apenas depois que o lcd_init sinalizar
						if LCD_INIT_DONE = '1' then
							
							if m_state = SEND_CONFIG then
								byte_to_send <= CMD_ROM(idx_cmd);
								LCD_RS <= '0';		-- comando
								write_state <= UPPER_NIBBLE;
							
							elsif m_state = SEND_LINE1 then
								byte_to_send <= FIRST_LINE(idx_char);
								LCD_RS <= '1';		-- caractere
								write_state <= UPPER_NIBBLE;
								
							elsif m_state = LINE_CHANGE then
								byte_to_send <= x"40";	-- SET DD RAM ADDR 0x40
								LCD_RS <= '0';		-- comando
								write_state <= UPPER_NIBBLE;
							
							elsif m_state = SEND_LINE2 then
								byte_to_send <= SECOND_LINE(idx_char);
							   LCD_RS <= '1';
							   write_state <= UPPER_NIBBLE;
							
							elsif m_state = DONE then
								null; 		-- parou
							
							end if;
						end if;
					
					when UPPER_NIBBLE =>
						DATA_OUT <= byte_to_send(7 downto 4);
						LCD_RW <= '0'; 
						increment_and_check(counter, wait2, time_up);
						if time_up then 
							write_state <= UPPER_NIBBLE_E; 
						end if;
					
					when UPPER_NIBBLE_E =>
						LCD_E <= '1';
						increment_and_check(counter, wait12, time_up);
						if time_up then 
							write_state <= WAIT_1U;
						end if;
						
					when WAIT_1U =>
						LCD_E <= '0';
						LCD_RW <= '1';
						increment_and_check(counter, wait50, time_up);
						if time_up then 
							write_state <= LOWER_NIBBLE;
						end if;
					
					when LOWER_NIBBLE =>
						DATA_OUT <= byte_to_send(3 downto 0);
						LCD_RW <= '0';
						increment_and_check(counter, wait2, time_up);
						if time_up then 
							write_state <= LOWER_NIBBLE_E;
						end if;
					
					when LOWER_NIBBLE_E =>
						LCD_E <= '1';
						increment_and_check(counter, wait12, time_up);
						if time_up then 
							write_state <= WAIT_POST_BYTE;
						end if;
					
					when WAIT_POST_BYTE =>
						LCD_E <= '0';
						LCD_RW <= '1';
						
						if (m_state = SEND_CONFIG) and (cmd_idx = 3) then
							increment_and_check(counter, wait82k, time_up);		-- clear display pede 1.62 ms
						else 
							increment_and_check(counter, wait2k, time_up);
						end if;
						
						if time_up then 				
							if m_state = SEND_CONFIG then
								if idx_cmd < 3 then
									idx_cmd <= idx_cmd + 1;
								else 
									m_state <= SEND_LINE1;	-- acabou a config: escrever texto
									setup_finished <= '1';
								end if;
							
							elsif m_state = SEND_LINE1 then
								if idx_char < 15 then 
									idx_char <= idx_char + 1;
								else
									m_state <= LINE_CHANGE;
								end if;
								
							elsif m_state = LINE_CHANGE then
								idx_char <= 0;
								m_state <= SEND_LINE2;
							
							elsif m_state = SEND_LINE2 then
								if idx_char < 15 then 
									idx_char <= idx_char + 1;
								else
									m_state <= DONE;
								end if;
								
							end if;
							
							write_state <= IDLE;
							
						end if;
				end case;
			end if;
		end if;
	end process;
	

end Behavioral;
