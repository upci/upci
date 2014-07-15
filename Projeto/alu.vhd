---- Arithmetic Logic Unit ---------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.numeric_std.all;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;	
USE work.processor_functions.all;
------------------------------------------------------------------------------------------------------------------
ENTITY alu IS
	PORT (clk, nrst: IN STD_LOGIC; -- reset ativo em zero
			ALU_cmd: IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- 3 bits que indicam a operacao a ser executada pela alu
			ALU_zero: OUT STD_LOGIC; -- flag que indica se o resultado da alu foi zero
			ALU_slt: OUT STD_LOGIC; -- flag que indica se o resultado da alu foi menor que zero
			ALU_valid: IN STD_LOGIC; -- sinal que indica que o resultado da ALU deve ser colocado em ALU_bus (ou Z se 0)
			ALU_enable: IN STD_LOGIC; -- sinal que indica se a ALU deve realizar alguma operacao
			ALU_bus: INOUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)); -- barramento de entrada/saida
END ENTITY alu;
------------------------------------------------------------------------------------------------------------------
ARCHITECTURE rtl OF alu IS
	SIGNAL ACC: STD_LOGIC_VECTOR (n-1 DOWNTO 0); -- acumulador que guardara os resultados da alu
BEGIN
	-- Se o ALU_valid = '1', manda o valor do resultado da ALU pro barramento. Caso contrario, manda Z.
	ALU_bus <= ACC 
					WHEN ALU_valid = '1' 
						ELSE (others => 'Z');

	-- Define a flag ALU_zero como 1 caso o acumulador seja todo 0
	ALU_zero <= '1' 
						WHEN UNSIGNED(ACC) = reg_zero 
							ELSE '0';
							
	ALU_slt <= '1' 
					WHEN SIGNED(ACC) < 0 
						ELSE '0';
	
	PROCESS (clk, nrst) IS
	BEGIN
		-- De forma assincrona, se o reset ficar em nivel 0, volta o acumulador para 0
		IF nrst = '0' THEN
			ACC <= (others => '0');
		-- Se teve uma borda de subida no clock, faz as outras coisas
		ELSIF rising_edge(clk) THEN
			IF ALU_enable = '1' THEN
				-- Verifica o comando para poder decidir o que fazer
				CASE ALU_cmd IS
					-- Carrega o valor do barramento no ACC (ACC = 0 + BUS)
					WHEN "0000" => ACC <= ALU_bus;
					
					-- Soma o valor do barramento ao ACC (ACC = ACC + BUS)
					WHEN "0001" => ACC <= ACC + ALU_bus;	
					
					-- NOT do valor do barramento (ACC = not BUS)
					WHEN "0010" => ACC <= NOT ALU_bus;
					
					-- OR do valor do barramento com o ACC (ACC = ACC or BUS)
					WHEN "0011" => ACC <= ACC OR ALU_bus;
					
					-- AND do valor do barramento com o ACC (ACC = ACC and BUS)
					WHEN "0100" => ACC <= ACC AND ALU_bus;
					
					-- XOR do valor do barramento com o ACC (ACC = ACC xor BUS)
					WHEN "0101" => ACC <= ACC XOR ALU_bus;
					
					-- Incrementa o ACC (ACC = ACC + 1)
					WHEN "0110" => ACC <= ACC + 1;
					
					-- Subtracao
					WHEN "0111" => ACC <= ACC - ALU_bus;
					
					-- Decremento
					WHEN "1000" => ACC <= ACC - 1;
					
					WHEN OTHERS => ACC <= ACC;
				END CASE;
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE rtl;
------------------------------------------------------------------------------------------------------------------