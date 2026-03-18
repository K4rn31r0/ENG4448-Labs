library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Parking is
    Port (
        clk   : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        a     : in  STD_LOGIC;
        b     : in  STD_LOGIC;
        z     : out STD_LOGIC_VECTOR (7 downto 0)
    );
end Parking;

architecture Behavioral of Parking is

    type state_type is (idle, e1, e2, e3, e4, s1, s2, s3, s4);
    signal current_state, next_state : state_type;

    signal count : integer range 0 to 8 := 0;

begin

    ----------------------------------------------------------------
    -- Registrador de estado + contador de carros
    ----------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= idle;
            count <= 0;

        elsif rising_edge(clk) then
            current_state <= next_state;

            case current_state is
                when e4 =>
                    if count < 8 then
                        count <= count + 1;
                    end if;

                when s4 =>
                    if count > 0 then
                        count <= count - 1;
                    end if;

                when others =>
                    null;
            end case;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Lógica de próximo estado
    ----------------------------------------------------------------
    process(current_state, a, b)
    begin
        next_state <= idle;

        case current_state is

            when idle =>
                case (a & b) is
                    when "00" => next_state <= idle;
                    when "10" => next_state <= e1;
                    when "01" => next_state <= s1;
                    when others => next_state <= idle; -- "11"
                end case;

            when e1 =>
                case (a & b) is
                    when "10" => next_state <= e1;
                    when "11" => next_state <= e2;
                    when others => next_state <= idle;
                end case;

            when e2 =>
                case (a & b) is
                    when "11" => next_state <= e2;
                    when "01" => next_state <= e3;
                    when others => next_state <= idle;
                end case;

            when e3 =>
                case (a & b) is
                    when "01" => next_state <= e3;
                    when "00" => next_state <= e4;
                    when others => next_state <= idle;
                end case;

            when e4 =>
                case (a & b) is
                    when "00" => next_state <= idle;
                    when "10" => next_state <= e1;
                    when "01" => next_state <= s1;
                    when others => next_state <= idle;
                end case;

            when s1 =>
                case (a & b) is
                    when "01" => next_state <= s1;
                    when "11" => next_state <= s2;
                    when others => next_state <= idle;
                end case;

            when s2 =>
                case (a & b) is
                    when "11" => next_state <= s2;
                    when "10" => next_state <= s3;
                    when others => next_state <= idle;
                end case;

            when s3 =>
                case (a & b) is
                    when "10" => next_state <= s3;
                    when "00" => next_state <= s4;
                    when others => next_state <= idle;
                end case;

            when s4 =>
                case (a & b) is
                    when "00" => next_state <= idle;
                    when "10" => next_state <= e1;
                    when "01" => next_state <= s1;
                    when others => next_state <= idle;
                end case;

        end case;
    end process;

    ----------------------------------------------------------------
    -- Saída: quantidade de LEDs acesos = quantidade de carros
    ----------------------------------------------------------------
    process(count)
    begin
        case count is
            when 0 => z <= "00000000";
            when 1 => z <= "00000001";
            when 2 => z <= "00000011";
            when 3 => z <= "00000111";
            when 4 => z <= "00001111";
            when 5 => z <= "00011111";
            when 6 => z <= "00111111";
            when 7 => z <= "01111111";
            when 8 => z <= "11111111";
            when others => z <= "00000000";
        end case;
    end process;

end Behavioral;