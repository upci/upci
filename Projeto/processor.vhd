-- The processor --
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.processor_functions.all;


ENTITY processor IS
	PORT (clk, nrst, WAKE_signal: IN std_logic;
			
			-- Switches
			switches: IN std_logic_vector(17 downto 0);
			
			-- Leds vermelhos
			red_leds: OUT std_logic_vector(17 downto 0);
			
			-- Leds verdes
			green_leds: OUT std_logic_vector(8 downto 0);
			
			-- 7 Seg
			hex7: OUT std_logic_vector(0 TO 7);
			hex6: OUT std_logic_vector(0 TO 7);
			hex5: OUT std_logic_vector(0 TO 7);
			hex4: OUT std_logic_vector(0 TO 7);
			hex3: OUT std_logic_vector(0 TO 7);
			hex2: OUT std_logic_vector(0 TO 7);
			hex1: OUT std_logic_vector(0 TO 7);
			hex0: OUT std_logic_vector(0 TO 7));
END ENTITY processor;

ARCHITECTURE processor OF processor IS
	SIGNAL CONTROL_bus: std_logic_vector(n-1 DOWNTO 0);
	SIGNAL clk_out: std_logic;
	
	-- IR
	SIGNAL IR_opcode: opcode;
	SIGNAL IR_load: std_logic;
	SIGNAL IR_valid: std_logic;
	SIGNAL IR_opcode_leds: std_logic_vector(3 DOWNTO 0);

	-- PC
	SIGNAL PC_inc: std_logic;
	SIGNAL PC_load: std_logic;
	SIGNAL PC_valid: std_logic;
	SIGNAL PC_7seg: std_logic_vector(0 TO 15);

	-- Memory
	SIGNAL MDR_load: std_logic;
	SIGNAL MAR_load: std_logic;
	SIGNAL MEM_valid: std_logic;
	SIGNAL MEM_en: std_logic;
	SIGNAL MEM_rw: std_logic;

	-- ALU
	SIGNAL ALU_zero: std_logic;
	SIGNAL ALU_slt: std_logic;
	SIGNAL ALU_valid: std_logic;
	SIGNAL ALU_enable: std_logic;
	SIGNAL ALU_cmd: std_logic_vector(3 DOWNTO 0);
	
	-- IO
	SIGNAL IODR_load: std_logic;
	SIGNAL IOAR_load: std_logic;
	SIGNAL IO_valid: std_logic;
	SIGNAL IO_en: std_logic;
	SIGNAL IO_rw: std_logic;
	
BEGIN
	-- Para visualizacao
	green_leds(0) <= not nrst;
	green_leds(7) <= not WAKE_signal;
	
	red_leds(17) <= clk_out;
	red_leds(11 DOWNTO 0) <= CONTROL_bus;
	red_leds(16 DOWNTO 13) <= IR_opcode_leds;
	
	hex7 <= "01100001";
	hex5 <= PC_7seg(8 TO 15);
	hex4 <= PC_7seg(0 TO 7);
	
	-- Divisor de clock
	clock_divisor : entity work.clock_divisor port map(clk, nrst, clk_out);
	
	-- Entidades internas
	controller : entity work.controller port map(clk_out, nrst, CONTROL_bus, hex6, IR_opcode, IR_load, IR_valid, PC_inc, PC_load, PC_valid, MDR_load, MAR_load, MEM_valid, MEM_en, MEM_rw, ALU_zero, ALU_valid, ALU_slt, ALU_enable, ALU_cmd, IODR_load, IOAR_load, IO_valid, IO_en, IO_rw, WAKE_signal, green_leds(8));
	memory : entity work.memory port map(clk_out, nrst, MDR_load, MAR_load, MEM_valid, MEM_en, MEM_rw, CONTROL_bus);
	alu : entity work.alu port map(clk_out, nrst, ALU_cmd, ALU_zero, ALU_slt, ALU_valid, ALU_enable, CONTROL_bus);
	ir : entity work.ir port map(clk_out, nrst, IR_load, IR_valid, IR_opcode, CONTROL_bus, IR_opcode_leds);
	pc : entity work.pc port map(clk_out, nrst, PC_inc, PC_load, PC_valid, CONTROL_bus, PC_7seg);
	io : entity work.io port map(clk_out, nrst, IODR_load, IOAR_load, IO_valid, IO_en, IO_rw, CONTROL_bus, switches, hex3, hex2, hex1, hex0);
END ARCHITECTURE;