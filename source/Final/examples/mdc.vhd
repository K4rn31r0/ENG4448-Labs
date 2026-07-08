library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity RAM_8x256 is
    port(
        CLK     : in std_logic;
        DIN     : in std_logic_vector(7 downto 0);
        ADDR    : in std_logic_vector(7 downto 0);
        WE      : in std_logic;
        DOUT    : out std_logic_vector(7 downto 0);
        POS_255 : out std_logic_vector(7 downto 0)
    );
end RAM_8x256;

architecture rtl of RAM_8x256 is
    
    type RAM_t is array(0 to 255) of std_logic_vector(7 downto 0);
    signal read_address : std_logic_vector(7 downto 0) := (others => '0');

    -- mdc.asm
    signal ram : RAM_t := (
        0   => "11000000", --   1:             .global @start
        1   => "00000010", --   1:             jmp 2
        2   => "10000011", --   7:             ld ra, @vala
        3   => "00011000", --   7:             24
        4   => "10000111", --   8:             ld rb, @valb
        5   => "00010010", --   8:             18
        6   => "10000000", --  11:             push ra
        7   => "00010001", --  12:             sub ra, rb
        8   => "10001111", --  13:             ld rd, @mdc_done
        9   => "00010101", --  13:             21
        10  => "11011110", --  14:             beq rd
        11  => "10001111", --  16:             ld rd, @ra_smaller
        12  => "00010001", --  16:             17
        13  => "11101101", --  17:             blt rd
        14  => "10001101", --  20:             pop rd
        15  => "11000000", --  21:             jmp @mdc_loop
        16  => "00000110", --  21:             6
        17  => "10000001", --  24:             pop ra
        18  => "00010100", --  25:             sub rb, ra
        19  => "11000000", --  26:             jmp @mdc_loop
        20  => "00000110", --  26:             6
        21  => "10000001", --  29:             pop ra
        22  => "10001111", --  30:             ld rd, @io
        23  => "11111111", --  30:             255
        24  => "10100011", --  31:             str ra, [rd]
        25  => "11110000", --  32:             halt
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
