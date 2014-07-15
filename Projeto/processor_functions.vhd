LIBRARY ieee;
USE ieee.numeric_std.all;
USE ieee.std_logic_1164.all;

PACKAGE processor_functions IS
	TYPE opcode IS (LOAD, STORE, ADD, NOTT, ANDD, ORR, XORR, INC, SUB, JUMP, BZERO, BGREATER, BLESS, DEC, NOP, WAITT);
	FUNCTION decode (word: STD_LOGIC_VECTOR) RETURN opcode;
	FUNCTION cmdDecode (op: opcode) RETURN STD_LOGIC_VECTOR;
	CONSTANT n: integer := 12;
	CONSTANT seg_en: STD_LOGIC := '1';
	CONSTANT wordlen: integer := 12;
	CONSTANT oplen: integer := 4;
	CONSTANT clk_frequency : integer := 1000000;
	CONSTANT mem_limit: INTEGER := 128;
	TYPE memory_array IS ARRAY (0 to 2**(n-oplen-1)) of STD_LOGIC_VECTOR(n-1 DOWNTO 0);
	CONSTANT reg_zero: unsigned (n-1 DOWNTO 0) := (OTHERS => '0');
END PACKAGE processor_functions;

PACKAGE BODY processor_functions IS
	FUNCTION decode (word: STD_LOGIC_VECTOR) RETURN opcode IS
		VARIABLE opcode_out: opcode;
	BEGIN
		CASE word(n-1 DOWNTO n-oplen) IS
			WHEN "0000" => opcode_out := LOAD;
			WHEN "0001" => opcode_out := STORE;
			WHEN "0010" => opcode_out := ADD;
			WHEN "0011" => opcode_out := SUB;
			WHEN "0100" => opcode_out := INC;
			WHEN "0101" => opcode_out := DEC;
			WHEN "0110" => opcode_out := NOTT;
			WHEN "0111" => opcode_out := ANDD;
			WHEN "1000" => opcode_out := ORR;
			WHEN "1001" => opcode_out := XORR;
			WHEN "1010" => opcode_out := JUMP;
			WHEN "1011" => opcode_out := BZERO;
			WHEN "1100" => opcode_out := BGREATER;
			WHEN "1101" => opcode_out := BLESS;
			WHEN "1110" => opcode_out := WAITT;
			WHEN "1111" => opcode_out := NOP;
			WHEN OTHERS => NULL;
		END CASE;
		RETURN opcode_out;
	END FUNCTION decode;

	FUNCTION cmdDecode (op: opcode) RETURN STD_LOGIC_VECTOR IS
		VARIABLE cmd_out: STD_LOGIC_VECTOR(3 DOWNTO 0);
	BEGIN
		CASE op IS
			WHEN LOAD => cmd_out := "0000";
			WHEN ADD => cmd_out := "0001";
			WHEN NOTT => cmd_out := "0010";
			WHEN ORR => cmd_out := "0011";
			WHEN ANDD => cmd_out := "0100";
			WHEN XORR => cmd_out := "0101";
			WHEN INC => cmd_out := "0110";
			WHEN SUB => cmd_out := "0111";
			WHEN DEC => cmd_out := "1000";
			WHEN OTHERS => NULL;
		END CASE;
		RETURN cmd_out;
	END FUNCTION cmdDecode;
END PACKAGE BODY processor_functions;