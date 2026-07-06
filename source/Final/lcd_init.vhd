library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.lcd_utils_pkg.ALL;

-- Sequencia de inicializacao do LCD em modo 4 bits (portada do Lab07).
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

begin

	process(CLK)
		variable time_up : boolean := false;
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

						increment_and_check(counter, wait750k, time_up);
						if time_up then
							 fsm <= STEP1;
						end if;

					when STEP1 =>
						DATA_INIT <= x"3";	-- 0x3
						LCD_RW_INIT <= '0';	-- write

						increment_and_check(counter, wait2, time_up);
						if time_up then
							 fsm <= STEP1_ENABLE;
						end if;

					when STEP1_ENABLE =>
						LCD_E_INIT <= '1'; 	-- enable

						increment_and_check(counter, wait12, time_up);
						if time_up then
							 fsm <= STEP2;
						end if;

					when STEP2 =>
						LCD_E_INIT <= '0';	-- disable
						LCD_RW_INIT <= '1';	-- read

						increment_and_check(counter, wait205k, time_up);
						if time_up then
							 fsm <= STEP3;
						end if;

					when STEP3 =>
						-- data_init igual, nao precisa mudar
						LCD_RW_INIT <= '0';	-- write

						increment_and_check(counter, wait2, time_up);
						if time_up then
							 fsm <= STEP3_ENABLE;
						end if;

					when STEP3_ENABLE =>
						LCD_E_INIT <= '1'; 	-- enable

						increment_and_check(counter, wait12, time_up);
						if time_up then
							 fsm <= STEP4;
						end if;

					when STEP4 =>
						LCD_E_INIT <= '0';	-- disable
						LCD_RW_INIT <= '1';	-- read

						increment_and_check(counter, wait5k, time_up);
						if time_up then
							 fsm <= STEP5;
						end if;

					when STEP5 =>
						LCD_RW_INIT <= '0';	-- write

						increment_and_check(counter, wait2, time_up);
						if time_up then
							 fsm <= STEP5_ENABLE;
						end if;

					when STEP5_ENABLE =>
						LCD_E_INIT <= '1'; 	-- enable

						increment_and_check(counter, wait12, time_up);
						if time_up then
							 fsm <= STEP6;
						end if;

					when STEP6 =>
						LCD_E_INIT <= '0';	-- disable
						LCD_RW_INIT <= '1';	-- read

						increment_and_check(counter, wait2k, time_up);
						if time_up then
							 fsm <= STEP7;
						end if;

					when STEP7 =>
						DATA_INIT <= x"2"; 	-- 0x2
						LCD_RW_INIT <= '0';	-- write

						increment_and_check(counter, wait2, time_up);
						if time_up then
							 fsm <= STEP7_ENABLE;
						end if;

					when STEP7_ENABLE =>
						LCD_E_INIT <= '1';	-- enable

						increment_and_check(counter, wait12, time_up);
						if time_up then
							 fsm <= STEP8;
						end if;

					when STEP8 =>
						LCD_E_INIT <= '0';	-- disable
						LCD_RW_INIT <= '1';	-- read

						increment_and_check(counter, wait2k, time_up);
						if time_up then
							 fsm <= DONE;
						end if;

					when DONE =>
						LCD_INIT_DONE <= '1';	-- :)

				end case;
			end if;
		end if;

	end process;

end Behavioral;
