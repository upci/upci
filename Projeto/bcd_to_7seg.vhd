--------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
--------------------------------------------------------
ENTITY bcd_to_7seg IS
	PORT (bcd: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			en: IN std_logic;
			output: OUT STD_LOGIC_VECTOR (0 TO 7));
END bcd_to_7seg;
--------------------------------------------------------
ARCHITECTURE bcd_to_7seg OF bcd_to_7seg IS
	SIGNAL segment: STD_LOGIC_VECTOR (0 TO 7);
BEGIN
	output <= segment WHEN en = '1' ELSE "11111111";
	WITH bcd SELECT
		segment <= "00000011" WHEN "0000", -- 0
					 "10011111" WHEN "0001", -- 1
					 "00100101" WHEN "0010", -- 2
					 "00001101" WHEN "0011", -- 3
					 "10011001" WHEN "0100", -- 4
					 "01001001" WHEN "0101", -- 5
					 "01000001" WHEN "0110", -- 6
					 "00011111" WHEN "0111", -- 7
					 "00000001" WHEN "1000", -- 8
					 "00001001" WHEN "1001", -- 9
					 "00010001" WHEN "1010", -- a
					 "11000001" WHEN "1011", -- b
					 "01100011" WHEN "1100", -- c
					 "10000101" WHEN "1101", -- d
					 "01100001" WHEN "1110", -- e
					 "01110001" WHEN "1111"; -- f
END bcd_to_7seg;
