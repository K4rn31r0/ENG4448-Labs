library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dac_ctrl is
	 GENERIC( 
			  DIV_FACTOR 		: natural := 1; 	-- divisor de frequencia
			  SAMPLE_ROM_SIZE   : natural := 16 	-- # de amostras
	 );
    Port ( CLK50		  : in STD_LOGIC;
		   SPI_MOSI : out  STD_LOGIC;
           DAC_CS : out  STD_LOGIC;
           SPI_SCK : out  STD_LOGIC;
           DAC_CLR : out  STD_LOGIC);
end dac_ctrl;

architecture Behavioral of dac_ctrl is

	subtype byte_t is STD_LOGIC_VECTOR(7 downto 0);
	type sample_rom_t is array (natural range<>) of byte_t;
	

	signal div_counter : natural := 0;
	signal spi_sck_r : STD_LOGIC := 0;

begin

	SPI_SCK <= spi_sck_r;

	spi_sck_proc : process(CLK50)
	begin
		 if rising_edge(CLK50) then

            if div_counter = DIV_FACTOR-1 then
                spi_sck_r <= not spi_sck_r;
                div_counter <= 0;
            else
                div_counter <= div_counter + 1;
            end if;

        end if;
	end process spi_sck_proc;

end Behavioral;

