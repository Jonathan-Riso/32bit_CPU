library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all ;

entity alu is
port(x, y : in std_logic_vector(31 downto 0) := (others => '0');
	-- two input operands
	add_sub : in std_logic := '0' ; -- 0 = add , 1 = sub
	logic_func : in std_logic_vector(1 downto 0 ) := "00" ;
	-- 00 = AND, 01 = OR , 10 = XOR , 11 = NOR
	
	func : in std_logic_vector(1 downto 0 ) := "00";
	-- 00 = lui, 01 = setless , 10 = arith , 11 = logic
	
	output : out std_logic_vector(31 downto 0);
	overflow : out std_logic ;
	zero : out std_logic);
end alu ;

architecture arch_alu  of alu is
signal out_add_sub : std_logic_vector(31 downto 0) := (others => '0') ;
signal out_logic_unit : std_logic_vector(31 downto 0) := (others => '0') ;
begin
	-- adder_subtract
	process(x, y, add_sub)
	begin
	if (add_sub = '0') then
		out_add_sub <= x + y;
	else
		out_add_sub <= x + (not y + 1);
	end if;
	

	end process;

	-- overflow
	process(x, y, add_sub, out_add_sub)
	begin
	
	overflow <= (not add_sub and not out_add_sub(31) and x(31) and y(31))
			or (not add_sub and out_add_sub(31) and not x(31) and not y(31))
			or (add_sub and not out_add_sub(31) and x(31) and not y(31))
			or (add_sub and out_add_sub(31) and not x(31) and y(31));

	end process;
	
	-- zero
	process(out_add_sub)
	begin

	if (out_add_sub = 0) then
		zero <= '1';
	else
		zero <= '0';
	end if;

	end process;

	-- logic unit
	process(x, y, logic_func)
	begin

	case logic_func is
		when "00" => out_logic_unit <= x and y;
		when "01" => out_logic_unit <= x or y;
		when "10" => out_logic_unit <= x xor y;
		when others => out_logic_unit <= x nor y;
	end case;

	end process;

	-- 4-1 multiplexer
	process(func, out_add_sub, out_logic_unit, y)
	begin

	case func is
		when "00" => output <= y;
		when "01" => output <= (0 => out_add_sub(31), others => '0');
		when "10" => output <= out_add_sub;
		when others => output <= out_logic_unit;
	end case;

	end process;

end arch_alu;

