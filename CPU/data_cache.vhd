-- 32 x 32 register file
-- two read ports, one data_write port with data_write enable
-- simulation info:
--	reset 	
--	do 5 data_writes in simulation and read each one.
-- 	then read 4 other registers not written (0) on
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity data_cache is
	port( din : in std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	reset : in std_logic := '0';
	clk : in std_logic := '0';
	data_cache_write : in std_logic := '0';
	read_address : in std_logic_vector(4 downto 0) := "00000";
	output : out std_logic_vector(31 downto 0));
end data_cache ;

architecture data_cache_arch of data_cache is
type register_file is array(31 downto 0) of std_logic_vector(31 downto 0);
signal cache : register_file;	
begin

output <= cache(conv_integer(read_address));
process(clk, reset, read_address, data_cache_write, cache)
begin
	if (reset = '1') then
		for i in cache'range loop
			cache(i) <= (others => '0');
		end loop;
	elsif (clk'event and clk = '1') then
		if (data_cache_write = '1') then
		cache(conv_integer(read_address)) <= din;
		end if;		
	end if;
end process;

end data_cache_arch;

				


		
		
	
