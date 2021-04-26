library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity seteseg is
port(
	clock		: in std_logic;
   tempdec, tempuni, tempdez, tempcem  : in STD_LOGIC_VECTOR(3 DOWNTO 0);
	saida		: out std_logic_vector(0 to 7);
	dig		: out std_logic_vector(0 to 3)
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
		------------------- contador para alternar os digitos do displays
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
	------------------------------ a depender do contador, ativa um digito e atribui seu respectivo valor
	case digito is
		when 0 => dig <= "0111"; aux <= tempdec;
		when 1 => dig <= "1011"; aux <= tempuni;
		when 2 => dig <= "1101"; aux <= tempdez;
		when 3 => dig <= "1110"; aux <= tempcem;
	end CASE;
	if digito = 1 then ---- para o digito da unidade, deve haver um ponto, por causa do decimal que o segue
		case aux is
			when "0000" => saida <= "00000010";
			when "0001" =>	saida	<=	"10011110";
			when "0010"	=>	saida	<= "00100100";
			when "0011" =>	saida	<= "00001100";
			when "0100" =>	saida	<= "10011000";
			when "0101" => saida	<= "01001000";
			when "0110" => saida	<= "01000000";
			when "0111" => saida	<= "00011110";
			when "1000" => saida	<= "00000000";
			when "1001" => saida	<= "00001000";
			when others => saida <= "01100000";
		end case;
	else
		case aux is
			when "0000" => saida <= "00000011";
			when "0001" =>	saida	<=	"10011111";
			when "0010"	=>	saida	<= "00100101";
			when "0011" =>	saida	<= "00001101";
			when "0100" =>	saida	<= "10011001";
			when "0101" => saida	<= "01001001";
			when "0110" => saida	<= "01000001";
			when "0111" => saida	<= "00011111";
			when "1000" => saida	<= "00000001";
			when "1001" => saida	<= "00001001";
			when others => saida <= "01100001";
		end case;
	end if;
	end process;
end behavior;