---- IO ------------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.processor_functions.all;
------------------------------------------------------------------------------------------------------------------
ENTITY io IS
	PORT (clk, nrst: IN STD_LOGIC; -- reset ativo em zero
				IODR_load: IN STD_LOGIC; -- sinal de carregamento do BUS para IODR
				IOAR_load: IN STD_LOGIC; -- sinal de carregamento do BUS para IOAR
				IO_valid: IN STD_LOGIC; -- sinal que indica que o resultado da IODR deve ser colocado em IO_bus (ou Z se 0)
				IO_en: IN STD_LOGIC; -- ativacao do componente para operacoes de leitura e escrita
				IO_rw: IN STD_LOGIC; -- flag que indica se a operacao a ser realizada eh de leitura ou escrita
				IO_bus: INOUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);  -- barramento de entrada/saida

				-- Switches
				switches: IN std_logic_vector(17 downto 0);
				
				-- Displays
				hex3: OUT std_logic_vector(0 TO 7);
				hex2: OUT std_logic_vector(0 TO 7);
				hex1: OUT std_logic_vector(0 TO 7);
				hex0: OUT std_logic_vector(0 TO 7));
END ENTITY io;

ARCHITECTURE processor_io OF io IS
	SIGNAL iodr: STD_LOGIC_VECTOR(wordlen-1 DOWNTO 0); -- registrador de dados
	SIGNAL ioar: UNSIGNED(wordlen-oplen-1 downto 0); -- registrador de enderecos
	SIGNAL bcd0: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL bcd1: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL bcd2: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL bcd3: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL bcd_en: STD_LOGIC;
	
	COMPONENT bcd_to_7seg IS
		PORT (bcd: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
				en: IN std_logic;
				output: OUT STD_LOGIC_VECTOR (0 TO 7));
	END COMPONENT;
BEGIN
	-- Se o IO_valid = '1', manda o valor do resultado do iodr pro barramento. Caso contrario, manda Z.
	IO_bus <= iodr 
					WHEN IO_valid = '1' AND ioar(7) = '1'
						ELSE (others => 'Z');
						
	-- Gera a visualizacao 7seg
	bcd0_7seg: bcd_to_7seg PORT MAP(bcd0, seg_en, hex0);
	bcd1_7seg: bcd_to_7seg PORT MAP(bcd1, seg_en, hex1);
	bcd2_7seg: bcd_to_7seg PORT MAP(bcd2, seg_en, hex2);
	bcd3_7seg: bcd_to_7seg PORT MAP(bcd3, seg_en, hex3);
						
	PROCESS (clk, nrst) IS
	BEGIN
		-- De forma assincrona, se o reset ficar em nivel 0, reseta os registradores e conteudo da memoria
		IF nrst = '0' THEN
			iodr <= (OTHERS => '0');
			ioar <= (OTHERS => '0');
			bcd0 <= "0000";
			bcd1 <= "0000";
			bcd2 <= "0000";
			bcd3 <= "0000";
		-- Se teve uma borda de subida no clock, faz as outras coisas
		ELSIF rising_edge(clk) THEN
			IF IOAR_load = '1' THEN
				ioar <= UNSIGNED(IO_bus(n-oplen-1 DOWNTO 0)); -- Para carregar IOAR, basta ler o endereco do que tem no BUS (desconsidera o OPCODE)
			ELSIF IODR_load = '1' THEN
				iodr <= IO_BUS; -- Para carregar IODR, basta ler direto do BUS
			ELSIF IO_en = '1' THEN
				IF IO_rw = '0' THEN
				-- Porta '0' de IO é de leitura (switches)
					IF to_integer(ioar) = mem_limit + 0 THEN
						iodr <= switches(11 downto 0);
					END IF;
				ELSE
					-- Porta '1' de IO é de saída.
					IF ioar = mem_limit + 1 THEN
						bcd0 <= iodr(3 downto 0);
						bcd1 <= iodr(7 downto 4);
					-- Porta '2' de IO é de saída.
					ELSIF ioar = mem_limit + 2 THEN
						bcd2 <= iodr(3 downto 0);
						bcd3 <= iodr(7 downto 4);
					END IF;
				END IF;
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE processor_io;