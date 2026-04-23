library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ps2_keyboard_top_tb is
end ps2_keyboard_top_tb;

architecture behavior of ps2_keyboard_top_tb is

    component ps2_keyboard_top
        Port (
            clk      : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            ps2_clk  : in  STD_LOGIC;
            ps2_data : in  STD_LOGIC;
            sseg     : out STD_LOGIC_VECTOR(6 downto 0);
            sel      : out STD_LOGIC;
            led_erro : out STD_LOGIC
        );
    end component;

    -- Inputs
    signal clk      : STD_LOGIC := '0';
    signal reset    : STD_LOGIC := '0';
    signal ps2_clk  : STD_LOGIC := '1';
    signal ps2_data : STD_LOGIC := '1';

    -- Outputs
    signal sseg     : STD_LOGIC_VECTOR(6 downto 0);
    signal sel      : STD_LOGIC;
    signal led_erro : STD_LOGIC;

    constant clk_period : time := 20 ns;  -- 50 MHz

    -- Calcula o bit de paridade ímpar para um byte
    function odd_parity_bit(
        data_b : STD_LOGIC_VECTOR(7 downto 0)
    ) return STD_LOGIC is
        variable x : STD_LOGIC := '0';
    begin
        for i in data_b'range loop
            x := x xor data_b(i);
        end loop;

        -- Se os dados já têm número ímpar de 1s, o bit de paridade deve ser 0.
        -- Se têm número par, o bit de paridade deve ser 1.
        return not x;
    end function;

begin

    uut: ps2_keyboard_top
        port map (
            clk      => clk,
            reset    => reset,
            ps2_clk  => ps2_clk,
            ps2_data => ps2_data,
            sseg     => sseg,
            sel      => sel,
            led_erro => led_erro
        );

    -- Clock principal da FPGA
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    stim_proc: process

        procedure send_bit(b : in STD_LOGIC) is
        begin
            -- Coloca o dado enquanto o clock PS/2 está em nível alto
            ps2_data <= b;
            wait for 10 us;

            -- Borda de descida: o receptor deve ler aqui
            ps2_clk <= '0';
            wait for 40 us;

            -- Volta para nível alto
            ps2_clk <= '1';
            wait for 40 us;
        end procedure;

        procedure send_frame(data_byte : in STD_LOGIC_VECTOR(7 downto 0)) is
            variable p : STD_LOGIC;
        begin
            p := odd_parity_bit(data_byte);

            -- start bit
            send_bit('0');

            -- 8 bits de dados, LSB first
            for i in 0 to 7 loop
                send_bit(data_byte(i));
            end loop;

            -- bit de paridade ímpar
            send_bit(p);

            -- stop bit
            send_bit('1');

            -- Idle
            ps2_data <= '1';
            ps2_clk  <= '1';
            wait for 100 us;
        end procedure;

    begin
        -- Reset inicial
        reset <= '1';
        ps2_clk <= '1';
        ps2_data <= '1';
        wait for 200 ns;

        reset <= '0';
        wait for 100 us;

        ----------------------------------------------------------------
        -- Exemplo do enunciado: Shift + F
        -- Shift = 12
        -- F     = 2B
        ----------------------------------------------------------------

        -- Envia Shift (12)
        send_frame(x"12");

        -- Envia F (2B)
        send_frame(x"2B");

        wait for 500 us;

    end process;

end behavior;