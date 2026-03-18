library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Comp1bit is
    Port ( a : in  STD_LOGIC;
           b : in  STD_LOGIC;
           z : out  STD_LOGIC);
end Comp1bit;

architecture dataflow of Comp1bit is
begin

   z <= a xnor b;

end dataflow;