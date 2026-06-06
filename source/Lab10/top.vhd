library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity top is
    Port ( CLK50 		: in 	 STD_LOGIC;
			  RST			: in	 STD_LOGIC;
			  VGA_HSYNC : out  STD_LOGIC;
           VGA_VSYNC : out  STD_LOGIC;
           VGA_RED 	: out  STD_LOGIC;
           VGA_GREEN : out  STD_LOGIC;
           VGA_BLUE	: out  STD_LOGIC);
end top;

architecture Behavioral of top is

	signal pixel_clk 	: STD_LOGIC;
	signal display_on : STD_LOGIC;
	signal pixel_x 	: NATURAL;
	signal pixel_y 	: NATURAL;

	COMPONENT pixel_clk_gen
	PORT(
		CLKIN_IN : IN std_logic;
		RST_IN : IN std_logic;          
		CLKFX_OUT : OUT std_logic;
		CLKIN_IBUFG_OUT : OUT std_logic;
		CLK0_OUT : OUT std_logic;
		LOCKED_OUT : OUT std_logic;
		STATUS_OUT : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

begin

	u_clk_gen : pixel_clk_gen PORT MAP(
		CLKIN_IN => CLK50,
		RST_IN => RST,
		CLKFX_OUT => pixel_clk,
		CLKIN_IBUFG_OUT => open,
		CLK0_OUT => open,
		LOCKED_OUT => open,
		STATUS_OUT => open
	);
	
	u_vga_ctrl : entity work.vga_ctrl(Behavioral)
	port map (
		pixel_clock => pixel_clk,
		h_sync => VGA_HSYNC,
		v_sync => VGA_VSYNC,
		display_on => display_on,
		pixel_x => pixel_x,
		pixel_y => pixel_y
	);
	
	u_pixel_ctrl : entity work.pixel_ctrl(Behavioral)
	port map (
		pixel_clock => pixel_clk,
		display_on => display_on,
		pixel_x => pixel_x,
		pixel_y => pixel_y,
		red => VGA_RED,
		green => VGA_GREEN,
		blue => VGA_BLUE
	);

end Behavioral;

