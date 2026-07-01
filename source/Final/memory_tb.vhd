LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY memory_tb IS
END memory_tb;
 
ARCHITECTURE behavior OF memory_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT memory
    PORT(
         CLK : IN  std_logic;
         DIN : IN  std_logic_vector(7 downto 0);
         ADDR : IN  std_logic_vector(7 downto 0);
         WE : IN  std_logic;
         DOUT : OUT  std_logic_vector(7 downto 0);
         POS_255 : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal DIN : std_logic_vector(7 downto 0) := (others => '0');
   signal ADDR : std_logic_vector(7 downto 0) := (others => '0');
   signal WE : std_logic := '0';

 	--Outputs
   signal DOUT : std_logic_vector(7 downto 0);
   signal POS_255 : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 20 ns;
   -- Na implementacao real, o clock vai ser bem mais lento do que isso
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: memory PORT MAP (
          CLK => CLK,
          DIN => DIN,
          ADDR => ADDR,
          WE => WE,
          DOUT => DOUT,
          POS_255 => POS_255
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
	  
	  wait for clk_period*2;
	  
	  -- comecar a escrever
	  WE <= '1';
	  
	  for i in 10 to 19 loop
		-- mudar sinais na borda de subida...
		wait until rising_edge(CLK);
		ADDR <= std_logic_vector(to_unsigned(i, 8));
		DIN <= std_logic_vector(to_unsigned(i, 8));
		-- mas a escrita mesmo so acontece na falling_edge
	  end loop;
	  
	  -- gravar qualquer coisa no IO
	  wait until rising_edge(CLK);
	  ADDR <= x"FF";
	  DIN <= "10101010";
	  
	  -- trocar para read e esperar um pouquinho
	  wait until rising_edge(CLK);
	  WE <= '0';
	  wait for clk_period*2;
	  
	  -- ler de volta o que foi escrito
	  for i in 10 to 19 loop
		wait until rising_edge(CLK);
		ADDR <= std_logic_vector(to_unsigned(i, 8));
		
		-- checar o valor que saiu no DOUT
		wait until rising_edge(CLK);
		assert DOUT = std_logic_vector(to_unsigned(i, 8))
		report "Erro de leitura: Valor incorreto no endereco " & integer'image(i)
		severity error;
	  end loop;
	  
	  -- o valor no IO esta certo tambem?
	  assert POS_255 = "10101010"
	  report "Erro: POS_255 (IO) nao atualizou corretamente"
	  severity error;
	  
	  assert false report "FIM" severity failure;
	  
      wait;
   end process;

END;
