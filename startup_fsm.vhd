library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity startup_fsm is
    Port (
        clk_slow     : in  STD_LOGIC;
        reset        : in  STD_LOGIC;

        X1_lights : out STD_LOGIC_VECTOR(2 downto 0);
        X2_lights : out STD_LOGIC_VECTOR(2 downto 0);
        Y1_lights : out STD_LOGIC_VECTOR(2 downto 0);
        Y2_lights : out STD_LOGIC_VECTOR(2 downto 0);

        X1F : out STD_LOGIC_VECTOR(1 downto 0);
        X2F : out STD_LOGIC_VECTOR(1 downto 0);
        Y1F : out STD_LOGIC_VECTOR(1 downto 0);
        Y2F : out STD_LOGIC_VECTOR(1 downto 0);

        startup_done : out STD_LOGIC
    );
end startup_fsm;

architecture Behavioral of startup_fsm is
    signal blink_counter : integer range 0 to 10 := 0;
    signal blinking_on   : STD_LOGIC := '0';
    signal done          : STD_LOGIC := '0';
begin

    process(clk_slow, reset)
    begin
        if reset = '0' then
            blink_counter <= 0;
            blinking_on   <= '0';
            done          <= '0';
        elsif rising_edge(clk_slow) then
            if done = '0' then
                blink_counter <= blink_counter + 1;
                blinking_on   <= not blinking_on;

                if blink_counter = 9 then  -- 10 ticks total (5 blinks)
                    done <= '1';
                end if;
            end if;
        end if;
    end process;

    startup_done <= done;

    process(blinking_on, done)
    begin
        if done = '0' then
            if blinking_on = '1' then
                -- Yellow ON
                X1_lights <= "010";
                X2_lights <= "010";
                Y1_lights <= "010";
                Y2_lights <= "010";
            else
                -- Yellow OFF
                X1_lights <= "000";
                X2_lights <= "000";
                Y1_lights <= "000";
                Y2_lights <= "000";
            end if;

            -- Pedestrian lights always OFF
            X1F <= "00";
            X2F <= "00";
            Y1F <= "00";
            Y2F <= "00";

        else
            -- After startup: all OFF
            X1_lights <= "000";
            X2_lights <= "000";
            Y1_lights <= "000";
            Y2_lights <= "000";

            X1F <= "00";
            X2F <= "00";
            Y1F <= "00";
            Y2F <= "00";
        end if;
    end process;

end Behavioral;
