library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity smartLocker is 
    Port(
        clock, reset, config, add_user : in STD_LOGIC;
        pass: in STD_LOGIC_VECTOR (7 downto 0);
        admin_led, valid_led, error_led, registered: out STD_LOGIC
    );
end smartLocker;

architecture Behavioral of smartLocker is 
    -- Tipo para os arrays de senhas
    type senha_array is array (0 to 5) of STD_LOGIC_VECTOR(7 downto 0);

    -- Array de senhas de administradores
    constant admin_senhas : senha_array := (
        "01010101", -- senha 1 (8 bits)
        "01100001", -- senha 2 (8 bits)
        others => "00000000"  -- Preenche os demais elementos
    );

    -- Array para as senhas de usuários
    signal user_senhas : senha_array := (
        others => "00000000" -- Inicializa com valores padrão
    );

    -- Array concatenado
    signal all_senhas : senha_array := (others => "00000000");

    signal is_match : boolean := false; -- Sinal para indicar que a senha foi encontrada
    signal selected_index : integer range 0 to 11 := 0;

begin
    process(clock, reset)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                selected_index <= 0;
                admin_led <= '0';
                valid_led <= '0';
                error_led <= '0';
                registered <= '0';

                -- Inicializa os arrays
                user_senhas <= (others => "00000000");
                all_senhas <= (others => "00000000");
                is_match <= false;
            elsif config = '1' then
                selected_index <= '1';
                if add_user = '1' then
                    selected_index <= '2';

                    -- Adiciona uma nova senha ao array user_senhas
                    for i in 0 to 5 loop
                        if user_senhas(i) = "00000000" then
                            user_senhas(i) <= pass;
                            registered <= '1';
                            exit; -- Sai do loop após adicionar a senha
                        end if;
                    end loop;
                else
                selected_index <= '4';
                -- logica par aremover a senha
                -- selected_index <= '5';
                end if;
            else
                selected_index <= '6';
                -- Concatena os arrays admin_senhas e user_senhas
                for i in 0 to 1 loop
                    all_senhas(i) <= admin_senhas(i);
                end loop;
                for i in 0 to 3 loop
                    all_senhas(i + 2) <= user_senhas(i);
                end loop;

                -- Verifica se a senha de entrada é válida
                valid_led <= '0';
                error_led <= '1';
                is_match <= false;

                for j in 0 to 2 loop
                    exit when is_match; -- Sai do loop externo se a senha foi encontrada
                    for i in 0 to 5 loop
                        if pass = all_senhas(i) then
                            valid_led <= '1';
                            error_led <= '0';
                            is_match <= true; -- Indica que a senha foi encontrada
                            exit; -- Sai do loop interno
                        end if;
                    end loop;
                end loop;

                selected_index <= 10;
            end if;
        end if;
    end process;

end Behavioral;
