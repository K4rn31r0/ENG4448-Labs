library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        rx          : in  STD_LOGIC;
        rx_data     : out STD_LOGIC_VECTOR(7 downto 0);
        rx_done_tick: out STD_LOGIC
    );
end uart_rx;

architecture Behavioral of uart_rx is

    -- 50 MHz / 115200 bps ≈ 434 clocks por bit
    constant CLKS_PER_BIT : integer := 434;

    type state_t is (idle, startbit, data, stopbit, done);
    signal state_reg : state_t := idle;

    signal baud_count  : integer range 0 to CLKS_PER_BIT-1 := 0;
    signal bit_index   : integer range 0 to 7 := 0;

    signal rx_data_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal rx_done_reg : STD_LOGIC := '0';

    -- Sincronização da entrada assíncrona rx
    signal rx_sync_0 : STD_LOGIC := '1';
    signal rx_sync_1 : STD_LOGIC := '1';

begin

    process(clk, reset)
    begin
        if reset = '1' then
            state_reg   <= idle;
            baud_count  <= 0;
            bit_index   <= 0;
            rx_data_reg <= (others => '0');
            rx_done_reg <= '0';
            rx_sync_0   <= '1';
            rx_sync_1   <= '1';

        elsif rising_edge(clk) then

            -- Sempre sincroniza rx com o clock da placa
            rx_sync_0 <= rx;
            rx_sync_1 <= rx_sync_0;

            -- Default: pulso de done só dura 1 ciclo
            rx_done_reg <= '0';

            case state_reg is

                when idle =>
                    baud_count <= 0;
                    bit_index  <= 0;

                    -- Linha idle = '1'
                    -- Start bit = transição para '0'
                    if rx_sync_1 = '0' then
                        state_reg <= startbit;
                    end if;

                when startbit =>
                    -- Espera meio bit para amostrar o centro do start bit
                    if baud_count = (CLKS_PER_BIT/2 - 1) then
                        baud_count <= 0;

                        -- Se ainda estiver em 0, start bit válido
                        if rx_sync_1 = '0' then
                            state_reg <= data;
                        else
                            -- falso start, volta para idle
                            state_reg <= idle;
                        end if;
                    else
                        baud_count <= baud_count + 1;
                    end if;

                when data =>
                    -- Espera 1 bit inteiro entre amostragens
                    if baud_count = CLKS_PER_BIT - 1 then
                        baud_count <= 0;

                        -- UART envia LSB first
                        rx_data_reg(bit_index) <= rx_sync_1;

                        if bit_index = 7 then
                            bit_index <= 0;
                            state_reg <= stopbit;
                        else
                            bit_index <= bit_index + 1;
                        end if;
                    else
                        baud_count <= baud_count + 1;
                    end if;

                when stopbit =>
                    if baud_count = CLKS_PER_BIT - 1 then
                        baud_count <= 0;

                        -- Stop bit deve ser '1'
                        if rx_sync_1 = '1' then
                            state_reg <= done;
                        else
                            -- Frame inválido, descarta e volta
                            state_reg <= idle;
                        end if;
                    else
                        baud_count <= baud_count + 1;
                    end if;

                when done =>
                    rx_done_reg <= '1';
                    state_reg <= idle;

                when others =>
                    state_reg <= idle;

            end case;
        end if;
    end process;

    rx_data <= rx_data_reg;
    rx_done_tick <= rx_done_reg;

end Behavioral;