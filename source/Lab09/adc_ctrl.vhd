library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Controlador do circuito de captura analogica do Spartan-3E Starter Kit.
-- Fluxo:
--   1) configura o pre-amplificador LTC6912-1 com ganho -1 (uma vez);
--   2) dispara o ADC LTC1407A-1 (AD_CONV) e le os 14 bits do canal A (VINA);
--   3) acende os LEDs proporcionalmente a tensao de entrada.
-- Referencia: UG230, Capitulo 10 (Analog Capture Circuit).
entity adc_ctrl is
	GENERIC(
			  DIV_FACTOR : natural := 8	-- divisor de frequencia do SPI_SCK
	);
	Port ( CLK50    : in  STD_LOGIC;
	       SPI_MISO : in  STD_LOGIC;	-- dado serial vindo do ADC
	       SPI_MOSI : out STD_LOGIC;	-- dado serial para o amplificador
	       SPI_SCK  : out STD_LOGIC;
	       AMP_CS   : out STD_LOGIC;	-- chip-select do amplificador (ativo-baixo)
	       AMP_SHDN : out STD_LOGIC;	-- shutdown do amplificador (ativo-alto)
	       AD_CONV  : out STD_LOGIC;	-- inicia a conversao do ADC (ativo-alto)
	       LEDS     : out STD_LOGIC_VECTOR(7 downto 0));
end adc_ctrl;

architecture Behavioral of adc_ctrl is

	-- palavra de ganho do LTC6912-1: [B3 B2 B1 B0 A3 A2 A1 A0], B3 enviado primeiro.
	-- ganho -1 => codigo "0001" em cada canal (Tabela 10-2 do UG230).
	constant AMP_GAIN_WORD : STD_LOGIC_VECTOR(7 downto 0) := "00010001";

	-- # de ciclos de SPI_SCK por leitura do ADC (UG230 Fig. 10-6: sequencia de 34 ciclos)
	constant ADC_CYCLES : natural := 34;

	-- fsm
	type state_t is (AMP_CS_LOW, AMP_SHIFT, AMP_LATCH, ADC_PREP, ADC_READ, ADC_LATCH);
	signal state : state_t := AMP_CS_LOW;

	-- geracao do SPI_SCK (mesma tecnica do Lab08)
	signal div_counter : natural range 0 to DIV_FACTOR-1 := 0;
	signal spi_sck_r : STD_LOGIC := '0';
	signal sck_rise : STD_LOGIC := '0';
	signal sck_fall : STD_LOGIC := '0';

	-- controle do amplificador
	signal amp_cnt : natural range 0 to 7 := 0;
	signal amp_cs_r : STD_LOGIC := '1';
	signal spi_mosi_r : STD_LOGIC := '0';

	-- controle do ADC
	signal adc_conv_r : STD_LOGIC := '0';
	signal adc_cnt : natural range 0 to ADC_CYCLES-1 := 0;
	signal adc_shift : STD_LOGIC_VECTOR(ADC_CYCLES-1 downto 0) := (others => '0');

	-- saida
	signal led_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

begin

	AMP_SHDN <= '0';			-- amplificador sempre ativo
	SPI_SCK  <= spi_sck_r;
	AMP_CS   <= amp_cs_r;
	AD_CONV  <= adc_conv_r;
	SPI_MOSI <= spi_mosi_r;
	LEDS     <= led_reg;

	-- divisor de clock: gera SPI_SCK e os pulsos de borda (1 ciclo de CLK50 de largura)
	clk_div_proc : process(CLK50)
	begin
		if rising_edge(CLK50) then
			sck_rise <= '0';
			sck_fall <= '0';

			if div_counter = DIV_FACTOR-1 then
				div_counter <= 0;
				spi_sck_r <= not spi_sck_r;

				-- spi_sck_r ainda tem o valor anterior aqui
				if spi_sck_r = '0' then
					sck_rise <= '1';	-- vai subir
				else
					sck_fall <= '1';	-- vai descer
				end if;
			else
				div_counter <= div_counter + 1;
			end if;
		end if;
	end process clk_div_proc;

	-- convencao: CPOL=0 CPHA=0
	--   amplificador: amostra MOSI na subida  -> trocamos MOSI na descida
	--   ADC:          apresenta MISO na descida -> amostramos MISO na subida
	fsm_proc : process(CLK50)
		variable ch0 : signed(13 downto 0);
		variable lvl : integer range 0 to 16383;
		variable n   : integer range 0 to 8;
	begin
		if rising_edge(CLK50) then
			case state is

				-- ===== configuracao do amplificador =====
				when AMP_CS_LOW =>
					amp_cs_r <= '1';
					if sck_fall = '1' then
						amp_cs_r   <= '0';						-- abaixa CS com SCK baixo
						spi_mosi_r <= AMP_GAIN_WORD(7);		-- primeiro bit (B3)
						amp_cnt    <= 6;							-- proximo bit a apresentar
						state      <= AMP_SHIFT;
					end if;

				when AMP_SHIFT =>
					if sck_fall = '1' then
						spi_mosi_r <= AMP_GAIN_WORD(amp_cnt);
						if amp_cnt = 0 then
							state <= AMP_LATCH;					-- bit 0 apresentado
						else
							amp_cnt <= amp_cnt - 1;
						end if;
					end if;

				when AMP_LATCH =>
					-- a subida que amostra o bit 0 e onde latcheamos o ganho
					if sck_rise = '1' then
						amp_cs_r <= '1';							-- CS volta a High: ganho aplicado
						state    <= ADC_PREP;
					end if;

				-- ===== leitura do ADC =====
				when ADC_PREP =>
					adc_conv_r <= '0';
					adc_cnt    <= 0;
					-- assertamos AD_CONV com SCK baixo; a proxima subida sera o ciclo 1
					if sck_fall = '1' then
						adc_conv_r <= '1';
						state      <= ADC_READ;
					end if;

				when ADC_READ =>
					if sck_rise = '1' then
						adc_shift  <= adc_shift(ADC_CYCLES-2 downto 0) & SPI_MISO;
						adc_conv_r <= '0';						-- AD_CONV baixa apos a 1a subida
						if adc_cnt = ADC_CYCLES-1 then
							state <= ADC_LATCH;
						else
							adc_cnt <= adc_cnt + 1;
						end if;
					end if;

				when ADC_LATCH =>
					-- canal A (VINA) = primeira palavra de 14 bits apos 2 ciclos em Hi-Z.
					-- ciclo k capturado em adc_shift(ADC_CYCLES-k); canal A = ciclos 3..16.
					ch0 := signed(adc_shift(31 downto 18));
					-- ganho -1: tensao sobe => D fica mais negativo. Normaliza para 0..16383
					-- crescente com a tensao (VIN=0.4V -> 0 ; VIN=2.9V -> 16383).
					lvl := 8191 - to_integer(ch0);
					-- 8 LEDs proporcionais: 9 niveis (0..8) sobre o fundo de escala.
					n := (lvl * 9) / 16384;
					for i in 0 to 7 loop
						if i < n then
							led_reg(i) <= '1';
						else
							led_reg(i) <= '0';
						end if;
					end loop;
					state <= ADC_PREP;						-- proxima amostra

			end case;
		end if;
	end process fsm_proc;

end Behavioral;
