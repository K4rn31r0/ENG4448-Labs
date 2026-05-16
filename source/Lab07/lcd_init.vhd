library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lcd_init is
    Port ( DATA_INIT : out  STD_LOGIC_VECTOR (3 downto 0);
           LCD_E_INIT : out  STD_LOGIC;		-- enable
           LCD_RS_INIT : out  STD_LOGIC;		-- register select
           LCD_RW_INIT : out  STD_LOGIC;		-- read / write
           LCD_INIT_DONE : out  STD_LOGIC;
			  RST : in STD_LOGIC;
			  CLK : in STD_LOGIC
			  );
end lcd_init;

architecture Behavioral of lcd_init is

	type init_fsm is (
		STEP0,
		STEP1, STEP1_ENABLE,
		STEP2,
		STEP3, STEP3_ENABLE,
		STEP4,
		STEP5, STEP5_ENABLE,
		STEP6,
		STEP7, STEP7_ENABLE,
		STEP8, DONE
	);
	
	signal fsm : init_fsm := STEP0;
	signal counter : unsigned(19 downto 0) := (others => '0');
	
	procedure increment_or_advance (
		signal counter 		: inout unsigned(19 downto 0);
		constant limit 		: in unsigned(19 downto 0);
		signal fsm 				: inout init_fsm;
		constant next_state 	: in init_fsm
	) is
	begin 
		if counter < limit then
			counter <= counter + 1;
		else 
			counter <= (others => '0');
			fsm <= next_state;
		end if;
	end procedure increment_or_advance;
	
begin

	process(CLK)
		constant wait750k : unsigned(19 downto 0) := to_unsigned(750000, 20);
		constant wait205k : unsigned(19 downto 0) := to_unsigned(205000, 20);
		constant wait5k : unsigned(19 downto 0) := to_unsigned(5000, 20);
		constant wait2k : unsigned(19 downto 0) := to_unsigned(2000, 20);
		constant wait12 : unsigned(19 downto 0) := to_unsigned(12, 20);
		constant wait2 : unsigned(19 downto 0) := to_unsigned(2, 20);
	begin
		
		if rising_edge(CLK) then
			if (RST = '1') then
				counter <= (others => '0');
				fsm <= STEP0;
			else
				case fsm is 
				
					when STEP0 =>
						DATA_INIT <= (others => '0');
						LCD_E_INIT <= '0';
						LCD_RS_INIT <= '0';		-- registrador de instrucao
						LCD_RW_INIT <= '1';
						LCD_INIT_DONE <= '0';
						increment_or_advance(
							counter, wait750k,
							fsm, STEP1
						);
						
					when STEP1 =>
						DATA_INIT <= x"3";	-- 0x3
						LCD_RW_INIT <= '0';	-- write
						increment_or_advance(
							counter, wait2,
							fsm, STEP1_ENABLE
						);
						
					when STEP1_ENABLE =>
						LCD_E_INIT <= '1'; 	-- enable
						increment_or_advance(
							counter, wait12,		-- hold for 240 ns
							fsm, STEP2
						);
						
					when STEP2 =>
						LCD_E_INIT <= '0';	-- disable
						LCD_RW_INIT <= '1';	-- read
						increment_or_advance(
							counter, wait205k,
							fsm, STEP3
						);
						
					when STEP3 =>
						-- data_init igual, nao precisa mudar
						LCD_RW_INIT <= '0';	-- write
						increment_or_advance(
							counter, wait2,
							fsm, STEP3_ENABLE
						);
					
					when STEP3_ENABLE =>
						LCD_E_INIT <= '1'; 	-- enable
						increment_or_advance(
							counter, wait12,	-- hold for 240 ns
							fsm, STEP4
						);
					
					when STEP4 =>
						LCD_E_INIT <= '0';	-- disable
						LCD_RW_INIT <= '1';	-- read
						increment_or_advance(
							counter, wait5k,
							fsm, STEP5
						);
					
					when STEP5 =>
						LCD_RW_INIT <= '0';	-- write
						increment_or_advance(
							counter, wait2,
							fsm, STEP5_ENABLE
						);
					
					when STEP5_ENABLE =>
						LCD_E_INIT <= '1'; 	-- enable
						increment_or_advance(
							counter, wait12,	-- hold for 240 ns
							fsm, STEP6
						);
					
					when STEP6 => 
						LCD_E_INIT <= '0';	-- disable
						LCD_RW_INIT <= '1';	-- read
						increment_or_advance(
							counter, wait2k,
							fsm, STEP7
						);
					
					when STEP7 =>
						DATA_INIT <= x"2"; 	-- 0x2
						LCD_RW_INIT <= '0';	-- write
						increment_or_advance(
							counter, wait2,
							fsm, STEP7_ENABLE
						);
					
					when STEP7_ENABLE =>
						LCD_E_INIT <= '1';	-- enable
						increment_or_advance(
							counter, wait12,	-- hold for 240 ns
							fsm, STEP8
						);
					
					when STEP8 => 
						LCD_E_INIT <= '0';	-- disable
						LCD_RW_INIT <= '1';	-- read
						increment_or_advance(
							counter, wait2k,	
							fsm, DONE
						);
					
					when DONE =>
						LCD_INIT_DONE <= '1';	-- :)
						
				end case;
			end if;
		end if;
		
	end process;

end Behavioral;

