--=============================
-- Corrected pedestrian_request_fsm.vhd
--=============================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pedestrian_request_fsm is
    Port (
        clk_slow     : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        startup_done : in  STD_LOGIC;

        btn_X1 : in STD_LOGIC;
        btn_X2 : in STD_LOGIC;
        btn_Y1 : in STD_LOGIC;
        btn_Y2 : in STD_LOGIC;

        traffic_state : in STD_LOGIC_VECTOR(2 downto 0);

        -- Car lights [2]=Red, [1]=Yellow, [0]=Green
        X1_lights : out STD_LOGIC_VECTOR(2 downto 0);
        X2_lights : out STD_LOGIC_VECTOR(2 downto 0);
        Y1_lights : out STD_LOGIC_VECTOR(2 downto 0);
        Y2_lights : out STD_LOGIC_VECTOR(2 downto 0);

        -- Pedestrian lights [1]=Red, [0]=Green
        X1F : out STD_LOGIC_VECTOR(1 downto 0);
        X2F : out STD_LOGIC_VECTOR(1 downto 0);
        Y1F : out STD_LOGIC_VECTOR(1 downto 0);
        Y2F : out STD_LOGIC_VECTOR(1 downto 0);

        request_active : out STD_LOGIC
    );
end pedestrian_request_fsm;

architecture Behavioral of pedestrian_request_fsm is
    signal count       : integer range 0 to 5 := 0;
    signal active      : STD_LOGIC := '0';
    signal phase       : STD_LOGIC := '0'; -- '0' = X, '1' = Y
    signal request_X   : STD_LOGIC := '0';
    signal request_Y   : STD_LOGIC := '0';
begin

    -- FSM: latch request, wait for safe traffic state, then activate
    process(clk_slow, reset)
    begin
        if reset = '0' then
            count      <= 0;
            active     <= '0';
            request_X  <= '0';
            request_Y  <= '0';
        elsif rising_edge(clk_slow) then
            if startup_done = '1' then
                -- latch requests
                if (btn_X1 = '0') or (btn_X2 = '0') then
                    request_X <= '1';
                end if;
                if (btn_Y1 = '0') or (btn_Y2 = '0') then
                    request_Y <= '1';
                end if;

                if active = '0' then
                    if request_X = '1' and traffic_state = "001" then -- X_GREEN
                        active <= '1';
                        phase  <= '0';
                        count  <= 0;
                        request_X <= '0';
                    elsif request_Y = '1' and traffic_state = "101" then -- Y_GREEN
                        active <= '1';
                        phase  <= '1';
                        count  <= 0;
                        request_Y <= '0';
                    end if;
                else
                    if count < 4 then
                        count <= count + 1;
                    else
                        active <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;

    request_active <= active;

    -- Output logic
    process(active, phase)
    begin
        X1_lights <= "000"; X2_lights <= "000";
        Y1_lights <= "000"; Y2_lights <= "000";

        X1F <= "10"; X2F <= "10";
        Y1F <= "10"; Y2F <= "10";

        if active = '1' then
            if phase = '0' then
                X1_lights <= "001"; X2_lights <= "001";
                Y1_lights <= "100"; Y2_lights <= "100";

                X1F <= "01"; X2F <= "01";
            else
                X1_lights <= "100"; X2_lights <= "100";
                Y1_lights <= "001"; Y2_lights <= "001";

                Y1F <= "01"; Y2F <= "01";
            end if;
        end if;
    end process;

end Behavioral;
