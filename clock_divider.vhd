library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clock_divider is
    Port (
        clk       : in  STD_LOGIC;    -- 50 MHz input clock
        reset     : in  STD_LOGIC;    -- synchronous reset
        clk_slow  : out STD_LOGIC     -- slow output clock (~1Hz)
    );
end clock_divider;

architecture Behavioral of clock_divider is
    constant DIVISOR : integer := 25_000_000; -- 50 MHz / 2 = 1 Hz toggle
    signal counter   : integer range 0 to DIVISOR := 0;
    signal temp_clk  : STD_LOGIC := '0';
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '0' then
                counter  <= 0;
                temp_clk <= '0';
            elsif counter = DIVISOR - 1 then
                counter  <= 0;
                temp_clk <= not temp_clk;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    clk_slow <= temp_clk;

end Behavioral;
