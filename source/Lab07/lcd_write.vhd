library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lcd_write is
    Port ( DATA_INIT : in  STD_LOGIC_VECTOR (3 downto 0);
           LCD_E_INIT : in  STD_LOGIC;
           LCD_RS_INIT : in  STD_LOGIC;
           LCD_RW_INIT : in  STD_LOGIC;
           LCD_INIT_DONE : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           DATA_OUT : out  STD_LOGIC_VECTOR (3 downto 0);
           LCD_E : out  STD_LOGIC;
           LCD_RS : out  STD_LOGIC;
           LCD_RW : out  STD_LOGIC);
end lcd_write;

architecture Behavioral of lcd_write is

	signal DATA_OUT_REG : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
	signal LCD_E_REG : STD_LOGIC := '0';
	signal LCD_RS_REG : STD_LOGIC := '0';
	signal LCD_RW_REG : STD_LOGIC := '0';
	
begin		-- architecture
	
	-- combinacional: decidir qual valor que vai pro LCD
	DATA_OUT <= DATA_OUT_REG when LCD_INIT_DONE = '1' else DATA_INIT;
	LCD_E <= LCD_E_REG when LCD_INIT_DONE = '1' else LCD_E_INIT;
	LCD_RS <= LCD_RS_REG when LCD_INIT_DONE = '1' else LCD_RS_INIT;
	LCD_RW <= LCD_RW_REG when LCD_INIT_DONE = '1' else LCD_RW_INIT;

end Behavioral;

