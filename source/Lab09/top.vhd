library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity top is
    Port ( CLK       : in  STD_LOGIC;
           SPI_MISO  : in  STD_LOGIC;
           SPI_MOSI  : out STD_LOGIC;
           SPI_SCK   : out STD_LOGIC;
           AMP_CS    : out STD_LOGIC;
           AMP_SHDN  : out STD_LOGIC;
           AD_CONV   : out STD_LOGIC;
           LEDS      : out STD_LOGIC_VECTOR(7 downto 0);
           -- dispositivos SPI desabilitados (Tabela 10-4 do UG230)
           SPI_SS_B    : out STD_LOGIC;
           DAC_CS      : out STD_LOGIC;
           SF_CE0      : out STD_LOGIC;
           FPGA_INIT_B : out STD_LOGIC);
end top;

architecture Structural of top is
begin

	u_adc_ctrl : entity work.adc_ctrl(Behavioral)
		port map (
			CLK50    => CLK,
			SPI_MISO => SPI_MISO,
			SPI_MOSI => SPI_MOSI,
			SPI_SCK  => SPI_SCK,
			AMP_CS   => AMP_CS,
			AMP_SHDN => AMP_SHDN,
			AD_CONV  => AD_CONV,
			LEDS     => LEDS
		);

	-- desabilita os outros dispositivos do barramento SPI para evitar contencao
	SPI_SS_B    <= '1';
	DAC_CS      <= '1';
	SF_CE0      <= '1';
	FPGA_INIT_B <= '0';

end Structural;
