library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sseg_refresher is
	generic (
		N : natural := 18		-- refresh rate ~ 381 Hz (T ~ 2.62 ms)
	);
    Port (
			  clk : in  STD_LOGIC;
           clr : in  STD_LOGIC;
           q : out  STD_LOGIC
	);
end sseg_refresher;

architecture Behavioral of sseg_refresher is

	signal counter, c_next : unsigned(N-1 downto 0) := (others => '0');

begin

	process(clk)	
	begin
		if rising_edge(clk) then
			if (clr = '1') then
				counter <= (others => '0');
			else 
				counter <= c_next;
			end if;
		end if;
	end process;
	
	c_next <= counter + 1;
	q <= std_logic(counter(N-1));

end Behavioral;

