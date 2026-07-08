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

    -- greatest.asm
    signal ram : RAM_t := (
        0   => "11000000", --   1:               .global @start
        1   => "00000111", --   1:               jmp 7
        2   => "00001111", --   5:               .byte 15
        3   => "00111000", --   6:               .byte 56
        4   => "00001001", --   7:               .byte 9
        5   => "11111100", --   8:               .byte 252
        6   => "01100011", --   9:               .byte 99
        7   => "10000011", --  13:               ld ra, @vector_start
        8   => "00000010", --  13:               2
        9   => "10000111", --  14:               ld rb, @vector_end
        10  => "00000111", --  14:               7
        11  => "10001011", --  15:               ld rc, 0x00
        12  => "00000000", --  15:               0
        13  => "10000000", --  18:               push ra
        14  => "00010001", --  19:               sub ra, rb
        15  => "10001111", --  20:               ld rd, @end
        16  => "00100000", --  20:               32
        17  => "11011110", --  21:               beq rd
        18  => "10000001", --  22:               pop ra
        19  => "10011100", --  24:               ldr rd, [ra]
        20  => "10001100", --  25:               push rd
        21  => "00011110", --  26:               sub rd, rc
        22  => "10001111", --  27:               ld rd, @new_greatest
        23  => "00011101", --  27:               29
        24  => "11101100", --  28:               bgt rd
        25  => "10001101", --  29:               pop rd
        26  => "00100000", --  32:               inc ra
        27  => "11000000", --  33:               jmp @loop
        28  => "00001101", --  33:               13
        29  => "10001001", --  36:               pop rc
        30  => "11000000", --  37:               jmp @next_iter
        31  => "00011010", --  37:               26
        32  => "10001101", --  40:               pop rd
        33  => "10001111", --  41:               ld rd, @io
        34  => "11111111", --  41:               255
        35  => "10101011", --  42:               str rc, [rd]
        36  => "11110000", --  43:               halt
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
