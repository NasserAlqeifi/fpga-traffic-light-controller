library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fsm_selector is
    Port (
        startup_done     : in STD_LOGIC;
        request_active   : in STD_LOGIC;

        -- Startup FSM
        X1_lights_s, X2_lights_s, Y1_lights_s, Y2_lights_s : in STD_LOGIC_VECTOR(2 downto 0);
        X1F_s, X2F_s, Y1F_s, Y2F_s : in STD_LOGIC_VECTOR(1 downto 0);

        -- Traffic FSM
        X1_lights_t, X2_lights_t, Y1_lights_t, Y2_lights_t : in STD_LOGIC_VECTOR(2 downto 0);
        X1F_t, X2F_t, Y1F_t, Y2F_t : in STD_LOGIC_VECTOR(1 downto 0);

        -- Pedestrian FSM
        X1_lights_p, X2_lights_p, Y1_lights_p, Y2_lights_p : in STD_LOGIC_VECTOR(2 downto 0);
        X1F_p, X2F_p, Y1F_p, Y2F_p : in STD_LOGIC_VECTOR(1 downto 0);

        -- Final Output
        X1_lights, X2_lights, Y1_lights, Y2_lights : out STD_LOGIC_VECTOR(2 downto 0);
        X1F, X2F, Y1F, Y2F : out STD_LOGIC_VECTOR(1 downto 0)
    );
end fsm_selector;

architecture Behavioral of fsm_selector is
    signal fsm_select : STD_LOGIC_VECTOR(1 downto 0);
begin
    process(startup_done, request_active)
    begin
        if startup_done = '0' then
            fsm_select <= "00";
        elsif request_active = '1' then
            fsm_select <= "10";
        else
            fsm_select <= "01";
        end if;
    end process;

    process(fsm_select)
    begin
        case fsm_select is
            when "00" =>
                X1_lights <= X1_lights_s; X2_lights <= X2_lights_s;
                Y1_lights <= Y1_lights_s; Y2_lights <= Y2_lights_s;
                X1F <= X1F_s; X2F <= X2F_s; Y1F <= Y1F_s; Y2F <= Y2F_s;

            when "01" =>
                X1_lights <= X1_lights_t; X2_lights <= X2_lights_t;
                Y1_lights <= Y1_lights_t; Y2_lights <= Y2_lights_t;
                X1F <= X1F_t; X2F <= X2F_t; Y1F <= Y1F_t; Y2F <= Y2F_t;

            when "10" =>
                X1_lights <= X1_lights_p; X2_lights <= X2_lights_p;
                Y1_lights <= Y1_lights_p; Y2_lights <= Y2_lights_p;
                X1F <= X1F_p; X2F <= X2F_p; Y1F <= Y1F_p; Y2F <= Y2F_p;

            when others =>
                X1_lights <= "000"; X2_lights <= "000";
                Y1_lights <= "000"; Y2_lights <= "000";
                X1F <= "10"; X2F <= "10"; Y1F <= "10"; Y2F <= "10";
        end case;
    end process;
end Behavioral;
