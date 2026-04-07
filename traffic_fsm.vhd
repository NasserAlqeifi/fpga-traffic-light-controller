library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity traffic_fsm is
    Port (
        clk_slow     : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        startup_done : in  STD_LOGIC;

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

        -- New: FSM state as vector
        traffic_state : out STD_LOGIC_VECTOR(2 downto 0)
    );
end traffic_fsm;

architecture Behavioral of traffic_fsm is
    type state_type is (IDLE, X_GREEN, X_YELLOW, Y_GREEN, Y_YELLOW);
    signal state   : state_type := IDLE;
    signal counter : integer range 0 to 3 := 0;
begin

    -- State transitions
    process(clk_slow, reset)
    begin
        if reset = '0' then
            state   <= IDLE;
            counter <= 0;
        elsif rising_edge(clk_slow) then
            case state is
                when IDLE =>
                    if startup_done = '1' then
                        state <= X_GREEN;
                        counter <= 0;
                    end if;

                when X_GREEN =>
                    if counter = 2 then
                        state <= X_YELLOW;
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;

                when X_YELLOW =>
                    state <= Y_GREEN;
                    counter <= 0;

                when Y_GREEN =>
                    if counter = 2 then
                        state <= Y_YELLOW;
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;

                when Y_YELLOW =>
                    state <= X_GREEN;
                    counter <= 0;
            end case;
        end if;
    end process;

    -- Output control
    process(state)
    begin
        -- Default: all car lights OFF
        X1_lights <= "000";
        X2_lights <= "000";
        Y1_lights <= "000";
        Y2_lights <= "000";

        -- Default FSM state output
        traffic_state <= "000";

        case state is
            when X_GREEN =>
                X1_lights <= "001";
                X2_lights <= "001";
                Y1_lights <= "100";
                Y2_lights <= "100";
                traffic_state <= "001";

            when X_YELLOW =>
                X1_lights <= "010";
                X2_lights <= "010";
                Y1_lights <= "100";
                Y2_lights <= "100";
                traffic_state <= "010";

            when Y_GREEN =>
                X1_lights <= "100";
                X2_lights <= "100";
                Y1_lights <= "001";
                Y2_lights <= "001";
                traffic_state <= "101";

            when Y_YELLOW =>
                X1_lights <= "100";
                X2_lights <= "100";
                Y1_lights <= "010";
                Y2_lights <= "010";
                traffic_state <= "110";

            when others =>
                traffic_state <= "000";
        end case;
    end process;

    -- Pedestrian lights: always RED during FSM operation
    X1F <= "10";
    X2F <= "10";
    Y1F <= "10";
    Y2F <= "10";

end Behavioral;
