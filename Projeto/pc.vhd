---- Program Counter ---------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.numeric_std.all;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;	
USE work.processor_functions.all;
------------------------------------------------------------------------------------------------------------------
ENTITY pc IS
	PORT (clk, nrst: IN STD_LOGIC; -- reset ativo em zero
				PC_inc: IN STD_LOGIC; -- sinal que indica que o PC deve ser incrementado
				PC_load: IN STD_LOGIC; -- sinal que indica que PC deve ser substitui­do pelo valor em PC_bus
				PC_valid: IN STD_LOGIC; -- sinal que indica que o valor de PC deve ser colocado em PC_bus (ou Z se 0)
				PC_bus: INOUT STD_LOGIC_VECTOR(n-1  DOWNTO 0);
				PC_7seg: OUT STD_LOGIC_VECTOR(0 TO 15)); -- barramento de entrada/saida
END ENTITY pc;
------------------------------------------------------------------------------------------------------------------
ARCHITECTURE rtl OF pc IS
	SIGNAL counter: INTEGER RANGE 0 to 2**n -1; -- contador em si
	SIGNAL counter_vector: STD_LOGIC_VECTOR(n-1  DOWNTO 0);
	COMPONENT bcd_to_7seg IS
		PORT (bcd: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
				en: IN STD_LOGIC;
				output: OUT STD_LOGIC_VECTOR (0 TO 7));
	END COMPONENT;
BEGIN
	-- Se o PC_valid = '1', manda o valor do PC pro barramento. Caso contrario, manda Z.
	PC_bus <= counter_vector
					WHEN PC_valid = '1' 
						ELSE (OTHERS => 'Z');
						
	counter_vector <= STD_LOGIC_VECTOR(to_unsigned(counter, PC_bus'length));
	
	-- Gera a visualizacao 7seg 
	counter7seg_0: bcd_to_7seg PORT MAP(counter_vector(3 DOWNTO 0), seg_en, PC_7seg(0 TO 7));
	counter7seg_1: bcd_to_7seg PORT MAP(counter_vector(7 DOWNTO 4), seg_en, PC_7seg(8 TO 15));
	
	PROCESS (clk, nrst) IS
	BEGIN
		-- De forma assincrona, se o reset ficar em ni­vel 0, volta o contador pra 0
		IF nrst = '0' THEN
			counter <= 0;
		-- Se teve uma borda de subida no clock, faz as outras coisas
		ELSIF rising_edge(clk) THEN
			-- A maior prioridade eh do incremento. Se esta em 1, incrementa o PC
			IF PC_inc = '1' THEN
				counter <= counter + 1;
			-- Caso contrario, verifica se eh pra carregar o valor do bus.
			ELSIF PC_load = '1' THEN
				-- O PC_load deve carregar apenas o endereco, desconsiderando o OPCODE
				counter <= TO_INTEGER(UNSIGNED(PC_bus(n-oplen-1 DOWNTO 0))); -- Cast de STD_LOGIC_VECTOR pra INTEGER
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE rtl;
------------------------------------------------------------------------------------------------------------------