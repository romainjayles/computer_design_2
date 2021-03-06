----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:41:21 10/30/2015 
-- Design Name: 
-- Module Name:    IF_stage - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity IF_stage is
Port ( 
	 reset : in STD_LOGIC;
	 clk : in STD_LOGIC;
	 stall_hazard : in STD_LOGIC;
	 processor_enable : in  std_logic;
	 PCsrc				: in	std_logic;
	 PCbranch			: in	std_logic_vector(31 downto 0);
	 pc_enable        : in  std_logic;
	 stall            : in std_logic;
	 instruction_out  : out std_logic_vector(31 downto 0);
    imem_data_in     : in  std_logic_vector(31 downto 0);
    imem_address     : out std_logic_vector(7 downto 0);
	 pc_out        : out  std_logic_vector(31 downto 0)
	 );

end IF_stage;

architecture Behavioral of IF_stage is

-- The actual value of PC
  signal PC                  : std_logic_vector(31 downto 0) := x"00000000";
  -- The Value of PC which will be updated
  signal next_PC             : std_logic_vector(31 downto 0);
  -- PC -1
  signal stall_PC             : std_logic_vector(31 downto 0);
  -- PC +1
  signal increment_PC        : std_logic_vector(31 downto 0);

	signal current_instruction : std_logic_vector(31 downto 0);

begin
	-- When the Processor is stalled, we use stall_PC to querry the Instruction memory
	pc_out <= PC when stall_hazard = '0' else
	stall_PC;

	-- The mux used by branch and jump
  with PCsrc select
	next_PC <=
	increment_PC when '0',
	PCbranch     when '1';

	-- PC 
	 increment_PC        <= std_logic_vector(unsigned(PC) + 1);  -- PC +1
	imem_address        <= PC(7 downto 0) when stall_hazard = '0' else
	stall_PC(7 downto 0);
	
	-- instruction --
	with stall select
		current_instruction <= 
		imem_data_in when '0',
		x"00000000" when '1';
		
	instruction_out     <= current_instruction;
	 
	process(clk, reset, processor_enable, pc_enable, stall_hazard) is
		begin
		 if reset = '1' then
			PC <= x"00000000";
			-- if the processor is enable, if we are not reseting and if control
			-- allow it
		 elsif rising_edge(processor_enable) then
			PC <= x"00000001";
			
		 elsif rising_edge(clk) and processor_enable = '1' and pc_enable = '1' and stall_hazard='0' then
			-- PC takes the next value
			PC <= next_PC;
			stall_PC <= std_logic_vector(signed(next_PC) -1);
		
		 end if;
  end process;
  

end Behavioral;

