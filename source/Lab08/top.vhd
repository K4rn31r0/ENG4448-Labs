library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity top is
    Port ( CLK : in  STD_LOGIC;
			  DAC_CLR : out STD_LOGIC;
           SPI_SCK : out  STD_LOGIC;
           DAC_CS : out  STD_LOGIC;
           SPI_MOSI : out  STD_LOGIC;
           SPI_SS_B : out  STD_LOGIC;
           AMP_CS : out  STD_LOGIC;
           AD_CONV : out  STD_LOGIC;
           SF_CE0 : out  STD_LOGIC;
           FPGA_INIT_B : out  STD_LOGIC);
end top;

architecture Structural of top is
begin

	u_dac_ctrl : entity work.dac_ctrl(Behavioral)
		port map (
			CLK50 => CLK,
			SPI_MOSI => SPI_MOSI,
			DAC_CS => DAC_CS,
			SPI_SCK => SPI_SCK,
			DAC_CLR => DAC_CLR
		);
	
	-- outros dispositivos
	SPI_SS_B <= '1';
	AMP_CS <= '1';
	AD_CONV <= '0';
	SF_CE0 <= '1';
	FPGA_INIT_B <= '0';

end Structural;

