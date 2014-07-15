LIBRARY ieee;
USE ieee.numeric_std.all;
USE ieee.std_logic_1164.all;

PACKAGE processor_functions IS
    TYPE opcode IS (load, store, add, nott, andd, orr, xorr, inc, sub, branch);
    FUNCTION Decode (word: STD_LOGIC_VECTOR) RETURN opcode;
    CONSTANT n: integer := 12;
	 CONSTANT wordlen: integer := 12;
    CONSTANT oplen: integer := 4;
    TYPE memory_array IS ARRAY (0 to 2**(n-oplen-1)) of STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    CONSTANT reg_zero: unsigned (n-1 DOWNTO 0) := (OTHERS => '0');
END PACKAGE processor_functions;

PACKAGE BODY processor_functions IS
    FUNCTION Decode (word: STD_LOGIC_VECTOR) return opcode IS
        VARIABLE opcode_out: opcode;
    BEGIN
        CASE word(n-1 DOWNTO n-oplen) IS
            WHEN "0000" => opcode_out := load;
            WHEN "0001" => opcode_out := store;
            WHEN "0010" => opcode_out := add;
            WHEN "0011" => opcode_out := nott;
            WHEN "0100" => opcode_out := andd;
            WHEN "0101" => opcode_out := orr;
            WHEN "0110" => opcode_out := xorr;
            WHEN "0111" => opcode_out := inc;
            WHEN "1000" => opcode_out := sub;
            WHEN "1001" => opcode_out := branch;
            WHEN OTHERS => null;
        END CASE;
        RETURN opcode_out;
    END FUNCTION decode;
END PACKAGE BODY processor_functions;