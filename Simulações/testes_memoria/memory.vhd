---- Memory ------------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.processor_functions.all;
------------------------------------------------------------------------------------------------------------------
ENTITY memory IS
	PORT (clk, nrst: IN STD_LOGIC; -- reset ativo em zero
				MDR_load: IN STD_LOGIC; -- sinal de carregamento do BUS para MDR
				MAR_load: IN STD_LOGIC; -- sinal de carregamento do BUS para MAR
				MEM_valid: IN STD_LOGIC; -- sinal que indica que o resultado da MDR deve ser colocado em MEM_bus (ou Z se 0)
				MEM_en: IN STD_LOGIC; -- ativacao da memorica para operacoes de leitura e escrita
				MEM_rw: IN STD_LOGIC; -- flag que indica se a operacao a ser realizada eh de leitura ou escrita
				MEM_bus: INOUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)); -- barramento de entrada/saida
END ENTITY memory;
------------------------------------------------------------------------------------------------------------------
ARCHITECTURE rtl OF memory IS
	SIGNAL mdr: STD_LOGIC_VECTOR(wordlen-1 DOWNTO 0); -- registrador de dados
	SIGNAL mar: UNSIGNED(wordlen-oplen-1 DOWNTO 0); -- registrador de enderecos
BEGIN
	-- Se o MEM_valid = '1', manda o valor do resultado do MDR pro barramento. Caso contrario, manda Z.
	MEM_bus <= mdr 
					WHEN MEM_valid = '1' 
						ELSE (others => 'Z');
						
	PROCESS (clk, nrst) IS
		VARIABLE contents: memory_array; -- conteudo da memoria
		
		-- Definicao do valor padrao da memoria (para simular ROM com programa)
		CONSTANT program: memory_array := (0 => "000000000011",
														1 => "001000000100",
														2 => "000100000101",
														3 => "000000001100",
														4 => "000000000011",
														5 => "000000000000" ,
														OTHERS => (OTHERS => '0'));
	BEGIN
		-- De forma assincrona, se o reset ficar em nivel 0, reseta os registradores e conteudo da memoria
		IF nrst = '0' THEN
			mdr <= (OTHERS => '0');
			mar <= (OTHERS => '0');
			contents := program;
		-- Se teve uma borda de subida no clock, faz as outras coisas
		ELSIF (clk'EVENT AND clk='1') THEN
			-- A ordem de prioridade eh: Carregamento do MAR, Carregamento do MDR e leitura/escrita
			IF MAR_load = '1' THEN
				mar <= UNSIGNED(MEM_bus(n-oplen-1 DOWNTO 0)); -- Para carregar MAR, basta ler o endereco do que tem no BUS (desconsidera o OPCODE)
			ELSIF MDR_load = '1' THEN
				mdr <= MEM_bus; -- Para carregar MDR, basta ler direto do BUS
			ELSIF MEM_en = '1' THEN
				IF MEM_rw = '0' THEN
					mdr <= contents(to_integer(mar)); -- Se for leitura, pega o conteudo do endereco salvo em MAR e manda para MDR
				ELSE
					contents(to_integer(mar)) := mdr; -- Se for escrita, escreve MDR no endereco salvo em MAR
				END IF;
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE rtl;
------------------------------------------------------------------------------------------------------------------