library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cpu is
    port (
        CLK            : in     STD_LOGIC;
        -- CPU / RAM
        RAM_DIN         : out std_logic_vector(7 downto 0);
        RAM_DOUT        : in  std_logic_vector(7 downto 0);
        RAM_ADDR        : out std_logic_vector(7 downto 0);
        WE              : out std_logic
        -- 
        
    );
end cpu;

architecture Behavioral of cpu is        
    
    -- registradores
	signal IR : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal PC : UNSIGNED(7 downto 0) := (others => '0');
    signal SP : UNSIGNED(7 downto 0) := to_unsigned(254, 8);
	signal MAR: UNSIGNED(7 downto 0) := (others => '0');
	signal MBR: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	 -- IR vira STD_LOGIC_VECTOR porque se trata sempre de uma instrucao
	 -- MBR vira STD_LOGIC_VECTOR porque o buffer pode conter qualquer coisa
    
    type reg_t is array (natural range <>) of STD_LOGIC_VECTOR(7 downto 0);
    signal REG       : reg_t(3 downto 0); -- 4 regs (REG A,B,C,D)
    
    -- FSM para as operacoes da cpu
    type FSM_CPU is (FETCH, DECODE_1, DECODE_2, EXECUTE);
    signal STATE : FSM_CPU := FETCH;

    signal ALU_A     : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    signal ALU_B     : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    signal ALU_S     : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    signal ALU_FLAGS : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    signal ALU_CMD   : STD_LOGIC_VECTOR(4 downto 0) := "00000";

begin

    u_alu : entity work.alu(Behavioral)
        port map (
            A         => ALU_A,
            B         => ALU_B,
            CMD       => ALU_CMD,
            FLAGS     => ALU_FLAGS,
            S         => ALU_S
        );
    
    p_fsm_cycle : process(CLK)
    begin
        if rising_edge(CLK) then
            if (RESET = '1') then
                -- registradores
                REG <= (others => x"00");
                PC  <= (others => '0');
				IR  <= (others => '0');
				MAR <= (others => '0');
				MBR <= (others => '0');			 
                SP  <= x"FE";					-- SP precisa ser 254
					 
                STATE         <= FETCH;
					 
            else
                case STATE is

                    when FETCH =>
						WE <= '0';				-- read!
						IR <= RAM_DOUT;		-- ler posicao indicada pelo PC
                        STATE <= DECODE_1;	-- mas so teremos o resultado no falling_edge...
                    
                    when DECODE_1 =>
                        if IR(7) = '0' then 	-- instruções de ALU
                            ALU_A <= REG( to_integer(unsigned(IR(3 downto 2))) );
                            ALU_B <= REG( to_integer(unsigned(IR(1 downto 0))) );
                            ALU_CMD <= IR(6 downto 4) & IR(1 downto 0);
                        end if;
                        STATE <= DECODE_2;

                    when DECODE_2 =>
                        if IR(7) = "0" then -- instruções de ALU
                            NULL; -- iremos salvar o dado da operação com a ALU no estado EXECUTE
                        end if;
                        
                        STATE <= EXECUTE;

                    when EXECUTE =>
						WE <= '0';
                        -- add Rx, Ry
                        -- OPCODE "0000" & Rx & Ry
                        -- Rx <- Rx + Ry, pc <- pc + 1
                        if IR(7) = '0' then -- instruções de ALU
                            REG( to_integer(unsigned(IR(3 downto 2))) ) <= ALU_S;
                            PC  <= PC + 1;
                            MAR <= PC + 1;
                        end if;

                        STATE <= FETCH;
                        
                    when others =>
                        STATE <= FETCH;
                        
                end case;
            end if;
        end if;
    end process;
    
    RAM_ADDR <= std_logic_vector(MAR);
	RAM_DIN  <= MBR;
	-- o dado em MBR e DIN vai escrito apenas quando WE='1'
    
end Behavioral;

