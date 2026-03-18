library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Parking_tb is
end Parking_tb;

architecture behavior of Parking_tb is

    component Parking
        Port (
            clk   : in  STD_LOGIC;
            reset : in  STD_LOGIC;
            a     : in  STD_LOGIC;
            b     : in  STD_LOGIC;
            z     : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    signal clk   : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal a     : STD_LOGIC := '0';
    signal b     : STD_LOGIC := '0';
    signal z     : STD_LOGIC_VECTOR (7 downto 0);

    constant clk_period : time := 10 ns;

    -- Procedimento auxiliar para aplicar um valor em a e b por 1 período de clock
    procedure set_ab(
        signal sa : out STD_LOGIC;
        signal sb : out STD_LOGIC;
        constant va : in STD_LOGIC;
        constant vb : in STD_LOGIC
    ) is
    begin
        sa <= va;
        sb <= vb;
        wait for clk_period;
    end procedure;

    -- Sequência completa de entrada: 00 -> 10 -> 11 -> 01 -> 00
    procedure enter_car(
        signal sa : out STD_LOGIC;
        signal sb : out STD_LOGIC
    ) is
    begin
        set_ab(sa, sb, '0', '0');
        set_ab(sa, sb, '1', '0');
        set_ab(sa, sb, '1', '1');
        set_ab(sa, sb, '0', '1');
        set_ab(sa, sb, '0', '0');
    end procedure;

    -- Sequência completa de saída: 00 -> 01 -> 11 -> 10 -> 00
    procedure exit_car(
        signal sa : out STD_LOGIC;
        signal sb : out STD_LOGIC
    ) is
    begin
        set_ab(sa, sb, '0', '0');
        set_ab(sa, sb, '0', '1');
        set_ab(sa, sb, '1', '1');
        set_ab(sa, sb, '1', '0');
        set_ab(sa, sb, '0', '0');
    end procedure;

    -- Carro tentou entrar, acionou os dois sensores e desistiu:
    -- 00 -> 10 -> 11 -> 10 -> 00
    procedure abort_entry(
        signal sa : out STD_LOGIC;
        signal sb : out STD_LOGIC
    ) is
    begin
        set_ab(sa, sb, '0', '0');
        set_ab(sa, sb, '1', '0');
        set_ab(sa, sb, '1', '1');
        set_ab(sa, sb, '1', '0');
        set_ab(sa, sb, '0', '0');
    end procedure;

begin

    uut: Parking
        port map (
            clk   => clk,
            reset => reset,
            a     => a,
            b     => b,
            z     => z
        );

    -- Geração de clock
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Estímulos
    stim_proc: process
    begin
        -- Reset inicial
        reset <= '1';
        a <= '0';
        b <= '0';
        wait for 2 * clk_period;

        reset <= '0';
        wait for 2 * clk_period;

        -- Entrar 5 carros
        enter_car(a, b);
        enter_car(a, b);
        enter_car(a, b);
        enter_car(a, b);
        enter_car(a, b);

        wait for 2 * clk_period;

        -- Sair 2 carros
        exit_car(a, b);
        exit_car(a, b);

        wait for 2 * clk_period;

        -- Carro tentou entrar e desistiu
        abort_entry(a, b);

        wait for 2 * clk_period;

        -- Sair 1 carro
        exit_car(a, b);

        wait for 2 * clk_period;

        -- Entrar 1 carro
        enter_car(a, b);

        wait for 4 * clk_period;

        wait;
    end process;

end behavior;