library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dac_ctrl is
	 GENERIC( 
			  DIV_FACTOR 		: natural := 8; 	-- divisor de frequencia
			  SAMPLE_ROM_SIZE   : natural := 16 	-- # de amostras
	 );
    Port ( CLK50		  : in STD_LOGIC;
		   SPI_MOSI : out  STD_LOGIC;
           DAC_CS : out  STD_LOGIC;
           SPI_SCK : out  STD_LOGIC;
           DAC_CLR : out  STD_LOGIC);
end dac_ctrl;

architecture Behavioral of dac_ctrl is

	-- tipos
	subtype word32_t is STD_LOGIC_VECTOR(31 downto 0);
	subtype sample_t is STD_LOGIC_VECTOR(11 downto 0);
	type sample_rom_t is array (0 to SAMPLE_ROM_SIZE-1) of sample_t;
	
	-- ROM de 16 amostras gerada pelo lut_gen.py
	constant SAMPLE_ROM : sample_rom_t := (
		 x"FFF",  -- i=  0 : 4095
		 x"D39",  -- i=  1 : 3385
		 x"800",  -- i=  2 : 2048
		 x"5D5",  -- i=  3 : 1493
		 x"7FF",  -- i=  4 : 2047
		 x"A2A",  -- i=  5 : 2602
		 x"800",  -- i=  6 : 2048
		 x"2C6",  -- i=  7 :  710
		 x"000",  -- i=  8 :    0
		 x"2C6",  -- i=  9 :  710
		 x"7FF",  -- i= 10 : 2047
		 x"A2A",  -- i= 11 : 2602
		 x"800",  -- i= 12 : 2048
		 x"5D5",  -- i= 13 : 1493
		 x"7FF",  -- i= 14 : 2047
		 x"D39"   -- i= 15 : 3385
	);

	-- construindo a palavra SPI de 32 bits
	function build_spi_word(sample : sample_t) return word32_t is
		constant pad_8 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
		constant command_word : STD_LOGIC_VECTOR(3 downto 0) := "0011";
		constant dac_address : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
		constant pad_4 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
	begin
		return pad_8 & command_word & dac_address & sample & pad_4;
	end function;
	
	-- fsm
	type state_t is (IDLE, LOAD, SHIFT, CS_HI);
	signal state : state_t := IDLE;

	-- geracao do SPI_SCK
	signal div_counter : natural range 0 to DIV_FACTOR-1 := 0;
	signal spi_sck_r : STD_LOGIC := '0';
	signal sck_rise : STD_LOGIC := '0';
	signal sck_fall : STD_LOGIC := '0';
	
	-- controle SPI
	signal phase : natural range 0 to SAMPLE_ROM_SIZE-1 := 0;
	signal bit_cnt : natural range 0 to 31 := 31;
	signal shift_reg : word32_t := (others => '0');
	signal dac_cs_r : STD_LOGIC := '1';

begin

	DAC_CLR <= '1';
	SPI_SCK <= spi_sck_r;
	DAC_CS <= dac_cs_r;

	clk_div_proc : process(CLK50)
	begin
		if rising_edge(CLK50) then
			sck_rise <= '0';
			sck_fall <= '0';
			
			if div_counter = DIV_FACTOR-1 then
				div_counter <= 0;
				spi_sck_r <= not spi_sck_r;
				
				-- quando esse if roda, o spi_sck_r ainda tem o valor anterior
				if spi_sck_r <= '0' then
					sck_rise <= '1';	-- vai subir
				else
					sck_fall <= '1';	-- vai descer
				end if;
			else
				div_counter <= div_counter + 1;
			end if;
		end if;
	end process clk_div_proc;
	
	-- convencao: CPHA=0 CPOL=0
	fsm_proc : process(CLK50)
	begin
		if rising_edge(CLK50) then
			case state is
				
				when IDLE =>
					dac_cs_r <= '1';
					if sck_fall = '1' then
						state <= LOAD;
					end if;
				
				when LOAD =>
					shift_reg <= build_spi_word(SAMPLE_ROM(phase));
					bit_cnt <= 30; 	-- 30 em vez de 31 porque o primeiro bit vem agora
					dac_cs_r <= '0';	-- abaixar CS pra comecar a transmitir
					SPI_MOSI <= build_spi_word(SAMPLE_ROM(phase))(31);
					state <= SHIFT;	-- iniciar shifting imediatamente
					
				when SHIFT =>
					if sck_fall = '1' then
						shift_reg <= shift_reg(30 downto 0) & '0';
						SPI_MOSI <= shift_reg(30);		-- proximo bit apos shift
							
						if bit_cnt = 0 then
							state <= CS_HI;
						else
							bit_cnt <= bit_cnt - 1;
						end if;
					end if;
				
				when CS_HI =>
					if sck_rise = '1' then
						dac_cs_r <= '1';
						phase <= (phase+1) mod SAMPLE_ROM_SIZE;
						state <= IDLE;
					end if;
					
			end case;
		end if;
	end process fsm_proc;

end Behavioral;

