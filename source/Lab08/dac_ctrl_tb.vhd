LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY dac_ctrl_tb IS
END dac_ctrl_tb;
 
ARCHITECTURE behavior OF dac_ctrl_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT dac_ctrl
    PORT(
         CLK50 : IN  std_logic;
         SPI_MOSI : OUT  std_logic;
         DAC_CS : OUT  std_logic;
         SPI_SCK : OUT  std_logic;
         DAC_CLR : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK50 : std_logic := '0';

 	--Outputs
   signal SPI_MOSI : std_logic;
   signal DAC_CS : std_logic;
   signal SPI_SCK : std_logic;
   signal DAC_CLR : std_logic;

   -- Clock period definitions
   constant CLK50_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: dac_ctrl PORT MAP (
          CLK50 => CLK50,
          SPI_MOSI => SPI_MOSI,
          DAC_CS => DAC_CS,
          SPI_SCK => SPI_SCK,
          DAC_CLR => DAC_CLR
        );

   -- Clock process definitions
   CLK50_process :process
   begin
		CLK50 <= '0';
		wait for CLK50_period/2;
		CLK50 <= '1';
		wait for CLK50_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      wait for 170 us;
      assert false report "END" severity failure;
   end process;

END;
