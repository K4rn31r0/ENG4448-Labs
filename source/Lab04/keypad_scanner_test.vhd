LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY keypad_scanner_test IS
END keypad_scanner_test;
 
ARCHITECTURE behavior OF keypad_scanner_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT keypad_scanner
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         col : OUT  std_logic_vector(3 downto 0);
         row : IN  std_logic_vector(3 downto 0);
         key_code : OUT  std_logic_vector(3 downto 0);
         key_pressed : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal row : std_logic_vector(3 downto 0) := "1111";

 	--Outputs
   signal col : std_logic_vector(3 downto 0);
   signal key_code : std_logic_vector(3 downto 0);
   signal key_pressed : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
	
	signal btn_5_pressed : std_logic := '0';
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: keypad_scanner PORT MAP (
          clk => clk,
          rst => rst,
          col => col,
          row => row,
          key_code => key_code,
          key_pressed => key_pressed
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
	
	-- Logica combinacional fora dos processes
	row(3) <= '1';
   row(2) <= col(2) when btn_5_pressed = '1' else '1';
   row(1) <= '1';
   row(0) <= '1';
 
   -- Stimulus process
   stim_proc: process
   begin		
      -- reseta o sistema
      rst <= '1';
		btn_5_pressed <= '0';
		
      wait for 100 ns;
		
      rst <= '0';
      
      -- deixa o scanner varrer um pouco no vazio
      wait for 30 ms; 

      -- dedo aperta a tecla '5'!
      btn_5_pressed <= '1';
      wait for 50 ms; -- Segura por 50 milissegundos

      -- dedo solta a tecla
      btn_5_pressed <= '0';
      wait for 50 ms; -- Observa o sistema voltar ao normal

      assert false report "FIM" severity failure;
   end process;

END;
