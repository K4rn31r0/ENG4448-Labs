library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity main is
    Port ( CLK50 : in  STD_LOGIC;
           RST : in  STD_LOGIC;
		   CLK_LED : out STD_LOGIC;
		   FLAGS : out STD_LOGIC_VECTOR(4 downto 0);
		   -- interface do LCD (barramento compartilhado com a StrataFlash)
		   SF_D   : out STD_LOGIC_VECTOR(11 downto 8);
		   LCD_E  : out STD_LOGIC;
		   LCD_RS : out STD_LOGIC;
		   LCD_RW : out STD_LOGIC;
		   SF_CE0 : out STD_LOGIC
		   );
end main;

architecture Structural of main is

	-- CLOCK
	signal r_CLK_SLOW : std_logic := '0';

	-- RAM
	signal r_RAM_DIN : std_logic_vector(7 downto 0) := (others => '0');
	signal r_RAM_DOUT : std_logic_vector(7 downto 0) := (others => '0');
	signal r_RAM_ADDR : std_logic_vector(7 downto 0) := (others => '0');
	signal r_WE : std_logic := '0';

	-- LCD
	signal r_IR      : std_logic_vector(7 downto 0) := (others => '0');
	signal r_POS_255 : std_logic_vector(7 downto 0) := (others => '0');

begin

	u_cpu : entity work.cpu(Behavioral)
		port map (
			CLK => r_CLK_SLOW,
			RESET => RST,
			RAM_DIN => r_RAM_DIN,
			RAM_DOUT => r_RAM_DOUT,
			RAM_ADDR => r_RAM_ADDR,
			WE => r_WE,
			IR_OUT => r_IR,
			FLAGS => FLAGS
		);

	u_memory : entity work.memory(rtl)
		port map (
			CLK => r_CLK_SLOW,
			DIN => r_RAM_DIN,
			DOUT => r_RAM_DOUT,
			ADDR => r_RAM_ADDR,
			WE => r_WE,
			POS_255 => r_POS_255		-- alimenta a 2a linha do LCD
		);

	u_clk_gen : entity work.clk_gen(Behavioral)
		port map (
			CLK50 => CLK50,
			CLKOUT => r_CLK_SLOW
		);

	-- LCD roda no clock rapido (50 MHz), nao no clock lento da CPU
	u_lcd : entity work.LCD(Behavioral)
		port map (
			CLK50   => CLK50,
			RST     => RST,
			IR      => r_IR,
			POS_255 => r_POS_255,
			SF_D    => SF_D,
			LCD_E   => LCD_E,
			LCD_RS  => LCD_RS,
			LCD_RW  => LCD_RW,
			SF_CE0  => SF_CE0
		);
	
	CLK_LED <= r_CLK_SLOW;

end Structural;
