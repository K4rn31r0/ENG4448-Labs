library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

package lcd_utils_pkg is

	constant wait750k : unsigned(19 downto 0) := to_unsigned(750000, 20);
	constant wait205k : unsigned(19 downto 0) := to_unsigned(205000, 20);
	constant wait5k : unsigned(19 downto 0) := to_unsigned(5000, 20);
	constant wait2k : unsigned(19 downto 0) := to_unsigned(2000, 20);
	constant wait12 : unsigned(19 downto 0) := to_unsigned(12, 20);
	constant wait2 : unsigned(19 downto 0) := to_unsigned(2, 20);

	procedure increment_and_check (
		  signal counter   : inout unsigned(19 downto 0);
		  constant limit   : in unsigned(19 downto 0);
		  variable is_done : out boolean
	 );

end lcd_utils_pkg;

package body lcd_utils_pkg is

	procedure increment_and_check (
		  signal counter   : inout unsigned(19 downto 0);
		  constant limit   : in unsigned(19 downto 0);
		  variable is_done : out boolean
	 ) is
	 begin 
		  if counter < limit - 1 then
				counter <= counter + 1;
				is_done := false;
		  else 
				counter <= (others => '0');
				is_done := true;
		  end if;
	 end procedure;
 
end lcd_utils_pkg;
