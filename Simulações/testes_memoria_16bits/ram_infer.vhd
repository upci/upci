LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.processor_functions.all;
ENTITY ram_infer IS
   PORT
   (
      clock: IN   std_logic;
      data:  IN   std_logic_vector (wordlen-1 DOWNTO 0);
      write_address:  IN   integer RANGE 0 to 2**(n-oplen-1);
      read_address:   IN   integer RANGE 0 to 2**(n-oplen-1);
      we:    IN   std_logic;
      q:     OUT  std_logic_vector (wordlen-1 DOWNTO 0)
   );
END ram_infer;
ARCHITECTURE rtl OF ram_infer IS
   SIGNAL ram_block : memory_array;
BEGIN
   PROCESS (clock)
   BEGIN
      IF (clock'event AND clock = '1') THEN
         IF (we = '1') THEN
            ram_block(write_address) <= data;
         END IF;
         q <= ram_block(read_address);
      END IF;
   END PROCESS;
END rtl;