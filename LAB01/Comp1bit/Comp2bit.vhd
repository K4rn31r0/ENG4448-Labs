library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Comp2bit is
    Port ( a : in  STD_LOGIC_VECTOR(1 downto 0);
           b : in  STD_LOGIC_VECTOR(1 downto 0);
           z : out  STD_LOGIC);
end Comp2bit;

architecture Compare of Comp2bit is
	
	signal comp0, comp1 : STD_LOGIC;
	
begin

	bit0comparator : entity work.comp1bit(compare)
	port map (
		a => a(0),
		b => b(0),
		z => comp0
	);
	
	bit1comparator : entity work.comp1bit(compare)
	port map (
		a => a(1),
		b => b(1),
		z => comp1
	);
	
	-- os dois bits tem q ser iguais
	z <= comp0 AND comp1;

end Compare;

