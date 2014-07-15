-------- Clock Divisor -----------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.processor_functions.all;
----------------------------------------------------------------------------------
ENTITY clock_divisor IS
	PORT (clk, nrst : IN STD_LOGIC; -- clock de entrada, que é o de 25MHz da placa
			clk_out : BUFFER STD_LOGIC); -- clock de saída, configurável pelo "clk_frequency" de "processor_functions"
			
END ENTITY clock_divisor;
----------------------------------------------------------------------------------

ARCHITECTURE rtl OF clock_divisor IS
	BEGIN
		PROCESS (clk, nrst)
			VARIABLE count : INTEGER RANGE 0 TO clk_frequency;
			BEGIN
				IF (nrst = '0') THEN
					count := 0;
					clk_out <= '0';
				ELSIF rising_edge(clk) THEN
					count := count + 1;
					IF (count = clk_frequency) THEN
						clk_out <= NOT clk_out;
						count := 0;
					END IF;
				END IF;
		END PROCESS;
END rtl;