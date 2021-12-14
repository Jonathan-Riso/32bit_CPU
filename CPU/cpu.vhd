library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity cpu is
    port (
        global_reset : in std_logic := '0';
	    global_clk : in std_logic := '0';

	    rs_out, rt_out : out std_logic_vector(3 downto 0):= (others => '0');
	    pc_out : out std_logic_vector(3 downto 0):= (others => '0');
	    overflow_output, zero_output : out std_logic); 
end cpu;

architecture cpu_arch of cpu is
    component pc_component is
    port ( in_address : in std_logic_vector(31 downto 0) := (others => '0');
        reset : in std_logic;
        clk : in std_logic;
        out_pc : out std_logic_vector(31 downto 0) := (others => '0'));
    end component;

    for PC : pc_component use entity work.pc(pc_arch);

    component instruct_cache is
    port( read : in std_logic_vector(4 downto 0);
    output : out std_logic_vector(31 downto 0));
    end component;

    for InstructCache : instruct_cache use entity work.instruct_cache(instruct_cache_arch);

    component next_address is
    port(	
        rt,rs	    	: in std_logic_vector(31 downto 0);  -- two register input
        pc		: in std_logic_vector(31 downto 0);
        target_address	: in std_logic_vector(25 downto 0);
        branch_type	: in std_logic_vector(1 downto 0);
        pc_sel	    	: in std_logic_vector(1 downto 0);
        next_pc	    	: out std_logic_vector(31 downto 0));
    end component;
    
    for NextAddress : next_address use entity work.next_address(next_address_arch);

    component regfile_component is
    port( din : in std_logic_vector(31 downto 0);
        reset : in std_logic;
        clk	: in std_logic;
        write : in std_logic;
        read_a : in std_logic_vector(4 downto 0);
        read_b : in std_logic_vector(4 downto 0);
        write_address : in std_logic_vector(4 downto 0);
        out_a : out std_logic_vector(31 downto 0);
        out_b : out std_logic_vector(31 downto 0));
    end component;
    
    for RegFile : regfile_component use entity work.regfile(regfile_arch);

    component sign_extend is
    port( input : in std_logic_vector(15 downto 0);
        func : in std_logic_vector(1 downto 0);
        output : out std_logic_vector(31 downto 0));
    end component;
    
    for SignExtend : sign_extend use entity work.sign_extend(sign_extend_arch);

    component alu_component is
    port(	
        x,y : in std_logic_vector(31 downto 0);
        add_sub : in std_logic;
        logic_func : in std_logic_vector(1 downto 0);
        func : in std_logic_vector(1 downto 0);

        output : out std_logic_vector(31 downto 0);
        overflow : out std_logic;
        zero : out std_logic);
    end component;

    for ALU : alu_component use entity work.alu(arch_alu);

    component data_cache is
    port(	din : in std_logic_vector(31 downto 0);
        reset : in std_logic;
        clk : in std_logic;
        read_address : in std_logic_vector(4 downto 0);
        data_cache_write : in std_logic;
        output : out std_logic_vector(31 downto 0));
    end component;

    for DataCache : data_cache use entity work.data_cache(data_cache_arch);

    signal pc_output, next_pc_output, instruct_cache_output, data_cache_output : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
    signal a_output, b_output, alu_output, sign_extend_output, alu_input, regfile_input : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
    signal reg_address_input : std_logic_vector(4 downto 0) := (others => '0');
    signal pc_s, branch_t, alu_func, alu_logic_func : std_logic_vector(1 downto 0) := "00";
    signal addsub, data_write, reg_write, reg_dst, alu_src, reg_in_src : std_logic := '0';

-- opcode, func and control signal holder respectively for control unit implementation
signal opcode , instruc_func : std_logic_vector(5 downto 0) := (others => '0');
signal ctrl_signal : std_logic_vector(13 downto 0);

