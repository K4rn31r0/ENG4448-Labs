library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory is
    Port ( CLK : in  STD_LOGIC;
           DIN : in  STD_LOGIC_VECTOR (7 downto 0);
           ADDR : in  STD_LOGIC_VECTOR (7 downto 0);
           WE : in  STD_LOGIC;
           DOUT : out  STD_LOGIC_VECTOR (7 downto 0);
           POS_255 : out  STD_LOGIC_VECTOR (7 downto 0));
end memory;

architecture rtl of memory is
    
    type RAM_t is array(0 to 255) of std_logic_vector(7 downto 0);
    signal read_address : std_logic_vector(7 downto 0) := (others => '0');

    -- testinst.asm
    signal ram : RAM_t := (
        others => (others => '0')
    );

begin

    process(CLK) is
    begin
        if falling_edge(CLK) then
            if WE = '1' then
                ram(to_integer(unsigned(ADDR))) <= DIN;
            end if;
            read_address <= ADDR;
        end if;
    end process;

    DOUT    <= ram(to_integer(unsigned(read_address)));
    POS_255 <= ram(255);

end architecture;
