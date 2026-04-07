library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity led_organizer is
    Port (
        -- Grouped LED inputs
        X1_lights : in STD_LOGIC_VECTOR(2 downto 0);
        X2_lights : in STD_LOGIC_VECTOR(2 downto 0);
        Y1_lights : in STD_LOGIC_VECTOR(2 downto 0);
        Y2_lights : in STD_LOGIC_VECTOR(2 downto 0);

        X1F : in STD_LOGIC_VECTOR(1 downto 0);
        X2F : in STD_LOGIC_VECTOR(1 downto 0);
        Y1F : in STD_LOGIC_VECTOR(1 downto 0);
        Y2F : in STD_LOGIC_VECTOR(1 downto 0);

        -- Individual LED outputs
        X1_Red, X1_Yellow, X1_Green     : out STD_LOGIC;
        X2_Red, X2_Yellow, X2_Green     : out STD_LOGIC;
        Y1_Red, Y1_Yellow, Y1_Green     : out STD_LOGIC;
        Y2_Red, Y2_Yellow, Y2_Green     : out STD_LOGIC;

        X1F_Red, X1F_Green              : out STD_LOGIC;
        X2F_Red, X2F_Green              : out STD_LOGIC;
        Y1F_Red, Y1F_Green              : out STD_LOGIC;
        Y2F_Red, Y2F_Green              : out STD_LOGIC
    );
end led_organizer;

architecture Behavioral of led_organizer is
begin
    -- Cars
    X1_Red    <= X1_lights(2);
    X1_Yellow <= X1_lights(1);
    X1_Green  <= X1_lights(0);

    X2_Red    <= X2_lights(2);
    X2_Yellow <= X2_lights(1);
    X2_Green  <= X2_lights(0);

    Y1_Red    <= Y1_lights(2);
    Y1_Yellow <= Y1_lights(1);
    Y1_Green  <= Y1_lights(0);

    Y2_Red    <= Y2_lights(2);
    Y2_Yellow <= Y2_lights(1);
    Y2_Green  <= Y2_lights(0);

    -- Pedestrians
    X1F_Red   <= X1F(1);
    X1F_Green <= X1F(0);

    X2F_Red   <= X2F(1);
    X2F_Green <= X2F(0);

    Y1F_Red   <= Y1F(1);
    Y1F_Green <= Y1F(0);

    Y2F_Red   <= Y2F(1);
    Y2F_Green <= Y2F(0);
end Behavioral;
