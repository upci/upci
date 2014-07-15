---- Controller --------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.processor_functions.all;
------------------------------------------------------------------------------------------------------------------
ENTITY controller IS
	PORT (clk, nrst: IN std_logic;
			CONTROL_bus: INOUT std_logic_vector(n-1 DOWNTO 0);
			state_7seg: OUT std_logic_vector(0 TO 7);

			-- IR
			IR_opcode: IN opcode;
			IR_load: OUT std_logic;
			IR_valid: OUT std_logic;

			-- PC
			PC_inc: OUT std_logic;
			PC_load: OUT std_logic;
			PC_valid: OUT std_logic;

			-- Memory
			MDR_load: OUT std_logic;
			MAR_load: OUT std_logic;
			MEM_valid: OUT std_logic;
			MEM_en: OUT std_logic;
			MEM_rw: OUT std_logic;

			-- ALU
			ALU_zero: IN std_logic;
			ALU_valid: OUT std_logic;
			ALU_slt: IN std_logic;
			ALU_enable: OUT std_logic;
			ALU_cmd: OUT std_logic_vector(3 DOWNTO 0);
			
			-- IO
			IODR_load: OUT STD_LOGIC;
			IOAR_load: OUT STD_LOGIC;
			IO_valid: OUT STD_LOGIC;
			IO_en: OUT STD_LOGIC;
			IO_rw: OUT STD_LOGIC;

			-- WAKE
			WAKE_signal: IN STD_LOGIC;
			waiting: OUT STD_LOGIC);
			
END ENTITY controller;
------------------------------------------------------------------------------------------------------------------
ARCHITECTURE RTL OF controller IS
	TYPE states IS (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10);
	SIGNAL current_state, next_state: states;
	SIGNAL BRANCH_trigger: std_logic;
	SIGNAL state_vector: STD_LOGIC_VECTOR(3 DOWNTO 0);
	COMPONENT bcd_to_7seg IS
		PORT (bcd: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
				en: IN std_logic;
				output: OUT STD_LOGIC_VECTOR (0 TO 7));
	END COMPONENT;
BEGIN
	-- Converte o estado atual para um std_logic_vector com sua posicao na lista
	state_vector <= std_logic_vector(to_unsigned(states'pos(current_state), 4));
	
	-- Gera a visualizacao 7seg 
	state7seg: bcd_to_7seg PORT MAP(state_vector, seg_en, state_7seg);
	
	-- Indicador de se o branch deve ser aceito
	BRANCH_trigger <= '1' WHEN ((IR_opcode = BZERO AND ALU_zero = '1') OR (IR_opcode = BLESS AND ALU_slt = '1') OR (IR_opcode = BGREATER AND ALU_zero = '0' AND ALU_slt = '0')) ELSE '0';
	
	-- Esta em waiting?
	waiting <= '1' WHEN current_state = s10 ELSE '0';
	
	-- Processo que gerencia a transicao do current_state para o next_state
	-- e a configuracao de reset
	state_sequence: PROCESS (clk, nrst) BEGIN
		IF nrst = '0' THEN -- reset assi­ncrono
			current_state <= s0;
		ELSE
			IF rising_edge(clk) THEN -- mudanca de estado eh sincrona
				current_state <= next_state;
			END IF;
		END IF;
	END PROCESS state_sequence;

	-- espera a mudanca de estado ou opcode
	-- processo que de fato mudam os sinais de controle conforme a transicao
	state_machine: PROCESS ( current_state, IR_opcode ) IS
	BEGIN
		-- Reset all the control SIGNALs
		IR_load <= '0';
		IR_valid <= '0';
		PC_inc <= '0';
		PC_load <= '0';
		PC_valid <= '0';
		MDR_load <= '0';
		MAR_load <= '0';
		MEM_valid <= '0';
		MEM_en <= '0';
		MEM_rw <= '0';
		ALU_valid <= '0';
		ALU_enable <= '0';
		ALU_cmd <= "0000";
		IODR_load <= '0';
		IOAR_load <= '0';
		IO_valid <= '0';
		IO_en <= '0';
		IO_rw <= '0';

		CASE current_state IS
			WHEN s0 =>
				MAR_load <= '1';
				PC_valid <= '1';
				PC_inc <= '1';
				next_state <= s1;

			WHEN s1 =>
				MEM_en <='1';
				next_state <= s2;

			WHEN s2 =>
				MEM_valid <= '1';
				IR_load <= '1';
				next_state <= s3;

			WHEN s3 =>
				IR_valid <= '1';
				MAR_load <= '1';
				IOAR_load <= '1';
				
				IF (IR_opcode = INC) THEN
					next_state <= s7;
				ELSIF (IR_opcode = JUMP) THEN
					next_state <= s9;
				ELSIF (IR_opcode = BZERO OR IR_opcode = BGREATER OR IR_opcode = BLESS) THEN
					next_state <= s8;
				ELSIF (IR_opcode = NOP) THEN
					next_state <= s0;
				ELSIF (IR_opcode = WAITT) THEN
					next_state <= s10;
				ELSIF (IR_opcode = STORE) THEN
					next_state <= s4;
				ELSE
					next_state <= s6;
				END IF;

			WHEN s4 =>
				ALU_valid <= '1';
				MDR_load <= '1';
				IODR_load <= '1';
				next_state <= s5;

			WHEN s5 =>
				MEM_en <= '1';
				MEM_rw <= '1';
				IO_en <= '1';
				IO_rw <= '1';
				next_state <= s0;

			WHEN s6 =>
				MEM_en <= '1';
				IO_en <= '1';
				next_state <= s7;

			WHEN s7 =>
				MEM_valid <= '1';
				IO_valid <= '1';
				ALU_enable <= '1';
				ALU_cmd <= cmdDecode(IR_opcode);
				next_state <= s0;

			WHEN s8 =>
				IF (BRANCH_trigger = '1') THEN
					next_state <= s9;
				ELSE
					next_state <= s0;
				END IF;

			WHEN s9 =>
				PC_load <= '1';
				IR_valid <= '1';
				next_state <= s0;
			
			WHEN s10 =>
				IF (WAKE_signal = '0') THEN
					next_state <= s0;
				END IF;
				
		END CASE;
	END PROCESS state_machine;
END ARCHITECTURE;
------------------------------------------------------------------------------------------------------------------