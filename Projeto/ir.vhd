LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.processor_functions.all;
ENTITY ir IS
    PORT (clk : IN STD_LOGIC; -- sinal de clock
			  nrst : IN STD_LOGIC; -- reset ativo em zero
			  IR_load : IN STD_LOGIC; -- indica se o IR esta no modo load
			  IR_valid : IN STD_LOGIC; -- indica se o IR esta ativo
			  IR_opcode : OUT opcode; -- sinal de saida com o opcode decodificado
			  IR_bus : INOUT STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- acesso ao barramento externo
			  IR_opcode_leds: OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
END ENTITY IR;

ARCHITECTURE RTL OF IR IS
    SIGNAL IR_internal : STD_LOGIC_VECTOR (n-1 DOWNTO 0); -- sinal interno do IR
BEGIN
	-- O IR, por padrao, eh configurado no modo address (passar valor interno para sai­da)
	-- caso valid = 0, sai­da no barramento deve ir para Z
	IR_bus <= IR_internal
					WHEN IR_valid = '1' 
						ELSE (OTHERS => 'Z');
		  
	-- O opcode de sai­da deve ser decodificado assincronamente quando o valor no IR mudar.	  
	IR_opcode <= Decode(IR_internal);
	
	IR_opcode_leds <= IR_internal(n-1 DOWNTO n-oplen);
	 
	PROCESS (clk, nrst) IS
	BEGIN
		-- Se reset for para 0, o valor do registrador interno deve ir para 0s.
		IF nrst = '0' THEN
			IR_internal <= (OTHERS => '0'); 
		ELSIF rising_edge(clk) THEN
			IF IR_load = '1' THEN
				IR_internal <= IR_bus; -- na borda de subida, o valor do barramento deve ser enviado para o registrador interno (modo load)
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE RTL;