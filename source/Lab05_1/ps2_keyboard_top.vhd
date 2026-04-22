library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ps2_keyboard_top is
    Port (
        clk      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        ps2_clk  : in  STD_LOGIC;
        ps2_data : in  STD_LOGIC;
        led_erro : out STD_LOGIC
    );
end ps2_keyboard_top;

architecture Behavioral of ps2_keyboard_top is

    type state_t is (idle, receiving, parity, stopbit);
    signal state : state_t := idle;

    signal bit_count        : integer range 0 to 7 := 0;
    signal data_reg         : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal parity_reg       : STD_LOGIC := '0';
    signal last_byte_reg    : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal parity_error_reg : STD_LOGIC := '0';
    signal rx_done_reg      : STD_LOGIC := '0';

    signal ps2_clk_sync_0   : STD_LOGIC := '1';
    signal ps2_clk_sync_1   : STD_LOGIC := '1';
    signal ps2_clk_prev     : STD_LOGIC := '1';
    signal ps2_data_sync_0  : STD_LOGIC := '1';
    signal ps2_data_sync_1  : STD_LOGIC := '1';

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

    process(clk, reset)
    begin
        if reset = '1' then
            state            <= idle;
            bit_count        <= 0;
            data_reg         <= (others => '0');
            parity_reg       <= '0';
            last_byte_reg    <= (others => '0');
            parity_error_reg <= '0';
            rx_done_reg      <= '0';

            ps2_clk_sync_0   <= '1';
            ps2_clk_sync_1   <= '1';
            ps2_clk_prev     <= '1';
            ps2_data_sync_0  <= '1';
            ps2_data_sync_1  <= '1';

        elsif rising_edge(clk) then

            -- sincronização dos sinais PS/2 no domínio do clock principal
            ps2_clk_sync_0  <= ps2_clk;
            ps2_clk_sync_1  <= ps2_clk_sync_0;
            ps2_clk_prev    <= ps2_clk_sync_1;

            ps2_data_sync_0 <= ps2_data;
            ps2_data_sync_1 <= ps2_data_sync_0;

            rx_done_reg <= '0';

            -- avança a FSM somente na borda de descida de ps2_clk, detectada internamente
            if (ps2_clk_prev = '1' and ps2_clk_sync_1 = '0') then

                case state is

                    when idle =>
                        bit_count <= 0;

                        -- start bit deve ser 0
                        if ps2_data_sync_1 = '0' then
                            state <= receiving;
                        end if;

                    when receiving =>
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
                        last_byte_reg <= data_reg;
                        rx_done_reg <= '1';

                        -- stop bit deve ser 1
                        if ps2_data_sync_1 = '1' then
                            if odd_parity_ok(data_reg, parity_reg) = '1' then
                                parity_error_reg <= '0';
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

    led_erro <= parity_error_reg;

end Behavioral;