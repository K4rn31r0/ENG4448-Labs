library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity main is
    Port ( CLK50 : in  STD_LOGIC;
           RST : in  STD_LOGIC);
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

begin

	u_cpu : entity work.cpu(Behavioral)
		port map (
			CLK => r_CLK_SLOW,
			RESET => RST,
			RAM_DIN => r_RAM_DIN,
			RAM_DOUT => r_RAM_DOUT,
			RAM_ADDR => r_RAM_ADDR,
			WE => r_WE
		);
	
	u_memory : entity work.memory(rtl) 
		port map (
			CLK => r_CLK_SLOW,
			DIN => r_RAM_DIN,
			DOUT => r_RAM_DOUT,
			ADDR => r_RAM_ADDR,
			WE => r_WE,
			POS_255 => open		-- mudar depois que o LCD for implementado!
		);
	
	u_clk_gen : entity work.clk_gen(Behavioral)
		port map (
			CLK50 => CLK50,
			CLKOUT => r_CLK_SLOW
		);

end Structural;

