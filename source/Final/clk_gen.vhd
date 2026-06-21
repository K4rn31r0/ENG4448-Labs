library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clk_gen is
    generic (
        DIVISOR : positive := 50_000_000	-- 0.5 Hz (periodo 2s, 1 toggle/s)
    );
    port (
        CLK50  : in  STD_LOGIC;
        CLKOUT : out STD_LOGIC
    );
end clk_gen;

architecture Behavioral of clk_gen is

	-- 
    signal cnt   : natural range 0 to DIVISOR-1 := 0;
    signal clk_r : STD_LOGIC := '0';

begin

    process (CLK50)
    begin
        if rising_edge(CLK50) then
			if cnt = DIVISOR-1 then
				cnt   <= 0;
                clk_r <= not clk_r;
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end process;

    CLKOUT <= clk_r;

end Behavioral;