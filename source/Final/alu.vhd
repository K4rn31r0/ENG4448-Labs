library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    Port ( A : in  STD_LOGIC_VECTOR (7 downto 0);
           B : in  STD_LOGIC_VECTOR (7 downto 0);
           CMD : in  STD_LOGIC_VECTOR (4 downto 0);
           S : out  STD_LOGIC_VECTOR (7 downto 0);
           FLAGS : out  STD_LOGIC_VECTOR (4 downto 0));
			  -- 4 = EQUAL
			  -- 3 = GREATER
			  -- 2 = SMALLER
			  -- 1 = ZERO
			  -- 0 = OVERFLOW
end alu;

architecture Behavioral of alu is
begin

	process(A, B, CMD)
		-- 9 bits em vez de 8 porque pode haver overflow...
		-- se houver, levanta a flag com base no MSB de var_S
		variable var_A : unsigned(8 downto 0);
		variable var_B : unsigned(8 downto 0);
		variable var_S : unsigned(8 downto 0);
		variable var_operation : STD_LOGIC_VECTOR(2 downto 0);	-- a operacao que vai ser feita
		variable var_op_detail  : STD_LOGIC_VECTOR(1 downto 0);	-- detalhe, i.e. shift L ou R?
	begin
	
		var_A := unsigned("0" & A);
		var_B := unsigned("0" & B);
		var_S := (others => '0');
		var_operation := CMD(4 downto 2);
		var_op_detail := CMD(1 downto 0);
		
		case var_operation is
			
			-- add
			when "000" =>
				var_S := var_A + var_B;
			
			-- sub
			when "001" =>
				var_S := var_A - var_B;
			
			-- inc OU dec
			when "010" =>
				if var_op_detail = "00" then
					var_S := var_A + 1;
				elsif var_op_detail = "01" then
					var_S := var_A - 1;
				end if;
			
			-- and
			when "011" =>
				var_S := var_A and var_B;
			
			-- or
			when "100" => 
				var_S := var_A or var_B;
				
			-- not
			when "101" =>
				var_S := not var_A;
				var_S(8) := '0';		-- para evitar flag de carry
			
			-- xor
			when "110" =>
				var_S := var_A xor var_B;
			
			-- rotate ou shift
			when "111" =>
				if var_op_detail = "00" then		-- rotate L
					var_S(7 downto 0) := unsigned(A(6 downto 0) & A(7));
				elsif var_op_detail = "01" then	-- rotate R
					var_S(7 downto 0) := unsigned(A(0) & A(7 downto 1));
				elsif var_op_detail = "10" then	-- shift L
					var_S(7 downto 0) := unsigned(A(6 downto 0) & "0");
				elsif var_op_detail = "11" then	-- shift R
					var_S(7 downto 0) := unsigned("0" & A(7 downto 1));
				end if;
			
			when others =>
				var_S := (others => '0');
			
		end case;
		
		-- atribuir resultado
		S <= std_logic_vector(var_S(7 downto 0));
		
		-- EQUAL
		if (A = B) then
			FLAGS(4) <= '1';
		else 
			FLAGS(4) <= '0';
		end if;
		
		-- GREATER 
		if (A > B) then 
			FLAGS(3) <= '1';
		else 
			FLAGS(3) <= '0';
		end if;
		
		-- SMALLER
		if (A < B) then 
			FLAGS(2) <= '1';
		else 
			FLAGS(2) <= '0';
		end if;
		
		-- ZERO
		if var_S(7 downto 0) = x"00" then
			FLAGS(1) <= '1';
		else 
			FLAGS(1) <= '0';
		end if;
		
		-- OVERFLOW
		FLAGS(0) <= std_logic(var_S(8));
		
	end process;

end Behavioral;

