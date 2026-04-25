library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx_tb is
end uart_rx_tb;

architecture behavior of uart_rx_tb is

    component uart_rx
        Port (
            clk          : in  STD_LOGIC;
            reset        : in  STD_LOGIC;
            rx           : in  STD_LOGIC;
            rx_data      : out STD_LOGIC_VECTOR(7 downto 0);
            rx_done_tick : out STD_LOGIC
        );
    end component;

    -- Inputs
    signal clk          : STD_LOGIC := '0';
    signal reset        : STD_LOGIC := '0';
    signal rx           : STD_LOGIC := '1';

    -- Outputs
    signal rx_data      : STD_LOGIC_VECTOR(7 downto 0);
    signal rx_done_tick : STD_LOGIC;

    constant clk_period  : time := 20 ns;       -- 50 MHz
    constant bit_period  : time := 8680 ns;     -- ~ 1 / 115200 s

begin

    -- Unit Under Test
    uut: uart_rx
        port map (
            clk          => clk,
            reset        => reset,
            rx           => rx,
            rx_data      => rx_data,
            rx_done_tick => rx_done_tick
        );

    --------------------------------------------------------------------
    -- Clock principal da FPGA
    --------------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    --------------------------------------------------------------------
    -- Processo de estímulo
    --------------------------------------------------------------------
    stim_proc: process

        procedure send_uart_byte(data_byte : in STD_LOGIC_VECTOR(7 downto 0)) is
        begin
            -- Start bit
            rx <= '0';
            wait for bit_period;

            -- 8 bits de dados, LSB first
            for i in 0 to 7 loop
                rx <= data_byte(i);
                wait for bit_period;
            end loop;

            -- Stop bit
            rx <= '1';
            wait for bit_period;

            -- Pequeno tempo extra em idle entre frames
            rx <= '1';
            wait for bit_period;
        end procedure;

    begin
        ----------------------------------------------------------------
        -- Estado inicial
        ----------------------------------------------------------------
        rx <= '1';      -- idle
        reset <= '1';
        wait for 100 ns;

        reset <= '0';
        wait for 100 us;

        ----------------------------------------------------------------
        -- Envia "VHDL\n"
        -- V = 0x56
        -- H = 0x48
        -- D = 0x44
        -- L = 0x4C
        -- \n = 0x0A
        ----------------------------------------------------------------

        -- V
        send_uart_byte(x"56");
        wait for 20 us;
        assert rx_data = x"56"
            report "ERRO: byte recebido nao foi 0x56 (V)"
            severity error;

        -- H
        send_uart_byte(x"48");
        wait for 20 us;
        assert rx_data = x"48"
            report "ERRO: byte recebido nao foi 0x48 (H)"
            severity error;

        -- D
        send_uart_byte(x"44");
        wait for 20 us;
        assert rx_data = x"44"
            report "ERRO: byte recebido nao foi 0x44 (D)"
            severity error;

        -- L
        send_uart_byte(x"4C");
        wait for 20 us;
        assert rx_data = x"4C"
            report "ERRO: byte recebido nao foi 0x4C (L)"
            severity error;

        -- \n
        send_uart_byte(x"0A");
        wait for 20 us;
        assert rx_data = x"0A"
            report "ERRO: byte recebido nao foi 0x0A (LF)"
            severity error;

        report "Teste UART com VHDL\\n concluido com sucesso." severity note;

        wait for 100 us;

        assert false
            report "Fim da simulacao"
            severity failure;

    end process;

end behavior;