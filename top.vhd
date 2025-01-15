library ieee;
use ieee.std_logic_1164.all;

entity top is
    port (
        clk        : in  std_logic; -- Clock de 50 MHz
        rst        : in  std_logic; -- Reset síncrono
        z, p       : in  std_logic;
        verde1, vermelho1, amarelo1,
        pdverde1, pdvermelho1,
        verde2, vermelho2, amarelo2,
        pdverde2, pdvermelho2 : out std_logic
    );
end top;

architecture Behavioral of top is
    -- Sinais internos para conexão
    signal clock_2s : std_logic;
begin

    -- Instância do contador de 2 segundos
    contador_inst : entity work.contador_2seg
        port map (
            clk   => clk,       -- Conectado ao clock principal de 50 MHz
            rst   => rst,       -- Reset global
            saida => clock_2s   -- Clock de 2 segundos
        );

    -- Instância do semáforo
    semaforo_inst : entity work.semaforo
        port map (
            CLOCK       => clock_2s, -- Clock gerado pelo contador
            z           => z,
            p           => p,
            verde1      => verde1,
            vermelho1   => vermelho1,
            amarelo1    => amarelo1,
            pdverde1    => pdverde1,
            pdvermelho1 => pdvermelho1,
            verde2      => verde2,
            vermelho2   => vermelho2,
            amarelo2    => amarelo2,
            pdverde2    => pdverde2,
            pdvermelho2 => pdvermelho2
        );

end Behavioral;
