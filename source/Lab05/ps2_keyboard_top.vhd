library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ps2_keyboard_top is
    Port (
        clk      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        ps2_clk  : in  STD_LOGIC;
        ps2_data : in  STD_LOGIC;
        sseg     : out STD_LOGIC_VECTOR(6 downto 0);
        sel      : out STD_LOGIC;
        led_erro : out STD_LOGIC
    );
end ps2_keyboard_top;

architecture Behavioral of ps2_keyboard_top is

    --------------------------------------------------------------------
    -- Componente do display
    --------------------------------------------------------------------
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
    -- FSM do receptor PS/2
    --------------------------------------------------------------------
    type state_t is (idle, receiving, parity, stopbit);
    signal state : state_t := idle;

    signal bit_count        : integer range 0 to 7 := 0;
    signal data_reg         : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal parity_reg       : STD_LOGIC := '0';
    signal parity_error_reg : STD_LOGIC := '0';

    --------------------------------------------------------------------
    -- Sincronização dos sinais PS/2 no domínio de clk
    --------------------------------------------------------------------
    signal ps2_clk_sync_0  : STD_LOGIC := '1';
    signal ps2_clk_sync_1  : STD_LOGIC := '1';
    signal ps2_clk_prev    : STD_LOGIC := '1';
    signal ps2_data_sync_0 : STD_LOGIC := '1';
    signal ps2_data_sync_1 : STD_LOGIC := '1';

    --------------------------------------------------------------------
    -- Guarda os dois últimos bytes válidos recebidos
    --------------------------------------------------------------------
    signal byte0_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); -- mais recente
    signal byte1_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); -- anterior

    --------------------------------------------------------------------
    -- Alternância entre os dois bytes a cada 2 segundos
    -- 50 MHz * 2 s = 100.000.000 ciclos
    --------------------------------------------------------------------
    signal display_toggle_counter : unsigned(26 downto 0) := (others => '0');
    signal display_toggle         : STD_LOGIC := '0';

    --------------------------------------------------------------------
    -- Byte atualmente exibido e nibbles para o display
    --------------------------------------------------------------------
    signal displayed_byte : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal hex0_display   : STD_LOGIC_VECTOR(3 downto 0);
    signal hex1_display   : STD_LOGIC_VECTOR(3 downto 0);

    --------------------------------------------------------------------
    -- Função de verificação de paridade ímpar
    -- Retorna '1' se (dados + bit de paridade) tiver número ímpar de 1s
    --------------------------------------------------------------------
    function odd_parity_ok(
        data_b   : STD_LOGIC_VECTOR(7 downto 0);
        parity_b : STD_LOGIC
    ) return STD_LOGIC is
        variable x : STD_LOGIC := '0';
    begin
        for i in data_b'range loop
            x := x xor data_b(i);
        end loop;
        return x xor parity_b;
    end function;

begin

    --------------------------------------------------------------------
    -- Processo 1: receptor PS/2
    --------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            state            <= idle;
            bit_count        <= 0;
            data_reg         <= (others => '0');
            parity_reg       <= '0';
            parity_error_reg <= '0';

            ps2_clk_sync_0   <= '1';
            ps2_clk_sync_1   <= '1';
            ps2_clk_prev     <= '1';
            ps2_data_sync_0  <= '1';
            ps2_data_sync_1  <= '1';

            byte0_reg        <= (others => '0');
            byte1_reg        <= (others => '0');

        elsif rising_edge(clk) then

            -- sincroniza os sinais vindos do teclado PS/2
            ps2_clk_sync_0  <= ps2_clk;
            ps2_clk_sync_1  <= ps2_clk_sync_0;
            ps2_clk_prev    <= ps2_clk_sync_1;

            ps2_data_sync_0 <= ps2_data;
            ps2_data_sync_1 <= ps2_data_sync_0;

            -- avança a FSM apenas quando detecta borda de descida do ps2_clk
            if (ps2_clk_prev = '1' and ps2_clk_sync_1 = '0') then

                case state is

                    when idle =>
                        bit_count <= 0;

                        -- start bit deve ser 0
                        if ps2_data_sync_1 = '0' then
                            state <= receiving;
                        end if;

                    when receiving =>
                        -- PS/2 envia LSB first
                        data_reg(bit_count) <= ps2_data_sync_1;

                        if bit_count = 7 then
                            bit_count <= 0;
                            state <= parity;
                        else
                            bit_count <= bit_count + 1;
                        end if;

                    when parity =>
                        parity_reg <= ps2_data_sync_1;
                        state <= stopbit;

                    when stopbit =>
                        -- stop bit deve ser 1
                        if ps2_data_sync_1 = '1' then
                            -- paridade correta
                            if odd_parity_ok(data_reg, parity_reg) = '1' then
                                parity_error_reg <= '0';

                                -- desloca os bytes válidos recebidos
                                if (data_reg /= x"F0") and (data_reg /= x"E0") then
                                    byte1_reg <= byte0_reg;
                                    byte0_reg <= data_reg;
                                end if;

                            else
                                parity_error_reg <= '1';
                            end if;
                        else
                            parity_error_reg <= '1';
                        end if;

                        state <= idle;

                    when others =>
                        state <= idle;

                end case;

            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- Processo 2: alternância entre os dois últimos bytes a cada 2 segundos
    --------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            display_toggle_counter <= (others => '0');
            display_toggle <= '0';

        elsif rising_edge(clk) then
            if display_toggle_counter = to_unsigned(99999999, display_toggle_counter'length) then
                display_toggle_counter <= (others => '0');
                display_toggle <= not display_toggle;
            else
                display_toggle_counter <= display_toggle_counter + 1;
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- Seleção do byte a ser mostrado
    --------------------------------------------------------------------
    displayed_byte <= byte0_reg when display_toggle = '0' else byte1_reg;

    -- nibble baixo no hex0, nibble alto no hex1
    hex0_display <= displayed_byte(3 downto 0);
    hex1_display <= displayed_byte(7 downto 4);

    --------------------------------------------------------------------
    -- Instância do controlador do display de 7 segmentos
    --------------------------------------------------------------------
    display_unit : sseg_controller
        port map (
            clk       => clk,
            rst       => reset,
            hex0      => hex0_display,
            hex1      => hex1_display,
            sseg      => sseg,
            digit_sel => sel
        );

    --------------------------------------------------------------------
    -- Saída do LED de erro
    --------------------------------------------------------------------
    led_erro <= parity_error_reg;

end Behavioral;