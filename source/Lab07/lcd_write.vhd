library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
	
begin		-- architecture

end Behavioral;

