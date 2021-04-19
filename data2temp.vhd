library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

ENTITY data2temp IS
  PORT(
		data   : in STD_LOGIC_VECTOR(15 DOWNTO 0);
      clk    : IN  STD_LOGIC;  --system clock+
      tempdec, tempuni, tempdez, tempcem  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		); 
END data2temp;

ARCHITECTURE behavior OF data2temp IS
  SIGNAL dec, uni, dez, cem : integer range 0 to 9;
  signal convert	: integer range 0 to 3000;
BEGIN
	process(clk, data)
	begin	
		convert <= to_integer(unsigned(data(15 downto 7)));
		convert <= convert * 5;
		cem <= convert/1000;
		dez <= (convert/100) mod 10;
		uni <= (convert mod 100)/10;
		dec <= convert mod 10;
--		if ((convert mod 2 \= 0) then
--			dec <= 5;
--		else 
--			dec <= 0;
	end process;
	tempdec <= std_logic_vector(to_unsigned(dec, 4));
	tempuni <= std_logic_vector(to_unsigned(uni, 4));
	tempdez <= std_logic_vector(to_unsigned(dez, 4));
	tempcem <= std_logic_vector(to_unsigned(cem, 4));
end behavior;