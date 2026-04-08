library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux_2to1 is
	 generic (N : natural := 4);
    Port ( in0 : in  STD_LOGIC_VECTOR(N-1 downto 0);
           in1 : in  STD_LOGIC_VECTOR(N-1 downto 0);
           outp : out  STD_LOGIC_VECTOR(N-1 downto 0);
           sel : in  STD_LOGIC);
end mux_2to1;

architecture Behavioral of mux_2to1 is
begin

	outp <= in0 when sel = '0' else in1;

end Behavioral;

