library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx_top is
    Port (
        clk   : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        rx    : in  STD_LOGIC;
        sseg  : out STD_LOGIC_VECTOR(6 downto 0);
        sel   : out STD_LOGIC
    );
end uart_rx_top;

architecture Behavioral of uart_rx_top is

    --------------------------------------------------------------------
    -- Componentes
    --------------------------------------------------------------------
    component uart_rx
        Port (
            clk          : in  STD_LOGIC;
            reset        : in  STD_LOGIC;
            rx           : in  STD_LOGIC;
            rx_data      : out STD_LOGIC_VECTOR(7 downto 0);
            rx_done_tick : out STD_LOGIC
        );
    end component;

    component sseg_controller
        Port (
            clk       : in  STD_LOGIC;
            rst       : in  STD_LOGIC;
            hex0      : in  STD_LOGIC_VECTOR(3 downto 0);
            hex1      : in  STD_LOGIC_VECTOR(3 downto 0);
            sseg      : out STD_LOGIC_VECTOR(6 downto 0);
            digit_sel : out STD_LOGIC
        );
    end component;

    --------------------------------------------------------------------
    -- Sinais internos
    --------------------------------------------------------------------
    signal rx_data_int      : STD_LOGIC_VECTOR(7 downto 0);
    signal rx_done_tick_int : STD_LOGIC;

    signal display_byte     : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal hex0_display     : STD_LOGIC_VECTOR(3 downto 0);
    signal hex1_display     : STD_LOGIC_VECTOR(3 downto 0);

begin

    --------------------------------------------------------------------
    -- Instância do receptor UART
    --------------------------------------------------------------------
    uart_rx_unit : uart_rx
        port map (
            clk          => clk,
            reset        => reset,
            rx           => rx,
            rx_data      => rx_data_int,
            rx_done_tick => rx_done_tick_int
        );

    --------------------------------------------------------------------
    -- Guarda o último caractere útil recebido
    -- Ignora LF = 0x0A e CR = 0x0D
    --------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            display_byte <= (others => '0');

        elsif rising_edge(clk) then
            if rx_done_tick_int = '1' then
                if (rx_data_int /= x"0A") and (rx_data_int /= x"0D") then
                    display_byte <= rx_data_int;
                end if;
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- Separa o byte em dois nibbles para o display
    --------------------------------------------------------------------
    hex0_display <= display_byte(3 downto 0);  -- nibble baixo
    hex1_display <= display_byte(7 downto 4);  -- nibble alto

    --------------------------------------------------------------------
    -- Instância do controlador do display de 7 segmentos
    --------------------------------------------------------------------
    sseg_unit : sseg_controller
        port map (
            clk       => clk,
            rst       => reset,
            hex0      => hex0_display,
            hex1      => hex1_display,
            sseg      => sseg,
            digit_sel => sel
        );

end Behavioral;