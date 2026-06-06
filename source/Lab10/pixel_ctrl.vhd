library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pixel_ctrl is
	generic (
			h_pixels : NATURAL := 800;
			v_pixels : NATURAL := 600
	);
    Port ( pixel_clock : in  STD_LOGIC;
           display_on : in  STD_LOGIC;
           pixel_x : in  NATURAL;
           pixel_y : in  NATURAL;
           red : out  STD_LOGIC;
           green : out  STD_LOGIC;
           blue : out  STD_LOGIC);
end pixel_ctrl;

architecture Behavioral of pixel_ctrl is

	type region_enum is (
		TRIANGLE,
		SQUARE,
		CIRCLE,
		BACKGROUND,		-- fundo branco
		NOTHING			-- preto (nao desenha nada)
	);
	
	signal within_area : region_enum := BACKGROUND;

	type point_t is record 
		x : INTEGER;
		y : INTEGER;
	end record;
	
	-- triangulo
	constant A : point_t := (x => 150, y => 75);
	constant B : point_t := (x => 250, y => 225);
	constant C : point_t := (x => 50	, y => 225);
	
	type rect_t is record
		top_left 	: point_t;
		bottom_right: point_t;
	end record;
	
	-- quadrado (nada mais que um retangulo especial)
	constant SQUARE_R : rect_t := (
		top_left		=> (x => 325, y => 75 ),
		bottom_right=> (x => 475, y => 225)
	);
	
	-- circulo (basta o centro e o r^2)
	constant CIRCLE_CENTER : point_t := (x => 650, y => 150);
	constant CIRCLE_R2 : NATURAL := 75 * 75;
	
	-- sinais intermediarios das cores
	signal red_int, green_int, blue_int : STD_LOGIC;
	
	-- sinais auxiliares pro xadrez
	signal   col_toggle : STD_LOGIC := '0';
	signal   row_toggle : STD_LOGIC := '0';

begin

	find_region : process (pixel_clock)
		variable px : INTEGER;
		variable py : INTEGER;
		variable dx : INTEGER;
		variable dy : INTEGER;
	begin
		if rising_edge(pixel_clock) then
		
			px := INTEGER(pixel_x);
			py := INTEGER(pixel_y);		
			dx := px - CIRCLE_CENTER.x;
			dy := py - CIRCLE_CENTER.y;
			
			
			-- XADREZ preto-branco na metade inferior da tela:
			if (py > 300) then
				if (col_toggle xor row_toggle) = '0' then
					within_area <= BACKGROUND;
				else
					within_area <= NOTHING;
				end if; 

			
			-- TRIANGULO:
			-- forma geral para retas com 2 pontos P1 e P2:
			-- (py - P1.y)*(P2.x - P1.x) > (px - P1.x)*(P2.y - P1.y)
			
			elsif	((py - A.y) * (B.x - A.x) > (px - A.x) * (B.y - A.y))	-- esquerda de AB
			and	(py < B.y)															-- acima de BC
			and	((py - C.y) * (A.x - C.x) > (px - C.x) * (A.y - C.y))	-- direita de AC
			then			
				within_area <= TRIANGLE;
				
			
			-- QUADRADO:
			elsif (px > SQUARE_R.top_left.x) 
			and	(px < SQUARE_R.bottom_right.x)
			and	(py > SQUARE_R.top_left.y)
			and	(py < SQUARE_R.bottom_right.y) 
			then
				within_area <= SQUARE;
				
			
			-- CIRCULO:
			-- se o centro do circulo = O e o raio = r, entao:
			-- (px - O.x)^2 + (py - O.y)^2 <= r^2
			
			elsif (dx*dx + dy*dy < CIRCLE_R2) then
				within_area <= CIRCLE;
			
			else
				within_area <= BACKGROUND;
				
			end if;
					
		end if;
	end process find_region;
	
	
	-- processo para desenhar o xadrez
	chess_proc : process(pixel_clock)
		 variable col_count : NATURAL range 0 to 49 := 0;
		 variable row_count : NATURAL range 0 to 49 := 0;
	begin
		 if rising_edge(pixel_clock) then
			  -- conta colunas de 50 pixels
			  if pixel_x = 0 then
					col_count  := 0;
					col_toggle <= '0';
			  elsif col_count = 49 then
					col_count  := 0;
					col_toggle <= not col_toggle;
			  else
					col_count := col_count + 1;
			  end if;

			  -- conta linhas de 50 pixels (apenas quando comeca nova linha)
			  if pixel_x = 0 then
					if pixel_y = 0 then
						 row_count  := 0;
						 row_toggle <= '0';
					elsif row_count = 49 then
						 row_count  := 0;
						 row_toggle <= not row_toggle;
					else
						 row_count := row_count + 1;
					end if;
			  end if;
		 end if;
	end process;
	
	
	-- triangulo vermelho, quadrado verde, circulo magenta,
	-- background branco, e o nothing preto
	with within_area select red_int		<= '1' when TRIANGLE,
														'0' when SQUARE,
														'1' when CIRCLE,
														'1' when BACKGROUND,
														'0' when NOTHING,
														'0' when others;

	with within_area select green_int	<= '0' when TRIANGLE,
														'1' when SQUARE,
														'0' when CIRCLE,
														'1' when BACKGROUND,
														'0' when NOTHING,
														'0' when others;

	with within_area select blue_int 	<= '0' when TRIANGLE,
														'0' when SQUARE,
														'1' when CIRCLE,
														'1' when BACKGROUND,
														'0' when NOTHING,
														'0' when others;
	
	-- saida so quando estiver na area do display
	red   <= red_int when display_on = '1' else '0';
	green <= green_int when display_on = '1' else '0';
	blue  <= blue_int when display_on = '1' else '0';

end Behavioral;

