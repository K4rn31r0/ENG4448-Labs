library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_ctrl is
	 generic (
		h_pol		: STD_LOGIC := '0';						-- hpulse on low
		h_pulse	: NATURAL := 128;							-- horizontal pulse pixels
		h_bp		: NATURAL := 88;							-- horizontal back porch pixels
		h_pixels	: NATURAL := 800;							-- horizontal display pixels
		h_fp		: NATURAL := 40;							-- horizontal front porch pixels
		v_pol 	: STD_LOGIC := '0';						-- vpulse on low
		v_pulse 	: NATURAL := 4;							-- vertical pulse rows
		v_bp 		: NATURAL := 23; 							-- vertical back porch rows
		v_pixels : NATURAL := 600;							-- vertical display rows
		v_fp 		: NATURAL := 1								-- vertical front porch rows
	 );
    Port ( 
		pixel_clock : in  STD_LOGIC;
      h_sync : out  STD_LOGIC;
      v_sync : out  STD_LOGIC;
      display_on : out  STD_LOGIC;
      pixel_x : out  NATURAL;
      pixel_y : out  NATURAL
	 );
end vga_ctrl;

architecture Behavioral of vga_ctrl is

	constant h_period : NATURAL := h_pulse + h_bp + h_pixels + h_fp;
	constant v_period : NATURAL := v_pulse + v_bp + v_pixels + v_fp;
	
	subtype h_count_t is NATURAL range 0 to h_period - 1;
   subtype v_count_t is NATURAL range 0 to v_period - 1;
	
	signal h_sync_reg : STD_LOGIC := '0';
	signal v_sync_reg : STD_LOGIC := '0';
	signal display_on_reg : STD_LOGIC := '0';
	signal pixel_x_reg : h_count_t := 0;
	signal pixel_y_reg : v_count_t := 0;
	
begin

	-- VGA process
	process(pixel_clock)
		variable h_counter : h_count_t := 0;
		variable v_counter : v_count_t := 0;
	begin
		if rising_edge(pixel_clock) then
			if (h_counter < h_period - 1) then
				h_counter := h_counter + 1;
			else
				h_counter := 0;
				if (v_counter < v_period - 1) then
					v_counter := v_counter + 1;
				else
					v_counter := 0;
				end if;
			end if;
			
			-- horizontal sync
			if ( (h_counter < h_pixels + h_fp) or (h_counter >= h_pixels + h_fp + h_pulse) ) then
				h_sync_reg <= not h_pol;
			else
				h_sync_reg <= h_pol;
			end if;
			
			-- vertical sync
			if ( (v_counter < v_pixels + v_fp) or (v_counter >= v_pixels + v_fp + v_pulse) ) then
				v_sync_reg <= not v_pol;
			else
				v_sync_reg <= v_pol;
			end if;
			
			-- inside display area?
			if ( (h_counter < h_pixels) and (v_counter < v_pixels) ) then
				display_on_reg <= '1';
			else
				display_on_reg <= '0';
			end if;
			
			-- update pixel_x and pixel_y
			pixel_x_reg <= h_counter;
			pixel_y_reg <= v_counter;
			
		end if;
	end process;
	
	h_sync <= h_sync_reg;
	v_sync <= v_sync_reg;
	display_on <= display_on_reg;
	pixel_x <= pixel_x_reg;
	pixel_y <= pixel_y_reg;

end Behavioral;

