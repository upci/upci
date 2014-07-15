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
	SIGNAL dataIn: std_logic_vector (wordlen-1 DOWNTO 0);
	SIGNAL dataOut: std_logic_vector (wordlen-1 DOWNTO 0);
	
	COMPONENT ram_infer IS
	PORT
   (
      clock: IN   std_logic;
      data:  IN   std_logic_vector (wordlen-1 DOWNTO 0);
      write_address:  IN   integer RANGE 0 to 2**(n-oplen-1);
      read_address:   IN   integer RANGE 0 to 2**(n-oplen-1);
      we:    IN   std_logic;
      q:     OUT  std_logic_vector (wordlen-1 DOWNTO 0)
   );
	END COMPONENT;
	
BEGIN
	mem1: ram_infer PORT MAP (clk, dataIn, to_integer(mar), to_integer(mar), MEM_rw, dataOut);
	-- Se o MEM_valid = '1', manda o valor do resultado do MDR pro barramento. Caso contrario, manda Z.
	MEM_bus <= mdr 
					WHEN MEM_valid = '1' 
						ELSE (others => 'Z');
						
	PROCESS (clk, nrst) IS
	--	VARIABLE contents: memory_array; -- conteudo da memoria
		
		-- Definicao do valor padrao da memoria (para simular ROM com programa)
		CONSTANT program: memory_array := (0 => "0000000000000011",
														1 => "0000001000000100",
														2 => "0000000100000101",
														3 => "0000000000001100",
														4 => "0000000000000011",
														5 => "0000000000000000" ,
														OTHERS => (OTHERS => '0'));
	BEGIN
		-- De forma assincrona, se o reset ficar em nivel 0, reseta os registradores e conteudo da memoria
		IF nrst = '0' THEN
			mdr <= (OTHERS => '0');
			mar <= (OTHERS => '0');
			FOR i IN 0 TO 2**(n-oplen-1) LOOP
				dataIn <= program(i);
			END LOOP;
		-- Se teve uma borda de subida no clock, faz as outras coisas
		ELSIF (clk'EVENT AND clk='1') THEN
			-- A ordem de prioridade eh: Carregamento do MAR, Carregamento do MDR e leitura/escrita
			IF MAR_load = '1' THEN
				mar <= UNSIGNED(MEM_bus(n-oplen-1 DOWNTO 0)); -- Para carregar MAR, basta ler o endereco do que tem no BUS (desconsidera o OPCODE)
			ELSIF MDR_load = '1' THEN
				mdr <= MEM_bus; -- Para carregar MDR, basta ler direto do BUS
			ELSIF MEM_en = '1' THEN
				IF MEM_rw = '0' THEN
				--	mdr <= contents(to_integer(mar)); -- Se for leitura, pega o conteudo do endereco salvo em MAR e manda para MDR
					mdr <= dataOut;
				ELSE
				--	contents(to_integer(mar)) := mdr; -- Se for escrita, escreve MDR no endereco salvo em MAR
					dataIn <= mdr;
				END IF;
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE rtl;
-------------------------------------------------------------------------------------------------------------------