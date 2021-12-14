library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity next_address is
port(
	rt, rs : in std_logic_vector(31 downto 0) := "00000000000000000000000000000000"; -- two register inputs
	pc : in std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	target_address : in std_logic_vector(25 downto 0) := "00000000000000000000000000";
	branch_type : in std_logic_vector(1 downto 0) := "00";
	pc_sel : in std_logic_vector(1 downto 0) := "00";
	next_pc : out std_logic_vector(31 downto 0));
end next_address ;

architecture next_address_arch of next_address is
signal sign_extend : std_logic_vector(31 downto 0) := (others => '0');

begin
	process(pc_sel, pc, target_address, rt, rs, branch_type) 
	begin
	sign_extend <= (31 downto 16 => target_address(15), others => '0') ;
	sign_extend(15 downto 0) <= target_address(15 downto 0) ;
		
	if (pc_sel = "00" and branch_type = "00") then
		next_pc <= pc + 1 ;
	else
		case pc_sel is
			when "00" => null;
			when "01" => 
				next_pc <= "000000" & target_address;
			when "10" => 
				next_pc <= pc ;
			when others => null ; -- forbidden
		end case;

		case branch_type is
			when "00" => null ;
			when "01" => 
				if (rt = rs) then
					next_pc <= pc + sign_extend + 1 ;
				else
					next_pc <= pc + 1 ;
				end if;
			when "10" =>
				if (rt /= rs) then
					next_pc <= pc + sign_extend + 1 ;
				else
					next_pc <= pc + 1 ;
				end if;
			when "11" => 
			if (rs < 0) then
				next_pc <= pc + sign_extend + 1 ;
			else
				next_pc <= pc + 1 ;
			end if;
			when others => null;
		end case;
	end if;
	end process;
end next_address_arch;

