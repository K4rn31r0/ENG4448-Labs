LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY ps2_keyboard_top_tb IS
END ps2_keyboard_top_tb;
 
ARCHITECTURE behavior OF ps2_keyboard_top_tb IS 
  
    COMPONENT ps2_keyboard_top
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         ps2_clk : IN  std_logic;
         ps2_data : IN  std_logic;
         led_erro : OUT  std_logic
        );
    END COMPONENT;
    
   -- Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal ps2_clk : std_logic := '1';
   signal ps2_data : std_logic := '1';

   -- Outputs
   signal led_erro : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
   -- Instantiate the Unit Under Test (UUT)
   uut: ps2_keyboard_top 
   PORT MAP (
      clk => clk,
      reset => reset,
      ps2_clk => ps2_clk,
      ps2_data => ps2_data,
      led_erro => led_erro
   );

   -- Clock principal da FPGA
   clk_process : process
   begin
      clk <= '0';
      wait for clk_period / 2;
      clk <= '1';
      wait for clk_period / 2;
   end process;
 
   -- Stimulus process
   stim_proc: process
	
      procedure send_bit(b : in std_logic) is
      begin
         -- coloca o dado com o clock em nível alto
         ps2_data <= b;
         wait for 20 us;
			
         -- borda de descida: é aqui que o receptor lê
         ps2_clk <= '0';
         wait for 40 us;
			
         -- volta para nível alto
         ps2_clk <= '1';
         wait for 20 us;
      end procedure;
		
      procedure send_frame(
         data_byte  : in std_logic_vector(7 downto 0);
         parity_bit : in std_logic
      ) is
      begin
         -- start bit
         send_bit('0');
			
         -- 8 bits de dados, LSB first
         for i in 0 to 7 loop
            send_bit(data_byte(i));
         end loop;
			
         -- bit de paridade
         send_bit(parity_bit);
			
         -- stop bit
         send_bit('1');
			
         -- volta ao idle
         ps2_data <= '1';
         wait for 100 us;
      end procedure;
	
   begin		
      -- reset inicial
      reset <= '1';
      ps2_clk <= '1';
      ps2_data <= '1';
      wait for 100 ns;
		
      reset <= '0';
      wait for 100 us;
		
      -- Frame válido
      -- Exemplo de byte: x"1C" = 00011100
      -- Tem 3 bits '1', então para paridade ímpar o bit de paridade correto é '0'
      send_frame(x"1C", '0');
		
      wait for 200 us;
		
      -- Mesmo byte, mas com paridade errada
      send_frame(x"1C", '1');
		
      wait for 200 us;
		
      report "Fim da simulacao" severity failure;
		
   end process;

END behavior;