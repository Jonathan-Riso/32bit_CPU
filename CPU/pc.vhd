library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity pc is
port( in_address: in std_logic_vector(31 downto 0);
      	reset	: in std_logic;
      	clk	: in std_logic;
      	out_pc	: out std_logic_vector(31 downto 0));
end pc;

architecture pc_arch of pc is

begin
	process(in_address, reset, clk)
	begin
		if (reset = '1') then
			out_pc <= X"00000000";

		elsif( rising_edge(clk) ) then
			out_pc <= in_address;
		end if;
	end process;
end pc_arch;