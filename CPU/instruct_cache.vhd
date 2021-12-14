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

entity instruct_cache is
	port(
	read : in std_logic_vector(4 downto 0);
	output : out std_logic_vector(31 downto 0));
end instruct_cache ;

architecture instruct_cache_arch of instruct_cache is
begin

process(read)
begin
	case read is
        when "00000" => output <= "00100000000000110000000000000000"; -- addi r1, r0, 1
        when "00001" => output <= "00100000000000010000000000000000"; -- addi r2, r0, r2
        when "00010" => output <= "00100000000000100000000000000101"; -- add r2, r2, r1
        when "00011" => output <= "00000000001000100000100000100000"; -- jump 00010
        when "00100" => output <= "00100000010000101111111111111111"; -- nothing
        when "00101" => output <= "00010000010000110000000000000001";
        when "00110" => output <= "00001000000000000000000000000011";
        when "00111" => output <= "10101100000000010000000000000000";
        when "01000" => output <= "10001100000001000000000000000000";
        when "01001" => output <= "00110000100001000000000000001010";
        when "01010" => output <= "00110100100001000000000000000001";
        when "01011" => output <= "00111000100001000000000000001011";
        when "01100" => output <= "00111000100001000000000000000000";
        when others => output <= "00000000000000000000000000000000";
    end case;
end process;
end instruct_cache_arch;

--       "00000"   "00100000000000110000000000000000"; -- addi r3, r0, 0
--       "00001"   "00100000000000010000000000000000"; -- addi r1, r0, 0
--       "00010"   "00100000000000100000000000000101"; -- addi r2,r0,5
-- LOOP: "00011"  "00000000001000100000100000100000"; -- add r1,r1,r2
--       "00100"  "00100000010000101111111111111111"; -- addi r2, r2, -1
--       "00101"  "00010000010000110000000000000001"; -- beq r2,r3 (+1) THERE
--       "00110"  "00001000000000000000000000000011"; -- jump 3  (LOOP)
-- THERE:"00111"  "10101100000000010000000000000000"; -- sw r1, 0(r0)  
--       "01000"  "10001100000001000000000000000000"; -- lw r4, 0(r0)
--       "01001"  "00110000100001000000000000001010"; -- andi r4,r4, 0x000A
--       "01010"  "00110100100001000000000000000001"; -- ori r4,r4, 0x0001
--       "01011"  "00111000100001000000000000001011"; -- xori r4,r4, 0xB
--      "01100"   "00111000100001000000000000000000"; -- xori r4,r4, 0x0000
--       others   "00000000000000000000000000000000"; -- dont care


				


		
		
	
