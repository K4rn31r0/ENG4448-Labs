library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.lcd_utils_pkg.ALL;

-- Escrita dinamica no LCD (baseada no lcd_write do Lab07).
--   Linha 1: nome da instrucao corrente (decodificado do IR).
--   Linha 2: "MEM[255]=<valor>" (posicao 255 da RAM em decimal).
-- Apos escrever as duas linhas, volta a capturar IR/POS_255 e reescreve,
-- espelhando continuamente o estado do processador.
entity lcd_write is
    Port ( LCD_INIT_DONE : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           IR      : in  STD_LOGIC_VECTOR (7 downto 0);
           POS_255 : in  STD_LOGIC_VECTOR (7 downto 0);
           DATA_OUT : out  STD_LOGIC_VECTOR (3 downto 0);
           LCD_E : out  STD_LOGIC;
           LCD_RS : out  STD_LOGIC;
           LCD_RW : out  STD_LOGIC);
end lcd_write;

architecture Behavioral of lcd_write is

	constant CMD_ROM : initcmd_array_type := (
		x"28",			-- FUNCTION SET (4 bits, 2 linhas)
		x"06",			-- ENTRY MODE SET
		x"0F",			-- DISPLAY ON
		x"01"				-- CLEAR DISPLAY
	);

	-- conteudo das linhas (latcheado a cada refresh)
	signal line1 : rom_str := (others => (others => '0'));	-- instrucao
	signal line2 : rom_str := (others => (others => '0'));	-- MEM[255]

	type master_fsm is (
		SEND_CONFIG,
		LATCH,			-- captura IR/POS_255 e monta as linhas
		SET_ADDR1,		-- posiciona cursor no inicio da linha 1 (0x80)
		SEND_LINE1,
		LINE_CHANGE,	-- posiciona cursor no inicio da linha 2 (0xC0)
		SEND_LINE2
	);

	type write_fsm is (
		IDLE,
		UPPER_NIBBLE, UPPER_NIBBLE_E,
		WAIT_1U,
		LOWER_NIBBLE, LOWER_NIBBLE_E,
		WAIT_POST_BYTE
	);

	signal m_state	: master_fsm := SEND_CONFIG;
	signal write_state : write_fsm := IDLE;

	signal idx_cmd : integer range 0 to 3 := 0;		-- comando de config
	signal idx_char : integer range 0 to 15 := 0;	-- caractere da linha

	signal byte_to_send : byte_t := (others => '0');
	signal counter : unsigned (19 downto 0) := (others => '0');

begin

	process(CLK)
		variable time_up : boolean := false;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				write_state <= IDLE;
				m_state <= SEND_CONFIG;
				idx_cmd <= 0;
				idx_char <= 0;
			else
				case write_state is

					when IDLE =>
						-- comecar apenas depois que o lcd_init sinalizar
						if LCD_INIT_DONE = '1' then

							case m_state is
								when SEND_CONFIG =>
									byte_to_send <= CMD_ROM(idx_cmd);
									LCD_RS <= '0';		-- comando
									write_state <= UPPER_NIBBLE;

								when LATCH =>
									-- captura o estado atual e monta as duas linhas
									line1 <= ir_to_line(IR);
									line2 <= pos255_to_line(POS_255);
									idx_char <= 0;
									m_state <= SET_ADDR1;	-- (nao envia byte agora)

								when SET_ADDR1 =>
									byte_to_send <= x"80";	-- DDRAM addr 0x00 (linha 1)
									LCD_RS <= '0';
									write_state <= UPPER_NIBBLE;

								when SEND_LINE1 =>
									byte_to_send <= line1(2*idx_char) & line1(2*idx_char + 1);
									LCD_RS <= '1';		-- caractere
									write_state <= UPPER_NIBBLE;

								when LINE_CHANGE =>
									byte_to_send <= x"C0";	-- DDRAM addr 0x40 (linha 2)
									LCD_RS <= '0';
									write_state <= UPPER_NIBBLE;

								when SEND_LINE2 =>
									byte_to_send <= line2(2*idx_char) & line2(2*idx_char + 1);
									LCD_RS <= '1';
									write_state <= UPPER_NIBBLE;
							end case;

						else		-- estado padrao esperando o init
							DATA_OUT <= (others => '0');
							LCD_E <= '0';
							LCD_RS <= '0';
							LCD_RW <= '1';
						end if;

					when UPPER_NIBBLE =>
						DATA_OUT <= byte_to_send(7 downto 4);
						LCD_RW <= '0';
						increment_and_check(counter, wait2, time_up);
						if time_up then
							write_state <= UPPER_NIBBLE_E;
						end if;

					when UPPER_NIBBLE_E =>
						LCD_E <= '1';
						increment_and_check(counter, wait12, time_up);
						if time_up then
							write_state <= WAIT_1U;
						end if;

					when WAIT_1U =>
						LCD_E <= '0';
						LCD_RW <= '1';
						increment_and_check(counter, wait50, time_up);
						if time_up then
							write_state <= LOWER_NIBBLE;
						end if;

					when LOWER_NIBBLE =>
						DATA_OUT <= byte_to_send(3 downto 0);
						LCD_RW <= '0';
						increment_and_check(counter, wait2, time_up);
						if time_up then
							write_state <= LOWER_NIBBLE_E;
						end if;

					when LOWER_NIBBLE_E =>
						LCD_E <= '1';
						increment_and_check(counter, wait12, time_up);
						if time_up then
							write_state <= WAIT_POST_BYTE;
						end if;

					when WAIT_POST_BYTE =>
						LCD_E <= '0';
						LCD_RW <= '1';

						-- clear display (ultimo comando de config) pede ~1.64 ms
						if (m_state = SEND_CONFIG) and (idx_cmd = 3) then
							increment_and_check(counter, wait82k, time_up);
						else
							increment_and_check(counter, wait2k, time_up);
						end if;

						if time_up then
							case m_state is
								when SEND_CONFIG =>
									if idx_cmd < 3 then
										idx_cmd <= idx_cmd + 1;
									else
										m_state <= LATCH;	-- config pronta: comeca o refresh
									end if;

								when SET_ADDR1 =>
									idx_char <= 0;
									m_state <= SEND_LINE1;

								when SEND_LINE1 =>
									if idx_char < 15 then
										idx_char <= idx_char + 1;
									else
										m_state <= LINE_CHANGE;
									end if;

								when LINE_CHANGE =>
									idx_char <= 0;
									m_state <= SEND_LINE2;

								when SEND_LINE2 =>
									if idx_char < 15 then
										idx_char <= idx_char + 1;
									else
										m_state <= LATCH;	-- recomeca (espelhamento continuo)
									end if;

								when others =>
									null;	-- LATCH nunca envia byte
							end case;

							write_state <= IDLE;
						end if;

				end case;
			end if;
		end if;
	end process;

end Behavioral;
