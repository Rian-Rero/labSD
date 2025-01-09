

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity contador_2seg is
    Port (
        clk       : in  STD_LOGIC; -- Clock de 50 MHz
        rst       : in  STD_LOGIC; -- Reset síncrono
        saida     : out STD_LOGIC  -- Saída que fica em '1' após 2 segundos
    );
end contador_2seg;

architecture Behavioral of contador_2seg is
    constant MAX_COUNT : unsigned(26 downto 0) := to_unsigned(100_000_000 - 1, 27); -- 100.000.000 ciclos
    signal count        : unsigned(26 downto 0) := (others => '0');
    signal saida_reg    : STD_LOGIC := '0';
begin

    process(clk, rst)
    begin
        if rst = '1' then
            count <= (others => '0');
            saida_reg <= '0';
        elsif rising_edge(clk) then
            if count = MAX_COUNT then
                count <= (others => '0');
                saida_reg <= '1'; -- Sinaliza que 2 segundos passaram
            else
                count <= count + 1;
                saida_reg <= '0';
            end if;
        end if;
    end process;

    saida <= saida_reg;

end Behavioral;
