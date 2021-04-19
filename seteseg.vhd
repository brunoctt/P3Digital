library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity seteseg is
port(
	clock		: in std_logic;
   tempdec, tempuni, tempdez, tempcem  : in STD_LOGIC_VECTOR(3 DOWNTO 0);
	saida		: out std_logic_vector(0 to 6);
	dig		: out std_logic_vector(3 downto 0)
);
end seteseg;
architecture behavior of seteseg is
signal digito : integer range 0 to 3;
signal aux 	  : std_logic_vector(3 downto 0);
begin
	process(clock)
	variable counter : integer range 0 to 50000;
	begin
		if clock'event and clock='1' then
			if counter = 50000 then
				counter := 0;
				if digito = 3 then
					digito <= 0;
				else
					digito <= digito + 1;
				end if;
			else
				counter := counter + 1;
			end if;
		end if;
	case digito is
		when 0 => dig <= "0111"; aux <= tempdec;
		when 1 => dig <= "1011"; aux <= tempuni;
		when 2 => dig <= "1101"; aux <= tempdez;
		when 3 => dig <= "1110"; aux <= tempcem;
	end CASE;
	case aux is
		when "0000" => saida <= "0000001";
		when "0001" =>	saida	<=	"1001111";
		when "0010"	=>	saida	<= "0010010";
		when "0011" =>	saida	<= "0000110";
		when "0100" =>	saida	<= "1001100";
		when "0101" => saida	<= "0100100";
		when "0110" => saida	<= "0100000";
		when "0111" => saida	<= "0001111";
		when "1000" => saida	<= "0000000";
		when "1001" => saida	<= "0000100";
		when others => saida <= "0110000";
	end case;
	end process;
end behavior;