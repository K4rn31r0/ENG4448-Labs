library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sseg_controller is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           hex0 : in  STD_LOGIC_VECTOR (3 downto 0);
           hex1 : in  STD_LOGIC_VECTOR (3 downto 0);
           sseg : out  STD_LOGIC_VECTOR (6 downto 0);
			  digit_sel : out STD_LOGIC);
end sseg_controller;

architecture Structural of sseg_controller is

	signal hex_muxed : STD_LOGIC_VECTOR(3 downto 0);
	signal sel_internal : STD_LOGIC;

begin

	refresh_unit : entity work.sseg_refresher
		Generic map (N => 18)
		Port map (
			clk => clk,
			clr => rst,
			q => sel_internal
		);
	
	mux_unit : entity work.mux_2to1
		Generic map (N => 4)
		Port map(
			in0 => hex0,
			in1 => hex1,
			sel => sel_internal,
			outp => hex_muxed
		);
	
	decode_unit : entity work.hex_to_sseg
		Port map (
			input => hex_muxed,
			output => sseg
		);
	
	digit_sel <= sel_internal;

end Structural;

