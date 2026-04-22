library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_level is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           kypd_row : in  STD_LOGIC_VECTOR (3 downto 0);
           kypd_col : out  STD_LOGIC_VECTOR (3 downto 0);
           sseg_out : out  STD_LOGIC_VECTOR (6 downto 0);
           sseg_sel : out  STD_LOGIC);
end top_level;

architecture Structural of top_level is

	signal w_key_code : STD_LOGIC_VECTOR (3 downto 0);
	signal w_key_pressed : STD_LOGIC;
	signal w_hex0 : STD_LOGIC_VECTOR (3 downto 0);
	signal w_hex1 : STD_LOGIC_VECTOR (3 downto 0);

begin

	u_keypad : entity work.keypad_scanner
		Port map (
			clk => clk,
			rst => rst,
			col => kypd_col,
			row => kypd_row,
			key_code => w_key_code,
			key_pressed => w_key_pressed
		);
	
	u_shift_reg : entity work.shift_register
		Port map (
			clk => clk,
			hex0 => w_hex0,
			hex1 => w_hex1,
			key_pressed => w_key_pressed,
			key_code => w_key_code
		);
	
	u_display : entity work.sseg_controller
		Port map (
			clk => clk,
			rst => rst,
			hex0 => w_hex0,
			hex1 => w_hex1,
			sseg => sseg_out,
			digit_sel => sseg_sel
		);

end Structural;

