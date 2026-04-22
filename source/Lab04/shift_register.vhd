library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity shift_register is
    Port ( key_code : in  STD_LOGIC_VECTOR (3 downto 0);
           hex0 : out  STD_LOGIC_VECTOR (3 downto 0);
           hex1 : out  STD_LOGIC_VECTOR (3 downto 0);
           clk : in  STD_LOGIC;
           key_pressed : in  STD_LOGIC);
end shift_register;

architecture Behavioral of shift_register is

	signal last_key_pressed : STD_LOGIC := '0';
	signal hex0_register : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
	signal hex1_register : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');

begin

	shift_proc : process (clk)
	begin
		if rising_edge(clk) then
			last_key_pressed <= key_pressed;
			
			-- rising edge detector
			if (key_pressed = '1' and last_key_pressed = '0') then
				hex1_register <= hex0_register;
				hex0_register <= key_code;
			end if;
			
		end if;
	end process shift_proc;
	
	hex0 <= hex0_register;
	hex1 <= hex1_register;

end Behavioral;