begin
-- Control Unit
process(instruct_cache_output, opcode, instruc_func, ctrl_signal, global_clk, global_reset)
begin
    opcode <= instruct_cache_output(31 downto 26);
    instruc_func <= instruct_cache_output(5 downto 0);

    case opcode is
        when "000000" =>
            if (instruc_func = "100100") then ctrl_signal <= "11101000110000"; -- and
            elsif (instruc_func = "100101") then ctrl_signal <= "11100001110000"; -- or
            elsif (instruc_func = "100110") then ctrl_signal <= "11100010110000"; -- xor
            elsif (instruc_func = "100111") then ctrl_signal <= "11100011110000"; -- nor
            elsif (instruc_func = "001000") then ctrl_signal <= "00000000000010"; -- jr
            elsif (instruc_func = "100000") then ctrl_signal <= "11100000100000"; -- add
            elsif (instruc_func = "100010") then ctrl_signal <= "11101000100000"; -- sub
            elsif (instruc_func = "101010") then ctrl_signal <= "11100000010000"; -- slt
            else ctrl_signal <= "00000000000000"; --  nothing
            end if;
        when "000001" => ctrl_signal <= "00000000001100"; -- less than zero
        when "000010" => ctrl_signal <= "00000000000001"; -- j
        when "000100" => ctrl_signal <= "00000000000100"; -- beq
        when "000101" => ctrl_signal <= "00000000001000"; -- bne
        when "001000" => ctrl_signal <= "10110000100000"; -- addi
        when "001010" => ctrl_signal <= "10110000010000"; -- slti
        when "001100" => ctrl_signal <= "10110000110000"; -- andi
        when "001101" => ctrl_signal <= "10110001110000"; -- ori
        when "001110" => ctrl_signal <= "10110010110000"; -- xori
        when "001111" => ctrl_signal <= "10110000000000"; -- lui
        when "100011" => ctrl_signal <= "10010010100000"; -- lw
        when "101011" => ctrl_signal <= "00010100100000"; -- sw
        when others => ctrl_signal <= "00000000000000"; -- nothing
    end case;

    reg_write <= ctrl_signal(13);
    reg_dst	 <= ctrl_signal(12);
    reg_in_src <= ctrl_signal(11);
    alu_src <= ctrl_signal(10);
    addsub <= ctrl_signal(9);
    data_write <= ctrl_signal(8);
    alu_logic_func <= ctrl_signal(7 downto 6);
    alu_func <= ctrl_signal(5 downto 4);
    branch_t <= ctrl_signal(3 downto 2);
    pc_s <= ctrl_signal(1 downto 0);
end process; 


PC: pc_component port map(in_address => next_pc_output, reset => global_reset, clk => global_clk, out_pc => pc_output);

InstructCache: instruct_cache port map(read => pc_output(4 downto 0), output => instruct_cache_output);

NextAddress: next_address port map(rt => b_output, rs => a_output, pc => pc_output, target_address => instruct_cache_output(25 downto 0), 
                                    branch_type => branch_t, pc_sel => pc_s, next_pc => next_pc_output);

RegFile: regfile_component port map(din => regfile_input, reset => global_reset, clk => global_clk, write => reg_write, 
		      read_a => instruct_cache_output(25 downto 21), read_b => instruct_cache_output(20 downto 16),
		      write_address => reg_address_input, out_a => a_output, out_b => b_output);

SignExtend: sign_extend port map(input => instruct_cache_output(15 downto 0), func => alu_func, output => sign_extend_output);

ALU: alu_component port map(x => a_output, y => alu_input, add_sub => addsub, logic_func => alu_logic_func, 
                    func => alu_func, output => alu_output, overflow => overflow_output, zero => zero_output);

DataCache: data_cache port map(din => b_output, reset => global_reset, clk => global_clk, 
		      read_address => alu_output(4 downto 0), data_cache_write => data_write, output => data_cache_output);



-- Other connections
reg_address_input <= instruct_cache_output(20 downto 16) WHEN (reg_dst = '0') ELSE
	      instruct_cache_output(15 downto 11) WHEN (reg_dst = '1');

alu_input <= sign_extend_output WHEN (alu_src = '1') ELSE
	 b_output WHEN (alu_src = '0');

regfile_input <= alu_output WHEN (reg_in_src = '1') ELSE
	 data_cache_output WHEN (reg_in_src = '0');

rs_out <= a_output(3 downto 0);
rt_out <= b_output(3 downto 0);
pc_out <= pc_output(3 downto 0);

end cpu_arch;
