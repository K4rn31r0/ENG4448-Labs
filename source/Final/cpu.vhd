library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cpu is
    port (
        CLK            : in     STD_LOGIC;
		RESET		   : in 	STD_LOGIC;
        -- CPU / RAM
        RAM_DIN         : out std_logic_vector(7 downto 0);
        RAM_DOUT        : in  std_logic_vector(7 downto 0);
        RAM_ADDR        : out std_logic_vector(7 downto 0);
        WE              : out std_logic;
        -- IR espelhado para o LCD
        IR_OUT          : out std_logic_vector(7 downto 0);
        -- CPU / FLAGS
		FLAGS			: out std_logic_vector(4 downto 0)

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
    
	-- A=0, B=1, C=2, D=3 
    type reg_t is array (natural range <>) of STD_LOGIC_VECTOR(7 downto 0);
    signal REG       : reg_t(3 downto 0);
    
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
		-- variaveis locais (simplifica indices dos registradores)
		variable rx : integer range 0 to 3;
		variable ry : integer range 0 to 3;
    begin
        if rising_edge(CLK) then
			-- atualizar os indices
			rx := to_integer(unsigned(IR(3 downto 2)));
			ry := to_integer(unsigned(IR(1 downto 0)));
			
            if (RESET = '1') then
                REG <= (others => x"00");
                PC  <= (others => '0');
				IR  <= (others => '0');
				MAR <= (others => '0');
				MBR <= (others => '0');			 
                SP  <= x"FE";				-- SP precisa ser 254
				WE  <= '0';
                STATE <= FETCH;
					 
            else
                case STATE is
                    when FETCH =>
						WE <= '0';			-- read!
						IR <= RAM_DOUT;		-- a instrucao ja esta disponivel na DOUT
						PC <= PC + 1;		-- incrementa PC agora
                        STATE <= DECODE_1;
						
                    
                    when DECODE_1 =>
                        if IR(7) = '0' then 	-- instru��es de ALU
                            ALU_A <= REG( rx );
                            ALU_B <= REG( ry );
                            ALU_CMD <= IR(6 downto 4) & IR(1 downto 0);
						
						else
							case IR(6 downto 4) is
								when "000" =>
									if IR(1 downto 0) = "00" then					-- PUSH
										WE  <= '1';		-- write 
										MAR <= SP;		-- na posicao do SP
										MBR <= REG(rx);	-- o dado em Rx
										SP  <= SP - 1;	-- empilhar
									elsif IR(1 downto 0) = "01" then				-- POP
										SP  <= SP + 1;	-- desempilhar
										MAR <= SP + 1;	-- o dado no topo da pilha
									elsif IR(1 downto 0) = "10" then				-- STORE
										MAR <= PC;		-- endereco para escrever
									else 											-- LOAD
										MAR <= PC;		-- endereco para ler
									end if;
								
								when "001" =>										-- LOAD REGISTER
									MAR <= unsigned(REG(ry));
								
								when "010" =>										-- STORE REGISTER
									-- aqui, precisamos escrever na memoria
									-- usamos o MBR (buffer) com write enable
									MBR <= REG(rx);
									MAR <= unsigned(REG(ry)); 
									WE  <= '1';
								
								when "011" =>										-- MOVE
									REG(rx) <= REG(ry);
								
								when "100" =>
									if IR(1 downto 0) = "00" then					-- JUMP
										MAR <= PC;	-- pular para MEM[PC+1]
										-- o PC ja foi incrementado no FETCH! 
									elsif IR(1 downto 0) = "01" then				-- JUMP REGISTER
										PC <= unsigned(REG(rx));										
									elsif IR(1 downto 0) = "10" then				-- BRANCH ON ZERO
										if ALU_FLAGS(1)='1' then 
										PC <= unsigned(REG(rx)); end if;
									else											-- BRANCH ON NOT ZERO
										if ALU_FLAGS(1)='0' then 
										PC <= unsigned(REG(rx)); end if;
									end if;
								
								when "101" =>
									if IR(1 downto 0) = "00" then					-- BRANCH ON CARRY
										if ALU_FLAGS(0)='1' then 
										PC <= unsigned(REG(rx)); end if;
									elsif IR(1 downto 0) = "01" then				-- BRANCH ON NOT CARRY
										if ALU_FLAGS(0)='0' then 
										PC <= unsigned(REG(rx)); end if;
									elsif IR(1 downto 0) = "10" then				-- BRANCH ON EQUAL
										if ALU_FLAGS(4)='1' then 
										PC <= unsigned(REG(rx)); end if;
									else											-- BRANCH ON NOT EQUAL
										if ALU_FLAGS(4)='0' then 
										PC <= unsigned(REG(rx)); end if;
									end if;
								
								when "110" =>
									if IR(1 downto 0) = "00" then					-- BRANCH ON GREATER
										if ALU_FLAGS(3)='1' then 
										PC <= unsigned(REG(rx)); end if;
									elsif IR(1 downto 0) = "01" then				-- BRANCH ON SMALLER
										if ALU_FLAGS(2)='1' then 
										PC <= unsigned(REG(rx)); end if;
									end if;
								
								when others => NULL;
								
							end case;
                        end if;
						
                        STATE <= DECODE_2;
						

                    when DECODE_2 =>
                        -- nesse estado, nao precisa fazer nada quanto a instrucoes da ALU
						-- apenas desativar o write por padrao para evitar escrever sem querer
						WE <= '0';
						
						case IR(6 downto 4) is
							when "000" =>
								if IR(1 downto 0) = "00" then					-- PUSH
									NULL;			-- ja foi escrito na pilha
								elsif IR(1 downto 0) = "01" then				-- POP
									MBR <= RAM_DOUT;
								elsif IR(1 downto 0) = "10" then				-- STORE
									-- MAR recebe o endereco-alvo:
									MAR <= unsigned(RAM_DOUT);
									MBR <= reg(rx);	-- o dado a ser escrito
									WE  <= '1';		-- write!
									PC  <= PC + 1;	-- pular o byte do endereco
								else 											-- LOAD
									MBR <= RAM_DOUT;
									PC  <= PC + 1;	-- pular o byte do valor
								end if;
							
							when "001" =>										-- LOAD REGISTER
								MBR <= RAM_DOUT;	-- dado ja foi lido!
							
							when "100" =>
								if IR(1 downto 0) = "00" then					-- JUMP
									-- o PC passa a ter o valor lido da memoria
									PC <= unsigned(RAM_DOUT);
								end if;		
							
							-- as outras instrucoes que nao foram mencionadas nesse estado
							-- nao requerem nenhuma acao adicional por enquanto
							when others => NULL;
							
						end case;
                        
                        STATE <= EXECUTE;
						

                    when EXECUTE =>
						WE <= '0';		-- para ler a proxima instrucao
						
                        if IR(7) = '0' then
                            REG( rx ) <= ALU_S;		-- salvar resultados da ALU
							
						else
							case IR(6 downto 4) is
								when "000" =>
									if IR(0) = '1' then		-- POP ou LOAD:
										REG(rx) <= MBR;		-- salvar no registrador certo
									end if;
								
								when "001" =>				-- LOAD REGISTER
									REG(rx) <= MBR;			-- idem
								
								when others => NULL;
								
								end case;
                        end if;
						
						if IR(7 downto 4) = "1111" then
                            STATE <= EXECUTE; -- HALT: Congela a FSM neste estado para sempre
                        else
                            MAR   <= PC;    -- importante: apontar o MAR para o proximo fetch!!
                            STATE <= FETCH;
                        end if;
						
                        
                    when others =>
                        STATE <= FETCH;
                        
                end case;
            end if;
        end if;
    end process;
    
    RAM_ADDR <= std_logic_vector(MAR);
	RAM_DIN  <= MBR;
	-- o dado em MBR e DIN vai ser escrito apenas quando WE='1'

	IR_OUT <= IR;			-- espelha a instrucao corrente para o LCD
	FLAGS <= ALU_FLAGS;
    
end Behavioral;

