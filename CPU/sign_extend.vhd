library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all ;

entity sign_extend is
	port(
        input : in std_logic_vector(15 downto 0) := "0000000000000000"; -- two input
	    func : in std_logic_vector(1 downto 0 ) := "00" ;
	    output : out std_logic_vector(31 downto 0)) ;
	end sign_extend;

    architecture sign_extend_arch of sign_extend is
    begin
        process(input, func)
        begin
            case func is
                when "00" => 
                    output <= (31 downto 16 => '0', others => '0') ;
                    output(15 downto 0) <= input(15 downto 0) ;
            
                when "01" =>
                    output <= (31 downto 16 => input(15), others => '0') ;
                    output(15 downto 0) <= input(15 downto 0) ;
                when "10" =>
                    output <= (31 downto 16 => input(15), others => '0') ;
                    output(15 downto 0) <= input(15 downto 0) ;
                when "11" =>
                    output <= (31 downto 16 => '0', others => '0') ;
                    output(15 downto 0) <= input(15 downto 0) ;
                when others => null ;
            end case ;
        end process ;
    end sign_extend_arch ;

