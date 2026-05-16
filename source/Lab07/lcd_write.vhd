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
		x"28",
		x"06",
		x"0F",
		x"01"
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
	 
begin		-- architecture

end Behavioral;
