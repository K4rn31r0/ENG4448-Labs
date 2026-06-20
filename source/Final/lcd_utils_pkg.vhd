library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

package lcd_utils_pkg is

    type rom_str is array(0 to 31) of std_logic_vector(3 downto 0); -- linha com 16 chars / 32bits
    type TEXT_MAP_ROM_t is array (0 to 255) of std_logic_vector(8*16-1 downto 0);

    function to_std_logic_vector(a : string) return rom_str;
    function to_std_logic_vector(a : string) return std_logic_vector;
    
    function decimal_size(n: integer) return integer;
    function to_bcd(Binary : unsigned) return unsigned;

    constant STR_ADD  : rom_str := to_std_logic_vector("add Rx, Ry      ");
    constant STR_SUB  : rom_str := to_std_logic_vector("sub Rx, Ry      ");
    constant STR_INC  : rom_str := to_std_logic_vector("inc Rx          ");
    constant STR_INCC : rom_str := to_std_logic_vector("incc Rx         ");
    constant STR_DEC  : rom_str := to_std_logic_vector("dec Rx          ");
    constant STR_DECC : rom_str := to_std_logic_vector("decc Rx         ");
    constant STR_AND  : rom_str := to_std_logic_vector("AND Rx, Ry      ");
    constant STR_OR   : rom_str := to_std_logic_vector("OR Rx, Ry       ");
    constant STR_NOT  : rom_str := to_std_logic_vector("NOT Rx          ");
    constant STR_XOR  : rom_str := to_std_logic_vector("XOR Rx, Ry      ");
    constant STR_ROL  : rom_str := to_std_logic_vector("ROL Rx          ");
    constant STR_ROR  : rom_str := to_std_logic_vector("ROR Rx          ");
    constant STR_LSL  : rom_str := to_std_logic_vector("lsl Rx          ");
    constant STR_LSR  : rom_str := to_std_logic_vector("lsr Rx          ");
    constant STR_PUSH : rom_str := to_std_logic_vector("push Rx         ");
    constant STR_POP  : rom_str := to_std_logic_vector("pop Rx          ");
    constant STR_LD   : rom_str := to_std_logic_vector("ld Rx, 0x--     ");
    constant STR_LDR  : rom_str := to_std_logic_vector("ldr Rx, [Ry]    ");
    constant STR_STR  : rom_str := to_std_logic_vector("str Rx, [Ry]    ");
    constant STR_JMP  : rom_str := to_std_logic_vector("jmp 0x--        ");
    constant STR_JMPR : rom_str := to_std_logic_vector("jmpr Rx         ");
    constant STR_BZ   : rom_str := to_std_logic_vector("bz Rx           ");
    constant STR_BNZ  : rom_str := to_std_logic_vector("bnz Rx          ");
    constant STR_BCS  : rom_str := to_std_logic_vector("bcs Rx          ");
    constant STR_BCC  : rom_str := to_std_logic_vector("bcc Rx          ");
    constant STR_BEQ  : rom_str := to_std_logic_vector("beq Rx          ");
    constant STR_BNEQ : rom_str := to_std_logic_vector("bneq Rx         ");
    constant STR_BGT  : rom_str := to_std_logic_vector("bgt Rx          ");
    constant STR_BGEZ : rom_str := to_std_logic_vector("bgez Rx         ");
    constant STR_BLT  : rom_str := to_std_logic_vector("blt Rx          ");
    constant STR_BLEZ : rom_str := to_std_logic_vector("blez Rx         "); 
    constant STR_HALT : rom_str := to_std_logic_vector("halt            ");

    -- ROM de opcodes
    constant TEXT_MAP_ROM : TEXT_MAP_ROM_t := (
        0 => to_std_logic_vector("add RA, RA      "),
        1 => to_std_logic_vector("add RA, RB      "),
        2 => to_std_logic_vector("add RA, RC      "),
        3 => to_std_logic_vector("add RA, RD      "),
        4 => to_std_logic_vector("add RB, RA      "),
        5 => to_std_logic_vector("add RB, RB      "),
        6 => to_std_logic_vector("add RB, RC      "),
        7 => to_std_logic_vector("add RB, RD      "),
        8 => to_std_logic_vector("add RC, RA      "),
        -- etc.
        240 => to_std_logic_vector("halt            "),
        others => to_std_logic_vector("invalid instr.  ")
    );

end package lcd_utils_pkg;

package body lcd_utils_pkg is

	 -- String para rom_str
    function to_std_logic_vector(a : string) return rom_str is
        variable chr2slv               : std_logic_vector(7 downto 0);
        variable ret                   : rom_str;
    begin
        for i in a'range loop
            chr2slv              := std_logic_vector(to_unsigned(character'pos(a(i)), 8));
            ret(2 * (i - 1) + 0) := chr2slv(7 downto 4);
            ret(2 * (i - 1) + 1) := chr2slv(3 downto 0);
        end loop;
        return ret;
    end function to_std_logic_vector;

    -- String para std_logic_vector linear
    function to_std_logic_vector(a : string) return std_logic_vector is
        variable ret : std_logic_vector(a'length*8-1 downto 0);
    begin
        for i in a'range loop
            ret(i*8+7 downto i*8) := std_logic_vector(to_unsigned(character'pos(a(i)), 8));
        end loop;
        return ret;
    end function to_std_logic_vector;

    -- Aux. matematica (tamanho decimal)
    function decimal_size(n: integer) return integer is
    begin
        if n = 0 then return 1; end if;
        return integer(ceil(log10(real(n + 1))));
    end function decimal_size;

    -- Binario para BCD
    function to_bcd(Binary : unsigned) return unsigned is
        variable b             : unsigned(Binary'length - 1 downto 0) := Binary;
        constant DIGITS        : natural := decimal_size(2 ** Binary'length - 1);
        variable bcd           : unsigned(DIGITS * 4 - 1 downto 0) := (others => '0');
    begin
        for i in b'range loop
            for d in 0 to DIGITS - 1 loop
                if bcd(d * 4 + 3 downto d * 4) >= 5 then 
                    bcd(d * 4 + 3 downto d * 4) := bcd(d * 4 + 3 downto d * 4) + 3;
                end if;
            end loop;
            bcd := bcd(bcd'left - 1 downto 0) & b(b'left);
            b   := b(b'left - 1 downto 0) & '0';
        end loop; 
        return bcd;
    end function;

end package body lcd_utils_pkg;
