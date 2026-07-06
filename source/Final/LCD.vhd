library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Controlador do display LCD (roda no clock de 50 MHz da FPGA).
--   Instancia a inicializacao (lcd_init) e a escrita dinamica (lcd_write) e
--   arbitra o barramento: enquanto o init nao termina, o LCD e controlado por
--   lcd_init; depois, por lcd_write.
-- Espelha o IR (linha 1) e a posicao 255 da RAM (linha 2).
entity LCD is
    Port ( CLK50   : in  STD_LOGIC;		-- 50 MHz (nao e o clock lento da CPU)
           RST     : in  STD_LOGIC;
           IR      : in  STD_LOGIC_VECTOR (7 downto 0);
           POS_255 : in  STD_LOGIC_VECTOR (7 downto 0);
           -- interface fisica do LCD (compartilha o barramento com a StrataFlash)
           SF_D    : out STD_LOGIC_VECTOR (11 downto 8);
           LCD_E   : out STD_LOGIC;
           LCD_RS  : out STD_LOGIC;
           LCD_RW  : out STD_LOGIC;
           SF_CE0  : out STD_LOGIC);
end LCD;

architecture Behavioral of LCD is

    signal init_done : STD_LOGIC;

    -- saidas do lcd_init
    signal data_init : STD_LOGIC_VECTOR(3 downto 0);
    signal e_init, rs_init, rw_init : STD_LOGIC;

    -- saidas do lcd_write
    signal data_wr : STD_LOGIC_VECTOR(3 downto 0);
    signal e_wr, rs_wr, rw_wr : STD_LOGIC;

begin

    u_init : entity work.lcd_init(Behavioral)
        port map (
            DATA_INIT     => data_init,
            LCD_E_INIT    => e_init,
            LCD_RS_INIT   => rs_init,
            LCD_RW_INIT   => rw_init,
            LCD_INIT_DONE => init_done,
            RST           => RST,
            CLK           => CLK50
        );

    u_write : entity work.lcd_write(Behavioral)
        port map (
            LCD_INIT_DONE => init_done,
            RST           => RST,
            CLK           => CLK50,
            IR            => IR,
            POS_255       => POS_255,
            DATA_OUT      => data_wr,
            LCD_E         => e_wr,
            LCD_RS        => rs_wr,
            LCD_RW        => rw_wr
        );

    -- mux: init controla o barramento ate terminar; depois quem controla e a escrita
    SF_D   <= data_init when init_done = '0' else data_wr;
    LCD_E  <= e_init    when init_done = '0' else e_wr;
    LCD_RS <= rs_init   when init_done = '0' else rs_wr;
    LCD_RW <= rw_init   when init_done = '0' else rw_wr;

    -- mantem a StrataFlash desabilitada (barramento SF_D compartilhado)
    SF_CE0 <= '1';

end Behavioral;
