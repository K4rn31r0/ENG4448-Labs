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

    -- testinst.asm
    signal ram : RAM_t := (
        0   => "11000000", --   1:            .global @start
        1   => "00010000", --   1:            jmp 16
        2   => "11111110", --   2:            .byte 0xfe
        3   => "00000000", -- 
        4   => "00000000", -- 
        5   => "00000000", -- 
        6   => "00000000", -- 
        7   => "00000000", -- 
        8   => "00000000", -- 
        9   => "00000000", -- 
        10  => "00000000", -- 
        11  => "00000000", -- 
        12  => "00000000", -- 
        13  => "00000000", -- 
        14  => "00000000", -- 
        15  => "00000000", -- 
        16  => "10000011", --   8: start:     ld ra, 0x14
        17  => "00010100", --   8: start:     20
        18  => "10000111", --   9:            ld rb, 0x0a
        19  => "00001010", --   9:            10
        20  => "10001011", --  10:            ld rc, @vala
        21  => "00001100", --  10:            12
        22  => "10001111", --  11:            ld rd, @valb
        23  => "01111111", --  11:            127
        24  => "00000110", --  13:            add rb, rc
        25  => "00000111", --  14:            add rb, rd
        26  => "00010100", --  15:            sub rb, ra
        27  => "00010111", --  16:            sub rb, rd
        28  => "01010000", --  18:            not ra
        29  => "10010001", --  20:            ldr ra, [rb]
        30  => "10100010", --  21:            str ra, [rc]
        31  => "11000000", --  22:            jmp @start
        32  => "00010000", --  22:            16
        33  => "00000000", -- 
        34  => "00000000", -- 
        35  => "00000000", -- 
        36  => "00000000", -- 
        37  => "00000000", -- 
        38  => "00000000", -- 
        39  => "00000000", -- 
        40  => "00000000", -- 
        41  => "00000000", -- 
        42  => "00000000", -- 
        43  => "00000000", -- 
        44  => "00000000", -- 
        45  => "00000000", -- 
        46  => "00000000", -- 
        47  => "00000000", -- 
        48  => "00000001", --  26: testinstr: add ra, rb
        49  => "00011011", --  27:            sub rc, rd
        50  => "00100000", --  28:            inc ra
        51  => "00100100", --  29:            inc rb
        52  => "00101000", --  30:            inc rc
        53  => "00101100", --  31:            inc rd
        54  => "00100001", --  32:            dec ra
        55  => "00100101", --  33:            dec rb
        56  => "00101001", --  34:            dec rc
        57  => "00101101", --  35:            dec rd
        58  => "00110001", --  36:            and ra, rb
        59  => "01001011", --  37:            or  rc, rd
        60  => "01010000", --  38:            not ra
        61  => "01100011", --  39:            xor ra, rd
        62  => "01111000", --  40:            rol rc
        63  => "01110101", --  41:            ror rb
        64  => "01111110", --  42:            lsl rd
        65  => "01111011", --  43:            lsr rc
        66  => "10000000", --  44:            push ra
        67  => "10000101", --  45:            pop rb
        68  => "10001010", --  46:            st  rc, 0xf0
        69  => "11110000", --  46:            240
        70  => "10000111", --  47:            ld  rb, 0xf0
        71  => "11110000", --  47:            240
        72  => "10010001", --  48:            ldr ra, [rb]
        73  => "10100110", --  49:            str rb, [rc]
        74  => "10111011", --  50:            mov rc, rd
        75  => "11000000", --  51:            jmp 42
        76  => "00101010", --  51:            42
        77  => "11000000", --  52:            jmp 0x30
        78  => "00110000", --  52:            48
        79  => "11000000", --  53:            jmp @testinstr
        80  => "00110000", --  53:            48
        81  => "11000001", --  54:            jmpr ra
        82  => "11000101", --  55:            jmpr rb
        83  => "11001001", --  56:            jmpr rc
        84  => "11001101", --  57:            jmpr rd
        85  => "11000010", --  58:            bz  ra
        86  => "11000111", --  59:            bnz rb
        87  => "11011000", --  60:            bcs rc
        88  => "11011101", --  61:            bcc rd
        89  => "11010010", --  62:            beq ra
        90  => "11010111", --  63:            bneq rb
        91  => "11101000", --  64:            bgt rc
        92  => "11101101", --  65:            blt rd
        93  => "11110000", --  66:            halt
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
