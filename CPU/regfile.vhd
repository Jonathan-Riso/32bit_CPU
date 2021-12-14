-- 32 x 32 register file
-- two read ports, one write port with write enable
-- simulation info:
--	reset 	
--	do 5 writes in simulation and read each one.
-- 	then read 4 other registers not written (0) on
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity regfile is
	port( din : in std_logic_vector(31 downto 0);
	reset : in std_logic;
	clk : in std_logic;
	write : in std_logic;
	read_a : in std_logic_vector(4 downto 0);
	read_b : in std_logic_vector(4 downto 0);
	write_address : in std_logic_vector(4 downto 0);
	out_a : out std_logic_vector(31 downto 0);
	out_b : out std_logic_vector(31 downto 0));
end regfile ;

architecture regfile_arch of regfile is
type register_file is array(31 downto 0) of std_logic_vector(31 downto 0);
signal registers : register_file;	
begin

out_a <= registers(conv_integer(read_a));
out_b <= registers(conv_integer(read_b));

process(clk, reset, read_a, read_b, write, write_address, registers)
begin
	if (reset = '1') then
		for i in registers'range loop
			registers(i) <= (others => '0');
		end loop;
	elsif (clk'event and clk = '1') then
		if (write = '1') then
		registers(conv_integer(write_address)) <= din;
		end if;		
	end if;
end process;

end regfile_arch;

				


		
		
	
