library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           SF_D : out  STD_LOGIC_VECTOR (11 downto 8);
           LCD_E : out  STD_LOGIC;
           LCD_RS : out  STD_LOGIC;
           LCD_RW : out  STD_LOGIC;
			  SF_CE0 : out STD_LOGIC);
end top;

architecture Structural of top is

	signal init_data : STD_LOGIC_VECTOR(3 downto 0);
	signal init_e : STD_LOGIC;
	signal init_rs : STD_LOGIC;
	signal init_rw : STD_LOGIC;
	
	signal write_data : STD_LOGIC_VECTOR(3 downto 0);
	signal write_e : STD_LOGIC;
	signal write_rs : STD_LOGIC;
	signal write_rw : STD_LOGIC;
	
	signal init_done : STD_LOGIC;

begin

	init_u : entity work.lcd_init(Behavioral) port map(
		CLK => CLK,
		RST => RST,
		DATA_INIT => init_data,
		LCD_E_INIT => init_e,
		LCD_RS_INIT => init_rs,
		LCD_RW_INIT => init_rw,
		LCD_INIT_DONE => init_done
	);
	
	write_u : entity work.lcd_write(Behavioral) port map(
		CLK => CLK,
		RST => RST,
		DATA_OUT => write_data,
		LCD_E => write_e,
		LCD_RS => write_rs,
		LCD_RW => write_rw,
		LCD_INIT_DONE => init_done
	);
	
	-- MUX dependendo do estagio (init ou write)
	SF_D <= write_data when init_done = '1' else init_data;
	LCD_E <= write_e when init_done = '1' else init_e;
	LCD_RS <= write_rs when init_done = '1' else init_rs;
	LCD_RW <= write_rw when init_done = '1' else init_rw;
	
	-- DISABLE strataflash
	SF_CE0 <= '1';
	
end Structural;

