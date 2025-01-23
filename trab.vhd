library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity smartLocker is
  port (
    clock, reset, config, add_user                        : in std_logic;
    pass                                                  : in std_logic_vector (7 downto 0);
    admin_led, valid_led, error_led, registered, isLogged : out std_logic;
    hex_display                                           : out std_logic_vector(6 downto 0) -- Sinais para os segmentos do visor HEX
  );
end smartLocker;

architecture Behavioral of smartLocker is
  -- Tipo para os arrays de senhas
  type senha_array is array (0 to 5) of std_logic_vector(7 downto 0);
  type users_senha_array is array (0 to 3) of std_logic_vector(7 downto 0);

  -- Array de senhas de administradores
  constant admin_senhas : senha_array := (
  "01010101", -- senha 1 (8 bits)
  "01100001", -- senha 2 (8 bits)
  others => "00000000" -- Preenche os demais elementos
  );

  -- Array para as senhas de usuários
  signal user_senhas : users_senha_array := (
  others => "00000000" -- Inicializa com valores padrão
  );

  -- Array concatenado
  signal all_senhas : senha_array := (others => "00000000");

  signal is_match        : boolean              := false; -- Sinal para indicar que a senha foi encontrada
  signal selected_index  : integer range 0 to 7 := 0;
  signal is_admin_Logged : boolean              := false;

  -- Tabela de decodificação para o display de 7 segmentos
  function decode_to_7seg(value : integer range 0 to 7) return std_logic_vector is
  begin
    case value is
      when 0      => return "1000000"; -- Exibe '0'
      when 1      => return "1111001"; -- Exibe '1'
      when 2      => return "0100100"; -- Exibe '2'
      when 3      => return "0110000"; -- Exibe '3'
      when 4      => return "0011001"; -- Exibe '4'
      when 5      => return "0010010"; -- Exibe '5'
      when 6      => return "0000010"; -- Exibe '6'
      when 7      => return "1111000"; -- Exibe '7'
      when others => return "1111111"; -- Desligado
    end case;
  end function;

begin
  process (clock, reset)
  begin
    if rising_edge(clock) then
      if reset = '1' then
        selected_index <= 0; --init
        admin_led      <= '0';
        valid_led      <= '0';
        error_led      <= '0';
        registered     <= '0';
        isLogged       <= '0';
        is_match       <= false;

      elsif selected_index = 0 then
        if config = '1' then
          is_match <= false;
          if is_admin_Logged then
            if add_user = '1' then --add
              selected_index <= 5;

              -- Adiciona uma nova senha ao array user_senhas
              for i in 0 to 3 loop
                if user_senhas(i) = "00000000" then
                  user_senhas(i)  <= pass;
                  registered      <= '1';
                  isLogged        <= '1';
                  valid_led       <= '1';
                  selected_index  <= 0;
                  is_admin_Logged <= false;
                  exit; -- Sai do loop após adicionar a senha
                end if;
              end loop;

            elsif add_user = '0' then --remove
              -- Remove a senha correspondente no array user_senhas
              for i in 0 to 3 loop
                if user_senhas(i) = pass then
                  user_senhas(i)  <= "00000000";
                  registered      <= '0';
                  valid_led       <= '1';
                  is_admin_Logged <= false;
                  is_match        <= false;
                  exit; -- Sai do loop após remover a senha
                end if;
              end loop;
            end if;
          else
            for i in 0 to 1 loop
              if pass = admin_senhas(i) then
                isLogged        <= '1';
                error_led       <= '0';
                valid_led       <= '0';
                registered      <= '0';
                is_admin_Logged <= true;
                exit;
              else
                isLogged        <= '0';
                error_led       <= '1';
                selected_index  <= 0;
                is_admin_Logged <= false;
              end if;
            end loop;
          end if;

        else
          -- Concatena os arrays admin_senhas e user_senhas
          for i in 0 to 1 loop
            all_senhas(i) <= admin_senhas(i);
          end loop;
          for i in 0 to 3 loop
            all_senhas(i + 2) <= user_senhas(i);
          end loop;

          -- Verifica se a senha de entrada é válida
          valid_led       <= '0';
          registered      <= '0';
          is_admin_Logged <= false;
          isLogged        <= '0';

          for j in 0 to 2 loop
            exit when is_match;
            for i in 0 to 5 loop
              if pass = all_senhas(i) then
                is_match <= true;
                exit; -- Sai do loop se a senha for encontrada
              else
                is_match <= false;

              end if;
            end loop;
          end loop;

          if is_match then
            selected_index <= 0; --sucess
            valid_led      <= '1';
            error_led      <= '0';

          else
            -- selected_index <= 4; --blocked
            valid_led <= '0';
            error_led <= '1';
          end if;

          if selected_index = 2 then
            selected_index <= 3; --opened
            valid_led      <= '1';
          end if;

          if selected_index = 6 then
            selected_index <= 7; --sucess
            registered     <= '1';
          end if;

          if selected_index = 5 then
            selected_index <= 7; --sucess
            registered     <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;

  -- Atualiza o visor de 7 segmentos com o valor de selected_index
  hex_display <= decode_to_7seg(selected_index);

end Behavioral;