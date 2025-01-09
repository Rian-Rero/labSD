
library ieee;
use ieee.std_logic_1164.all;

entity semaforo is
    port (
        CLOCK       : in    std_logic;
        z, p        : in    std_logic;
        verde1, vermelho1, amarelo1,
        pdverde1, pdvermelho1,
        verde2, vermelho2, amarelo2,
        pdverde2, pdvermelho2 : out std_logic
    );
end semaforo;

architecture arch of semaforo is
    signal selected_index : integer range 0 to 11 := 0;
begin

    process (CLOCK)
    begin
        if rising_edge(CLOCK) then
            if z = '1' or p = '1' then
                selected_index <= 1;
            else
                selected_index <= (selected_index + 1) mod 12;
            end if;
        end if;
    end process;

    process (selected_index)
    begin
        verde1 <= '0'; vermelho1 <= '0'; amarelo1 <= '0';
        pdverde1 <= '0'; pdvermelho1 <= '0';
        verde2 <= '0'; vermelho2 <= '0'; amarelo2 <= '0';
        pdverde2 <= '0'; pdvermelho2 <= '0';

        case selected_index is
            when 0 to 5 =>
                verde1 <= '1'; vermelho2 <= '1';
                pdvermelho1 <= '1'; pdverde2 <= '1';
            when 6 =>
                amarelo1 <= '1'; vermelho2 <= '1';
                pdvermelho1 <= '1'; pdverde2 <= '1';
            when 7 to 10 =>
                verde2 <= '1'; vermelho1 <= '1';
                pdvermelho2 <= '1'; pdverde1 <= '1';
            when 11 =>
                amarelo2 <= '1'; vermelho1 <= '1';
                pdvermelho2 <= '1'; pdverde1 <= '1';
            when others =>
                null;
        end case;
    end process;

end arch;
