LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY top_tb IS
END top_tb;
 
ARCHITECTURE behavior OF top_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT top
    PORT(
         CLK : IN  std_logic;
         SPI_MISO : IN  std_logic;
         SPI_MOSI : OUT  std_logic;
         SPI_SCK : OUT  std_logic;
         AMP_CS : OUT  std_logic;
         AMP_SHDN : OUT  std_logic;
         AD_CONV : OUT  std_logic;
         LEDS : OUT  std_logic_vector(7 downto 0);
         SPI_SS_B : OUT  std_logic;
         DAC_CS : OUT  std_logic;
         SF_CE0 : OUT  std_logic;
         FPGA_INIT_B : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal SPI_MISO : std_logic := '0';

 	--Outputs
   signal SPI_MOSI : std_logic;
   signal SPI_SCK : std_logic;
   signal AMP_CS : std_logic;
   signal AMP_SHDN : std_logic;
   signal AD_CONV : std_logic;
   signal LEDS : std_logic_vector(7 downto 0);
   signal SPI_SS_B : std_logic;
   signal DAC_CS : std_logic;
   signal SF_CE0 : std_logic;
   signal FPGA_INIT_B : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top PORT MAP (
          CLK => CLK,
          SPI_MISO => SPI_MISO,
          SPI_MOSI => SPI_MOSI,
          SPI_SCK => SPI_SCK,
          AMP_CS => AMP_CS,
          AMP_SHDN => AMP_SHDN,
          AD_CONV => AD_CONV,
          LEDS => LEDS,
          SPI_SS_B => SPI_SS_B,
          DAC_CS => DAC_CS,
          SF_CE0 => SF_CE0,
          FPGA_INIT_B => FPGA_INIT_B
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLK_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
