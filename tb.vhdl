library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_tb is
end top_tb;

architecture Behavioral of top_tb is
    -- Constantes
    constant CLK_PERIOD : time := 20 ns; -- Clock de 50 MHz (20 ns por ciclo)
    
    -- Sinais internos
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal z, p        : std_logic := '0';
    signal verde1, vermelho1, amarelo1 : std_logic;
    signal pdverde1, pdvermelho1       : std_logic;
    signal verde2, vermelho2, amarelo2 : std_logic;
    signal pdverde2, pdvermelho2       : std_logic;

begin

    -- Geração do clock de 50 MHz
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Instância do módulo top
    uut : entity work.top
        port map (
            clk         => clk,
            rst         => rst,
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

    -- Estímulos para o reset e sinais de controle
    stimulus_process : process
    begin
        -- Reset inicial
        rst <= '1';
        wait for 100 ns; -- Aguarda 100 ns para estabilização
        rst <= '0';
        
        -- Testa o sinal z
        wait for 2 sec; -- Aguarda 2 segundos
        z <= '1';      
