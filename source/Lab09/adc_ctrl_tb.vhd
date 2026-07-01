LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY adc_ctrl_tb IS
END adc_ctrl_tb;

ARCHITECTURE behavior OF adc_ctrl_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT adc_ctrl
    PORT(
         CLK50    : IN  std_logic;
         SPI_MISO : IN  std_logic;
         SPI_MOSI : OUT std_logic;
         SPI_SCK  : OUT std_logic;
         AMP_CS   : OUT std_logic;
         AMP_SHDN : OUT std_logic;
         AD_CONV  : OUT std_logic;
         LEDS     : OUT std_logic_vector(7 downto 0)
        );
    END COMPONENT;

   --Inputs
   signal CLK50    : std_logic := '0';
   signal SPI_MISO : std_logic := '0';

   --Outputs
   signal SPI_MOSI : std_logic;
   signal SPI_SCK  : std_logic;
   signal AMP_CS   : std_logic;
   signal AMP_SHDN : std_logic;
   signal AD_CONV  : std_logic;
   signal LEDS     : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLK50_period : time := 20 ns;

   -- Padrao de teste do ADC (34 bits, na ordem ciclo 1 -> ciclo 34):
   --   3 ciclos de lideranca | canal A (14 bits) | canal B (14 bits) | 3 ciclos
   -- O controlador extrai o canal A de adc_shift(30 downto 17), ou seja, dos
   -- ciclos 4..17; portanto o canal A deve comecar no ciclo 4 (3 bits antes).
   -- canal A = "10000000000000" = -8192 (two's complement) => VIN maxima => 8 LEDs.
   constant MISO_VEC : std_logic_vector(33 downto 0) :=
       "000" & "10000000000000" & "00000000000000" & "000";

BEGIN

	-- Instantiate the Unit Under Test (UUT)
   uut: adc_ctrl PORT MAP (
          CLK50    => CLK50,
          SPI_MISO => SPI_MISO,
          SPI_MOSI => SPI_MOSI,
          SPI_SCK  => SPI_SCK,
          AMP_CS   => AMP_CS,
          AMP_SHDN => AMP_SHDN,
          AD_CONV  => AD_CONV,
          LEDS     => LEDS
        );

   -- Clock process definitions
   CLK50_process :process
   begin
		CLK50 <= '0';
		wait for CLK50_period/2;
		CLK50 <= '1';
		wait for CLK50_period/2;
   end process;

   -- Modelo do ADC: emula a saida serial em SPI_MISO.
   -- O ADC apresenta o ciclo 1 quando AD_CONV sobe (SCK ainda baixo) e
   -- avanca um bit a cada borda de descida de SPI_SCK.
   miso_proc : process(SPI_SCK, AD_CONV)
      variable c : integer := 0;
   begin
      if rising_edge(AD_CONV) then
         c := 1;
         SPI_MISO <= MISO_VEC(33);				-- ciclo 1
      elsif falling_edge(SPI_SCK) then
         c := c + 1;
         if c <= 34 then
            SPI_MISO <= MISO_VEC(34 - c);		-- ciclo c
         else
            SPI_MISO <= '0';
         end if;
      end if;
   end process;

   -- Stimulus process
   stim_proc: process
   begin
      -- aguarda a configuracao do amplificador + algumas leituras do ADC
      wait for 60 us;
      -- canal A = -8192 => tensao maxima => todos os LEDs acesos
      assert LEDS = "11111111"
         report "Falha: LEDS esperado 11111111, ordem dos bits incorreta" severity error;
      report "END" severity note;
      assert false report "END" severity failure;
   end process;

END;
